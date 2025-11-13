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

test_that("required collections exist and not empty: articles and sources", {
  con <- credentials(collection = "articles")

  collections_result <- con$run('{"listCollections": 1}')
  collections <- vapply(
    collections_result$cursor$firstBatch,
    function(x) x$name,
    FUN.VALUE = character(1)
  )

  # Check existence of collections
  expect_true("articles" %in% collections, info = "'articles' collection is missing.")
  expect_true("sources" %in% collections, info = "'sources' collection is missing.")

  # Check that collections are not empty
  count_articles <- con$count()
  expect_gt(count_articles, 0, info = "'articles' collection is empty.")

  con_sources <- credentials(collection = "sources")
  count_sources <- con_sources$count()
  expect_gt(count_sources, 0, info = "'sources' collection is empty.")
})
