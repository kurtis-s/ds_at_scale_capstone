rm(list=ls()[ls() != "datenv"])

library(rgdal)

parcel_size <- 50 # UTM is in meters, 25m ~ 80ft
xgrid <- seq(310000, 344000, by=parcel_size)
ygrid <- seq(4680000, 4708000, by=parcel_size)

x_ids <- findInterval(dat$x, xgrid)
y_ids <- findInterval(dat$y, ygrid)

# lower_left_x <- xgrid[-length(xgrid)]
# upper_right_x <- xgrid[-1]
# lower_left_y <- ygrid[-length(ygrid)]
# upper_right_y <- ygrid[-1]
#
# lower_pts <- expand.grid(lower_left_x, lower_left_y)
# upper_pts <- expand.grid(upper_right_x, upper_right_y)
#
# building_dat <- data.frame(lower_pts, upper_pts)
# colnames(building_dat) <- c("lower_left_x", "lower_left_y",
#                             "upper_right_x", "upper_right_y")
# building_dat$BuildID2 <- 1:nrow(building_dat)


# assign_buildings <- function(x, y) {
#     BuildID2 <- building_dat$BuildID2[(x > building_dat$lower_left_x) &
#                                           (x < building_dat$upper_right_x) &
#                                           (y > building_dat$lower_left_y) &
#                                           (y < building_dat$upper_right_y)]
#     return(BuildID2)
# }
#
# assign_building_to_record <- function(record) {
#     assign_buildings(record["x"], record["y"])
# }
#
# test <- apply(dat, 1, assign_building_to_record)
#
# building_grid <- SpatialGridDataFrame()
