# Creating Project 3 main data file.

setwd('C:/Users/Silvy/Documents/R/Repos/Project3WeatherPatterns')
library(dplyr)
library(lubridate)
library(stringr)



#Step 1: Load in data files.

# 1.1 - Load in main data
Acoustic_Data <- read.csv(file = 'Project3-Main_Data_Sheet.csv')
head(Acoustic_Data)

# 1.2 - Load in lunar phase data
Lunar_Data <- read.csv(file = 'Johnblake_dates_with_phase.csv')
head(Lunar_Data)

# 1.3 - Load in temperature data - overnight averages


# 1.4 - Load in temperature data - hourly temperature and humidity
Hourly_Weather_Data <- read.csv(file = 'WeatherDataPerHour.csv')
head(Hourly_Weather_Data)



#Step 2: Join file 1.2 to file 1.1

Acoustic_and_Lunar_Data <- left_join(Acoustic_Data, Lunar_Data, by = "Date")
head(Acoustic_and_Lunar_Data) #Double check this worked. Compare to MainData



# Step 3: Join file 1.3 to file 1.1

# This will likely be something like the following example, but will need to complete this file first:
# DF2 <- DF2 %>% 
# select(Date, Temperature, Humidity) (this uses only the three selected columns and ignores all other info that we don't need)
# joined_data <- left_join(DF1, DF2, by = "Date")



# Step 4: Join file 1.4 to file 1.1 - Code Witten by Tony Di Fiore.
Acoustic_and_Lunar_Data <- 
  Acoustic_and_Lunar_Data %>%
  mutate(Date2 = parse_date_time(Date, orders = c("mdy")),
         hh = str_sub(`StartTime`,1,2),
         mm = str_sub(`StartTime`,3,4),
         ss = str_sub(`StartTime`,5,6),
         dt = make_datetime(year=year(Date2), month=month(Date2), day=day(Date2), hour = as.numeric(hh), min = as.numeric(mm), sec = as.numeric(ss))) %>%
  select(-c(Date2, hh, mm, ss)) %>%
  mutate(roundDateTime = round_date(dt, unit = "hour"))

Hourly_Weather_Data <- Hourly_Weather_Data %>%
  mutate(Date2 = parse_date_time(Date, orders = c("dmy")),
         Time2 = parse_date_time(Time, orders = c("IMSp")),
         dt = make_datetime(year=year(Date2), month=month(Date2), day=day(Date2), hour = hour(Time2), min = minute(Time2), sec = second(Time2))) %>%
  select(-c(Date2, Time2)) %>%
  mutate(roundDateTime = round_date(dt, unit = "hour"))

trialMerge <- left_join(Acoustic_and_Lunar_Data, Hourly_Weather_Data[ , c("roundDateTime", "Celsius", "Humidity")], by = "roundDateTime")



# Step 5: Correct duration data -> from minutes and seconds since midnight to seconds.
# I did a stupid thing while analyzing audio files. For the 'CallDuration' column I would fill in how many minutes and seconds long a call was. A 1 minute 20 second call was then automatically recorded in Excel as 12:01:20 AM. I can't work with that, so I'll need to convert mm:ss to seconds.

# Maybe something like this? Can't quite get it to work...
# Acoustic_Data$CallDuration <- as_date(parse_date_time2(Acoustic_Data$CallDuration, orders = "hms", tz = "America/Bogota"))
# Acoustic_Data$DurationInSec <- dseconds(Acoustic_Data$CallDuration)


