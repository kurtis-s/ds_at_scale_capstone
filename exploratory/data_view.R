rm(list=ls())

library(dplyr)
library(rgdal)
library(rgeos)
library(ggplot2)

DATA_BASE_PATH <- "data/transforms/"

dat_311 <- tbl_df(read.csv(file=paste(DATA_BASE_PATH, "dat_311_transform.csv", sep=""), stringsAsFactors = FALSE))
dat_blight <- tbl_df(read.csv(file=paste(DATA_BASE_PATH, "dat_blight_transform.csv", sep=""), stringsAsFactors = FALSE))
dat_crime <- tbl_df(read.csv(file=paste(DATA_BASE_PATH, "dat_crime_transform.csv", sep=""), stringsAsFactors = FALSE))
dat_demolition <- tbl_df(read.csv(file=paste(DATA_BASE_PATH, "dat_demolition_transform.csv", sep=""), stringsAsFactors = FALSE))

detroit_zipcode_map <- readOGR(dsn="data/shapefiles/City of Detroit Zip Code Boundaries", layer="geo_export_811c61ad-91e0-45e5-8fee-48e8f79a05f1") %>%
    spTransform(CRS("+proj=longlat +datum=WGS84"))

ggplot(data = detroit_zipcode_map, aes(x = long, y = lat, group=group)) +
    geom_path() + geom_point(data=dat_311,
                               aes(group=NULL,
                                   x=lon,
                                   y=lat,
                                   inherit.aes=FALSE), col="blue", alpha=.1)
    xlim(-83.3, -82.9) +
    ylim(42.25, 42.45)
