# Load packages
library(janitor)
library(tidyverse)
library(dplyr)
library(lubridate)

# Load all processed rider data
trips_2022_Q2 <- read_csv('processed-data/trips_2022_Q2.csv')
trips_2022_Q3 <- read_csv('processed-data/trips_2022_Q3.csv')
trips_2022_Q4 <- read_csv('processed-data/trips_2022_Q4.csv')
trips_2023_Q1 <- read_csv('processed-data/trips_2023_Q1.csv')
all_trips <- read_csv('processed-data/all_trips.csv')

# Descriptive analysis on ride_length (all figures in seconds)
summary(all_trips$ride_length)

# Add ordering to day_of_week
all_trips$day_of_week <- ordered(all_trips$day_of_week, levels=
                                   c("Sunday", "Monday", "Tuesday", "Wednesday", 
                                     "Thursday", "Friday", "Saturday"))

# Analysis on ride_length grouped by rider type
aggregate(all_trips$ride_length ~ all_trips$member_casual, FUN = mean)
aggregate(all_trips$ride_length ~ all_trips$member_casual + 
            all_trips$day_of_week, FUN = mean)

# Analyze ridership data by type and day of week
all_trips %>% 
  group_by(member_casual, day_of_week) %>%        # group by rider type, then weekday
  summarise(number_of_rides = n()							    # calculates the number of rides
            ,average_duration = mean(ride_length)) %>% # calculates the average duration
  arrange(member_casual, day_of_week)							     # sort by rider type, then weekday

# Visualization of the number of rides by rider type
all_trips %>% 
  group_by(member_casual, day_of_week) %>% 
  summarise(number_of_rides = n()
            ,average_duration = mean(ride_length)) %>% 
  arrange(member_casual, day_of_week)  %>% 
  ggplot(aes(x = day_of_week, y = number_of_rides, fill = member_casual)) +
  geom_col(position = "dodge") +
  xlab("Day of Week") + ylab("Number of Rides") + labs(fill = "Rider Type") +
  ggtitle("Number of Rides by Rider Type and Day of Week")

# Visualization for average duration by rider type
all_trips %>% 
  group_by(member_casual, day_of_week) %>% 
  summarise(number_of_rides = n()
            ,average_duration = mean(ride_length)) %>% 
  arrange(member_casual, day_of_week)  %>% 
  ggplot(aes(x = day_of_week, y = average_duration, fill = member_casual)) +
  geom_col(position = "dodge") + labs(fill = "Rider Type") +
  xlab("Day of Week") + ylab("Average Ride Duration") +
  ggtitle("Average Ride Duration by Rider Type and Day of Week")

# Create data frame to be used in Tableau
trips_summary <- all_trips %>% 
  group_by(member_casual, as.Date(all_trips$started_at), day_of_week) %>% 
  summarise(number_of_rides = n()
            ,average_duration = mean(ride_length)) %>% 
  arrange(member_casual, `as.Date(all_trips$started_at)`)

trips_summary <- rename(trips_summary, date = `as.Date(all_trips$started_at)`)

write.csv(trips_summary, file = '~/Desktop/trips_summary.csv')
