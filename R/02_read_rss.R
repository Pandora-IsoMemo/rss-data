#' Read RSS Feeds
#' @param feed_url (str) url of the rss feed
#' @param fields (str) fields to read from the rss feed
#' @export
read_rss_feeds <- function(feed, fields=read_field_mapping()$rss_names) {
    feed <- tidyfeed(feed$url)
    feed_columns <- colnames(feed)
    if(!("item_link" %in% feed_columns) && !("item_text" %in% feed_columns)){
      warning(paste0("Neither 'item_link' nor 'item_text' is present in the feed: ", feed_url))
    }
    feed_data <- feed[, feed_columns[feed_columns %in% fields], drop = FALSE]
    missing_fields <- setdiff(fields, feed_columns)
    if("item_text" %in% missing_fields) {
      feed_data <- feed_data %>%
        rowwise() %>%
        mutate(item_text = read_text_via_url(url=item_link)) %>%
        ungroup()
    }
    return(feed_data)
}

#' Read item_text via Provided Link in RSS Feed
#' @param url (str) item_link from the rss feed
#' @export
read_text_via_url <- function(url) {
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

