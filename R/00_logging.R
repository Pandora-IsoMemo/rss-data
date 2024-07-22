#' Print logging messages
#'
#' @param msg message to log
#' @param ... further params passed to flog.info
#'
#' @export
logging <- function(msg, ...) {
  futile.logger::flog.info(msg, ...)
}

log_debug <- function(msg, ...) {
  futile.logger::flog.debug(msg, ...)
}

log_warn <- function(msg, ...) {
  futile.logger::flog.warn(msg, ...)
}
