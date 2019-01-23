# IPNOISY: a method to estimate noisy transcription factor binding sites from replicated experiments 
IPNOISY is a method capable to detect noisy DNA binding regions of several transcription factors in a given cell type. It takes in input ChIP-seq peaks and outputs the noisy ones that tend to be not reproducible. It can be useful to use this tool in case a wet lab has obtained peaks from ChIP-seq expriments and wants to know their reliability before downstream interpretative analysis and/or experimental follow up.


# Motivation
ChIP-seq is a standard technology in wet laboratories because it allows to map the genomic regions in which a protein or transcription factor is binding the DNA. Regulatory genomics labs have extensively used this technique to describe how, where and which gene is under the control of a transcription factor. However, the extent of the reproducibility of the binding sites can be confounded by several factors, such as the genomic location in which the transcription factor binds, DNA structures present at the moment of the immunoprecipitation, quality of the antibody as also the experimental conditions in cell culture (1,2,3,4). For this we have developed IPNOISY, a method that can report noisy transcription factors binding sites from ChIP-seq data. Here the workflow:  

![workflow2](https://user-images.githubusercontent.com/6462162/46674868-80910a00-cbdd-11e8-950b-30cd51a87cff.png)


###### Fig. 1) In the workflow: ENCODE experiments are selected according to standard parameters, peaks are mapped to genomic segments of a defined window size and a sliding window is used to compute a reproducibility score. Regions with a specific score are tested for significance and enriched with gene regulatory features. 

# Experimental Design: define suitable set of experiments from ENCODE project
We selected ENCODE experiments for four different proteins according to the following standard criteria:  
1) from the same cell line  
2) from the same lab (Snyder)  
3) quality check filter passed (green color)  
4) processed with the same bioinformatics ENCODE pipeline  
5) statistical test performed as Irreproducibility Discovery Rate (IDR)  
6) peaks significant at 5% FDR  

Here we select experiments of 4 proteins and each one with 3 replicates from cell line K562 in the Human Genome annotation hg19, example call:  
`python get_list.py K562 3 4 hg19`  

Here we select experiments of 4 proteins and each one with 3 replicates from cell line HepG2 in the Human Genome annotation hg19 example call:  
 `python get_list.py HepG2 3 4 hg19`  

# Extraction of the experiments, download the files and assign the peaks to genomic segments
The output of the python script is a table with the information of the experiments. We create the folder for each protein and download the files associated in the table. After we create for each protein the matrix with assigned peaks for every genomic segment. Segments can be of 200 or 400 bp length depending on the user choice. 

Segmentation of the genome is performed with this R script:  

` Rstudio Create.Bins.r ` 

Assignment of the peaks to genomics bins is performed with this bash script:  

`bash ./Create.Matrix.sh`  

# Identification of reproducible and not reproducible regions 
After the identification of suitable experiments, we binned the genome is segments of 200 base pairs (bp) and assigned the peaks obtained in the .bed format to them. We formalized the assignment of the peak for a given genomic segment as follow:

```
Let n be the number of replicates for a given protein;
     Let s be the segments for a genome;
         Let p be the signal detected in the genomic segment;
                for i in s;
                    If max p is < n , then reproducibility score is 0
                else  1
         return a list of regions reproducible and not reproducible
```

For our study n represents the number of replicates for each protein under investigation in a given cell type, s the segments of the genome considering a window size of 200 base pairs, p is the number of peaks in every genomic segment. Consecutive segments with a signal reaching as a max value n are considered as reproducible regions and assigned with a value of 1. Opposite, consecutive segments with a signal reaching a max value lower than n are considered as not reproducible regions and assigned with a value of 0. The output is a table with a list of regions that are reproducible and not reproducible that will be further aggregated for all the protein under study. Schematic represenation can be observed in the Fig. 2 below.


![example](https://user-images.githubusercontent.com/6462162/46016470-308e4f80-c0d5-11e8-86d9-de73e4d2d4b8.png)

###### Fig. 2) Steps to identify reproducible and not reproducible regions considering the boarder of each segment for NCOR1 protein. The genome is scanned using a sliding window apporach. Regions that are in between segments with sum vector of 0 are defined as reproducible if the maximum value is three and not reproducible if the maximum value is lower than three.  

For this we have developed three main functions in R that create the vector with the number of signals at each genomic segment (createSumMatrix), create the Id for each segment with the signal (createId) and finally extract the regions with a signal discarding all the others (getSignalContainingRegions) in order to compute reproducibile and not reproducible regions:

Function 1) `createSumMatrix`  

Function 2) `createId`

Function 3) `getSignalContaingRegions`


# Reproducibility score matrix  
Reproducible and not reproducible regions for all the proteins used in the experiments are aggregated in a reproducibility score matrix (Fig.3). 

Function 4) `ReproducibilityScoreMatrix(df1,df2,df3,df4)`  
where df1, df2, df3 and df4 are the matrix with the regions reproducible and not reproducible for each protein

![final score](https://user-images.githubusercontent.com/6462162/46009363-996acd00-c0bf-11e8-9dae-56426c72f764.png)

###### Fig. 3) Converted reproducibility values for each protein used in the experiment for a particular cell type.

Afterwards, regions with a reproducibility score of 0, that we named noisy, are estimated computing a z-score and respective p.value after 1000 sampling of the reproducibility score matrix. Sampling is performed with the "sample" function in R.
 

# Noisy regions estimation in K562, GM12878, HepG2 and MCF-7 cell lines

A statistical test was computed based on to the computation of a z-score and p.value using 1000 randomizations:  

Function 5) `simulated.pval(n.simulations,cutoff,real.value)`  


![forgith](https://user-images.githubusercontent.com/6462162/46032674-9510d500-c0fc-11e8-8ddc-ea3971f1e075.png)

###### Fig. 4) A null distribution is computed for each cell line by sampling the reproducibility score matrix of Fig3. Z-score and P.value is computed for each score. In the picture, represented are the statistical test for DNA regions with reproducibility score 0 (that we renamed Noisy).

# Noisy regions prediction in mESC according to several DNA features
We used the R package "randomforest" to check whether specific genomic regions were predictive of the noisy behaviour for the protein under investigation. We used a pannel of published datasets and mapped the noisy regions to them. A null model was created with the package gkmSVM and the performance of the algorithm was checked with the package pROC.

![roc curve no ctcf](https://user-images.githubusercontent.com/6462162/51404637-504df580-1b54-11e9-9ade-ec23620b2b48.png)
![variable explanation without ctcf](https://user-images.githubusercontent.com/6462162/51404642-5348e600-1b54-11e9-997d-a7bee7422342.png)



# References
1. Teytelman Leonid, et al. "Highly expressed loci are vulnerable to misleading ChIP localization of multiple unrelated proteins." Proceedings of the National Academy of Sciences 110.46 (2013): 18602-18607.  

2. Park Daechan, et al. "Widespread misinterpretable ChIP-seq bias in yeast." PLoS One 8.12 (2013): e83506.  

3. Jain Dhawal, et al. "Active promoters give rise to false positive ‘Phantom Peaks’ in ChIP-seq experiments." Nucleic acids research 43.14 (2015): 6959-6968.   

4. Wreczycka Katarzyna, et al. "HOT or not: Examining the basis of high-occupancy target regions." bioRxiv (2017).

5. Foley Joseph W., and Arend Sidow. "Transcription-factor occupancy at HOT regions quantitatively predicts RNA polymerase recruitment in five human cell lines." BMC genomics 14.1 (2013): 720.

6. Cho, S. H., Haning, K., Shen, W., Blome, C., Li, R., Yang, S., & Contreras, L. M. (2017). Identification and characterization of 5′ untranslated regions (5′ UTRs) in Zymomonas mobilis as regulatory biological parts. Frontiers in microbiology, 8, 2432.
