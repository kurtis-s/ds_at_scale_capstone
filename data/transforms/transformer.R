rm(list=ls())

library(dplyr)
library(rgdal)
library(rgeos)
library(ggplot2)

BASE_OUT_PATH <- "data/transforms/"

dat_311 <- tbl_df(read.csv(file="data/detroit-311.csv", stringsAsFactors = FALSE))
dat_blight <- tbl_df(read.csv(file="data/detroit-blight-violations.csv", stringsAsFactors = FALSE))
dat_crime <- tbl_df(read.csv(file="data/detroit-crime.csv", stringsAsFactors = FALSE))
dat_demolition <- tbl_df(read.csv(file="data/detroit-demolition-permits.tsv", sep="\t", stringsAsFactors = FALSE))


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
# 311 already has lat/lng
dat_311 <- dat_311 %>% rename(lon=lng)

# Blight
blight_lat_lon_pairs <- sapply(strsplit(dat_blight$ViolationAddress, "\n"), function(address_triple) address_triple[3])
blight_lat_lon <- split_lat_lon(blight_lat_lon_pairs)
dat_blight$lat <- blight_lat_lon$lat
dat_blight$lon <- blight_lat_lon$lon

# Crime
# Crime already has lat/lon

# Demolition
demolition_lat_lon_pairs <- sapply(strsplit(dat_demolition$site_location, "\n"), function(address_triple) address_triple[3])
# Some of the demolition lat/lon pairs are NA.  Some records are missing lat/lon
# and some records just don't have any location listed at all
demolition_lat_lon <- split_lat_lon(demolition_lat_lon_pairs)
dat_demolition$lat <- demolition_lat_lon$lat
dat_demolition$lon <- demolition_lat_lon$lon


# Write output ------------------------------------------------------------
write.csv(dat_311, file=paste(BASE_OUT_PATH, "dat_311_transform.csv", sep=""))
write.csv(dat_blight, file=paste(BASE_OUT_PATH, "dat_blight_transform.csv", sep=""))
write.csv(dat_crime, file=paste(BASE_OUT_PATH, "dat_crime_transform.csv", sep=""))
write.csv(dat_demolition, file=paste(BASE_OUT_PATH, "dat_demolition_transform.csv", sep=""))

