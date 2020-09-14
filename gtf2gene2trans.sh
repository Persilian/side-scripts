#!/bin/bash


#=============================gtf2gene2trans.sh====================================#
#extract a gene to transcript tab-separated list for use with RSEM from .gtf files
#requires a gtf file with the 9th column being of the format:
#transcript_id "AT1G01010.1"; gene_id "AT1G01010";
#use: source gtf2gene2trans.sh {gtf}
#Marc Beringer 2020g

###parameters
gtf=$1
###

#extract the 9th column
cut -f9 ${gtf} > temp1.txt

#remove special characters
sed "s/;//g" temp1.txt | sed "s/\"//g" > temp2.txt

#extract columns transcripts and genes
cut -d " " -f2 temp2.txt > trans_temp.txt
cut -d " " -f4 temp2.txt > gene_temp.txt

#paste them together to fit the format: gene_id\ttranscript_id
paste gene_temp.txt trans_temp.txt > temp3.txt

#collect all unique entries
uniq temp3.txt > gene2trans_map.txt

#previously miRNA entries had to be removed due to a corrupted gtf file
#this is not necessary anymore, as a curator has uploaded a viable gtf
#miRNA entries can now be kept for RSEM - NOT VALIDATED YET
#| sed "/ath-mi/d" > gene2trans_map.txt

#cleanup temporaries
rm temp1.txt
rm temp2.txt
rm temp3.txt
rm trans_temp.txt
rm gene_temp.txt
