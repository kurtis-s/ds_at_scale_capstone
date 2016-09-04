rm(list=ls())

library(sp)
library(rgdal)
library(RANN)

source("utilities.R")

# Nearest neighbors -------------------------------------------------------
datenv <- new.env()
read_transformed_dat(datenv)
building_coords <- datenv$dat_parcels_transform %>% select(x, y)

assign_building_id <- function(dat) {
    coords <- dat %>% select(x, y)
    nearest <- nn2(building_coords, coords, k=1)
    # nearest$nn.dists might want to do something with this later like if distance
    # is too large don't assign to that building

    dat$BuildID <- datenv$dat_parcels_transform$ID[nearest$nn.idx]

    return(dat)
}
dats_with_buildingIDs <- lapply(datenv, assign_building_id)

for(dat_name in names(dats_with_buildingIDs)) {
    write.csv(dats_with_buildingIDs[[dat_name]], file=paste(DATA_TRANSFORM_BASE_PATH, dat_name, ".csv", sep=""))
}
# latlon_parcels <- dat_parcels_transform %>% select(lat, lon)
# latlon_311 <- dat_311_transform %>% select(lat, lon)
# latlon_crime <- dat_crime_transform %>% select(lat, lon)
#
# x <- nn2(latlon_parcels, latlon_311, k=1)
# x <- nn2(latlon_parcels, latlon_crime, k=1)


