#' Run feed collector
#'
#' @param config_file (str) configuration file
#'
#' @export
main <- function(config_file = "config.yaml") {
  config <- load_yaml_config(config_file)
  feeds <- read_rss_sources(config)
  data_tibbles <- lapply(feeds, function(x) try(read_rss_feeds(x, config)))
  res <- lapply(data_tibbles, function(x) try(update_database(x)))
  invisible(
    if (any(unlist(lapply(res, inherits, what = "try-error")))) 1
    else 0
  )
}

