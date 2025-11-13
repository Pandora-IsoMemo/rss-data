library(testthat)

test_that("environment variables for DB are set and not empty", {
  expect_false(Sys.getenv("DB_USER") == "")
  expect_false(Sys.getenv("DB_PASSWORD") == "")
  expect_false(Sys.getenv("DB_NAME") == "")
  expect_false(Sys.getenv("DB_HOST") == "")
  port <- Sys.getenv("DB_PORT")
  expect_false(port == "")
  expect_true(!is.na(as.numeric(port)))
})

test_that("db connection can be established", {
  con <- credentials()
  expect_true(class(con)[1] == "mongo")
})

test_that("required collections are not empty: articles and sources", {
  con_articles <- credentials(collection = "articles")
  count_articles <- con_articles$count()
  expect_gt(count_articles, 0, info = "'articles' collection is empty.")

  con_sources <- credentials(collection = "sources")
  count_sources <- con_sources$count()
  expect_gt(count_sources, 0, info = "'sources' collection is empty.")
})
