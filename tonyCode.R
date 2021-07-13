library(tidyverse)
library(lubridate)
library(tuneR)

Data <- read_csv("https://raw.githubusercontent.com/Callicebus/Project3WeatherPatterns/main/Project3_Final_Data_per_Recording.csv", col_names = TRUE)
#Data <- read_csv("Project3_Final_Data_per_Recording_Updated.csv", col_names = TRUE)
#setwd('C:/Users/Silvy/Documents/R/Repos/Project3WeatherPatterns')
source("tonyPAMGuide_Meta.R")

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
#titi_data <- Data %>% filter(PrimateSpecies == "Titi")

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
result <- tonyPAMGuide_Meta(fullfile = paste0(d$recordingName, ".wav"), atype= "Broadband", StartTime=d$StartTime, CallOnset = d$CallOnset, seconds = 60, N = 1024, calib = 1, plottype = "Time")



# this loop will should work if all .wav files are included in the folder...
# results will be a LIST, 1 element for each row in howler_data
# each element is either NA or a matrix of data
# runs FAST without plotting... you will need to decide how to summarize the
# returned data
results <- list()
d <- howler_data
for (i in 1:3){
  # ... choose what data via atype... and set plottype="" to avoid time consuming plotting
  results[[i]] <- tonyPAMGuide_Meta(fullfile = paste0(d[i,]$recordingName, ".wav"), atype= "Broadband", StartTime=d[i,]$StartTime, CallOnset = d[i,]$CallOnset, N = 1024, seconds = 60, calib = 1, stype = "MF", mh = -36, g = 0, vADC = 1, plottype="None")
}

#Same code as above, but test in folder on external drive:
results <- list()
d <- howler_data
for (i in 1:1000){
  # ... choose what data via atype... and set plottype="" to avoid time consuming plotting
  results[[i]] <- tonyPAMGuide_Meta(fullfile = paste0("D:/John_Blake_Data/Harpia 2013/1,400/13 feb 2013/", d[i,]$recordingName, ".wav"), atype= "Broadband", StartTime=d[i,]$StartTime, CallOnset = d[i,]$CallOnset, N = 1024, seconds = 60, calib = 1, stype= "MF", mh=-36, g=0, vADC=1, plottype="None")
}




#TEST. 
#Can we circumvent further trouble with all the PAM scripts by averaging the 'result' variable?
#First I take an original audio file and add it to .csv file as test case. I'm going to determine mean SPL of the 2:30 to 3:30 min in this file.
Data <- read_csv("https://raw.githubusercontent.com/Callicebus/Project3WeatherPatterns/main/Project3_Final_Data_per_Recording_Updated.csv", col_names = TRUE)

#You can see this file as the first line of data with 'TEST' as Analyst. Run the normal script:
Data$StartTime <- str_split_fixed(Data$FileName, "_",3)[,3] #Pull the start time of the recording out of the file name.
Data$StartTime <- parse_date_time(Data$StartTime, "HMS")
Data$CallOnset <- parse_date_time(Data$CallOnset, "HMS")
Data$TimeDiff <- difftime(Data$CallOnset, Data$StartTime, units="secs")

Data <- Data %>% group_by(FileName)
Data$CallEnd <- Data$CallOnset + Data$CallDuration
Data$CallingAtStart <- if_else(Data$CallOnset==Data$StartTime, TRUE, FALSE)
Data$CallingAtEnd <- if_else(Data$CallEnd==Data$StartTime +minutes(10), TRUE, FALSE)

for(i in 1:length(Data$CallOnset)) {
  if(is.na(Data$CallOnset[i])) {
    Data$CallOnset[i] <- as.POSIXct(Data$StartTime[i]) + runif(n = 1, min = 10, max = 539)
  }
}

recordings <- tibble(recordingName = unique(Data$FileName))
howler_data <- Data %>% filter(PrimateSpecies == "Howler")
howler_data <- left_join(recordings, howler_data, by=c("recordingName"="FileName"))

l <- 1
d <- howler_data[l,]

result <- tonyPAMGuide_Meta(fullfile = paste0(d$recordingName, ".wav"), atype= "Broadband", StartTime=d$StartTime, CallOnset = d$CallOnset, seconds = 60, N = 1024, calib = 1, plottype = "None")
average_results <- mean(result[,2])

#average_result gives me a value of 96.3 dB.

#I cut this 60-sec section (from 2:30 to 3:30 in ths file) out of the file and will run it with the PAMGuide.R function. 
#The file you need to load in once the pop-up opens is called 'HARPIA_20130212_090000-test-0230', which can be found on my GitHub page.
source('PAMGuide.R')
PAMGuide(calib=1, envi="Air", atype = "Broadband", N = 1024, plottype = "None")

#The output in the console gives a value of 94.5 dB as mean SPL value. This is about 2 dB different from the earlier calculations, I'm not certain why this is the case. 
