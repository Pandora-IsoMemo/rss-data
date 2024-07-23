#' Read RSS Sources from YAML Config
#' @param config_file (str) name of config file
#' @export
read_rss_sources <- function(config_file = "config.yaml") {
  logging("Reading RSS sources from %s.", config_file)
  return(yaml.load_file("config.yaml")$sources)
}

#' Read Mapping Table for DB and RSS from YAML Config
#' @param config_file (str) name of config file
#' @export
read_field_mapping <- function(config_file = "config.yaml") {
  logging("Reading mapping table from %s.", config_file)
  mapping <- yaml.load_file("config.yaml")$fieldMapping
  return(
    data.frame(
    db_names = names(mapping),
    rss_names = unlist(mapping),
    stringsAsFactors = FALSE,
    row.names = NULL
  )
  )
}
