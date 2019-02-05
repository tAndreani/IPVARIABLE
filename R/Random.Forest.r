rm(list=ls())

library(randomForest)
library(MASS)
library(ggplot2)
library(dplyr)
library(caTools)
citation('randomForest')
getwd()
setwd("D:/PhD/ChIP.Update.Experiments/Prediction.Noisy.mESCs/mapping/tables")
master <- read.table("columns/Definitive.Table.for.Prediction.Noisy.regions.and.ID.txt",header=T)
dim(master)
master <- master[,c(-1)]
master[,1] <- as.factor(master[,1])
str(master)
head(master)

master <- master[,c(-30)]
str(master)




set.seed(123009)

#Create Train Data
ind <- sample.split(Y = master$Noisy, SplitRatio = 0.7)
trainDF <- master[ind,]
testDF <- master[!ind,]
str(master)

#Fitting the model
#modelRandom <- randomForest(Noisy~.,   data=trainDF)
modelRandom <- randomForest(Noisy~.,   data=trainDF,   mtry=2,   ntree=100)
head(modelRandom)
importance(modelRandom)
varImpPlot(modelRandom)

###Predictions
PredictionsWithClass <- predict(modelRandom, testDF, type='class')
t <- table(prediction=PredictionsWithClass, act=testDF$Noisy)
t
sum(diag(t))/sum(t)


##Plot ROC curve and calculating AUC metric
library(pROC)
PredictionsWithProbs <- predict(modelRandom, testDF, type = 'prob')
head(PredictionsWithClass)
head(modelRandom$predicted)
dim(testDF)
auc <- auc(testDF$Noisy, PredictionsWithProbs [,1])
auc

plot(roc(testDF$Noisy, PredictionsWithProbs [,1]),main="ROC curve on Real Dataset for NOISY regions in mESC, Value=0.8217")


#Find the bast mtry
bestmtry <- tuneRF(trainDF, trainDF$Noisy, ntreeTry = 200, stepFactor = 1.2, improve = 0.01, trace = T, plot = T)
bestmtry




###########################
###AT and CG composition###
###########################

setwd("/media/tandrean/Elements/PhD/ChIP.Update.Experiments/Prediction.Noisy.mESCs/CG.contents")
noisy <- read.table("Noisy.mm10.mESC.bed.for.Nuc.CG.and.AT",header = F)
control <- read.table("Noisy.mm10.control.mESC.bed.for.Nuc.CG.and.AT",header = F)


noisy$AT <- noisy$V4
control$AT <- control$V4
t.test(noisy$AT,control$AT)

noisy$condition <- 'noisy'
control$condition <- 'control'
head(noisy)
head(control)
definitive.AT <- rbind(noisy[,13:14], control[,13:14])
ggplot(definitive.AT, aes(AT, fill = condition)) + geom_density(alpha = 0.4) + xlim(0,1)+
  ggtitle("AT Percentage in the Noisy regions and Control regions in mESC \n p-value = 8.45e-08 ") +
  theme(plot.title = element_text(hjust = 0.5))

noisy$CG <- noisy$V5
control$CG <- control$V5
str(t.test(noisy$CG,control$CG))

noisy$condition <- 'noisy'
control$condition <- 'control'
head(noisy)
definitive.CG <- rbind(noisy[,15:14], control[,15:14])
ggplot(definitive.CG, aes(CG, fill = condition)) + geom_density(alpha = 0.4) + xlim(0,1) +
  ggtitle("CG Percentage in the Noisy regions and random control regions in mESC \n p-value = 2.51e-20 ") +
  theme(plot.title = element_text(hjust = 0.5))


