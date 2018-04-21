cd /project/jgu-cbdm/andradeLab/scratch/tandrean/Data/ChIP.Reproducibility/Classification/
module avail
module load bio/BEDTools/2.26.0-foss-2017a
cat Noisy.Regions.bed | awk '{print $1"\t"$2"\t"$3"\t"1}
cat Noisy.Regions.bed | awk '{print $1"\t"$2"\t"$3"\t"1}' | head
cat Noisy.Regions.bed | awk '{print $1"\t"$2"\t"$3"\t"1}' > Noisy.Regions.Number.bed
cat Sticky.Regions.bed | awk '{print $1"\t"$2"\t"$3"\t"0}' > Sticky.Regions.Number.bed
cat *Number* | sort -k 1,1 -k2,2n > Sticky.Noisy.bed
bedtools intersect -a ENCFF721JMB.cov.major.egual.10.Meth.bed -b Sticky.Noisy.bed -wb > Meth.Values.Noisy.And.Sticky.bed
wget http://ftp.gnu.org/gnu/datamash/datamash-1.3.tar.gz
tar -xzf datamash-1.3.tar.gz
cd datamash-1.3/
./configure
make
make check
make install
cat Meth.Values.Noisy.And.Sticky.bed | awk '{print $5"_"$6"_"$7"\t"$4"\t"$8}' > Format.Noisy.Sticky.bed
datamash-1.3/datamash -g 1 mean 2 < Format.Noisy.Sticky.bed > tmp
cat Meth.Values.Noisy.And.Sticky.bed | cut -f 5- | uniq > Only.Sticky.Noisy.bed
paste Only.Sticky.Noisy.bed tmp > Only.Sticky.Noisy.Meth.Mean.bed
cat Only.Sticky.Noisy.Meth.Mean.bed | cut -f 1,2,3,4,6 > Sticky.Noisy.Meth.Mean.bed
