###
#BIOS 6643 Longitudinal Data Analysis HW#1
###

#D.Simplest longitudinal analysis 
rm(list=ls()) # get rid of any existing data 
#import data from txt file
choldata <- read.table("C:/Users/ck/OneDrive - The University of Colorado Denver/FS2016/BIOS 6643 Long/cholesterol.txt")
#changes names of column to pre and post FEV
colnames(choldata) [1:2] <- c("preCHOL","postCHOL")
#make difference variable
choldata$d <- choldata$postCHOL - choldata$preCHOL
attach(choldata)
#linear regression (equal varaince) or paired t-test
t.test(preCHOL,postCHOL,paired=TRUE) #this would be a linear regression framework
wilcox.test(preCHOL,postCHOL,paired=TRUE) #dependent 2-group wilcoxon signed rank test
#The GLM model that fits the data with only the intercept
glm(d ~ 1, family=gaussian(link = "identity"), choldata)
plot(glm(d ~ 1, family=gaussian(link = "identity"), choldata))


#baseline as covariate
lmbac <- lm(postCHOL ~ preCHOL)
summary(lmbac)
plot(lmbac)


#Hybrid Model
lmhyb <- lm(d ~ preCHOL)
summary(lmhyb)
