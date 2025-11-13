#' Sync config sources with MongoDB
#'
#' Compares the sources listed in the config object
#' with the MongoDB "sources" collection.
#' Adds new sources, marks removed ones, and if a source with an existing
#' ID has changed (name or URL), it raises a warning, marks the old entry
#' as removed, and inserts the updated version.
#'
#' @param config The loaded configuration list (as from config.yaml)
#' @export
sync_sources_with_mongo <- function(config) {

  con <- credentials(collection="sources")

  config_sources <- map_df(config$sources, function(src) {
    tibble(
      source_id = as.character(src$id),
      source_name = as.character(src$name),
      source_url = as.character(src$url)
    )
  })

  # read current MongoDB sources
  mongo_sources <- tryCatch({
    con$find('{}', fields = '{"_id":0}')
  }, error = function(e) {
    stop("Failed to fetch data from MongoDB 'sources' collection: ", e$message, call. = FALSE)
  })

  now <- Sys.time()

  # detect new sources
  new_sources <- anti_join(config_sources, mongo_sources, by = "source_id")

  if (nrow(new_sources) > 0) {
    new_sources <- mutate(
      new_sources,
      date_added = now,
      date_removed = as.POSIXct(NA, tz = "UTC")
    )
    con$insert(new_sources)
    flog.info(
      glue("Inserted {nrow(new_sources)} new source(s): {paste(new_sources$source_name, collapse = ', ')}")
    )
  } else {
    flog.debug("No new sources found.")
  }

  # detect removed sources
  removed_sources <- anti_join(mongo_sources, config_sources, by = "source_id") %>%
    filter(is.na(.data$date_removed))

  if (nrow(removed_sources) > 0) {
    for (sid in removed_sources$source_id) {
      con$update(
        query = paste0('{"source_id": "', sid, '"}'),
        update = paste0('{"$set": {"date_removed": {"$date": "', format(now, "%Y-%m-%dT%H:%M:%S%z"), '"}}}')
      )
    }
    flog.info(
      glue("Marked {nrow(removed_sources)} source(s) as removed: {paste(removed_sources$source_id, collapse = ', ')}")
    )
  } else {
    flog.debug("No removed sources found.")
  }

  # detect updated sources (same id, changed name or url)
  updated_sources <- inner_join(config_sources, mongo_sources, by = "source_id") %>%
    filter(.data$source_name.x != .data$source_name.y | .data$source_url.x != .data$source_url.y)

  if (nrow(updated_sources) > 0) {
    flog.warn(glue(
      "Source update detected for {nrow(updated_sources)} source(s):\n",
      paste0(
        updated_sources$source_id, ": name/url changed\n",
        "  old name = ", updated_sources$source_name.y, "\n",
        "  new name = ", updated_sources$source_name.x, "\n",
        "  old url  = ", updated_sources$source_url.y, "\n",
        "  new url  = ", updated_sources$source_url.x,
        collapse = "\n\n"
      ),
      "\n\nOld entries will be marked as removed, and new ones inserted."
    ))

    for (i in seq_len(nrow(updated_sources))) {
      sid <- updated_sources$source_id[i]

      # mark old entry as removed
      con$update(
        query = paste0('{"source_id": "', sid, '"}'),
        update = paste0('{"$set": {"date_removed": {"$date": "', format(now, "%Y-%m-%dT%H:%M:%S%z"), '"}}}')
      )

      # Insert new entry (same id, updated name and url)
      con$insert(list(
        source_id = sid,
        source_name = updated_sources$source_name.x[i],
        source_url = updated_sources$source_url.x[i],
        date_added = now,
        date_removed = as.POSIXct(NA, tz = "UTC")
      ))
    }
  } else {
    flog.debug("No updated sources found.")
  }

  flog.info("MongoDB sync complete.")
}
