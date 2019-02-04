#Create list of samples
a="MNT NCOR1 SMARCA4 ZNF24"

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

#Select peaks with FDR <= 5%
for i in $b;
do
  awk '$9 >= 1.3' $i | sort -k1,1 -k2,2n > $i.q.val.thr.0.05.sort.bed; 
done &


c="
MNT/ENCFF059ONJ.bed.q.val.thr.0.05.sort.bed
MNT/ENCFF567GSX.bed.q.val.thr.0.05.sort.bed
MNT/ENCFF973OME.bed.q.val.thr.0.05.sort.bed
NCOR1/ENCFF080NBZ.bed.q.val.thr.0.05.sort.bed
NCOR1/ENCFF165BCW.bed.q.val.thr.0.05.sort.bed
NCOR1/ENCFF366UBB.bed.q.val.thr.0.05.sort.bed
SMARCA4/ENCFF002CVT.bed.q.val.thr.0.05.sort.bed
SMARCA4/ENCFF197YHU.bed.q.val.thr.0.05.sort.bed
SMARCA4/ENCFF883TOD.bed.q.val.thr.0.05.sort.bed
ZNF24/ENCFF261XPP.bed.q.val.thr.0.05.sort.bed
ZNF24/ENCFF905VXX.bed.q.val.thr.0.05.sort.bed
ZNF24/ENCFF854STX.bed.q.val.thr.0.05.sort.bed"

#Bin the genome in segments of a given window (200 base pairs)

bedtools makewindows -g hg19.chr.size.txt -w 200 > hg19.Serial.Number.txt

#Intersect regions overlapping
for i in $c;
do
bedtools intersect -a hg19.Serial.Number.txt -b $i -u | awk '{$4=1}1'  | awk '{print $1"\t"$2"\t"$3"\t"$4}' > $i.intersected.hg19.200bp; 
done 
&

#Intersect the regions non overlapping
for i in $c;
do
bedtools intersect -a hg19.Serial.Number.txt -b $i -v | awk '{$4=0}1'  | awk '{print $1"\t"$2"\t"$3"\t"$4}' > $i.intersected.hg19.200bp.not; 
done


#Concatenate the Two Files
for f in */*.200bp;
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
d="MNT NCOR1 SMARCA4 ZNF24"
for i in $d;
do
paste hg19.Serial.Number.txt $i/*.value | cut -f 1,2,3,5,6,7 > $i.txt;
done

#Split in chromosomes the master table in order to parallelize afterwards
e="chr1 chr2 chr3 chr4 chr5 chr6 chr7 chr8 chr9 chr10 chr11 chr12 chr13 chr14 chr15 chr16 chr17 chr18 chr19 chr20 chr21 chr22 chrX chrY chrM"

for i in $e; 
do
  grep -w $i SMARCA4.txt > $i.SMARCA4.txt ;
done &

#Subsitute all the files in input from a protein to another (in the r script for Job array)
grep -rl 'SMARCA4' ./*.r  | xargs sed -i 's/SMARCA4/CTCF/g'

#Copy the e file n time to run a job array
for i in {1..25}; do cp Algorithm.r "Algorithm.$i.r"; done

#Create the transaction file
NR == 1 { for(column=1; column <= NF; column++) values[column]=$column; }
NR > 1 { output=""
        for(column=1; column <= NF; column++)
                if($column) output=output ? output "," values[column] : values[column]
        print output }
