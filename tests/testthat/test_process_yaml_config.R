library(testthat)

# Test for load_yaml_config
test_that("load_yaml_config loads YAML file correctly", {
  config <- load_yaml_config("test_config.yaml")
  expect_true(is.list(config))
  expect_equal(names(config), c("sources", "dbMapping", "rssMapping"))

})

# Test for read_field_mapping
test_that("read_field_mapping returns correct mapping table", {
  config <- load_yaml_config("test_config.yaml")
  mapping <- read_field_mapping(config)
  expect_true(is.data.frame(mapping))
  expect_equal(ncol(mapping), 2)
  expect_equal(row.names(mapping), c("source_id", "source", "title", "link", "text", "timestamp_feed_updated", "timestamp_item_published"))
  expect_equal(names(mapping), c("db", "rss"))
})


