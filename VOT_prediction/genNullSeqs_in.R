library(BSgenome.Hsapiens.UCSC.hg19.masked)
library(BSgenome.Hsapiens.UCSC.hg19)
library(gkmSVM)
library(IRanges)

args <- commandArgs(trailingOnly = TRUE)

input_bed = args[1]
input_fa = args[2]
output_bed = args[3] # NULL model
output_fa = args[4]  # NULL model

genome=BSgenome.Hsapiens.UCSC.hg19.masked
genNullSeqs(inputBedFN=input_bed,nMaxTrials=10,xfold=5,genome=genome,outputPosFastaFN=input_fa,outputBedFN=output_bed,outputNegFastaFN=output_fa)

