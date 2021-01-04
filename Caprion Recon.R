library(readxl)
library(haven)
library(dplyr)
library(tidyverse)
library(writexl)
library(plyr)


setwd("C:/Users/JordanMyer/Desktop/New OneDrive/Emanate Life Sciences/DM - Alector - Documents/AL003/AL003-1/6. Data/7. Inputs")
source("../../../../Global AL Functions/AL_Global_Functions.R")
cleaner()
source("../../../../Global AL Functions/AL_Global_Functions.R")

#Imports
#MostRecentFile("Caprion/",".*CAPRION_UAD_MRM_PROD.*csv$","ctime")
importCaprion <-read.csv(MostRecentFile("Caprion/",".*CAPRION_UAD_MRM_PROD.*csv$","ctime"))
lumbarImport <- read_sas("EDC/prlp.sas7bdat", NULL)

#Trim and Rename Cols. 

#We want to keep Subject Number, Date, Visit Name

trimCaprion <- importCaprion %>% 
  select(c("SUBJID","VISITID","Sample.Collection.Date")) %>% 
  set_names(c("Subject","Visit","Caprion_Date")) %>% 
  filter(Visit!=""&!is.na(Caprion_Date))

trimEDC <- lumbarImport %>% 
  select(c("Subject","Folder","PRDAT")) %>% 
  set_names(c("Subject","Visit","EDC_Date")) %>% 
  filter(substring(Subject,1,1)!="3")

unique(trimEDC$Subject)

#Get Subject Numbers in same format. Already done. No need for further changes

#Get Date in the same format. Transfer is in 01JAN2020, EDC is 2020-01-01. When reformatting, use base R
# The code will be as.Date(dateColName,format = " Some format using %'s' look this up on google)

trimCaprion <- trimCaprion %>% 
  mutate(Caprion_Date = as.Date(Caprion_Date,format = "%d%b%Y"))

#Get same visit names. Use unique to see what values the files have

unique(trimCaprion$Visit)
unique(trimEDC$Visit)

trimEDC$Visit <- recode(trimEDC$Visit,"SCREEN"="Screening","DAY18"="Day 18","DAY8P1"="Day 8")

fj <- full_join(trimEDC,trimCaprion)

mismatchDates <- fj %>% 
  filter(EDC_Date!=Caprion_Date)

missingData <- fj %>% 
  filter(is.na(Caprion_Date)|is.na(EDC_Date)) %>% 
  filter(!(is.na(EDC_Date)&is.na(Caprion_Date)))





