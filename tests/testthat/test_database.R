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
