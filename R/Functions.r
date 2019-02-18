rm(list=ls())

install.packages("data.table")
install.packages("tidyverse")
library(data.table)
library(tidyverse)

###################################################
#Compute Reproducible and not reproducible Regions#
###################################################

#Function 1 
createSumMatrix <- function(mydata){
  Score <- rowSums(mydata[,4:6])
}

#Function 2
createId <- function(mydata){
  mydata.paste <- paste(mydata$V1, mydata$V2, mydata$V3, sep="_")
}

#Function 3
getSignalContaingRegions <- function(score_matrix) {
  
  Id <- createId(mydata)
  
  # Initialize a data.table with aggragted score signal information
  dt_segments <- data.table(Id=1:length(Id), 
                            Segment.name= Id,
                            Score=createSumMatrix(score_matrix), 
                            Region.name=rep(NA_character_,length(Id)), 
                            stringsAsFactors=FALSE, key =  "Id")
  head(dt_segments)
  
  # # Iniilaize list to be filled with info on detected regions 
  # # (i.e. each element of the list will be a set of segements)
  # BR <- vector(mode = "list",
  #              # this is the upper bound = max number of regions with
  #              # length of one segment (preceded/followed by single no-signal segment)
  #              length = nrow(dt_segments)/2
  # )
  # names(BR) <- paste0("BR_", 1:length(BR))
  
  counter <- 0
  set_segments <- c()
  for (id in dt_segments$Id) {
    if (dt_segments[id, "Score"] == 0) {
      nset <- length(set_segments)
      if (nset > 0) {
        # A region is completed, update table
        counter <- counter + 1
        new_name <- sprintf("BR_%d", counter)
        #BR[[new_name]] <-  set_segments
        dt_segments[set_segments,"Region.name"] <- rep(new_name, nset)
        set_segments <- c()
      }#Close 2nd if
      
    }else{ 
      # New region or extend already opened region
      set_segments <- c(set_segments, id)
    } 
  }
  ## Filter NAs from list, so we endup only with signal containg regions
  #BR <- BR[which(lapply(BR, is.null) == FALSE)]
  dt_segments <- na.omit(dt_segments, cols = "Region.name")
  
  return(list(#"aslist" = BR, 
              "astable" = dt_segments))
}

################################################################################
## Main code
################################################################################

#porject_path = "folder where you will save this script and also output results"
porject_path = "../Downloads/"
setwd(porject_path)

data_path <- "../Downloads/"
data_path = getwd()


# 1. Load data 
mydata <- fread(file.path(data_path, "text.txt"))
head(mydata)

# 2. Detect the non-zero scored regions 
start = Sys.time()
regions <- getSignalContaingRegions(score_matrix = mydata)
total = Sys.time() - start
print(total)
#head(regions$aslist) # note; we dont need the list anymore
head(regions$astable)

# 2.Compute the reproducible and non-reprodusible regions
start = Sys.time() 

# i) get the max per region and set the status flag 
regions_sum <- regions$astable %>% 
  group_by(Region.name) %>% 
  summarize(Region.maxScore = max(Score)) %>%
  mutate(Region.status = ifelse(Region.maxScore == 3, 
                                "Reproducible", 
                                "NotReproducible"))

# ii) get each type of region in a separte table and save it into a file
for (status in unique(regions_sum$Region.status)) {
  
  sel_regions <- regions_sum %>% 
    filter(Region.status == status) %>% 
    left_join(regions$astable, by = c("Region.name")) %>%
    separate(Segment.name, into = c("Chr", "Start", "End"), sep = "_") %>%
    # if you do not use these data frames for further analysis then there is no
    # need to convert the columns into numeric - we anyway write them into a file
    mutate(Start = as.numeric(Start), End = as.numeric(End)) %>% 
    select(-Id)
  
  head(sel_regions, n=10) %>% print
  
  
  write.table(sel_regions,
              sprintf("%s_regions.tsv", status),  sep="\t", quote=FALSE, 
              col.names = TRUE, row.names = FALSE)
}

total = Sys.time() - start
print(total)

#################################
#Build Reproducible score matrix#
#################################

#Import the matrix with reproducible and not reproducible regions
df1 <- fread("HCFC1.Reproducible.and.Not.Reproducible.txt.fomatted",header=T)
df2 <- fread("MAFK.Reproducible.and.Not.Reproducible.txt.fomatted",header=T)
df3 <- fread("ZC3H11A.Reproducible.and.Not.Reproducible.txt.fomatted",header=T)
df4 <- fread("ZNF384.Reproducible.and.Not.Reproducible.txt.fomatted",header=T)


ReproducibilityScoreMatrix<- function(df1,df2,df3,df4){
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
  colnames(datm3) <- c("Id","HCF1","MAFK","ZC3H11A","ZNF384")
  head(datm3)
  datm3$sum.observed <- rowSums(datm3[,2:5])
  head(datm3)
}

test <- ReproducibilityScoreMatrix(df1,df2,df3,df4)
head(test)

######################################################################
#Simulate p.value for noisy regions and also for other scoring values#
######################################################################

simulated.pval <- function(n.simulations, cutoff, real.value){
  for (i in 1:n.simulations) {
    random.regions.not.reproducible <- numeric(length = n.simulations)
    df2 <- datm3[,1:5]
    test <- sapply(df2[,2:5],sample)
    test <- as.data.frame(test)
    test$sum.expected <- rowSums(test[,1:4])
    random.regions.not.reproducible[i] <- subset(test, sum.expected == 4)
  }
  mu <- mean(lengths(random.regions.not.reproducible))
  std <- sd(lengths(random.regions.not.reproducible))
  zscore <- (real.value-mu)/std
  pvalue2sided=pnorm(-abs(zscore))
  head(pvalue2sided)
}

hist(lengths(random.regions.not.reproducible), xlim = c(500,700),main = "1000 Permutation distributions with 1 reproducibility score \n p.val=0.0008651502 segment 200 bp mouse ESCs",xlab = "Number of Regions",col=c("cornflowerblue"),cex.lab=1.5, cex.axis=1.5, cex.main=1.5, cex.sub=1.5)
abline(v=real.value,col="red")
