#!/bin/bash
input=$1
output=$2
Rscript=~/WorkFiles/script/cpgvalue.R
awk -F "\t" '{print $1"\t"$4"\t"$5"\t"$6"\t"$9}' $input >tmp
awk -F ";" '{print $1}' tmp >temp
rm tmp
R --vanilla -q < $Rscript
awk -F "\t" '{print $1"\tSBC\tCpgisland\t"$2"\t"$3"\t"$4"\t.\t.\t"$5}' temp.cpg >$output
rm temp.cpg
rm temp

