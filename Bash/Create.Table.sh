#Start New Analysis with CTCF

#Create list of files
a=/media/tandrean/Elements/PhD/ChIP-profile/New.Test.Steffen.Data/ChIP.GM12878/EN*.bed

#Extract chr start end and select q.val <= 0.05
for i in $a ;
do
awk '$9 >= 1.3' $i | sort -k1,1 -k2,2n > $i.q.val.thr.0.05.sort.bed;
done

#Intersect
for i in *.q.val.thr.0.05.sort.bed;
do
bedtools intersect -a GRCh38.Serial.Number.txt -b $i -u | awk '{$4=1}1'  | awk '{print $1"\t"$2"\t"$3"\t"$4}' > $i.intersected.GRCh38.400bp
done

#Intersect
for i in *.q.val.thr.0.05.sort.bed;
do
bedtools intersect -a GRCh38.Serial.Number.txt -b $i -v | awk '{$4=0}1'  | awk '{print $1"\t"$2"\t"$3"\t"$4}' > $i.intersected.GRCh38.400bp.not
done

#Concatenate the Two Files
for f in *.400bp;
do
cat "$f" "$f.not" > "$f.yes.and.not" ;  
done

#Sort the files
for i in *.yes.and.not;
do
sort -k 1,1 -k2,2n $i > $i.sorted;
done

#Extract values 0= intersected and 1= intersected
for i in *.sorted;
do
cut -f 4 $i > $i.value;
done


#Create Table
paste GRCh38.Serial.Number.txt *.value | cut -f 1,2,3,5,6,7 > GM12878.txt
Boehringer Ingelheim

/project/jgu-cbdm/andradeLab/scratch/tandrean/Tools_Script/bismark/bismark_v0.18.0/test.1.mismatch.parallel/unmapped.sample.6/sub.1mln.AS-165429-LR-25517_R1_val_1.fq_ambiguous_reads_1.fq.gz  

/project/jgu-cbdm/andradeLab/scratch/tandrean/Tools_Script/bismark/bismark_v0.18.0/test.1.mismatch.parallel/unmapped.sample.6/sub.1mln.AS-165429-LR-25517_R2_val_2.fq_ambiguous_reads_2.fq.gz
