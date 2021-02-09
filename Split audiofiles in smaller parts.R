# This code will split 60 minute files into 6 equal segments of 10 minutes.
library(seewave)
library(soundecology)
library(tuneR)

setwd('C:/Users/Silvy/Documents/AudioTrials')
wav_list <- dir(pattern="wav") # get a list of all wav files in the working directory.

if(length(wav_list)>0) {
#FROM STACK OVERFLOW:
# your audio file (using example file from seewave package)
data(tico)
audio <- tico
# the frequency of your audio file
freq <- 22050
# the length and duration of your audio file
totlen <- length(audio)
totsec <- totlen/freq

# the duration that you want to chop the file into
seglen <- 0.5

# defining the break points
breaks <- unique(c(seq(0, totsec, seglen), totsec))
index <- 1:(length(breaks)-1)
# a list of all the segments
lapply(index, function(i) audio[(breaks[i]*freq):(breaks[i+1]*freq)])
} 