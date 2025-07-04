#' Filter a tibble for keywords in specified columns
#'
#' @param df A tibble containing at least the columns specified in `search_in`
#' @param search_in A character vector of column names to search within
#' @param regex_pattern A compiled regular expression to match (case-insensitive recommended)
#'
#' @return A filtered tibble containing only rows where at least one column contains a keyword match
#' @export
filter_tibble <- function(df, search_in, regex_pattern) {
  filter_exprs <- lapply(search_in, function(col) {
    rlang::expr(stringr::str_detect(.data[[col]], !!regex_pattern))
  })

  combined_filter <- Reduce(function(x, y) rlang::expr(!!x | !!y), filter_exprs)

  return(dplyr::filter(df, !!combined_filter))
}

#' Filter a tibble for keywords based on the YAML config
#'
#' @param df A tibble containing rss data
#' @param config YAML config
#'   \itemize{
#'     \item \code{rss_filter$keywords}: Character vector of keywords to search for
#'     \item \code{rss_filter$search_in}: Character vector of column names to search within ('item_text' and/or 'item_title')
#'   }
#'
#' @return A filtered tibble where the specified columns contain one of the keywords (case-insensitive)
#' @export
filter_for_keywords <- function(df, config) {
  keywords <- config$rss_filter$keywords
  search_in <- config$rss_filter$search_in

  pattern <- paste(keywords, collapse = "|")
  regex_pattern <- stringr::regex(pattern, ignore_case = TRUE)

  filtered_tibbles <- filter_tibble(df, search_in, regex_pattern)

  filtered_tibbles %>%
    mutate(
      filter_keywords = list(keywords),
      filter_places = list(search_in)
    ) %>% return
}
