rm(list=ls())

library(dplyr)
library(rgdal)
library(rgeos)
library(ggplot2)

DATA_BASE_PATH <- "data/transforms/"

file_names <- c("dat_311_transform.csv",
               "dat_blight_transform.csv",
               "dat_crime_transform.csv",
               "dat_demolition_transform.csv")

read_csv_dat <- function(filename) {
    tbl_df(read.csv(file=paste(DATA_BASE_PATH, filename, sep=""), stringsAsFactors = FALSE))
}

dat_names <- vector()
for(filename in filenames) {
    dat_name <- gsub("_transform.csv", "", filename)
    dat_names <- c(dat_names, dat_name)
    assign(dat_name, read_csv_dat(filename))
}

detroit_zipcode_map <- readOGR(dsn="data/shapefiles/City of Detroit Zip Code Boundaries", layer="geo_export_811c61ad-91e0-45e5-8fee-48e8f79a05f1") %>%
    spTransform(CRS("+proj=longlat +datum=WGS84"))

## Just map the zip codes
ggplot(data = detroit_zipcode_map, aes(x = long, y = lat, group=group)) + geom_path()

## Look at the 311 calls
ggplot(data = detroit_zipcode_map, aes(x = long, y = lat, group = group)) +
    geom_path() +
    geom_point(
        data = dat_311,
        aes(
            group = NULL,
            x = lon,
            y = lat,
            inherit.aes = FALSE
        ),
        col = "blue",
        alpha = .1
    )
for(dat_name in dat_names) {
    lon <- get(dat_name)$lon
    lat <- get(dat_name)$lat

    wrong_lat <- (get(dat_name)$lat < 42.25 ) | (get(dat_name)$lat > 42.5)
    wrong_lon <- (get(dat_name)$lon < -83.3 ) | (get(dat_name)$lon > -82.9)

    print(dat_name)
    print(sum(wrong_lat | wrong_lon))
}
