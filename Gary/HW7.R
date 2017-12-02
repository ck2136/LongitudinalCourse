#HW 7 Dr. Grunwald GzLM
install.packages("xtable")
#1. Import Cereal Data
Cereal <- read.csv("C:/Users/ck/Dropbox/Academic Coursework/FS2016/Longitudinal/Gary/Cereal2.csv")
Cereal <- read.csv("C:/Users/kimchon/Downloads/Cereal2.csv")

#2. Cond2 = 1 - Cond 
Cereal$Cond2 <- 1 - Cereal$Cond

#3. Subset data for FamMem=3
Cereal3 <- Cereal[which(Cereal$FamMem==3),]
Cereal3$Cond2 <- as.factor(as.numeric(Cereal3$Cond2))
Cereal3$Sex <- as.factor(as.numeric(Cereal3$Sex))

#Plot data
library(ggplot2)
ggplot(Cereal3, aes(C1, fill = Cond2)) +  geom_histogram(binwidth=.5, position="dodge") + labs(x="Servings of Cereal") + ggtitle("Graph of Cereal Data")

#4. Poisson GzLM
library(xtable)
y.pois <- NULL
y.pois <- glm(Cereal3$C1 ~ factor(Cereal3$Cond2) + factor(Cereal3$Sex) + Cereal3$Wt1, family=poisson(link=log), data=Cereal3)
summary(y.pois)
p<-summary(y.pois)

print(xtable(p),type="html", file="pois1.html")
print(xtable(p),type="html", file="pois1.html")
exp(-0.86454) #Estimation

table(Cereal3$FamMem)
#1b. Estimate deviance parameter, relation between QL SE and from above
summary.glm(y.pois)$dispersion

295.98/95 = 3.115579 #Dispersion parameter by using the deviance method
pchisq(y.pois$deviance, df=y.pois$df.residual, lower.tail=FALSE)
#Chisq test very significant indicating poor fit

mod2 <- glm(Cereal3$C1 ~ Cereal3$Cond2 + Cereal3$Sex + Cereal3$Wt1, family=quasipoisson(link=log), data=Cereal3)
summary(mod2)
summary(mod2)$dispersion
p2 <- summary(mod2)
print(xtable(p2),type="html", file="pois1b.html")

#hW1c Use Normal error in linear predictors
install.packages("lme4")
library(lme4)
mod3 <- glmer(Cereal3$C1 ~ Cereal3$Cond2 + Cereal3$Sex + Cereal3$Wt1 + (1|Cereal3$FamIDNO), family=poisson(link=log), data=Cereal3)
p3<-summary(mod3)
p3$vcov
summary(mod3)
print(xtable(p3$coefficients),type="html", file="pois1c.html")

#hw1d negative binomial
library(MASS)
mod4 <- glm.nb(Cereal3$C1 ~ as.factor(Cereal3$Cond2) + as.factor(Cereal3$Sex) + Cereal3$Wt1, link=log, data=Cereal3)
p4 <- summary(mod4)
summary(mod4)
print(xtable(p4),type="html", file="pois1d.html")
exp(-0.8573)

#q2
#confint.glm
library(MASS)
c1<-xtable(confint(y.pois))
c2<-xtable(confint(mod2))
c3<-xtable(confint(mod3))
c4<-xtable(confint(mod4))

names(c1) <- c('low','up' )
names(c2) <- c('low','up' )
names(c3) <- c('low','up' )
names(c4) <- c('low','up' )
c1$expl <- exp(c1$low)
c1$expu <- exp(c1$up)
c2$expl <- exp(c2$low)
c2$expu <- exp(c2$up)
c3$expl <- exp(c3$low)
c3$expu <- exp(c3$up)
c4$expl <- exp(c4$low)
c4$expu <- exp(c4$up)

c1e<-data.frame(exp(data.frame(summary(y.pois)$coef[,1:2])[,1]))
c1e<-data.frame(summary(y.pois)$coef[,1:2])
c1e$expm<-exp(c1e[,1])

c2e<-data.frame(exp(data.frame(summary(mod2)$coef[,1])[,1]))
c2e<-data.frame(summary(mod2)$coef[,1:2])
c2e$expm<-exp(c2e[,1])

c3e<-data.frame(exp(data.frame(summary(mod3)$coef[,1])[,1]))
c3e<-data.frame(summary(mod3)$coef[,1:2])
c3e$expm<-exp(c3e[,1])

c4e<-data.frame(exp(data.frame(summary(mod4)$coef[,1])[,1]))
c4e<-data.frame(summary(mod4)$coef[,1:2])
c4e$expm<-exp(c4e[,1])

mod1f <- merge(c1e, c1, by="row.names")
mod2f <- merge(c2e, c2, by="row.names")
mod3f <- merge(c3e, c3, by="row.names")
mod4f <- merge(c4e, c4, by="row.names")
