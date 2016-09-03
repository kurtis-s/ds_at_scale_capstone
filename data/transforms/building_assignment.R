rm(list=ls())

library(sp)
library(rgdal)
library(RANN)

source("utilities.R")


# Convert to UTM ----------------------------------------------------------

xy <- latlon_parcels %>% select(lat, lon) %>% mutate(lon=lon, lat=lat)
coordinates(xy) <- c("lon", "lat")
proj4string(xy) <- CRS("+proj=longlat +datum=WGS84")  ## for example

res <- spTransform(xy, CRS("+proj=utm +zone=17 ellps=WGS84"))
res
plot(res@coords[,1], res@coords[,2])

# Nearest neighbors -------------------------------------------------------
dat_parcels_transform <- read_csv(DATA_TRANSFORM_BASE_PATH, "dat_parcels_transform.csv")
read_transformed_dat(environment())

latlon_parcels <- dat_parcels_transform %>% select(lat, lon)
latlon_311 <- dat_311_transform %>% select(lat, lon)
latlon_crime <- dat_crime_transform %>% select(lat, lon)

x <- nn2(latlon_parcels, latlon_311, k=1)
x <- nn2(latlon_parcels, latlon_crime, k=1)


