rm(list=ls())

install.packages("data.table")
install.packages("tidyverse")
library(data.table)
library(tidyverse)

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
