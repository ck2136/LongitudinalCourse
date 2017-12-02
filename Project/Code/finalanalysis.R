################################################
#Analysis of Longitudinal Treatment Step Asthma#
################################################

##########################################################################
#Objective: Association between Treatment step and patient characteristic#
##########################################################################

####################################################
#Modeling Framework: Generalized Linear Mixed Model#
#Cumulative Link Mixed Model for Ordinal Response  #
####################################################

#############
#Data: ats.R#
#############

###########
#libraries#
###########
#install.packages("ordinal")
#install.packages("glmm")
install.packages("sjPlot")
install.packages("arm")
library(arm)
library(sjPlot)
library(sjmisc)
library(lme4)
library(ordinal)
library(sas7bdat)
#Load data
ats5k  <- read.csv("C:/Users/ck/Dropbox/Academic Coursework/FS2016/Longitudinal/Project/Data/ats5k.csv", header=TRUE)
ats5k <- read.csv("C:/Users/kimchon/Downloads/ats5k.csv", head=TRUE)



#H2 fit model
fit <- glmer(eventb ~ year + (year | pat_id), ats5k, family = binomial("logit"))
fit2 <- glmer(eventb ~ year + Trt_Step + year*Trt_Step + age + gender + CCI + Insurance + (year | pat_id), ats5k, family = binomial("logit"))
ptm <- proc.time()
fit3 <- glmer(eventb ~ year + year*year + year*year*year + Trt_Step + year*Trt_Step + age + gender + CCI + Insurance + (1 + year | pat_id)
              , ats5k, family = binomial("logit"), 
              control = glmerControl(calc.derivs = FALSE)) 
proc.time() - ptm

sjp.glmer(fit, y.offset = .4)
sjp.glmer(fit2, type = "eff", show.ci = TRUE)


sjp.glmer(fit2, type = "pred", 
          vars = c("year", "Trt_Step"),
          facet.grid = F)

#Diagnostics
#Fixed effect correlation matrix
sjp.glmer(fit2, type = "fe.cor")


#Predicted Probability curve with CI
sjp.glmer(fit2, type = "re.qq")

#Create oddstable for hypothesis 1
ot <- read.table("C:/Users/ck/Dropbox/Academic Coursework/FS2016/Longitudinal/Project/Report/Model/12.2.2016/oddscalculation.csv", header=TRUE, sep=",")
xtable(ot)
