#' Read MongoDB Credentials from .Renviron
#'
#' This function reads MongoDB database credentials from environment variables defined in the
#' .Renviron file and returns a mongo connection object.
#'
#' The .Renviron file should contain the following environment variables:
#' \itemize{
#'   \item \code{DB_USER}: The username for the MongoDB database.
#'   \item \code{DB_PASSWORD}: The password for the MongoDB database, please use percent encoding
#'     here (https://developer.mozilla.org/en-US/docs/Glossary/Percent-encoding).
#'   \item \code{DB_HOST}: The host address of the MongoDB server.
#'   \item \code{DB_NAME}: The name of the MongoDB database.
#'   \item \code{DB_PORT}: The port number of the MongoDB server.
#' }
#'
#' @return A mongo connection object that can be used to interact with the MongoDB database.
#'
#' @export
credentials <- function() {
  URI <- sprintf(
    "mongodb://%s:%s@%s:%s/%s",
    Sys.getenv("DB_USER"),
    Sys.getenv("DB_PASSWORD"),
    Sys.getenv("DB_HOST"),
    Sys.getenv("DB_PORT"),
    Sys.getenv("DB_NAME")
  )

  return(mongo(collection = Sys.getenv("DB_COLLECTION"), db = Sys.getenv("DB_NAME"), url = URI))
}


#' Update MongoDB with New RSS Feed Data
#'
#' This function updates a MongoDB collection with new RSS feed data from a tibble.
#' For each tibble, it compares the `feed_last_build_date` with the corresponding
#' date in the database and updates the collection if the tibble contains newer data.
#'
#' @param tibble A tibble containing RSS feed data with unique `source_id`
#'   and `feed_last_build_date`.
#' @param config (list) Configuration file with column mapping and RSS field names.
#' @export
update_database <- function(tibble, config) {
  # skip if try error
  if (inherits(tibble, "try-error") || !is.data.frame(tibble)) {
    return(tibble)
  }

  mapping <- read_field_mapping(config)
  source_id <- unique(tibble$source_id)
  logging("Start to update database for source_id %s.", source_id)
  timestamp_feed_updated_db <- mapping["timestamp_feed_updated", ]$db
  timestamp_feed_updated_rss <- mapping["timestamp_feed_updated", ]$rss
  max_timestamp_feed_updated_rss <- max(tibble[[timestamp_feed_updated_rss]])

  con <- credentials()

  query <- sprintf('{"source_id": %s}', source_id)
  max_timestamp_feed_updated_db <- con$find(query, fields = sprintf('{"%s": 1, "_id": 0}', timestamp_feed_updated_db))

  if (nrow(max_timestamp_feed_updated_db) == 0 ||
      max_timestamp_feed_updated_rss > max(max_timestamp_feed_updated_db[[timestamp_feed_updated_db]], na.rm = TRUE)) {
    logging("Sending data for source_id %s.", source_id)
    rename_vector <- setNames(as.character(mapping$rss), mapping$db)
    tibble <- tibble %>% rename(!!!rename_vector)

    con$insert(tibble)
  } else {
    logging("Nothing to update for source_id %s.", source_id)
  }
}
