rm(list=ls()[ls() != "datenv"])

library(dplyr)
library(caret)
library(kernlab)
library(data.table)

source("utilities.R")

set.seed(38292989)

if(!exists("datenv")) {
    datenv <- new.env()
    read_transformed_dat(datenv)
}

parcels <- datenv$dat_parcels_transform %>%
    select(SalePrice,
           PropZip,
           TaxStatus,
           TotSqFt,
           TotAcres,
           ResYrBuilt,
           IsImproved,
           SEV,
           AV,
           TV,
           x,
           y,
           BuildID)
parcels$SalePrice <- as.numeric(sub("\\$","", parcels$SalePrice))

datenv$dat_blight_transform$AgencyName <- factor(datenv$dat_blight_transform$AgencyName)
datenv$dat_blight_transform$ViolationCode <- factor(datenv$dat_blight_transform$ViolationCode)
blight_transform <- datenv$dat_blight_transform %>%
    group_by(BuildID, AgencyName, ViolationCode) %>%
    summarise(n=n())
wide_blight <- dcast(blight_transform, BuildID ~ AgencyName + ViolationCode, value.var="n", fill=0)

datenv$dat_crime_transform$CATEGORY <- factor(datenv$dat_crime_transform$CATEGORY)
crime <- datenv$dat_crime_transform %>%
    group_by(BuildID, CATEGORY) %>%
    summarise(n=n())
wide_crime <- dcast(crime, BuildID ~ CATEGORY, value.var="n", fill=0)

datenv$dat_311_transform$ticket_status <- factor(datenv$dat_311_transform$ticket_status)
datenv$dat_311_transform$rating <- factor(datenv$dat_311_transform$rating)
datenv$dat_311_transform$issue_type <- factor(datenv$dat_311_transform$issue_type)
d311 <- datenv$dat_311_transform %>%
    group_by(BuildID, ticket_status, rating, issue_type) %>%
    summarise(n=n())
wide_311 <- dcast(d311, BuildID ~ ticket_status + rating + issue_type, value.var="n", fill=0)

## Merge all the datasets
full_dset <- Reduce(function(...) merge(..., all=TRUE, by="BuildID"),
                           list(parcels, wide_blight, wide_crime, wide_311))

## Get IDs of the blighted buildings
blighted_buildings_filtered <- datenv$dat_demolition_transform %>%
    filter(!is.na(BuildID))
blighted_building_ids <- unique(blighted_buildings_filtered$BuildID)

## Mark buildings as blighted or not
full_dset$blighted <- full_dset$BuildID %in% blighted_building_ids

## Sample an equal number of non-blighted buildings as blighted
nblighted <- length(blighted_building_ids)
non_blighted_samp <- sample_n(full_dset %>% filter(blighted==FALSE), nblighted)

## Make dset for the model
blighted <- buildings %>% filter(blighted==TRUE)
model_dset <- rbind(blighted, non_blighted_samp)