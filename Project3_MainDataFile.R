# Creating Project 3 main data file.

setwd('C:/Users/Silvy/Documents/R/Repos/Project3WeatherPatterns')
library(dplyr)
library(lubridate)



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



# Step 4: Join file 1.4 to file 1.1
# This I need help with. The join here is complicated. It needs to (1) join by date and (2) join by closest hour.
# Something with lapply(Acoustic_and_Lunar_Data, ) maybe?
# Maybe use round_date() from lubridate to match recording start times and temperature times?
# Or maybe fuzzy_left_join() from fuzzyjoin package?
MergeHourlyWeatherData <- function(Acoustic_and_Lunar_Data){
  for (i in Acoustic_and_Lunar_Data$StartTime) {
    if (Acoustic_and_Lunar_Data$Date == Hourly_Weather_Data$Date)
      #I have no idea what I'm doing.
  }
}




# Step 5: Correct duration data -> from minutes and seconds since midnight to seconds.
# I did a stupid thing while analyzing audio files. For the 'CallDuration' column I would fill in how many minutes and seconds long a call was. A 1 minute 20 second call was then automatically recorded in Excel as 12:01:20 AM. I can't work with that, so I'll need to convert mm:ss to seconds.

# Maybe something like this? Can't quite get it to work...
# Acoustic_Data$CallDuration <- as_date(parse_date_time2(Acoustic_Data$CallDuration, orders = "hms", tz = "America/Bogota"))
# Acoustic_Data$DurationInSec <- dseconds(Acoustic_Data$CallDuration)


