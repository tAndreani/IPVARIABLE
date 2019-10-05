# Computational identification of Variable regions in ChIP-seq data
In this work we provide a method capable to detect variable DNA binding regions of several transcription factors in a given cell type. The method takes in input ChIP-seq peaks and outputs the noisy ones that tend to be not reproducible. It can be useful to use this method in case a wet lab has obtained peaks from ChIP-seq expriments and wants to know their reliability before downstream interpretative analysis and/or experimental follow up. The method can be extended also to other sequencing techniques that use replicated experiments for example, ATAC-seq from multiple cell types in developmental studies.  

##### Manuscript in 2nd round of Revision in Nucleic Acid Research: "Computational Identification of cell-specific variable regions in ChIP-seq data". T. Andreani, S. Albrecht, J.F. Fontaine and MA. Andrade-Navarro


# Motivation
ChIP-seq is a standard technology in wet laboratories because it allows to map the genomic regions in which a protein or transcription factor is binding the DNA. Regulatory genomics labs have extensively used this technique to describe how, where and which gene is under the control of a transcription factor. However, the extent of the reproducibility of the binding sites can be confounded by several factors, such as the genomic location in which the transcription factor binds, DNA structures present at the moment of the immunoprecipitation, quality of the antibody as also the experimental conditions in cell culture (1,2,3). For this we have developed a method that can report variable transcription factors binding sites from ChIP-seq data in a given cell type of interest. Here the workflow:  

![workflow](https://user-images.githubusercontent.com/6462162/53744700-cd7fc080-3e9d-11e9-9eb0-247451da094b.png)

###### Figure 1) In the workflow: A) ENCODE experiments are selected according to standard parameters (see points from 1 to 6 in the experimental design paragraph), B) peaks are mapped to genomic segments of a defined window size and a sliding window is used to compute a reproducibility score. C) Regions with a specific score are tested for significance and D) PCA is performed to check if the removal of the variable regions can improve the explanation of the variability of  the samples. 

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

Segmentation of the genome and assignment of the peaks to genomics bins is performed with this bash script:  

`bash ./Map.Peaks.to.bins.sh`  

# Identification of reproducible and not reproducible regions 
After the identification of suitable experiments and assigned the significant peaks to the genomic bins, we extracted reproducible and not reproducibile regions. We formalized the assignment of reproducible and not reproducible segments according to the following pseudo code rules:

```
Let N be the number of replicates for a given protein;
Let S be the segments for a given genome;
Let P be the number of peaks detected in a genomic segment;

for every segment in S;
   if P = 0, then assign an NA
   if in between two NA P is < N, then reproducibility score at each segment is 0
      else,
   reproducibility score at each segment is 1
```

For our study N represents the number of replicates for each protein under investigation in a given cell type, S the segments of the genome considering a window size of 200 base pairs, P is the number of peaks in every genomic segment. Consecutive segments with a signal reaching as a max value N are considered as reproducible regions and assigned with a value of 1. Opposite, consecutive segments with a signal reaching a max value lower than N are considered as not reproducible regions and assigned with a value of 0. The output is a table with a list of regions that are reproducible and not reproducible that will be further aggregated for all the protein under study. Schematic represenation can be observed in the Fig. 2 below.


![fig 2a](https://user-images.githubusercontent.com/6462162/53745203-d755f380-3e9e-11e9-994a-1261e955e79b.png)

###### Figure 2-A) Steps to identify reproducible and not reproducible regions considering the boarder of each segment and then the tale of each peak for NCOR1 protein. The genome is scanned using a sliding window apporach. Regions that are in between segments with sum vector of 0 are defined as reproducible if the maximum value is three and not reproducible if the maximum value is lower than three.  

For this we have developed three main functions in R that create the vector with the number of signals at each genomic segment (createSumMatrix), create the Id for each segment with the signal (createId) and finally extract the regions with a signal and compute reproducibile and not reproducible regions (getSignalContainingRegions):

Function 1) `createSumMatrix`  

Function 2) `createId`

Function 3) `getSignalContaingRegions`


# Reproducibility Score Matrix (RSM)
Reproducible and not reproducible regions for all the proteins used in the experiments are aggregated in a reproducibility score matrix (Fig.2-B). 

Function 4) `ReproducibilityScoreMatrix(df1,df2,df3,df4)`  
where df1, df2, df3 and df4 are the matrix with the regions reproducible and not reproducible for each protein

![rsm](https://user-images.githubusercontent.com/6462162/53360397-b9840e00-3935-11e9-87cf-f577b7b8cb6d.png)
###### Figure 2-B) Reproducibility Score Matrix where rows show segments and columns show their conversion score for each protein (1 for segments in regions that are reproducible and 0 for segments in regions that are not reproducible) and a final reproducibility score (RS) defined as the average value of the row (or NA if more than 1 conversion score equals NA)

Afterwards, regions with more than one NA value were discarded and regions with a reproducibility score of 0, that we named variable, are estimated computing a z-score and respective p.value after 1000 sampling of the reproducibility score matrix. Sampling is performed with the "sample" function in R.
 

# Variable regions estimation in K562, GM12878, HepG2 and MCF-7 cell lines

A statistical test was computed based on to the computation of a z-score and p.value using 1000 randomizations:  

Function 5) `simulated.pval(n.simulations,cutoff,real.value)`  


![forgith](https://user-images.githubusercontent.com/6462162/46032674-9510d500-c0fc-11e8-8ddc-ea3971f1e075.png)

###### Figure 3) A null distribution is computed for each cell line by sampling the reproducibility score matrix of Fig2-B. Z-score and P.value is computed for each score. In the picture, represented are the statistical test for DNA regions with reproducibility score 0 (that we renamed variable).

# Variable regions prediction in mESC according to several DNA features
We used the R package "randomforest" to check whether specific genomic regions were predictive of the variable behaviour for the proteins under investigation. We used a pannel of published datasets and mapped the variable regions to them. A null model was created with the package gkmSVM and the performance of the algorithm was checked with the package pROC.

The script can be run:  

`Rstudio Random.Forest.r`


![roc for manuscript](https://user-images.githubusercontent.com/6462162/53503254-ff64e180-3aaf-11e9-8982-105edb3166cc.png)
![model random](https://user-images.githubusercontent.com/6462162/53503321-1e637380-3ab0-11e9-81fe-0f05beb48838.png)
###### Figure 4) Random forest algorithm predicts variable regions in mESCs according to several features


# PCA in K562 cell lines with and without the variable regions
We created a python script using pandas in order to perform the PCA and check whether the removal of variable peaks improves the separation of the replicates in the PCA.  

The script can be run:  
`python pca.py ./matrix.tsv`  

![pca](https://user-images.githubusercontent.com/6462162/53353427-f267b700-3924-11e9-94d0-669962139ab5.png)
###### Figure 5) PCA shows an improvment in the separation of the groups and respecitve replicates upon removal of the variable regions 


![intra k562](https://user-images.githubusercontent.com/6462162/53503435-566ab680-3ab0-11e9-91fd-d223dfcaa127.png)
![dotplot](https://user-images.githubusercontent.com/6462162/53503476-68e4f000-3ab0-11e9-880c-bb21e75caf62.png)
###### Figure 6) Euclidean distance of pairwise comparisons between replicates of the same protein as a box plot and as a dot plot 

# References
1. Teytelman, L., Thurtle, D. M., Rine, J., & van Oudenaarden, A. (2013). Highly expressed loci are vulnerable to misleading ChIP localization of multiple unrelated proteins. Proceedings of the National Academy of Sciences, 110(46), 18602–18607.  
2. Jain, D., Baldi, S., Zabel, A., Straub, T., & Becker, P. B. (2015). Active promoters give rise to false positive “Phantom Peaks” in ChIP-seq experiments. Nucleic Acids Research, 43(14), 6959–6968.  
3. Wreczycka K., F. Vedran, U. Bora, R. Wurmus, S. Bulut, B. Tursun, A. Akalin (2019). HOT or not: examining the basis of high-occupancy target regions, Nucleic Acids Research, 47(11), 5735-5745.  
4. Landt, S. G., Marinov, G. K., Kundaje, A., Kheradpour, P., Pauli, F., Batzoglou, S., ... & Chen, Y. (2012). ChIP-seq guidelines and practices of the ENCODE and modENCODE consortia. Genome research, 22(9), 1813-1831.  
5. Li, Q., Brown, J. B., Huang, H., & Bickel, P. J. (2011). Measuring reproducibility of high-throughput experiments. Annals of Applied Statistics, 5(3), 1752–1779.  
6. Sanz, L. A., Hartono, S. R., Lim, Y. W., Steyaert, S., Rajpurkar, A., Ginno, P. A., ... & Chédin, F. (2016). Prevalent, dynamic, and conserved R-loop structures associate with specific epigenomic signatures in mammals. Molecular cell, 63(1), 167-178.  
7. Quinlan, A. R., & Hall, I. M. (2010). BEDTools: A flexible suite of utilities for comparing genomic features. Bioinformatics, 26(6), 841–842.  
8. Shen, L., Wu, H., Diep, D., Yamaguchi, S., D’Alessio, A. C., Fung, H. L., ... & Zhang, Y. (2013). Genome-wide analysis reveals TET-and TDG-dependent 5-methylcytosine oxidation dynamics. Cell, 153(3), 692-706.  
9. Whyte, W. A., Bilodeau, S., Orlando, D. A., Hoke, H. A., Frampton, G. M., Foster, C. T., ... & Young, R. A. (2012). Enhancer decommissioning by LSD1 during embryonic stem cell differentiation. Nature, 482(7384), 221.  
10. Stadler, M. B., Murr, R., Burger, L., Ivanek, R., Lienert, F., Schöler, A., ... & Tiwari, V. K. (2011). DNA-binding factors shape the mouse methylome at distal regulatory regions. Nature, 480(7378), 490.  
11. Ghandi, M., Mohammad-Noori, M., Ghareghani, N., Lee, D., Garraway, L., & Beer, M. A. (2016). gkmSVM: an R package for gapped-kmer SVM. Bioinformatics, 32(14), 2205-2207.  
12. Ramachandran, P., Palidwor, G. A., & Perkins, T. J. (2015). BIDCHIPS: bias decomposition and removal from ChIP-seq data clarifies true binding signal and its functional correlates. Epigenetics & chromatin, 8(1), 33.  
13. Khan, A., Fornes, O., Stigliani, A., Gheorghe, M., Castro-Mondragon, J. A., van der Lee, R., .. & Baranasic, D. (2017). JASPAR 2018: update of the open-access database of transcription factor binding profiles and its web framework. Nucleic acids research, 46(D1), D260-D266.  
14. Neri, F., Incarnato, D., Krepelova, A., Rapelli, S., Anselmi, F., Parlato, C., ... & Oliviero, S. (2015). Single-base resolution analysis of 5-formyl and 5-carboxyl cytosine reveals promoter DNA methylation dynamics. Cell reports, 10(5), 674-683.  
15. Park, P. J. (2009). ChIP–seq: advantages and challenges of a maturing technology. Nature reviews genetics, 10(10), 669.  
16.  Park, D., Lee, Y., Bhupindersingh, G., & Iyer, V. R. (2013). Widespread misinterpretable ChIP-seq bias in yeast. PloS one, 8(12), e83506.  
17.  Mourad, Raphaël, et al. "Predicting double-strand DNA breaks using epigenome marks or DNA at kilobase resolution." Genome biology 19.1 (2018): 34.  
18. Xie D., Dan X., Boyle A.P., Linfeng W., Jie Z., Trupti K. et al. . Dynamic trans-acting factor colocalization in human cells. Cell. 2013; 155:713–724.  
19. Boyle A.P., Araya C.L., Cathleen B., Philip C., Chao C., Yong C., Gardner K., Hillier L.W., Janette J., Jiang L. et al. . Comparative analysis of regulatory information and circuits across distant species. Nature. 2014; 512:453–456.  
20. Haley M. Amemiya, Anshul Kundaje and Alan P. Boyle. The ENCODE Blacklist: Identification of Problematic Regions of the Genome. Scientific Reports 9.1 (2019): 9354.  
