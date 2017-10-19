setwd("/media/tandrean/Elements/PhD/ChIP-profile/New.Test.Steffen.Data/A.Priori/Apriori")

library(plyr)
library(dplyr)


#Rename column headers for ease of use
itemList.proteins <- read.table("master.table.motif.interaction.for.a.Priori.awk.txt")
colnames(itemList.proteins) <- c("itemList")
write.csv(itemList.proteins,"ItemList.proteins.csv", quote = FALSE, row.names = TRUE)
install.packages("arules", dependencies=TRUE)
library(arules)
txn = read.transactions(file="ItemList.proteins.csv", rm.duplicates= TRUE, format="basket",sep=",",cols=1);
txn@itemInfo$labels <- gsub("\"","",txn@itemInfo$labels)
str(txn)
basket_rules <- apriori(txn,parameter = list(sup = 0.01, conf = 0.5,target="rules"));
df_basket <- as(basket_rules,"data.frame")
df_basket
dim(df_basket)
library(arulesViz)
str(basket_rules)
basket_rules
df_basket
plot(basket_rules, method = "grouped", control = list(k = 5))
plot(basket_rules, method="graph", control=list(type="items"))
plot(basket_rules, method="paracoord",  control=list(alpha=.5, reorder=TRUE))
plot(basket_rules,measure=c("support","lift"),shading="confidence",interactive=T)
itemFrequencyPlot(txn, topN = 9,names=TRUE,mai=c(1, 1, 1, 1))
itemFrequencyPlot(txn, topN = 9,names=TRUE,type="absolute",mai=c(1, 1, 1, 1))
write.table(master.table.matrix,"master.table.motif.interaction.csv",row.names=T,col.names = T,quote=F,sep=",")

library(plyr)
df_basket_sorted_decrease <- arrange(df_basket,desc(support))
dim(df_basket_sorted_decrease)
dim(df_itemList)


##Methylation
setwd("/media/tandrean/Elements/PhD/ChIP-profile/New.Test.Steffen.Data/K562.New/Create.Table/WGBS")
library(data.table)
K562.methylome <- fread("GSM2308596_ENCFF721JMB_methylation_state_at_CpG_GRCh38.chr.start.end.cov.major.egual.10.meth.bed")
