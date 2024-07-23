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
  return(Credentials(
    dbtools::MySQL,
    user = Sys.getenv("DB_USER"),
    password = Sys.getenv("DB_PASSWORD"),
    host = Sys.getenv("DB_HOST"),
    dbname = Sys.getenv("DB_NAME"),
    port = as.numeric(Sys.getenv("DB_PORT"))
  ))
}

#' Update Database with New RSS Feed Data
#'
#' This function updates the database with new RSS feed data from a list of tibbles.
#' For each tibble, it compares the `feed_last_build_date` with the corresponding
#' date in the database and updates the database if the tibble contains newer data.
#'
#' @param tibble A tibble containing RSS feed data with unique `source_id`
#'   and `feed_last_build_date`.
#' @param con A DBI connection object to the MariaDB database.
#' @export
update_database <- function(tibble, con) {
    source_id <- unique(tibble$source_id)
    feed_last_build_date_r <- max(tibble$feed_last_build_date)

    query <- sprintf("SELECT MAX(feed_last_build_date) AS max_date FROM rss_feed_text WHERE source_id = %d", source_id)
    feed_last_build_date_db <- sendQuery(con, query)$max_date

    if (is.na(feed_last_build_date_db) || feed_last_build_date_r > feed_last_build_date_db) {
      logging("Updating data for source_id %s.", source_id)#
      sendData(con, data = tibble, table = "feed_text", mode = "insert")
    } else {
      logging("Nothing to update for source_id %s.", source_id)
    }
}
