#' Run feed collector
#'
#' @param config_file (str) configuration file
#'
#' @export
main <- function(config_file = "config.yaml") {
  config <- load_yaml_config(config_file)
  # read entries from each rss source
  feeds <- read_rss_sources(config)
  # read text from each entry for each rss source
  data_tibbles <- lapply(feeds, function(x) try(read_rss_feeds(x, config)))
  # apply keyword filters
  data_tibbles <- lapply(data_tibbles, function(x) try(filter_for_keywords(x, config)))
  # write to database (if newer than db entries)
  res <- lapply(data_tibbles, function(x) try(update_database(x, config)))
  invisible(
    if (any(unlist(lapply(res, inherits, what = "try-error")))) 1
    else 0
  )
}

