# IPNOISY: a method for genome-wide estimation of noisy transcription factor binding sites from replicated ChIP-seq experiments 
IPNOISY is a method capable to detect noisy DNA binding regions of several transcription factors in a given cell type. It takes in input ChIP-seq peaks and outputs the noisy ones that tend to be not reproducible. It can be useful to use this tool in case a wet lab has obtained peaks from ChIP-seq expriments and wants to know their reliability before downstream interpretative analysis and/or experimental follow up.


# Motivation
ChIP-seq is a standard technology in wet laboratories because it allows to map the genomic regions in which a protein or transcription factor is binding the DNA. Regulatory genomics labs have extensively used this technique to describe how, where and which gene is under the control of a transcription factor. However, the extent of the reproducibility of the binding sites can be confounded by several factors, such as the genomic location in which the transcription factor binds, DNA structures present at the moment of the immunoprecipitation, quality of the antibody as also the experimental conditions in cell culture (1,2,3,4). For this we have developed IPNOISY, a method that can report noisy transcription factors binding sites from ChIP-seq data. Here the workflow:  


# Experimental Design: define suitable set of experiments from ENCODE project
We selected ENCODE experiments for four different proteins according to the following standard criteria:  
1) from the same cell line  
2) from the same lab (Snyder)  
3) processed with the same bioinformatics ENCODE pipeline  
4) statistical test performed as Irreproducibility Discovery Rate (IDR)  
5) peaks significant at 5% FDR  

Here we select experiments of 4 proteins and each one with 3 replicates from cell line K562 in the Human Genome annotation GRCh38, example call:  
`python get_list.py K562 3 4 GRCh38`  

Here we select experiments of 4 proteins and each one with 2 replicates from cell line HepG2 in the Human Genome annotation hg19 example call:  
 `python get_list.py HepG2 2 4 hg19`  

# Extraction of the experiments, download the files and assign the peaks to genomic segments
The output of the python script is a table with the information of the experiments. We create the folder for each protein and download the files associated in the table. After we create for each protein the matrix with assigned peaks for every genomic segment. Segments can be of 200 or 400 bp length depending on the user choice. This task is performed with this bash script:  

`bash ./Create.Matrix.sh`  

# Identification of reproducible and not reproducible regions 
After assigning the peaks to the genomic segments, we processed the obtained matrix to identify reproducible and not reproducible regions. This is performed based on the assumption that the reliability of a binding site of a given transcription factor (or protein) requires the presence of replicates in the experimental design and the presence of the signal in the same genomic regions among the replicates can give a confidence of its reliability. Using this concept at the basis of the algorithm, a reproducibility value is assigned based on how many time a fixed DNA segment, is bounded by a protein among its replicates in the ChIP experiment. If a minimum number of three replicates for a given protein in a cell type is considered, reproducible regions will be those having a significant peak (FDR <= 5%) in all the replicates for a given segment. As expected, the length of the peaks variate between the replicates and for this reason, the board of the segment that do not reach the number three will be included as part of the reproducible region (Fig.1 in red). Contrary, regions with a peak but that never reach the number of three will be annotated as not reproducible (Fig.1 in green).

![forghit](https://user-images.githubusercontent.com/6462162/45961058-f4e47e80-c01d-11e8-96b6-bece17e76a3d.png)

###### Fig. 1) Steps to identify reproducible and not reproducible regions considering the boarder of each segment for NCOR1 protein. The genome is scanned using a sliding window apporach. Regions that are in between segments with sum vector of 0 are defined as reproducible if the maximum value is three and not reproducible if the maximum value is lower than three.  

For this we have developed five main functions in R that create the vector with the number of replicates at each genomic segment (sum vector), extract the regions with a signal and compute not reproducibile and reproducible regions:

Function 1) `CreateSumMatrix(matrix=matrix)`  

Function 2) `CreateId(matrix=matrix)`

Function 3) `CreateScore(matrix=matrix)`   

Function 4) `NoTReproducibleRegions(matrix=RegionsWithSignals, n.replicates=n.replicates, Score=Score, Id=Id)  `

Function 5) `ReproducibleRegions(matrix=RegionsWithSignals, n.replicates=n.replicates, Score=Score, Id=Id)  `


# Reproducibility score matrix and estimation of the noisy regions
Reproducible and not reproducible regions for all the proteins used in the experiments are aggregated in a reproducibility score matrix. Afterwards, regions with a reproducibility score of 0, that we named noisy, are estimated computing a z-score and respective p.value after 1000 sampling of the reproducibility score matrix. For this task we have created two R functions, one to create the reproducibility score matrix and the other to estimate the noisy regions:
 
Function 1) `ReproducibilityScoreMatrix(protein1=protein1, protein2=protein2, protein3=protein3, protein4=protein4)`  

Function 2) `Stath.Test(matrix=ReproducibilityScoreMatrix, n.simulations=1000, n.regions=n.regions.score.0)`  

# Noisy regions estimation in K562, GM12878, HepG2 and MCF-7 cell lines


# References
1. Teytelman Leonid, et al. "Highly expressed loci are vulnerable to misleading ChIP localization of multiple unrelated proteins." Proceedings of the National Academy of Sciences 110.46 (2013): 18602-18607.  

2. Park Daechan, et al. "Widespread misinterpretable ChIP-seq bias in yeast." PLoS One 8.12 (2013): e83506.  

3. Jain Dhawal, et al. "Active promoters give rise to false positive ‘Phantom Peaks’ in ChIP-seq experiments." Nucleic acids research 43.14 (2015): 6959-6968.   

4. Wreczycka Katarzyna, et al. "HOT or not: Examining the basis of high-occupancy target regions." bioRxiv (2017).

5. Foley Joseph W., and Arend Sidow. "Transcription-factor occupancy at HOT regions quantitatively predicts RNA polymerase recruitment in five human cell lines." BMC genomics 14.1 (2013): 720.

6. Cho, S. H., Haning, K., Shen, W., Blome, C., Li, R., Yang, S., & Contreras, L. M. (2017). Identification and characterization of 5′ untranslated regions (5′ UTRs) in Zymomonas mobilis as regulatory biological parts. Frontiers in microbiology, 8, 2432.
