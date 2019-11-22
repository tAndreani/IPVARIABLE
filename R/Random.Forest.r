rm(list=ls())

# generates null sequences (negative set) with matching repeat and GC content
library(gkmSVM)
library(BSgenome.Mmusculus.UCSC.hg19.masked)
genNullSeqs('variable_regions.bed', outputBedFN = 'variable_regions_negSet.bed', outputPosFastaFN = 'variable_regions__posSet.fa',outputNegFastaFN = 'variable_regions_negSet.fa' , genome = BSgenome.Mmusculus.UCSC.hg19.masked);





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

