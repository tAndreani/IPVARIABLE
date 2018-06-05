# ChIP Score
ChIP Score is a method capable to distinguish DNA regions that are bounded by several proteins and replicates within the same genomic locations and cell type. Also, the tool can report noisy regions that tend to be not reproducible for the transcription factor binding site under investigation.


# Idea Behind the tool
ChIP-seq is a standard technology in wet lab laboratories because it allows to map the genomic regions in which a protein of interest is acting. Regulatory genomics labs have extensively used this technique to describe how, where and which gene is under the control of a protein. However, in the last years, several labs have reported some limitations for the technique. In fact, regions of developmentally regulated, housekeeping and tRNA genes have shown un-specificity for DNA bining proteins in a consistent manner [ref 1,2,3,4]. There are some genomic regions that are attractors of Transcription Factors named "High Occupancy Target" (HOT) [ref 5]. It is still a debate whether these HOT regions are functional unit of the genome or simply artefact of ChIP techniques. To be able to distiguish real attractor of Transcription Factor regions Vs artefact it will be important for future analysis. For this we have developed ChIP-score, a method that can report Noisy and Attractor regions for a given cell type of interest.


# Conceptualization
Obtain the DNA binding of a given protein requires the presence of replicates in the experimental design and concordant regions among the replicates can give a confidence on its reliability. Using this concept at the basis of the method, a reproducibility score is developed based on how many time a fixed DNA region, that we named bin, is bounded by a protein among the replicates in the ChIP experiment. If a minimum number of three replicates for a given protein in a cell type is considered, reproducible regions will be those having a signal in all the replicates for a given bin. As expected, the length of the peaks variate between the replicates and for this reason, the board of the bin that do not reach the number three were considered as part of the reproducible region. Contrary, regions with a signal but that never reach the number of three were considered as not reproducible. Regions were considered in between values of 0. If from the region with 0 sum vector to the end region with 0 sum vectore there is a maximum value of 3 the whole region is reproducible. Opposite if there is not a maximum value of 3 the regions is not reproducible (Fig. 1). Aggregating reproducible regions for the same cell type and different proteins will result in a HOT region. Opposite aggregating not reproducible regions for the same cell type and different proteins will result in a Noisy region. Forther inspection of the HOT regions in respect of putative Phantom Peaks and/or Hyper-Chippable regions will give a reliability of these regions. 


![peaks](https://user-images.githubusercontent.com/6462162/40009504-8453ddac-57a2-11e8-98ce-1c874821e177.png)

Fig. 1) Step to identify reproducible and not reproducible regions considering the boarder of each bin. 


# References
1. Teytelman Leonid, et al. "Highly expressed loci are vulnerable to misleading ChIP localization of multiple unrelated proteins." Proceedings of the National Academy of Sciences 110.46 (2013): 18602-18607.  

2. Park Daechan, et al. "Widespread misinterpretable ChIP-seq bias in yeast." PLoS One 8.12 (2013): e83506.  

3. Jain Dhawal, et al. "Active promoters give rise to false positive ‘Phantom Peaks’ in ChIP-seq experiments." Nucleic acids research 43.14 (2015): 6959-6968.   

4. Wreczycka Katarzyna, et al. "HOT or not: Examining the basis of high-occupancy target regions." bioRxiv (2017).

5. Foley Joseph W., and Arend Sidow. "Transcription-factor occupancy at HOT regions quantitatively predicts RNA polymerase recruitment in five human cell lines." BMC genomics 14.1 (2013): 720.
