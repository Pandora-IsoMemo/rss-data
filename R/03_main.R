#' Run feed collector
#'
#' @param config_file (str) configuration file
#'
#' @export
main <- function(config_file = "config.yaml") {
  config <- load_yaml_config(config_file)
  feeds <- read_rss_sources(config)
  res <- lapply(feeds, function(x) try(read_rss_feeds(x, config)))
  invisible(
    if (any(unlist(lapply(res, inherits, what = "try-error")))) 1
    else 0
  )
}
