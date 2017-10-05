#Start New Analysis with CTCF

#Create list of files
a=/media/tandrean/Elements/PhD/ChIP-profile/New.Test.Steffen.Data/ChIP.GM12878/EN*.bed

#Extract chr start end and select q.val <= 0.05
for i in $a ;
do
awk '$9 >= 1.3' $i | sort -k1,1 -k2,2n > $i.q.val.thr.0.05.sort.bed;
done

#Intersect the regions overlapping
for i in *.q.val.thr.0.05.sort.bed;
do
bedtools intersect -a GRCh38.Serial.Number.txt -b $i -u | awk '{$4=1}1'  | awk '{print $1"\t"$2"\t"$3"\t"$4}' > $i.intersected.GRCh38.400bp;
done &

#Intersect the regions non overlapping
for i in *.q.val.thr.0.05.sort.bed;
do
bedtools intersect -a GRCh38.Serial.Number.txt -b $i -v | awk '{$4=0}1'  | awk '{print $1"\t"$2"\t"$3"\t"$4}' > $i.intersected.GRCh38.400bp.not;
done &

#Concatenate the Two Files
for f in *.400bp;
do
cat "$f" "$f.not" > "$f.yes.and.not" ;  
done &

#Sort the files
for i in *.yes.and.not;
do
sort -k 1,1 -k2,2n $i > $i.sorted;
done &

#Extract values 0= intersected and 1= intersected
for i in *.sorted;
do
cut -f 4 $i > $i.value;
done &


#Create Table
paste GRCh38.Serial.Number.txt *.value | cut -f 1,2,3,5,6,7 > GM12878.txt

#Quality Check
#control one sample with value 1 chek the pattern in the 3 files. After check the values (i.e. 110 or 010 etc..) control if after the merging they have the same pattern






