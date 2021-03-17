#Setting working directory to folder containing PAMGuide R scripts.
setwd('C:/Users/Silvy/Documents/R/PAMGuide')

#This command loads the PAMGuide function into the workspace, meaning it can now be called from the commans line.
source('PAMGuide.R')

#This opens a window where you can choose the file for analysis.
PAMGuide(calib=1, envi="Air", ctype="MP", mh=-36, g=24, vADC=1/414)
