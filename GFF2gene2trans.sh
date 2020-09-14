#!/bin/bash


#=============================GFF2gene2trans.sh====================================#
#extract a gene to transcript tab-separated list for use with RSEM from .gff files
#requires a GFF file in which the 9th column harbors gene and transcript IDs of the format:
#gene_id: BLAEV0054261
#transcript_id: BLAEV0054261-RA
#use: source GFF2gene2trans.sh {GFF}
#Marc Beringer 2020g.2

###parameters
GFF=$1
###

#extract the 9th column and from the 9th column only the transcript and gene IDs
cut -f9 ${GFF} | cut -d ";" -f1,2 | grep BLAEV | sed "s/[=;,]/\t/g" | cut -f2,4  > temp1.txt

#split the file to seperately reformat the first column of temp1.txt
cut -f1 temp1.txt | cut -d ":" -f1 > trans_temp.txt

#and extract gene names from the second column of temp1.txt
cut -f2 temp1.txt | cut -d "-" -f1 > gene_temp.txt

#paste them together to fit the format: gene_id\ttranscript_id and collect only unique entries
paste gene_temp.txt trans_temp.txt | uniq | awk '!($1==$2)' > gene_trans_map.txt

#cleanup temporaries
rm temp1.txt
rm trans_temp.txt
rm gene_temp.txt
