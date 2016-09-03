rm(list=ls())

library(dplyr)
library(rgdal)
library(rgeos)
library(ggplot2)

dat_311 <- tbl_df(read.csv(file="data/detroit-311.csv", stringsAsFactors = FALSE))
dat_blight <- tbl_df(read.csv(file="data/detroit-blight-violations.csv", stringsAsFactors = FALSE))
dat_crime <- tbl_df(read.csv(file="data/detroit-crime.csv", stringsAsFactors = FALSE))
dat_demolition <- tbl_df(read.csv(file="data/detroit-demolition-permits.tsv", sep="\t", stringsAsFactors = FALSE))
dat_parcels <- tbl_df(read.csv(file="data/shapefiles/PARCELS.csv", stringsAsFactors = FALSE))

#detroit_parcel_map <- readOGR(dsn="data/shapefiles/Parcel Map", layer="geo_export_87ebfb33-4ce3-4b81-8810-1cbe875d8d13") %>%
#    spTransform(CRS("+proj=longlat +datum=WGS84"))
detroit_zipcode_map <- readOGR(dsn="data/shapefiles/City of Detroit Zip Code Boundaries", layer="geo_export_811c61ad-91e0-45e5-8fee-48e8f79a05f1") %>%
    spTransform(CRS("+proj=longlat +datum=WGS84"))

#simplified_map <- gSimplify(detroit_parcel_map, tol=.001, topologyPreserve=TRUE)

#ggplot(data = detroit_parcel_map, aes(x = long, y = lat, group = group)) +
#    geom_path()
#ggplot(data = simplified_map, aes(x = long, y = lat, group = group)) +
#    geom_path()
ggplot(data = detroit_zipcode_map, aes(x = long, y = lat, group = group)) +
    geom_path()

ggplot(data = detroit_zipcode_map, aes(x = long, y = lat, group = group)) +
    geom_path()

ggplot(data = detroit_zipcode_map, aes(x = long, y = lat, group=group)) +
    geom_path() + geom_point(data=dat_311,
                               aes(group=NULL,
                                   x=lng,
                                   y=lat,
                                   inherit.aes=FALSE), col="blue", alpha=.1) +
    xlim(-83.3, -82.9) +
    ylim(42.25, 42.45)
