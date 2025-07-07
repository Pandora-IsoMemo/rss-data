test_that("filter_tibble works with single column match", {
  df <- tibble::tibble(
    item_title = c("This is great", "Nothing to see", "Keyword found"),
    item_text = c("Nope", "Still nothing", "Absolutely nothing")
  )

  result <- filter_tibble(
    df,
    search_in = "item_title",
    regex_pattern = stringr::regex("keyword", ignore_case = TRUE)
  )

  expect_equal(nrow(result), 1)
  expect_true(any(stringr::str_detect(result$item_title, stringr::regex("keyword", ignore_case = TRUE))))
})

test_that("filter_tibble works with multiple columns match", {
  df <- tibble::tibble(
    item_title = c("This is great", "Nothing to see", "No match here"),
    item_text = c("Keyword present", "Still nothing", "Nothing again")
  )

  result <- filter_tibble(
    df,
    search_in = c("item_title", "item_text"),
    regex_pattern = stringr::regex("keyword", ignore_case = TRUE)
  )

  expect_equal(nrow(result), 1)
  expect_true(any(stringr::str_detect(result$item_title, stringr::regex("keyword", ignore_case = TRUE))) ||
                any(stringr::str_detect(result$item_text, stringr::regex("keyword", ignore_case = TRUE))))
})

test_that("filter_tibble returns empty tibble when no matches found", {
  df <- tibble::tibble(
    item_title = c("foo", "bar", "baz"),
    item_text = c("abc", "def", "ghi")
  )

  result <- filter_tibble(
    df,
    search_in = c("item_title", "item_text"),
    regex_pattern = stringr::regex("keyword", ignore_case = TRUE)
  )

  expect_equal(nrow(result), 0)
})

test_that("filter_for_keywords works correctly with config", {
  df <- tibble::tibble(
    item_title = c("Something great", "Cool news", "Not much"),
    item_text = c("boring", "interesting keyword", "nothing here")
  )

  config <- list(
    rss_filter = list(
      keywords = c("great", "keyword"),
      search_in = c("item_title", "item_text")
    )
  )

  result <- filter_for_keywords(df, config)

  expect_equal(nrow(result), 2)
  expect_true(all(purrr::map_lgl(result$filter_keywords, ~ identical(., config$rss_filter$keywords))))
  expect_true(all(purrr::map_lgl(result$filter_places, ~ identical(., config$rss_filter$search_in))))
})

test_that("filter_for_keywords returns empty tibble if no matches", {
  df <- tibble::tibble(
    item_title = c("Nothing relevant", "Still nothing"),
    item_text = c("Just text", "More text")
  )

  config <- list(
    rss_filter = list(
      keywords = c("keyword", "magic"),
      search_in = c("item_title", "item_text")
    )
  )

  result <- filter_for_keywords(df, config)

  expect_equal(nrow(result), 0)
})
