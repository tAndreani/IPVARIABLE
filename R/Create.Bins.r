#Create an empty data frame for the intersection for hg19
#imoprt the h19 genome
h19 <- read.table("h19.chrom.size.bed",header = T)
h19
#Create the Genome Chunked of 400 bp
res <- data.frame()
for(i in 1:nrow(h19)){
  chr_start <- seq(from=h19$start[i],to=h19$end[i],by=400)
  chr_end <- chr_start+399
  chr <- rep(as.character(h19$chr[i],length(chr_end)))
  chr.complete <- cbind(chr,chr_start,chr_end)
  res <- rbind(res,chr.complete)
}
write.table(res, "h19.binned.400.bp.bed", quote = FALSE, row.names = FALSE, col.names = TRUE, sep = "\t")
