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
  # Determine bad inputs
  input_bad <- vapply(data_tibbles, function(x) inherits(x, "try-error") || !is.data.frame(x), logical(1))
  # write to database (if newer than db entries)
  res <- lapply(data_tibbles, function(x) try(update_database(x, config)))
  # Catch post-call errors (if update_database itself failed)
  post_errors <- vapply(res, inherits, what = "try-error", FUN.VALUE = logical(1))

  invisible(if (any(input_bad | post_errors)) 1L else 0L)
}

