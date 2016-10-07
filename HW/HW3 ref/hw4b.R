#1. Remove Previous Data
rm(list=ls())

#2. Import dog data
library(sas7bdat)
dat <- read.sas7bdat("C:/Users/ck/Dropbox/Academic Coursework/FS2016/Long/uni_dogs.sas7bdat")

library(ggplot2)
#3. set p object 
p <- ggplot(data = dat, aes(x = time, y = y, group = group))
##4. plot using ggplot2  (a.k.a., scatterplot, mean graph)
p + geom_smooth(aes(group = group, size = 2, method = "lm", se = FALSE) , )
)

library(nlme)
#5. Plot using nlme package
interaction.plot (dat$time, factor(dat$group), dat$y, lty=c(1:3),lwd=2,ylab="mean of Y", xlab="time", trace.label="Group")
