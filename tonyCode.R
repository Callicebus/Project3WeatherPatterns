library(tidyverse)
library(lubridate)
library(tuneR)

#Data <- read_csv("https://raw.githubusercontent.com/Callicebus/Project3WeatherPatterns/main/Project3_Final_Data_per_Recording.csv", col_names = TRUE)
Data <- read_csv("Project3_Final_Data_per_Recording_Updated.csv", col_names = TRUE)
setwd('C:/Users/Silvy/Documents/R/Repos/Project3WeatherPatterns')
#source("tonyPAMGuide_Meta.R")

Data$StartTime <- str_split_fixed(Data$FileName, "_",3)[,3] #Pull the start time of the recording out of the file name.
Data$StartTime <- parse_date_time(Data$StartTime, "HMS")
Data$CallOnset <- parse_date_time(Data$CallOnset, "HMS")

# TimeDiff is time since start of recording... this
Data$TimeDiff <- difftime(Data$CallOnset, Data$StartTime, units="secs")

# group_by recording
Data <- Data %>% group_by(FileName)
Data$CallEnd <- Data$CallOnset + Data$CallDuration
# these rows should match CallCompletion... they find some errors where CallCompletion... was coded wrong
Data$CallingAtStart <- if_else(Data$CallOnset==Data$StartTime, TRUE, FALSE)
Data$CallingAtEnd <- if_else(Data$CallEnd==Data$StartTime +minutes(10), TRUE, FALSE)

#Creating random CallOnsets for recordings that don't have primate calls
for(i in 1:length(Data$CallOnset)) {
  if(is.na(Data$CallOnset[i])) {
    Data$CallOnset[i] <- as.POSIXct(Data$StartTime[i]) + runif(n = 1, min = 10, max = 539)
  }
}

# create a vector of all recordings
recordings <- tibble(recordingName = unique(Data$FileName))

# now get only lines with howler calls
howler_data <- Data %>% filter(PrimateSpecies == "Howler")
titi_data <- Data %>% filter(PrimateSpecies == "Titi")

# left_join recordings and howler_data to make sure we include recordings with no howlers in data set
howler_data <- left_join(recordings, howler_data, by=c("recordingName"="FileName"))


l <- 3 # test running on individual lines from the dataframe
# in this line, howlers begin calling 290 sec into recording
d <- howler_data[l,]

# seems to work with all atype values... "Broadband", "PowerSpec", "Waveform", "PSD", "TOL"
result <- tonyPAMGuide_Meta(fullfile = paste0(d$recordingName, ".wav"), atype= "Broadband", N = 1024, StartTime=d$StartTime, CallOnset = d$CallOnset, seconds = 60, calib = 1, plottype = "Time")


l <- 4 # test running on individual lines from the dataframe
# in this line, howlers already calling at start of sample
d <- howler_data[l,]

# seems to work with all atype values... "Broadband", "PowerSpec", "Waveform", "PSD", "TOL"
result <- tonyPAMGuide_Meta(fullfile = paste0(d$recordingName, ".wav"), atype= "Broadband", StartTime=d$StartTime, CallOnset = d$CallOnset, seconds = 60, calib = 1, plottype = "Time")


l <- 1 # test running on individual lines from the dataframe
# in this line, no howler calls during sample
d <- howler_data[l,]

# seems to work with all atype values... "Broadband", "PowerSpec", "Waveform", "PSD", "TOL"
result <- tonyPAMGuide_Meta(fullfile = paste0("D:/John_Blake_Data/Harpia 2013/1,400/13 feb 2013", d$recordingName, ".wav"), atype= "Broadband", StartTime=d$StartTime, CallOnset = d$CallOnset, seconds = 60, N = 1024, calib = 1, plottype = "Time")

#Test in folder:
results <- list()
d <- howler_data
for (i in 1:1000){
  # ... choose what data via atype... and set plottype="" to avoid time consuming plotting
  results[[i]] <- tonyPAMGuide_Meta(fullfile = paste0("D:/John_Blake_Data/Harpia 2013/1,400/13 feb 2013/", d[i,]$recordingName, ".wav"), atype= "Broadband", StartTime=d[i,]$StartTime, CallOnset = d[i,]$CallOnset, N = 1024, seconds = 60, calib = 1, stype= "MF", mh=-36, g=0, vADC=1, plottype="None")
}

# this loop will should work if all .wav files are included in the folder...
# results will be a LIST, 1 element for each row in howler_data
# each element is either NA or a matrix of data
# runs FAST without plotting... you will need to decide how to summarize the
# returned data
results <- list()
d <- howler_data
for (i in 1:300){
  # ... choose what data via atype... and set plottype="" to avoid time consuming plotting
  results[[i]] <- tonyPAMGuide_Meta(fullfile = paste0(d[i,]$recordingName, ".wav"), atype= "Broadband", StartTime=d[i,]$StartTime, CallOnset = d[i,]$CallOnset, N = 1024, seconds = 60, calib = 1, stype = "MF", mh = -36, g = 0, vADC = 1, plottype="None")
}
