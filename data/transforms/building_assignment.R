rm(list=ls()[ls() != "datenv"])

library(sp)
library(rgdal)
library(RANN)

source("utilities.R")

if(!exists("datenv")) {
    datenv <- new.env()
    read_transformed_dat(datenv)
}

# Nearest neighbors -------------------------------------------------------
building_coords <- datenv$dat_parcels_transform %>% select(x, y)

assign_building_id <- function(dat) {
    coords <- dat %>% select(x, y)
    nearest <- nn2(building_coords, coords, k=1)
    # nearest$nn.dists might want to do something with this later like if distance
    # is too large don't assign to that building

    dat$BuildID <- datenv$dat_parcels_transform$ID[nearest$nn.idx]

    return(dat)
}
datenv <- lapply(datenv, assign_building_id)
