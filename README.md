# ChIP-Score
ChIP-Score is a method capable to distinguish DNA regions that are bounded by several functional unrelated proteins and respective replicates within genomic locations of the same cell type and to report noisy regions that tend to be not reproducible for all the transcription factors binding sites under investigation.


# Idea Behind the tool
ChIP-seq is a standard technology in wet laboratories because it allows to map the genomic regions in which a protein or transcription factor of interest is binding. Regulatory genomics labs have extensively used this technique to describe how, where and which gene is under the control of a transcription factor. However, the extent of the reproducibility of the binding sites can be confounded by several factors, such as the genomic location in which they bind or DNA structure present at the moment of the immunoprecipitation (1,2,3,4). For this we have developed ChIP-score, a method that can report variable binding sites for a given cell type of interest. We refer to these regions as noisy according to a developed reproducibility score.


# Experimental Design: extract suitable set of experiments from ENCODE project
We selected ENCODE experiments for four different proteins in triplicates according to the following standard criteria:  
1) from the same cell line K562  
2) from the same lab (Snyder)  
3) processed with the same bioinformatics ENCODE pipeline  
4) statistical test performed as Irreproducibility Discovery Rare (IDR)  
5) peaks significant at 5% FDR  

Here we select experiments of 4 proteins and each one with 3 replicates from cell line K562 in the Human Genome annotation GRCh38, example call:  
`python get_list.py K562 3 4 GRCh38`  

Here we select experiments of 4 proteins and each one with 2 replicates from cell line HepG2 in the Human Genome annotation hg19 example call:  
 `python get_list.py HepG2 2 4 hg19`  


# Conceptualization: identification of reproducible and not reproducible regions in K562 cell lines
Obtain the DNA binding of a given transcription factor (or protein) requires the presence of replicates in the experimental design and concordant regions among the replicates can give a confidence on its reliability. Using this concept at the basis of the method, a reproducibility score is developed based on how many time a fixed DNA region, that we named bin, is bounded by a protein among the replicates in the ChIP experiment. If a minimum number of three replicates for a given protein in a cell type is considered, reproducible regions will be those having a significant peak (FDR <= 5%) in all the replicates for a given bin. As expected, the length of the peaks variate between the replicates and for this reason, the board of the bin that do not reach the number three will be annotated as part of the reproducible region. Contrary, regions with a peak but that never reach the number of three will be annotated as not reproducible. If in between bins with 0 "Sum vector" there is a maximum value of 3 the whole region is reproducible. Opposite if there is not a maximum value of 3 the region is not reproducible. Aggregating reproducible regions for the same cell type and different proteins will result in unspecific bounded regions (Sticky). Opposite aggregating not reproducible regions for the same cell type and different proteins will result in Noisy regions.

![peaks](https://user-images.githubusercontent.com/6462162/40009504-8453ddac-57a2-11e8-98ce-1c874821e177.png)

Fig. 1) Step to identify reproducible and not reproducible regions considering the boarder of each bin for NCOR1 protein. 

# Reproducibility score matrix  

# References
1. Teytelman Leonid, et al. "Highly expressed loci are vulnerable to misleading ChIP localization of multiple unrelated proteins." Proceedings of the National Academy of Sciences 110.46 (2013): 18602-18607.  

2. Park Daechan, et al. "Widespread misinterpretable ChIP-seq bias in yeast." PLoS One 8.12 (2013): e83506.  

3. Jain Dhawal, et al. "Active promoters give rise to false positive ‘Phantom Peaks’ in ChIP-seq experiments." Nucleic acids research 43.14 (2015): 6959-6968.   

4. Wreczycka Katarzyna, et al. "HOT or not: Examining the basis of high-occupancy target regions." bioRxiv (2017).

5. Foley Joseph W., and Arend Sidow. "Transcription-factor occupancy at HOT regions quantitatively predicts RNA polymerase recruitment in five human cell lines." BMC genomics 14.1 (2013): 720.

6. Cho, S. H., Haning, K., Shen, W., Blome, C., Li, R., Yang, S., & Contreras, L. M. (2017). Identification and characterization of 5′ untranslated regions (5′ UTRs) in Zymomonas mobilis as regulatory biological parts. Frontiers in microbiology, 8, 2432.
