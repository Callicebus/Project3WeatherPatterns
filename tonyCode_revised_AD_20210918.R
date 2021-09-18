library(tidyverse)
library(lubridate)
library(tuneR)
library(dplyr)

Data <- read_csv("https://raw.githubusercontent.com/Callicebus/Project3WeatherPatterns/main/Project3_DataSheet_20210916.csv", col_names = TRUE)

#setwd('C:/Users/Silvy/Documents/R/Repos/Project3WeatherPatterns')
#Data <- read_csv("Project3_DataSheet_20210916.csv", col_names = TRUE)

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

# now get only lines with howler calls. I don't actually think we need this part as I need SPLs for titis, howlers and files without primates.
#howler_data <- Data %>% filter(PrimateSpecies == "Howler")
#titi_data <- Data %>% filter(PrimateSpecies == "Titi")

# left_join recordings and howler_data to make sure we include recordings with no howlers in data set
#howler_data <- left_join(recordings, howler_data, by=c("recordingName"="FileName"))


l <- 53 # test running on individual lines from the dataframe
# in this line, howlers begin calling 290 sec into recording
d <- Data[l,]

# seems to work with all atype values... "Broadband", "PowerSpec", "Waveform", "PSD", "TOL"
result <- tonyPAMGuide_Meta(fullfile = paste0("D:/John_Blake_Data/Harpia 2013/1,400/13 feb 2013/", d$FileName, ".wav"), atype= "Broadband", StartTime=d$StartTime, CallOnset = d$CallOnset, seconds = 60, calib = 1, plottype = "Both", lcut= 200, hcut= 2000, stype= "MF", mh=-36, g=0, vADC=1)

l <- 52 # test running on individual lines from the dataframe
# in this line, howlers already calling at start of sample
d <- Data[l,]

# seems to work with all atype values... "Broadband", "PowerSpec", "Waveform", "PSD", "TOL"
result <- tonyPAMGuide_Meta(fullfile = paste0("D:/John_Blake_Data/Harpia 2013/1,400/13 feb 2013/", d$FileName, ".wav"), atype= "Broadband", StartTime=d$StartTime, CallOnset = d$CallOnset, seconds = 60, calib = 1, plottype = "Both", lcut= 200, hcut= 2000, stype= "MF", mh=-36, g=0, vADC=1)


l <- 51 # test running on individual lines from the dataframe
# in this line, no howler calls during sample
d <- Data[l,]

# seems to work with all atype values... "Broadband", "PowerSpec", "Waveform", "PSD", "TOL"
result <- tonyPAMGuide_Meta(fullfile = paste0("D:/John_Blake_Data/Harpia 2013/1,400/13 feb 2013/", d$FileName, ".wav"), atype= "Broadband", StartTime=d$StartTime, CallOnset = d$CallOnset, seconds = 60, calib = 1, plottype = "Both", lcut= 200, hcut= 2000, stype= "MF", mh=-36, g=0, vADC=1)

# this loop will should work if all .wav files are included in the folder...
# results will be a LIST, 1 element for each row in howler_data
# each element is either NA or a matrix of data
# runs FAST without plotting... you will need to decide how to summarize the
# returned data

results <- list()
d <- Data[51:62,]
#for (i in 1:3){
  # ... choose what data via atype... and set plottype="" to avoid time consuming plotting
  #results[[i]] <- tonyPAMGuide_Meta(fullfile = paste0(d[i,]$recordingName, ".wav"), atype= "Broadband", StartTime=d[i,]$StartTime, CallOnset = d[i,]$CallOnset, seconds = 60, lcut = 300, hcut = 2000, calib = 1, plottype="Stats")
  #}

d<- d %>% rowwise() %>% mutate(RMS = tonyPAMGuide_Meta(fullfile = paste0("D:/John_Blake_Data/Harpia 2013/1,400/13 feb 2013/", d[1,]$FileName, ".wav"), atype= "Broadband", StartTime=StartTime, CallOnset=CallOnset, seconds= 60, lcut= 200, hcut= 2000, calib= 1, stype= "MF", mh=-36, g=0, vADC=1, plottype= "Stats"))


