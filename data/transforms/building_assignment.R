rm(list=ls())

library(RANN)

source("utilities.R")

dat_parcels_transform <- read_csv(DATA_TRANSFORM_BASE_PATH, "dat_parcels_transform.csv")
read_transformed_dat(environment())

latlon_parcels <- dat_parcels_transform %>% select(lat, lon)
latlon_311 <- dat_311_transform %>% select(lat, lon)
latlon_crime <- dat_crime_transform %>% select(lat, lon)

x <- nn2(latlon_parcels, latlon_311, k=1)
x <- nn2(latlon_parcels, latlon_crime, k=1)
