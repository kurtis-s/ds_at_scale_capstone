DATA_BASE_PATH <- "data/"
DATA_TRANSFORM_BASE_PATH <- "data/transforms/"
BASE_OUT_PATH <- "data/transforms/"
RAW_CSV_NAMES <- c("detroit-311.csv",
                "detroit-blight-violations.csv",
                "detroit-crime.csv",
                "detroit-demolition-permits.tsv")
TRANSFORMED_CSV_NAMES <- c("dat_311_transform.csv",
                "dat_blight_transform.csv",
                "dat_crime_transform.csv",
                "dat_demolition_transform.csv")

dat_names <- function() {
    sapply(TRANSFORMED_CSV_NAMES, function(filename) gsub("_transform.csv", "", filename))
}

read_csv <- function(basepath, filename, sep=",") {
    tbl_df(read.csv(file=paste(basepath, filename, sep=""), sep = sep, stringsAsFactors = FALSE))
}

read_raw_dat <- function(envir) {
    dframe_names <- dat_names()
    for(i in 1:length(dframe_names)) {
        filename <- RAW_CSV_NAMES[i]
        print(filename)
            if(".csv" %in% filename) {
                assign(dframe_names[i], read_csv(DATA_BASE_PATH, filename), envir=envir)
            }
            else {
                # For that one tab delimited file
                assign(dframe_names[i], read_csv(DATA_BASE_PATH, filename, sep="\t"), envir=envir)
            }
    }

    # ret <- sapply(RAW_CSV_NAMES, function(filename) {
    #     if(".csv" %in% filename) {
    #         read_csv(DATA_BASE_PATH, filename)
    #     }
    #     else {
    #         # For that one tab delimited file
    #         read_csv(DATA_BASE_PATH, filename, sep="\t")
    #     }
    # })
    #
    # if(!is.null(envir)) {
    #     dframe_names <- dat_names()
    #     for(i in 1:length(ret)) {
    #         assign(ret[i], dframe_names[i], )
    #     }
    # }
    #
    # return(ret)
}