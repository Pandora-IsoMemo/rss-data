#' Check Source_id Feed Updates
#'
#' This function connects to MongoDB and verifies whether all sources
#' (identified by `source_id`) have been updated within the last 14 days.
#' If any sources are outdated, the function throws an error listing the affected `source_id`s.
#'
#' @return Invisibly returns `TRUE` if all sources are up-to-date; otherwise throws an error.
#' @export
check_source_availability <- function() {
  con <- credentials()
  query <- '[
    { "$sort": { "source_id": 1, "ts_last_feed_updated": -1 } },
    {
      "$group": {
        "_id": "$source_id",
        "latest": { "$first": "$$ROOT" }
      }
    },
    { "$replaceRoot": { "newRoot": "$latest" } }
  ]'

  result <- con$aggregate(query)
  result$ts_last_feed_updated <- as.POSIXct(
    result$ts_last_feed_updated,
    format = "%Y-%m-%dT%H:%M:%OSZ",
    tz = "UTC"
  )

  two_weeks_ago <- Sys.time() - 14 * 24 * 60 * 60
  stale <- result[result$ts_item_published < two_weeks_ago, ]
  if (nrow(stale) > 0) {
    stop(
      sprintf(
        "ERROR: %d source(s) are outdated (no update in the last ~2 weeks). Affected source_ids: %s",
        nrow(stale),
        paste(stale$source_id, collapse = ", ")
      )
    )
  }
  invisible(TRUE)
}
