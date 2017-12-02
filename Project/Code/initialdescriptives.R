#Longitudinal Project Initial Description
#Objective: Create Table 1 and Initial Distribution Graphic

#Load Libraries necessary
install.packages("ggplot2")
install.packages("GGally")
install.packages("reshape2")
install.packages("lme4")
install.packages("compiler")
install.packages("parallel")
install.packages("boot")
install.packages("sjPlot")
install.packages("sjmisc")
install.packages("languageR")

library(ggplot2)
library(GGally)
library(reshape2)
library(lme4)
library(compiler)
library(parallel)
library(boot)
library(sjPlot)
library(sjmisc)
library(languageR)
library(dplyr)

#Load data
ats5k  <- read.csv("C:/Users/ck/Dropbox/Academic Coursework/FS2016/Longitudinal/Project/Data/ats5k.csv", header=TRUE)
ats5k <- read.csv("C:/Users/kimchon/Downloads/ats5k.csv",, stringsAsFactors=T)
ats5k$eventb=ifelse(ats5k$Event <1, 0, 1)
ats5k$Event <- as.factor(as.numeric(ats5k$Event))
ats5k$eventb <- as.factor(as.numeric(ats5k$eventb))
ats5k$Trt_Step <- as.factor(as.numeric(ats5k$Trt_Step))
ats5k$Replicate <- NULL

#Objective 1: Make Table 1

ggpairs(ats5k[ , c("age","baseline_cost","CCI","time")])

ggplot(ats5k, aes(x = Trt_Step, y = eventb)) +
  stat_sum(aes(size = ..n.., group = 1)) +
  scale_size_area(max_size=10)

tmp1 <- melt(ats5k[, c("Trt_Step", "age", "baseline_cost", "CCI", "gender","Insurance")],
            id.vars="Trt_Step")
tmp <- melt(ats5k[, c("eventb", "age", "baseline_cost", "CCI", "gender","Insurance")],
            id.vars="eventb")
ggplot(tmp, aes(factor(eventb), y = value, fill=factor(eventb))) +
  geom_boxplot() +
  facet_wrap(~variable, scales="free_y")

ggplot(tmp1, aes(factor(Trt_Step), y = value, fill=factor(Trt_Step))) +
  geom_boxplot() +
  facet_wrap(~variable, scales="free_y")

#New Approach subsetting data

t0<-subset(ats,ats$Trt_Step==0)
t1<-subset(ats,ats$Trt_Step==1)
t2<-subset(ats,ats$Trt_Step==2)
t3<-subset(ats,ats$Trt_Step==3)
t4<-subset(ats,ats$Trt_Step==4)
t5<-subset(ats,ats$Trt_Step==5)

m0<-glmer(eventb~time+(1|pat_id),data=t0,
            family=binomial(link="logit"))
m1<-glmer(eventb~time+(1|pat_id),data=t1,
          family=binomial(link="logit"))
m2<-glmer(eventb~time+(1|pat_id),data=t2,
          family=binomial(link="logit"))
m3<-glmer(eventb~time+(1|pat_id),data=t3,
          family=binomial(link="logit"))
m4<-glmer(eventb~time+(1|pat_id),data=t4,
          family=binomial(link="logit"))
m5<-glmer(eventb~time+(1|pat_id),data=t5,
          family=binomial(link="logit"))

plotLMER.fnc(m0,ylimit=0:1,lockYlim=TRUE,linecolor="red",
             lwd=4,xlabel="Time (days)",
             ylabel="Probability of Event")

par(new=TRUE)

plotLMER.fnc(m1,ylimit=0:1,lockYlim=TRUE,linecolor="blue",
             lwd=4,xlabel="Time (days)",
             ylabel="Probability of Event")
par(new=TRUE)

plotLMER.fnc(m2,ylimit=0:1,lockYlim=TRUE,linecolor="green",
             lwd=4,xlabel="Time (days)",
             ylabel="Probability of Event")
par(new=TRUE)
plotLMER.fnc(m3,ylimit=0:1,lockYlim=TRUE,linecolor="yellow",
             lwd=4,xlabel="Time (days)",
             ylabel="Probability of Event")

par(new=TRUE)
plotLMER.fnc(m4,ylimit=0:1,lockYlim=TRUE,linecolor="orange",
             lwd=4,xlabel="Time (days)",
             ylabel="Probability of Event")

par(new=TRUE)
plotLMER.fnc(m5,ylimit=0:1,lockYlim=TRUE,linecolor="cyan",
             lwd=4,xlabel="Time (days)",
             ylabel="Probability of Event")

legend("topright", c("Step0","Step1","Step2","Step3","Step4","Step5"), pch=15,
       col=c("red","blue","green","yellow","orange","cyan"),title="Treatment Steps")