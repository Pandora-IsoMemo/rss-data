# rssData: RSS Feed Collector for MongoDB

This R package provides a full pipeline to read, process, and store RSS feed content in a MongoDB database. It uses a YAML configuration file to define data sources, map RSS fields to database fields, and manage credentials securely via environment variables.

## Features

* Read configuration from YAML files
* Map RSS fields to database schema
* Fetch and parse RSS feeds
* Extract full article text via URL
* Store or update documents in MongoDB
* Validate feed freshness (e.g. last update within 14 days)
* Safe error handling and logging

## Installation

### Option 1: Install from Local Source

```r
# Install required dependencies
install.packages(c("yaml", "tidyRSS", "mongolite", "httr", "xml2", "rvest", "stringr", "dplyr", "rlang"))

# Install from local directory
devtools::install("path/to/your/package")
```

### Option 2: Using Docker

A `Dockerfile` is included for building a containerized environment.

```bash
# Build Docker image
docker build -t rss-feed-collector .

# Run the container with environment variables
# (from a file like .Renviron mounted into the container)
docker run --rm --env-file .Renviron rss-feed-collector
```

The Dockerfile is based on [`inwt/r-batch:4.1.2`](https://github.com/INWTlab/r-docker/blob/latest/r-batch/Dockerfile) and installs system dependencies needed for MongoDB and HTTPS connections.

## Configuration

Create a `config.yaml` file with sections for:

* `sources`: List of RSS feeds with `id` and `url`
* `dbMapping`: Mapping of database field names
* `rssMapping`: Mapping of RSS field names
* `rssFields`: RSS field names for text and link extraction

Environment variables for MongoDB connection must be set in `.Renviron`:

```ini
DB_USER=yourUser
DB_PASSWORD=yourPasswordEncoded
DB_HOST=localhost
DB_PORT=27017
DB_NAME=yourDatabase
DB_COLLECTION=yourCollection
```

## Example Usage

```r
# Run the full pipeline
main("config.yaml")
```

### Manual Pipeline

```r
config <- load_yaml_config("config.yaml")
sources <- read_rss_sources(config)

# Read and process feeds
feeds <- lapply(sources, function(source) read_rss_feeds(source, config))

# Write to MongoDB
lapply(feeds, function(feed) update_database(feed, config))
```

## Core Functions

| Function                      | Purpose                                        |
| ----------------------------- | ---------------------------------------------- |
| `load_yaml_config()`          | Load YAML config file                          |
| `read_rss_sources()`          | Get list of RSS sources from config            |
| `read_rss_feeds()`            | Parse and clean an RSS feed                    |
| `read_text_via_url()`         | Extract article text from a URL                |
| `update_database()`           | Insert/update RSS feed data into MongoDB       |
| `check_source_availability()` | Verify if all feeds have been updated recently |
| `credentials()`               | Connect to MongoDB using env variables         |
| `main()`                      | End-to-end pipeline using config file          |

## Error Handling

* Safe wrappers (`safe_GET`, `safe_HEAD`) avoid crashes on bad URLs
* Logs warnings for missing fields or unreachable sources
* Skips update if the database already contains fresher data

## Continuous Integration

A Jenkins pipeline is configured to test and run the ETL process daily at 7 AM:

* **Testing**: Builds a Docker image, runs it with `check`, and removes the container.
* **ETL**: Executes the full pipeline on the `main` branch.

The pipeline uses dynamic naming and `.Renviron` credentials managed in Jenkins.
