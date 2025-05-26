library(testthat)

# Test for read_rss_feeds
test_that("read_rss_feeds reads and processes RSS feeds correctly", {
  config <- load_yaml_config("test_config.yaml")

  source <- list(id = 1, url = "http://rss.cnn.com/rss/edition_world.rss")

  feed_data <- read_rss_feeds(source, config)
  expect_true(is.data.frame(feed_data))
  expect_equal(ncol(feed_data), 9)
  expect_true(nrow(feed_data) >= 1)
})

# Test for read_text_via_url
test_that("read_text_via_url fetches and reads text from URL correctly", {
  text <- read_text_via_url("http://inva-li-d123url.com")
  expect_equal(text, NA_character_)
})

# Test for url_exists
test_that("url_exists checks URL existence correctly", {
  expect_true(url_exists("http://example.com"))
  expect_false(url_exists("http://inva-li-d123url.com"))
})

# Test for safely function
test_that("safely wraps function execution correctly", {
  safe_fn <- safely(function(x) stop("Error!"))
  result <- safe_fn()
  expect_null(result$result)
  expect_true(inherits(result$error, "error"))
})

# Test for capture_error function
test_that("capture_error captures errors correctly", {
  result <- capture_error(stop("Error!"))
  expect_null(result$result)
  expect_true(inherits(result$error, "error"))
})
