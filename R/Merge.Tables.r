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

master.table.CTCF.POLR2A.KDM1A <- subset(master.table,CTCF == 1 & POLR2A == 1 & KDM1A == 1)
head(master.table.CTCF.POLR2A.KDM1A)
