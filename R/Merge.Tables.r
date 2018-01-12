rm(list=ls())
setwd("/media/tandrean/Elements/PhD/ChIP-reprod.LastTry/All.Table.Master.Chr1")
rm(list=ls())

library(data.table)
library(plyr)



df1 <- fread("Reproducible.and.Not.MNT.txt.new.format",header=T)
df2 <- fread("Reproducible.and.Not.NCOR1.txt.new.format",header=T)
df3 <- fread("Reproducible.and.Not.Polr2A.txt.new.format",header=T)
df4 <- fread("Reproducible.and.Not.SMARCA.txt.new.format",header=T)

setkeyv(df1, c('Id'))
setkeyv(df2, c('Id'))
setkeyv(df3, c('Id'))
setkeyv(df4, c('Id'))

datA<- as.data.frame(df1)
datB<- as.data.frame(df2)
datC<- as.data.frame(df3)
datD<- as.data.frame(df4)

datm<- merge(df1, df2)
datm2<- merge(datm, df3)
datm3<- merge(datm2, df4)


colnames(datm3) <- c("Id","MNT","NCOR1","POLR2A","SMARCA")
datm3$sum.observed <- rowSums(datm3[,2:5])
write.table(datm3, "definitive.table.Reproducible.and.not.All.Proteins.txt",row.names=F,col.names = T,sep="\t",quote=F)
