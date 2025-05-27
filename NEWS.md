# rssData 0.3.0

## Updates
- **RSS Sources**: Source 1 has been inactivated because it does not deliver data updates. 

# rssData 0.2.0

## New Features
- **Source Availability Check**: Added `check_source_availability()` function that throws an error if an RSS feed hasn't provided data within the last 14 days.

## Updates
- **Cron Trigger Enabled**: The ETL job is now scheduled via Jenkins to run daily at 7:00 AM.
- **Database Migration**: Switched from MariaDB to MongoDB for storing RSS feed news.

