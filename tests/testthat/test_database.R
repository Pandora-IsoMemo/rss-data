library(testthat)

test_that("environment variables for DB are set and not empty", {
  expect_false(Sys.getenv("DB_USER") == "")
  expect_false(Sys.getenv("DB_PASSWORD") == "")
  expect_false(Sys.getenv("DB_NAME") == "")
  expect_false(Sys.getenv("DB_HOST") == "")
  expect_false(Sys.getenv("DB_PORT") == "")
})
