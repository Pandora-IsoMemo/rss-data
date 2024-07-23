#' Read RSS Feeds
#' @param feed_url (str) url of the rss feed
#' @param fields (str) fields to read from the rss feed
#' @export
read_rss_feeds <- function(feed, fields=read_field_mapping()$rss_names) {
    logging("Reading feed %s.", feed)
    feed <- tidyfeed(feed$url)
    feed_columns <- colnames(feed)
    feed_data <- feed[, feed_columns[feed_columns %in% fields], drop = FALSE]
    missing_fields <- setdiff(fields, feed_columns)
    if(length(missing_fields) > 0) {
      log_warn("Fields are missing: %s.", missing_fields)
    }
    if("item_text" %in% missing_fields && !("item_link" %in% missing_fields)) {
      feed_data <- feed_data %>%
        rowwise() %>%
        mutate(item_text = read_text_via_url(url=item_link)) %>%
        ungroup() %>%
        return()
      } else {
        log_warn("Can't read text for %s. item_link and item_text are both missing.", feed)
      }
}

#' Read item_text via Provided Link in RSS Feed
#' @param url (str) item_link from the rss feed
#' @export
read_text_via_url <- function(url) {
  logging("Fetching text from url %s", url)
  page <- GET(url, timeout(30))
  page_content <- content(page, as = "text")
  html <- read_html(page_content)
  html %>%
    html_nodes("p") %>%
    html_text() %>%
    str_squish() %>%
    paste(collapse = " ") %>%
    return()
}
