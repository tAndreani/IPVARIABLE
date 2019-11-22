rm(list=ls())

# generates null sequences (negative set) with matching repeat and GC content
ibrary(gkmSVM)
library(BSgenome.Hsapiens.UCSC.hg19)
library(BSgenome.Hsapiens.UCSC.hg19.masked)
library(gkmSVM)
library(IRanges)

genome=BSgenome.Hsapiens.UCSC.hg19.masked
fileBed="Variable_Regions.bed"
fileFasta="Variable_Regions.fa"
fileNullBed="Variable_Regions_null.bed"
fileNullFasta="Variable_Regions_Null.fa"
genNullSeqs(inputBedFN=fileBed,nMaxTrials=5,xfold=2,genome=genome,outputPosFastaFN=fileFasta,outputBedFN=fileNullBed,outputNegFastaFN=fileNullFasta)



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

