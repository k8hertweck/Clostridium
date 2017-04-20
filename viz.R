## data visualization for Clostridium

# load library
library(dplyr)
library(ggplot2)

# read in data
dat <- read.table("ClostridiumStrains.lst", header=FALSE)
