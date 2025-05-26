#' Read RSS Feeds
#'
#' This function reads and processes RSS feeds, extracting specified fields.
#'
#' @param source (list) source feed entry from the configuration file.
#' @param config (list) configuration file with column mapping and rss field names.
#' @export
#'
#' @return A data frame containing the requested fields from the RSS feed.
read_rss_feeds <- function(source, config) {
  mapping <- read_field_mapping(config)
  logging("Reading source feed %s.", source$url)

  feed <- tidyfeed(source$url)
  feed[["source_id"]] <- source$id
  feed_columns <- colnames(feed)
  feed_data <- feed[, feed_columns %in% mapping$rss, drop = FALSE]

  missing_fields <- setdiff(mapping$rss, feed_columns)
  if (length(missing_fields) > 0) {
    log_warn("Fields are missing: %s.",
             paste(missing_fields, collapse = ", "))
    for (field in missing_fields) {
      feed_data[[field]] <- NA_character_
    }
  }
  if (mapping["text", ]$rss %in% missing_fields &&
        !(mapping["link", ]$rss %in% missing_fields)) {
    feed_data <- feed_data %>%
      rowwise() %>%
      mutate(!!mapping["text", ]$rss := read_text_via_url(url = !!sym(mapping["link", ]$rss))) %>%
      ungroup()
  }
  feed_data <- feed_data %>%
    mutate(!!sym("feed_last_build_date") := if_else(
      is.na(!!sym("feed_last_build_date")),
      as.POSIXct(max(!!sym("item_pub_date"), na.rm = TRUE)),
      as.POSIXct(!!sym("feed_last_build_date"))
    ),
    filter_keyword = NA_character_,
    filter_place = NA_character_)
  return(feed_data)
}

#' Fetch and read text from a URL
#'
#' This function fetches and reads text content from a URL, extracting and returning the text
#' from paragraph tags.
#'
#' @param url A string representing the URL to fetch text from.
#'
#' @return A character vector containing the extracted text, or \code{NA_character_} if the
#' URL is not reachable.
#' @export
read_text_via_url <- function(url) {
  logging("Fetching text from url %s", url)

  if (url_exists(url, timeout(30))) {
    page <- safe_GET(url, timeout(30))

    if (is.null(page$result) ||
          ((httr::status_code(page$result) %/% 200) != 1)) {
      log_warn(
        "The url %s is not reachable (%s).",
        url,
        if (is.null(page$result))
          "NULL"
        else
          httr::status_code(page$result)
      )
      return(NA_character_)
    } else {
      page_content <- httr::content(page$result, as = "text")
      html <- read_html(page_content)
      text <- html %>%
        html_nodes("p") %>%
        html_text() %>%
        str_squish() %>%
        paste(collapse = " ")
      return(text)
    }
  } else {
    return(NA_character_)
  }
}

#' Check if a URL exists and is reachable
#'
#' This function performs a HEAD request to check if a URL exists and is reachable.
#'
#' @param url A string representing the URL to check.
#' @param quiet A logical value indicating whether to suppress error messages.
#' Default is \code{FALSE}.
#' @param ... Additional arguments passed to the \code{httr::HEAD} function.
#'
#' @return \code{TRUE} if the URL exists and is reachable, \code{FALSE} if the URL is not
#' reachable, and logs a warning message.
#' @export
url_exists <- function(url, quiet = FALSE, ...) {
  res <- safe_HEAD(url, ...)

  if ((is.null(res$result)) || ((httr::status_code(res$result) %/% 200) != 1)) {
    log_warn("The url %s is not reachable.",
             url)
    return(FALSE)

  } else {
    return(TRUE)
  }
}

#' Safely wrap a function to capture errors
#'
#' This function wraps another function to safely execute it, capturing any errors that occur.
#'
#' @param .f The function to be executed safely.
#' @param otherwise A default value to return if an error occurs. Default is \code{NULL}.
#' @param quiet A logical value indicating whether to suppress error messages.
#' @param ... Additional arguments passed to the \code{httr::HEAD} function.
#' Default is \code{TRUE}.
#'
#' @return A function that safely executes the original function.
#' @export
safely <- function(.f,
                   otherwise = NULL,
                   quiet = TRUE,
                   ...) {
  function(...) {
    capture_error(.f(...), otherwise, quiet)
  }
}

#' Capture errors in code execution
#'
#' This function executes code and captures any errors that occur, returning a list with the
#' result and the error.
#'
#' @param code The code to be executed.
#' @param otherwise A default value to return if an error occurs. Default is \code{NULL}.
#' @param quiet A logical value indicating whether to suppress error messages.
#' Default is \code{TRUE}.
#'
#' @return A list with two elements: \code{result} (the result of the code execution)
#' and \code{error} (the error that occurred, if any).
#' @export
capture_error <- function(code,
                          otherwise = NULL,
                          quiet = TRUE) {
  tryCatch(
    list(result = code, error = NULL),
    error = function(e) {
      if (!quiet)
        message("Error: ", e$message)

      list(result = otherwise, error = e)
    },
    interrupt = function(e) {
      stop("Terminated by user", call. = FALSE)
    }
  )
}

#' Safely Wrapped HEAD Function from httr
#'
#' This function is a safely wrapped version of \code{httr::HEAD} using the \code{safely} function.
#' It captures errors and returns a list with the result and the error.
#' @param ... Additional arguments passed to the \code{httr::HEAD} function.
#' @return A function that performs a HEAD request and returns a list with elements
#' \code{result} and \code{error}.
#' @export
safe_HEAD <- safely(httr::HEAD)

#' Safely Wrapped GET Function from httr
#'
#' This function is a safely wrapped version of \code{httr::GET} using the \code{safely} function.
#' It captures errors and returns a list with the result and the error.
#' @param ... Additional arguments passed to the \code{httr::HEAD} function.
#' @return A function that performs a GET request and returns a list with elements
#' \code{result} and \code{error}.
#' @export
safe_GET <- safely(httr::GET)
