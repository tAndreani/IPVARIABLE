setwd("/media/tandrean/Elements/PhD/ChIP-profile/New.Test.Steffen.Data/A.Priori/Apriori")
df_groceries <- read.csv("Groceri.csv")
df_sorted <- df_groceries[order(df_groceries$Member_number),]
df_sorted$Member_number <- as.numeric(df_sorted$Member_number)
install.packages("plyr", dependencies= TRUE)
install.packages("dplyr",dependencies = TRUE)
library(plyr)
library(dplyr)
if(sessionInfo()['basePkgs']=="dplyr" | sessionInfo()['otherPkgs']=="dplyr"){
  detach(package:dplyr, unload=TRUE)
}
library(plyr)

head(df_sorted)
df_itemList <- ddply(df_groceries,c("Member_number","Date"), function(df1)paste(df1$itemDescription, collapse = ","))
head(df_itemList)
df_itemList$Member_number <- NULL
df_itemList$Date <- NULL

#Rename column headers for ease of use
colnames(df_itemList) <- c("itemList")
write.csv(df_itemList,"ItemList.csv", quote = FALSE, row.names = TRUE)
install.packages("arules", dependencies=TRUE)
library(arules)
txn = read.transactions(file="ItemList.csv", rm.duplicates= TRUE, format="basket",sep=",",cols=1);
txn@itemInfo$labels <- gsub("\"","",txn@itemInfo$labels)
basket_rules <- apriori(txn,parameter = list(sup = 0.001, conf = 0.2,target="rules"));
df_basket <- as(basket_rules,"data.frame")
head(df_basket)
library(arulesViz)
plot(basket_rules)
plot(basket_rules, method = "grouped", control = list(k = 5))
plot(basket_rules, method="graph", control=list(type="items"))
plot(basket_rules, method="paracoord",  control=list(alpha=.5, reorder=TRUE))
plot(basket_rules,measure=c("support","lift"),shading="confidence",interactive=T)
itemFrequencyPlot(txn, topN = 5)
write.table(master.table.matrix,"master.table.motif.interaction.csv",row.names=T,col.names = T,quote=F,sep=",")


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
head(df_basket)
dim(df_basket)
library(arulesViz)
str(basket_rules)
plot(basket_rules)
plot(basket_rules, method = "grouped", control = list(k = 5))
plot(basket_rules, method="graph", control=list(type="items"))
plot(basket_rules, method="paracoord",  control=list(alpha=.5, reorder=TRUE))
plot(basket_rules,measure=c("support","lift"),shading="confidence",interactive=T)
itemFrequencyPlot(txn, topN = 5)
write.table(master.table.matrix,"master.table.motif.interaction.csv",row.names=T,col.names = T,quote=F,sep=",")

library(plyr)
df_basket_sorted_decrease <- arrange(df_basket,desc(support))
dim(df_basket_sorted_decrease)

