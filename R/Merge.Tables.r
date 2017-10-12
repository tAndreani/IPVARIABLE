#Merge Tables
setwd("/media/tandrean/Elements/PhD/ChIP-profile/New.Test.Steffen.Data/K562.New/Create.Table/")
rm(list=ls())

library(data.table)
library(plyr)


df1 <- fread("Reproducible.CTCF.and.vector.bed.sort.bed.formatted.txt",header=T)
df2 <- fread("Reproducible.EGR1.and.vector.bed.sort.bed.formatted.txt",header=T)
df3 <- fread("Reproducible.HDAC2.and.vector.bed.sort.bed.formatted.txt",header=T)
df4 <- fread("Reproducible.KDM1A.and.vector.bed.sort.bed.formatted.txt",header=T)
df5 <- fread("Reproducible.MNT.and.vector.bed.sort.bed.formatted.txt", header=T)
df6 <- fread("Reproducible.NCOR1.and.vector.bed.sort.bed.formatted.txt",header=T)
df7 <- fread("Reproducible.POLR2A.and.vector.bed.sort.bed.formatted.txt",header=T)
df8 <- fread("Reproducible.RNF2.and.vector.bed.sort.bed.formatted.txt",header=T)
df9 <- fread("Reproducible.SMARCA4.and.vector.bed.sort.bed.formatted.txt",header=T)


master.table <- Reduce(function(x, y) merge(x, y, all=TRUE), list(df1, df2, df3, df4, df5, df6, df7, df8, df9))
colnames(master.table) <- c("Id","CTCF","EGR1","HDAC2","KDM1A","MNT","NCOR1","POLR2A","RNF2","SMARCA4")
master.table[is.na(master.table)] <- 0
master.table.matrix <- as.matrix(master.table[,2:10])
head(master.table)

master.table$sum <- rowSums(master.table[,2:10])
cor.test(master.table$MNT,master.table$CTCF)
hist(master.table$sum,xlim = c(1,9),main="Interacting Partner Histrogram",xlab = "Number of Proteins sharing a 400 bin", ylab = "Number of Bins")


prot <- t(master.table.matrix)%*%master.table.matrix
diag(prot) <- 0
prot.scale <- scale(prot)
head(prot.scale)

library(gplots)
heatmap.2(prot.scale,main = "Protein Bins Interactions",margins = c(5,5),reorderfun = function(d, w) reorder(d, w))

set.seed(1)
n <- 10
replace=TRUE
vec <- sample(master.table.matrix, replace=replace)
dim(master.table.matrix)
dim(vec) <- c(230826,9)
colnames(vec) <- c("CTCF","EGR1","HDAC2","KDM1A","MNT","NCOR1","POLR2A","RNF2","SMARCA4")
prot.samples <- t(vec)%*%vec
diag(prot.samples) <- 0
prot.samples.scale <- scale(prot.samples)
head(prot.samples.scale)
heatmap.2(prot.samples.scale,main = "Protein Bins Interactions Sampled",margins = c(5,5),reorderfun = function(d, w) reorder(d, w))

