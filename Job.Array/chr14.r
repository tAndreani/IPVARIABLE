rm(list=ls())
setwd("/media/tandrean/Elements/PhD/ChIP-profile/New.Test.Steffen.Data/ChIP.MCF7/CTCF")
library(data.table)
mydata<-fread("chr14.SMARCA4.txt")
mydata.paste <- paste(mydata$V1, mydata$V2, mydata$V3, sep="_")
Id <- mydata.paste
Score <- rowSums(mydata[,4:6])

     
#Detect the reproducible regions
#Open a data.table
df <-data.table(Id=1:length(Id), region.name= Id ,Score=Score, BR=rep(NA,length(Score)),stringsAsFactors=FALSE, key =  "Id")
head(df)
#Run The Algorithm 
BR <- list()
id = 0
tmp <- c()
start = Sys.time()
for (i in df$Id) {
  if (df[i, "Score"] == 0) {
    if (length(tmp) > 0) {
      id <- id + 1
      new_name <- sprintf("BR_%d", id)
      BR[[new_name]] <- tmp
      df[tmp,"BR"]=rep(new_name,length(tmp))
      tmp = c()
    }#Close 2nd if
  }else{ #open 1st if:else
    tmp = c(tmp,i)
  } #Close 1st if
}  #Close for loop
total = Sys.time() - start
print(total)


#Compute the reproducible regions
start = Sys.time()
VR_flag <- 
  sapply (BR,
          function(posList) {
            tmp=df$Score[match(posList, df$Id)]
            if (max(tmp) == 3){
              return(T)
            } else {
              df[posList,"BR"] <<- rep(NA,length(posList))
              return(F)
            }
          }
  )
total = Sys.time() - start
print(total)

#Extract the reproducible and open a dataframe 
VR = BR[VR_flag]
out <- unlist(VR)
out2 <- as.numeric(out)

#Back To the original data frame
df2 <- df[df$Id %in% out2,]
out3 <- strsplit(df2$region.name, "_")
head(out3)
length <- length(out3)
df.Reproducible <- data.frame("chr"=character(length=length),"start"=numeric(length=length),"end"=numeric(length = length))
df.Reproducible$chr <- as.character(df.Reproducible$chr)

#Extract in a dataframe the regions reproducible
for(i in 1:length(out3)){
  df.Reproducible$chr[i] <- out3[[i]][1]
  df.Reproducible$start[i] <- as.numeric(out3[[i]][2])
  df.Reproducible$end[i] <- as.numeric(out3[[i]][3])
}
options(scipen = 999)
write.table(df.Reproducible,"Reproducible.chr14.SMARCA4.Idr.txt",quote=FALSE,col.names = TRUE,row.names = FALSE,sep="\t")
length(Score)





#Compute the non reproducible regions
start = Sys.time()
VR_flag <- 
  sapply (BR,
          function(posList) {
            tmp=df$Score[match(posList, df$Id)]
            if (max(tmp) < 3){
              return(T)
            } else {
              df[posList,"BR"] <<- rep(NA,length(posList))
              return(F)
            }
          }
  )
total = Sys.time() - start


#Extract the non reproducible and open a dataframe 
VR = BR[VR_flag]
out <- unlist(VR)
out2 <- as.numeric(out)

#Back To the original data frame
df2 <- df[df$Id %in% out2,]
out3 <- strsplit(df2$region.name, "_")
head(out3)
length <- length(out3)
df.Not.Reproducible <- data.frame("chr"=character(length=length),"start"=numeric(length=length),"end"=numeric(length = length))
df.Not.Reproducible$chr <- as.character(df.Not.Reproducible$chr)

#Extract in a dataframe the regions not reproducible
for(i in 1:length(out3)){
  df.Not.Reproducible$chr[i] <- out3[[i]][1]
  df.Not.Reproducible$start[i] <- as.numeric(out3[[i]][2])
  df.Not.Reproducible$end[i] <- as.numeric(out3[[i]][3])
}
options(scipen = 999)
write.table(df.Not.Reproducible,"Not.Reproducible.chr14.SMARCA4.Idr.txt",quote=FALSE,col.names = TRUE,row.names = FALSE,sep="\t")



