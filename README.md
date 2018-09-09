# IPNOISY: a method for genome-wide estimation of noisy regions in transcription factor ChIP-seq data. 
IPNOISY is a method capable to detect noisy DNA binding regions of several transcription factors in a given cell type. It takes in input ChIP-seq peaks and outputs the noisy ones that tend to be not reproducible.


# Motivation
ChIP-seq is a standard technology in wet laboratories because it allows to map the genomic regions in which a protein or transcription factor is binding the DNA. Regulatory genomics labs have extensively used this technique to describe how, where and which gene is under the control of a transcription factor. However, the extent of the reproducibility of the binding sites can be confounded by several factors, such as the genomic location in which the transcription factor binds or DNA structures present at the moment of the immunoprecipitation (1,2,3,4). For this we have developed IPNOISY, a method that can report noisy transcription factors ChIP-seq binding sites.


# Experimental Design: define suitable set of experiments from ENCODE project
We selected ENCODE experiments for four different proteins according to the following standard criteria:  
1) from the same cell line  
2) from the same lab (Snyder)  
3) processed with the same bioinformatics ENCODE pipeline  
4) statistical test performed as Irreproducibility Discovery Rare (IDR)  
5) peaks significant at 5% FDR  

Here we select experiments of 4 proteins and each one with 3 replicates from cell line K562 in the Human Genome annotation GRCh38, example call:  
`python get_list.py K562 3 4 GRCh38`  

Here we select experiments of 4 proteins and each one with 2 replicates from cell line HepG2 in the Human Genome annotation hg19 example call:  
 `python get_list.py HepG2 2 4 hg19`  

# Extraction of the experiments, download the files and assign the peaks to genomic segments
The output of the python script is a table with the information of the experiments. We create the folder for each protein and download the files associated in the table. After we create for each protein the matrix with assiged peaks for every genomic segment. Segments can be of 200 or 400 bp length.

`bash ./Create.Matrix.sh`  

# Identification of reproducible and not reproducible regions in K562, GM12878 and HepG2 cell lines
After assigning the peaks to the genomic segments, we processed the obtained matrix to identify reproducible and not reproducible regions. This is performed based on the assumption that the reliability of a binding site of a given transcription factor (or protein) requires the presence of replicates in the experimental design and the presence of the signal in the same genomic regions among the replicates can give a confidence of its reliability. Using this concept at the basis of the method, a reproducibility value is assigned based on how many time a fixed DNA region, that we named segment, is bounded by a protein among its replicates in the ChIP experiment (YES for reproducible and NO for not reproducible). If a minimum number of three replicates for a given protein in a cell type is considered, reproducible regions will be those having a significant peak (FDR <= 5%) in all the replicates for a given segment. As expected, the length of the peaks variate between the replicates and for this reason, the board of the segment that do not reach the number three will be included as part of the reproducible region (Fig.1 in red). Contrary, regions with a peak but that never reach the number of three will be annotated as not reproducible (Fig.1 in green).

![peaks](https://user-images.githubusercontent.com/6462162/40009504-8453ddac-57a2-11e8-98ce-1c874821e177.png)

###### Fig. 1) Step to identify reproducible and not reproducible regions considering the boarder of each segment for NCOR1 protein. The genome is scanned using a sliding window apporach. Consecutive segments in between a sum vector of 0 are defined as reproducible if the maximum value is three and not reproducible if the maximum value is lower than three.  

For this we have developed 4 main functions in R that process the binding sites of the genomic segments and detect reproducibile and not reproducible consecutive segments (regions):

Function 1):  

Function 2):  

Function 3):  

Function 4):  


# Reproducibility score matrix and estimation of the noisy regions
Reproducible and not reproducible regions are aggregated in a reproducibility score matrix. Afterwards, z-score calculation obtained after 1000 sampling of the reproducibility score matrix is obtained using the following R function:
 
Function 


# References
1. Teytelman Leonid, et al. "Highly expressed loci are vulnerable to misleading ChIP localization of multiple unrelated proteins." Proceedings of the National Academy of Sciences 110.46 (2013): 18602-18607.  

2. Park Daechan, et al. "Widespread misinterpretable ChIP-seq bias in yeast." PLoS One 8.12 (2013): e83506.  

3. Jain Dhawal, et al. "Active promoters give rise to false positive ‘Phantom Peaks’ in ChIP-seq experiments." Nucleic acids research 43.14 (2015): 6959-6968.   

4. Wreczycka Katarzyna, et al. "HOT or not: Examining the basis of high-occupancy target regions." bioRxiv (2017).

5. Foley Joseph W., and Arend Sidow. "Transcription-factor occupancy at HOT regions quantitatively predicts RNA polymerase recruitment in five human cell lines." BMC genomics 14.1 (2013): 720.

6. Cho, S. H., Haning, K., Shen, W., Blome, C., Li, R., Yang, S., & Contreras, L. M. (2017). Identification and characterization of 5′ untranslated regions (5′ UTRs) in Zymomonas mobilis as regulatory biological parts. Frontiers in microbiology, 8, 2432.
