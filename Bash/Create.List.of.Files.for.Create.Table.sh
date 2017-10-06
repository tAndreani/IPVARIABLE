#Create list of samples
a="POLR2A RNF2 CTCF NCOR1 NRF1 ZNF24 EGR1 TARDBP SMARCA4 MNT KDM1A HDAC2 HDAC1"

#Create a directory for each protein
for i in $a;
do
         mkdir $i;
done


#Create variable with the name of the url
prefix=https://www.encodeproject.org


#Create url
for i in $a;
do
  	awk -v prefix="$prefix" '{print prefix $0}' $i/*files > $i/list.url;
done

#Download
for i in $a; 
do 
        for j in list.url; 
        do 
                 (cd $i ; wget -i $j); 
        done;
done &


#Unzip
b=/project/jgu-cbdm/andradeLab/scratch/tandrean/Data/Jean-Fred/Test.New.ChIP/files/HD*/*bed.gz
gunzip $b

b=/project/jgu-cbdm/andradeLab/scratch/tandrean/Data/Jean-Fred/Test.New.ChIP/files/HD*/*bed

for i in $b;
do
  awk '$9 >= 1.3' $i | sort -k1,1 -k2,2n > $i.q.val.thr.0.05.sort.bed; 
done &


c="CTCF/ENCFF002CEL.bed.q.val.thr.0.05.sort.bed 
CTCF/ENCFF002DBD.bed.q.val.thr.0.05.sort.bed
CTCF/ENCFF002DDJ.bed.q.val.thr.0.05.sort.bed
CTCF/ENCFF738TKN.bed.q.val.thr.0.05.sort.bed
EGR1/ENCFF004WYV.bed.q.val.thr.0.05.sort.bed
EGR1/ENCFF558JBX.bed.q.val.thr.0.05.sort.bed
HDAC2/ENCFF562JDH.bed.q.val.thr.0.05.sort.bed
HDAC2/ENCFF657VJX.bed.q.val.thr.0.05.sort.bed
KDM1A/ENCFF738WCE.bed.q.val.thr.0.05.sort.bed
KDM1A/ENCFF838COI.bed.q.val.thr.0.05.sort.bed
MNT/ENCFF059ONJ.bed.q.val.thr.0.05.sort.bed
MNT/ENCFF567GSX.bed.q.val.thr.0.05.sort.bed
MNT/ENCFF973OME.bed.q.val.thr.0.05.sort.bed
NCOR1/ENCFF080NBZ.bed.q.val.thr.0.05.sort.bed
NCOR1/ENCFF165BCW.bed.q.val.thr.0.05.sort.bed
NCOR1/ENCFF366UBB.bed.q.val.thr.0.05.sort.bed
POLR2A/ENCFF002CXQ.bed.q.val.thr.0.05.sort.bed
POLR2A/ENCFF002CXR.bed.q.val.thr.0.05.sort.bed
POLR2A/ENCFF248IWJ.bed.q.val.thr.0.05.sort.bed
POLR2A/ENCFF937VZI.bed.q.val.thr.0.05.sort.bed
RNF2/ENCFF644WLI.bed.q.val.thr.0.05.sort.bed
RNF2/ENCFF972LPT.bed.q.val.thr.0.05.sort.bed
SMARCA4/ENCFF002CVT.bed.q.val.thr.0.05.sort.bed
SMARCA4/ENCFF197YHU.bed.q.val.thr.0.05.sort.bed
SMARCA4/ENCFF883TOD.bed.q.val.thr.0.05.sort.bed
TARDBP/ENCFF261XPP.bed.q.val.thr.0.05.sort.bed
TARDBP/ENCFF905VXX.bed.q.val.thr.0.05.sort.bed"

#Intersect regions overlapping
for i in $c;
do
bedtools intersect -a GRCh38.Serial.Number.txt -b $i -u | awk '{$4=1}1'  | awk '{print $1"\t"$2"\t"$3"\t"$4}' > $i.intersected.GRCh38.400bp; 
done 
&

#Intersect the regions non overlapping
for i in $c;
do
bedtools intersect -a GRCh38.Serial.Number.txt -b $i -v | awk '{$4=0}1'  | awk '{print $1"\t"$2"\t"$3"\t"$4}' > $i.intersected.GRCh38.400bp.not; 
done


#Concatenate the Two Files
for f in */*.400bp;
do
cat "$f" "$f.not" > "$f.yes.and.not" ;  
done &

#Sort the files
for i in */*.yes.and.not;
do
sort -k 1,1 -k2,2n $i > $i.sorted;
done &


#Extract values 0= intersected and 1= intersected
for i in */*.sorted;
do
cut -f 4 $i > $i.value;
done &

#Final Matrix
d="CTCF EGR1 HDAC2 KDM1A MNT NCOR1 POLR2A RNF2 SMARCA4 TARDBP"
for i in $d;
do
paste GRCh38.Serial.Number.txt $i/*.value | cut -f 1,2,3,5,6,7 > $i.txt;
done

#Split in chromosomes the master table in order to parallelize afterwards
e="chr1 chr2 chr3 chr4 chr5 chr6 chr7 chr8 chr9 chr10 chr11 chr12 chr13 chr14 chr15 chr16 chr17 chr18 chr19 chr20 chr21 chr22 chrX chrY chrM"

for i in $e; 
do
  do grep -w $i SMARCA4.txt > $i.SMARCA4.txt ;
done &


