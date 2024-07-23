#' Load YAML Configuration
#' @param config_file (str) name of the config file
#' @return (list) The parsed YAML content
#' @export
load_yaml_config <- function(config_file = "config.yaml") {
  logging("Reading configuration from %s.", config_file)
  return(yaml.load_file(config_file))
}

#' Read Mapping Table for DB and RSS from Configuration
#' @param config (list) the configuration object
#' @export
read_field_mapping <- function(config) {
  mapping <- config$fieldMapping
  return(
    data.frame(
      db_names = names(mapping),
      rss_names = unlist(mapping),
      stringsAsFactors = FALSE,
      row.names = NULL
    )
  )
}

#' Read RSS Sources from Configuration
#' @param config (list) the configuration object
#' @export
read_rss_sources <- function(config) {
  logging("Start processing %s sources.", length(config$sources))
  return(config$sources)
}

#' Read RSS field names for text and url to text from Configuration
#' Needed in case of changes to the mapping table (e.g. renaming of database columns)
#' @param config (list) the configuration object
#' @export
read_rss_fields <- function(config) {
  return(config$rssFields)
}
