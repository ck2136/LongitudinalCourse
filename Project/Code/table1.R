#Initial Descriptive for Longitudinal Project ATS#

#load libraries#
install.packages("tableone")
install.packages("Hmisc")
install.packages("MASS")
install.packages("psych")
install.packages("gmodels")
install.packages("xtable")

library(tableone)
library(Hmisc)
library(MASS)
library(psych)
library(gmodels)
library(xtable)

#1. load data of the random sample 1k baseline for Table 1#
atsbase <- read.csv("C:/Users/ck/Dropbox/Academic Coursework/FS2016/Longitudinal/Project/Data/rs1k.csv", head=TRUE)
atsbase5k <- read.csv("C:/Users/ck/Dropbox/Academic Coursework/FS2016/Longitudinal/Project/Data/base5k.csv", head=TRUE)
atsbase5k <- read.csv("C:/Users/kimchon/Downloads/base5k.csv", head=TRUE)


#2. Create a variable list which we want in Table 1
#Categorical variables
catVars <- c("der_sex", "pat_region", "Insurance")
#All variables
listVars <- c("age", "der_sex", "pat_region", "Insurance", "baseline_cost", 
              "CCI"
                            )

table15k <- CreateTableOne(vars = listVars, atsbase5k, factorVars = catVars, strata = c("Trt_Step"))

#table1
#Create latex code
tabAsStringMatrix <- print(table1, printToggle = FALSE, noSpaces = TRUE)
tabAsStringMatrix5k <- print(table15k, printToggle = FALSE, noSpaces = TRUE)
xtable(tabAsStringMatrix)
xtable(tabAsStringMatrix5k)
