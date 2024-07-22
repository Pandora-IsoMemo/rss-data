#' Run feed collector
#'
#' @param feeds (list) see result of \code{read_rss_sources()}
#'
#' @export
main <- function(feeds = read_rss_sources()) {
  res <- lapply(feeds, function(x) try(read_rss_feeds(x)))
  invisible(
    if (any(unlist(lapply(res, inherits, what = "try-error")))) 1
    else 0
  )
}
