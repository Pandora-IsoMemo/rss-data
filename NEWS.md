# rssData 25.07.0

## New Features
-  **filter feature**: It allows that RSS texts can be filtered based on keywords specified in the config file.
- The filter location (**title** or **text**) is configurable via the config as well.

## Updates
- Added **two new sources** in the config file.

# rssData 0.2.0

## New Features
- **Source Availability Check**: Added `check_source_availability()` function that throws an error if an RSS feed hasn't provided data within the last 14 days.

## Updates
- **Cron Trigger Enabled**: The ETL job is now scheduled via Jenkins to run daily at 7:00 AM.
- **Database Migration**: Switched from MariaDB to MongoDB for storing RSS feed news.

