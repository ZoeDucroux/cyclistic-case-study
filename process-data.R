# Load packages
library(janitor)
library(tidyverse)
library(dplyr)
library(lubridate)

# Load all rider data from April 2022 to March 2023
trips_2022_04 <- read_csv('original-data/202204-divvy-tripdata.csv')
trips_2022_05 <- read_csv('original-data/202205-divvy-tripdata.csv')
trips_2022_06 <- read_csv('original-data/202206-divvy-tripdata.csv')
trips_2022_07 <- read_csv('original-data/202207-divvy-tripdata.csv')
trips_2022_08 <- read_csv('original-data/202208-divvy-tripdata.csv')
trips_2022_09 <- read_csv('original-data/202209-divvy-tripdata.csv')
trips_2022_10 <- read_csv('original-data/202210-divvy-tripdata.csv')
trips_2022_11 <- read_csv('original-data/202211-divvy-tripdata.csv')
trips_2022_12 <- read_csv('original-data/202212-divvy-tripdata.csv')
trips_2023_01 <- read_csv('original-data/202301-divvy-tripdata.csv')
trips_2023_02 <- read_csv('original-data/202302-divvy-tripdata.csv')
trips_2023_03 <- read_csv('original-data/202303-divvy-tripdata.csv')

# Compare columns of all tables
compare_df_cols(trips_2022_04, trips_2022_05, trips_2022_06, trips_2022_07, 
                trips_2022_08, trips_2022_09, trips_2022_10, trips_2022_11, 
                trips_2022_12, trips_2023_01, trips_2023_02, trips_2023_03,
                return = "mismatch")

# Combine to 4 seasonal data frames: Q1, Q2, Q3, Q4
trips_2022_Q2 <- bind_rows(trips_2022_04, trips_2022_05, trips_2022_06)
trips_2022_Q3 <- bind_rows(trips_2022_07, trips_2022_08, trips_2022_09)
trips_2022_Q4 <- bind_rows(trips_2022_10, trips_2022_11, trips_2022_12)
trips_2023_Q1 <- bind_rows(trips_2023_01, trips_2023_02, trips_2023_03)

# Add day_of_week column to each data frame
trips_2022_Q2$day_of_week <- wday(trips_2022_Q2$started_at, label=TRUE, abbr=FALSE)
trips_2022_Q3$day_of_week <- wday(trips_2022_Q3$started_at, label=TRUE, abbr=FALSE)
trips_2022_Q4$day_of_week <- wday(trips_2022_Q4$started_at, label=TRUE, abbr=FALSE)
trips_2023_Q1$day_of_week <- wday(trips_2023_Q1$started_at, label=TRUE, abbr=FALSE)

# Remove unused columns
trips_2022_Q2 <- subset(trips_2022_Q2, select = -c(start_lat, start_lng, end_lat, end_lng))
trips_2022_Q3 <- subset(trips_2022_Q3, select = -c(start_lat, start_lng, end_lat, end_lng))
trips_2022_Q4 <- subset(trips_2022_Q4, select = -c(start_lat, start_lng, end_lat, end_lng))
trips_2023_Q1 <- subset(trips_2023_Q1, select = -c(start_lat, start_lng, end_lat, end_lng))

# Add ride_length column to each data frame
trips_2022_Q2$ride_length <- difftime(trips_2022_Q2$ended_at, trips_2022_Q2$started_at)
trips_2022_Q3$ride_length <- difftime(trips_2022_Q3$ended_at, trips_2022_Q3$started_at)
trips_2022_Q4$ride_length <- difftime(trips_2022_Q4$ended_at, trips_2022_Q4$started_at)
trips_2023_Q1$ride_length <- difftime(trips_2023_Q1$ended_at, trips_2023_Q1$started_at)

# Check for negative ride lengths
table(sign(trips_2022_Q2$ride_length))
table(sign(trips_2022_Q3$ride_length))
table(sign(trips_2022_Q4$ride_length))
table(sign(trips_2023_Q1$ride_length))

# Remove rows with negative ride lengths
trips_2022_Q2 <- trips_2022_Q2[trips_2022_Q2$ride_length >= 0, ]
trips_2022_Q3 <- trips_2022_Q3[trips_2022_Q3$ride_length >= 0, ]
trips_2022_Q4 <- trips_2022_Q4[trips_2022_Q4$ride_length >= 0, ]
trips_2023_Q1 <- trips_2023_Q1[trips_2023_Q1$ride_length >= 0, ]

# Double check for negative ride lengths
table(sign(trips_2022_Q2$ride_length))
table(sign(trips_2022_Q3$ride_length))
table(sign(trips_2022_Q4$ride_length))
table(sign(trips_2023_Q1$ride_length))

# Convert "ride_length" from Factor to numeric so we can run calculations on the data
trips_2022_Q2$ride_length <- as.numeric(as.character(trips_2022_Q2$ride_length))
trips_2022_Q3$ride_length <- as.numeric(as.character(trips_2022_Q3$ride_length))
trips_2022_Q4$ride_length <- as.numeric(as.character(trips_2022_Q4$ride_length))
trips_2023_Q1$ride_length <- as.numeric(as.character(trips_2023_Q1$ride_length))

# Ensure that no rows are duplicated
trips_2022_Q2 <- distinct(trips_2022_Q2)
trips_2022_Q3 <- distinct(trips_2022_Q3)
trips_2022_Q4 <- distinct(trips_2022_Q4)
trips_2023_Q1 <- distinct(trips_2023_Q1)

# Summary of all data
all_trips <- bind_rows(trips_2022_Q2, trips_2022_Q3, trips_2022_Q4, trips_2023_Q1)
summary(all_trips)

# Save processed data in csv files
write.csv(trips_2022_Q2, "processed-data/trips_2022_Q2.csv", row.names=FALSE)
write.csv(trips_2022_Q3, "processed-data/trips_2022_Q3.csv", row.names=FALSE)
write.csv(trips_2022_Q4, "processed-data/trips_2022_Q4.csv", row.names=FALSE)
write.csv(trips_2023_Q1, "processed-data/trips_2023_Q1.csv", row.names=FALSE)
write.csv(all_trips, "processed-data/all_trips.csv", row.names=FALSE)

