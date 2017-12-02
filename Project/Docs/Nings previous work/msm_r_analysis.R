#Stochastic Process Project
#Asthma Treatment Step Multi State Modeling
#objective: Determine the Association between Treatment step transitions and Baseline Characteristics/Clinical Characteristics
rm(list=ls())
#Step 1: Install Packages/load libraries
install.packages("msm") #for multi state modeling
install.packages("haven") #loading sas 

#Install and load libraries
install.packages("xtable")
install.packages("tidyverse")
install.packages("tableone")
install.packages("knitr")
install.packages("lme4")
install.packages("nlme")
install.packages("arm")
install.packages("RCurl")
install.packages("ReporteRs")
install.packages("magick")
install.packages("flexsurv")
install.packages("mstate")
install.packages("colorspace")

library(msm)
library(haven)
library(tableone)
library(tidyverse)
library(xtable)
library(knitr)
library(pander)
library(lme4)
library(nlme)
library(arm)
library(RCurl)#to directly download the rikz dataset
library(ReporteRs)
library(magick)
library(flexsurv)
library(mstate)
library("colorspace")

#Step 2: Load data
ats1k<-read_sas("C:\\Users\\kimchon\\Downloads\\ats1k.sas7bdat")
atsfull<-read_sas("C:\\Users\\kimchon\\Downloads\\atsfull.sas7bdat")
ats500<-read_sas("C:\\Users\\kimchon\\Downloads\\ats500.sas7bdat")
ats750<-read_sas("C:\\Users\\kimchon\\Downloads\\ats750.sas7bdat")

ats1k$Trt_Step <- ats1k$Trt_Step + 1 #states need to start from 1
ats1k$months <- ats1k$start_date/12 #states need to start from 1
atsfull$Trt_Step <- atsfull$Trt_Step + 1 #states need to start from 1
atsfull$months <- atsfull$start_date/12 #states need to start from 1
ats500$Trt_Step <- ats500$Trt_Step + 1 #states need to start from 1
ats500$months <- ats500$start_date/12 #states need to start from 1
ats750$Trt_Step <- ats750$Trt_Step + 1 #states need to start from 1
ats750$months <- ats750$start_date/12 #states need to start from 1

#Combine treatment steps so that only have 4 states rather than 6

attach(ats1k)
ats1k$states[Trt_Step == 1] <- 1
ats1k$states[Trt_Step == 2] <- 2
ats1k$states[Trt_Step == 3 | Trt_Step == 4 | Trt_Step == 5 | Trt_Step == 6] <- 3
ats1k$age <- ats1k$age + ats1k$years
detach(ats1k)
ats1k$states <- as.integer(ats1k$states)
ats1k$region <- as.factor(ats1k$region)
ats1k$Insurance <- as.factor(ats1k$Insurance)
ats1k$hosp <- as.factor(ats1k$hosp)
ats1k$OP <- as.factor(ats1k$OP)
ats1k$LRTI <- as.factor(ats1k$LRTI)
ats1k$ED <- as.factor(ats1k$ED)
ats1k$gender <- as.factor(ats1k$gender)

#Change to flexsurv datastructure

Q <- rbind(c(1, 1, 1), 
           c(1, 1, 1),
           c(1, 1, 1))

ats1kn <- transform(ats1k,id=as.numeric(factor(pat_id)))

ats1kn.surv<-msm2Surv(data=ats1kn, subject = "id", time= "years", Q = Q, state = "states")


#Using Mstate package to get the data for multistate modeling
tgrid <- seq(0,14, by = 0.1)
tmat <- rbind(c(NA,1,2),
              c(3,NA,4),
              c(5,6,NA))
dimnames(tmat) <- list(from = c(1,2,3), to=c(1,2,3))
covs <- c("gender", "hosp", "ED", "OP", "LRTI", "CCI", "age")
ats1kn.surv <- expand.covs(ats1kn.surv, covs, append=TRUE, longnames = FALSE) #Dummyfying categorical variables



#Table 1. Prognostic factors and patient characteristics
events(ats1kn.surv)

#Figure 1. 3 state transition model


#Figure 2. Transition Probabilities Plot
c0 <- coxph(Surv(Tstart, Tstop, status) ~ strata(trans), data = ats1kn.surv, method = "breslow")
msf0 <- msfit(object = c0, vartype = "greenwood", trans = tmat)
plot(msf0, las = 1, lty = rep(1:2, c(8, 4)), xlab = "Years since Baseline")
pt0 <- probtrans(msf0, predt = 0, method = "greenwood")
summary(pt0, from = 1) #Estimated transition probabilities for each states 


library("colorspace")
statecols <- heat_hcl(6, c = c(80, 30), l = c(30, 90),power = c(1/5, 2))[c(6, 5, 3, 4, 2, 1)]
ord <- c(2, 4, 3, 5, 6, 1)
plot(pt0, ord = c(2,3,1), xlab = "Years since baseline",las = 1, type = "filled", col = statecols[ord])

pt100 <- probtrans(msf0, predt = 100/365.25, method = "greenwood")

#Figure 2a. Transition probabilities starting from different states 
plot(pt100,xlab = "Years since state 1", main = "Starting from state 1",xlim = c(0, 8), las = 1, type = "filled", col = statecols[ord])
plot(pt100, from = 2, xlab = "Years since baseline", main = "Starting from state 2", las = 1, type = "filled", col = statecols[ord])
plot(pt100, from = 3, xlab = "Years since baseline", main = "Starting from state 3", las = 1, type = "filled", col = statecols[ord])



#Table 2. Regression coefficient for the full model with age, gender, ED, OP, LRTI, CCI 
cfull <- coxph(Surv(Tstart, Tstop, status) ~ 
              gender.1 + gender.2 + gender.3 + gender.4 + gender.5 + gender.6 + 
              ED.1 + ED.2 + ED.3 + ED.4 + ED.5 + ED.6 +
              OP.1 + OP.2 + OP.3 + OP.4 + OP.5 + OP.6 + 
              LRTI.1 + LRTI.2 + LRTI.3 + LRTI.4 + LRTI.5 + LRTI.6 +
              CCI.1+CCI.2+CCI.3+CCI.4+CCI.5+CCI.6 + 
              age.1 + age.2+age.3+age.4+age.5+age.6 + strata(trans), data = ats1kn.surv, method = "breslow")


cfull


#Table 3. Prediction on two patients
whA <- which(ats1kn.surv$ED == "0" & ats1kn.surv$gender == "1"  & ats1kn.surv$CCI == 2 & ats1kn.surv$hosp == "0" & ats1kn.surv$OP == "0")
patA <- ats1kn.surv[rep(whA[1], 6), c("ED", "gender", "CCI", "hosp", "OP", "LRTI", "age")]
patA$trans <- 1:6
attr(patA, "trans") <- tmat
patA <- expand.covs(patA, covs, longnames = FALSE)
patA$strata <- patA$trans
msfA <- msfit(cfull, patA, trans = tmat)
ptA <- probtrans(msfA, predt = 0)

plot(ptA,  main = "Patient A",las = 1, xlab = "Years since baseline",
     type = "filled", col = statecols[ord]) #Transitino probabilities starting from state 1 at t=0 semi-parametric model


pt100A <- probtrans(msfA, predt = 100/365.25)# 100 days post baseline
plot(pt100A, from = 3,  main = "Patient A",las = 1, xlab = "Years since transplantation",type = "filled", col = statecols[ord])
#Transition state 3 at t=100



#Using Flexsurv to do parametric multi-state models but difficult to get covariate effects. would be mostly used
#To obtain transition-specific cumulative hazards using THMM(exp), semi-markov(weib), time inhomogeneous (clock forward)


#Fit parametric multi-state models
crexp <- flexsurvreg(Surv(time, status) ~ trans, data = ats1kn.surv, dist = "exp") #THMM
crwei <- flexsurvreg(Surv(time, status) ~ trans + shape(trans), data = ats1kn.surv, dist = "weibull") #THSM
cfwei <- flexsurvreg(Surv(Tstart, Tstop, status) ~ trans + shape(trans), data = ats1kn.surv, dist = "weibull") #TIMM


#Fit semi/non parametric multistate models
crcox <-  coxph(Surv(time, status) ~ strata(trans), data = ats1kn.surv)
cfcox <-  coxph(Surv(Tstart, Tstop, status) ~ strata(trans), data = ats1kn.surv)

AIC(crexp)
AIC(crwei) #weibull has best fit
AIC(cfwei)
-2*crcox$loglik
-2*cfcox$loglik

#obrain cumulative transition specific hazards
tgrid <- seq(0,14, by = 0.1)
tmat <- rbind(c(NA,1,2),
              c(3,NA,4),
              c(5,6,NA))
mrcox <- msfit(crcox, trans = tmat)
mfcox <- msfit(cfcox, trans = tmat)
mrwei <- msfit.flexsurvreg(crwei, t=tgrid, trans=tmat)
mrexp <- msfit.flexsurvreg(crexp, t=tgrid, trans=tmat)
mfwei <- msfit.flexsurvreg(cfwei, t=tgrid, trans=tmat)


#Plot the hazard functions
cols <- c("black", rainbow_hcl(7))
plot(mrcox,  xlab = "Years after baseline", lwd = 3, xlim = c(-3, 7), cols = cols[2:8])
for (i in 1:6) {
  lines(tgrid, mrexp$Haz$Haz[mrexp$Haz$trans == i], col = cols[i], lty = 2, lwd = 2)
  lines(tgrid, mrwei$Haz$Haz[mrwei$Haz$trans == i], col = cols[i], lty = 3, lwd = 2)
}

lines(mfcox$Haz$time[mfcox$Haz$trans == 3], mfcox$Haz$Haz[mfcox$Haz$trans == 3],
      type = "s", col = "Yellow", lty = 1, lwd = 2)
lines(tgrid, mfwei$Haz$Haz[mfwei$Haz$trans == 3], col = "Yellow", lty = 3, lwd = 2)
legend("bottomleft", inset = c(0, 0.2), lwd = 2, col = "Yellow", 
       c("2 -> 3 (clock-forward)"), bty = "n")
legend("bottomleft", inset = c(0, 0.3), c("Non-parametric", "Exponential", "Weibull"),
       lty = c(1, 2, 3), lwd = c(3, 2, 2), bty = "n")


pmatrix.fs(cfwei, t=c(1,2,3,4,5,6,7,8,9,10), trans=tmat) #Time inhomogeneous markov probabilities

#Transition probs for semi-Markov
pmatrix.simfs(crwei, trans = tmat, t=1)
pmatrix.simfs(crwei, trans = tmat, t=2)
pmatrix.simfs(crwei, trans = tmat, t=3)

#Probability of remaining in state 1 at 1 and 3 years
ptc <- probtrans(mfcox, predt = 0, direction = "forward")[[1]]
round(ptc[c(366, 1093),],3)


