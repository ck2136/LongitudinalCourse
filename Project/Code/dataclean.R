#Longitudinal Analysis Project: Asthma Treatment Step

#Data Visualization

#1. Import CSV
ats  <- read.csv("C:/Users/ck/Dropbox/Academic Coursework/FS2016/Longitudinal/Project Dataset/ats.csv", header=TRUE)

#2. Missing Data Check
library(mice)
library(VIM)

md.pattern(ats)
#5 Missing values in number
pdf("C:/Users/ck/Dropbox/Academic Coursework/FS2016/Longitudinal/Project/Docs/missing.pdf")
aggr(ats, prop = F, numbers = T)
dev.off()

#Event as categorical
ats$Event <- as.factor(as.numeric(ats$Event))
ats$Trt_Step <- as.factor(as.numeric(ats$Trt_Step))
ats$region <- as.factor(as.numeric(ats$region))
ats$season_index <- as.factor(as.numeric(ats$season_index))
ats$gender <- as.factor(as.numeric(ats$gender))

#Graphic Individiual

