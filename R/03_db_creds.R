#' Read Database Credentials from .Renviron
#'
#' This function reads database credentials from environment variables defined in the
#' .Renviron file and returns a credentials object.
#'
#' The .Renviron file should contain the following environment variables:
#' \itemize{
#'   \item \code{DB_USER}: The username for the database.
#'   \item \code{DB_PASSWORD}: The password for the database.
#'   \item \code{DB_HOST}: The host address of the database.
#'   \item \code{DB_NAME}: The name of the database.
#'   \item \code{DB_PORT}: The port number of the database.
#' }
#'
#' @return A list containing the database credentials:
#' \itemize{
#'   \item \code{user}: The username for the database.
#'   \item \code{password}: The password for the database.
#'   \item \code{host}: The host address of the database.
#'   \item \code{dbname}: The name of the database.
#'   \item \code{port}: The port number of the database.
#' }
#'
#' @export
credentials <- function() {
  return(
    Credentials(
      drv = RMySQL::MySQL,
      user = Sys.getenv("DB_USER"),
      password = Sys.getenv("DB_PASSWORD"),
      dbname = Sys.getenv("DB_NAME"),
      host = Sys.getenv("DB_HOST"),
      port = as.numeric(Sys.getenv("DB_PORT"))
    )
  )
}

#' Update Database with New RSS Feed Data
#'
#' This function updates the database with new RSS feed data from a list of tibbles.
#' For each tibble, it compares the `feed_last_build_date` with the corresponding
#' date in the database and updates the database if the tibble contains newer data.
#'
#' @param tibble A tibble containing RSS feed data with unique `source_id`
#'   and `feed_last_build_date`.
#' @param config (list) configuration file with column mapping and rss field names.
#' @export
update_database <- function(tibble, config) {
  mapping <- read_field_mapping(config)
  source_id <- unique(tibble$source_id)
  logging("Start to update databse for %s.", source_id)
  timestamp_feed_updated_db <- mapping["timestamp_feed_updated", ]$db
  timestamp_feed_updated_rss <- mapping["timestamp_feed_updated", ]$rss
  max_timestamp_feed_updated_rss <- max(tibble[[timestamp_feed_updated_rss]])

  query <- sprintf(
    "SELECT MAX(%s) AS max_date FROM mpiRss.feed_text WHERE source_id = %s;",
    timestamp_feed_updated_db,
    source_id
  )
  con <- credentials()
  max_timestamp_feed_updated_db <- sendQuery(con, query)$max_date

  if (is.na(max_timestamp_feed_updated_db) ||
      max_timestamp_feed_updated_rss > max_timestamp_feed_updated_db) {
    logging("Updating data for source_id %s.", source_id)
    rename_vector <- setNames(as.character(mapping$rss), mapping$db)
    tibble <- tibble %>%
      rename(!!!rename_vector)
    sendData(con, tibble, table = "mpiRss.feed_text", mode = "replace")
  } else {
    logging("Nothing to update for source_id %s.", source_id)
  }
}
