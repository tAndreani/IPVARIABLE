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