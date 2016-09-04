rm(list=ls())

source("utilities.R")

library(dplyr)
library(rgdal)
library(rgeos)
library(ggplot2)

BASE_OUT_PATH <- "data/transforms/"
read_raw_dat(environment())
#dat_parcels <- read.csv("data/Parcel_Points_Ownership.csv", stringsAsFactors = FALSE)

# Add lat/lon -------------------------------------------------------------

split_lat_lon <- function(lat_lon_pairs) {
    #' Given a vector of pairs like "(42.36318237000006, -83.09167672099994)"
    #' split them up into two separate vectors of lattitude and longitude
    split_pairs <- strsplit(lat_lon_pairs, ",")

    lat_strings <- sapply(split_pairs, function(lat_lon_pair) {
        lat_string <- lat_lon_pair[1]
    })
    lat <- as.numeric(substring(lat_strings, 2))

    lon_strings <- sapply(split_pairs, function(lat_lon_pair) {
        lat_string <- lat_lon_pair[2]
    })
    lon <- as.numeric(gsub(")", "", lon_strings))

    return(list(lat=lat, lon=lon))
}

# Parcels data already has Latitude/Longitude, but one record is incorrectly entered
dat_parcels$ID <- 1:nrow(dat_parcels)
dat_parcels <- dat_parcels %>% rename(lat=Latitude, lon=Longitude)
endsNAN <- function(charvec) endsWith(charvec, "NAN")
# Discard the incorrect record
dat_parcels <- dat_parcels[!endsNAN(dat_parcels$lat) & !endsNAN(dat_parcels$lon),]
dat_parcels$lat <- as.numeric(dat_parcels$lat)
dat_parcels$lon <- as.numeric(dat_parcels$lon)
# Remove any records without an address
dat_parcels <- dat_parcels %>% filter(PropAddr!="")
# There are a few listed as no square feet/acres
dat_parcels <- dat_parcels %>% filter(TotSqFt>0) %>% filter(TotAcres>0)

# 311 already has lat/lng
dat_311 <- dat_311 %>% rename(lon=lng)

# Blight
blight_lat_lon_pairs <- sapply(strsplit(dat_blight$ViolationAddress, "\n"), function(address_triple) address_triple[3])
blight_lat_lon <- split_lat_lon(blight_lat_lon_pairs)
dat_blight$lat <- blight_lat_lon$lat
dat_blight$lon <- blight_lat_lon$lon

# Crime
# Crime already has lat/lon
dat_crime <- dat_crime %>% rename(lon=LON, lat=LAT)

# Demolition
demolition_lat_lon_pairs <- sapply(strsplit(dat_demolition$site_location, "\n"), function(address_triple) address_triple[3])
# Some of the demolition lat/lon pairs are NA.  Some records are missing lat/lon
# and some records just don't have any location listed at all
demolition_lat_lon <- split_lat_lon(demolition_lat_lon_pairs)
dat_demolition$lat <- demolition_lat_lon$lat
dat_demolition$lon <- demolition_lat_lon$lon

# Remove any records where lat/lon is missing
for(dat_name in dat_names()) {
    lon <- get(dat_name)$lon
    lat <- get(dat_name)$lat

    missing_geo <- is.na(lon) | is.na(lat)

    print(dat_name)
    print(sum(missing_geo))

    assign(dat_name, get(dat_name)[!missing_geo,])
}

# Some of the records have lat/lon pairs outside of Detroit.  Just discard them
for(dat_name in dat_names()) {
    lon <- get(dat_name)$lon
    lat <- get(dat_name)$lat

    wrong_lat <- (get(dat_name)$lat < 42.25 ) | (get(dat_name)$lat > 42.5)
    wrong_lon <- (get(dat_name)$lon < -83.3 ) | (get(dat_name)$lon > -82.9)
    incorrect_geo <- wrong_lat | wrong_lon

    print(dat_name)
    print(sum(wrong_lat | wrong_lon))

    assign(dat_name, get(dat_name)[!incorrect_geo,])
}

# Add fields for UTM coordinates
for(dat_name in dat_names()) {
    newframe <- get(dat_name)
    xy <- newframe %>% select(lat, lon)
    coordinates(xy) <- c("lon", "lat")
    proj4string(xy) <- CRS("+proj=longlat +datum=WGS84")

    # Detroit is in UTM zone 17
    res <- spTransform(xy, CRS("+proj=utm +zone=17 ellps=WGS84"))
    newframe$x <- res@coords[,1]
    newframe$y <- res@coords[,2]
    assign(dat_name, newframe)
}

# Write output ------------------------------------------------------------
write.csv(dat_parcels, file=paste(BASE_OUT_PATH, "dat_parcels_transform.csv", sep=""))
write.csv(dat_311, file=paste(BASE_OUT_PATH, "dat_311_transform.csv", sep=""))
write.csv(dat_blight, file=paste(BASE_OUT_PATH, "dat_blight_transform.csv", sep=""))
write.csv(dat_crime, file=paste(BASE_OUT_PATH, "dat_crime_transform.csv", sep=""))
write.csv(dat_demolition, file=paste(BASE_OUT_PATH, "dat_demolition_transform.csv", sep=""))

