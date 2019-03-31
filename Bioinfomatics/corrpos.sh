#!/bin/bash
inputfile=$1;
outputfile=$2;
Rscript=~/WorkFiles/script/corrpos.R
awk -F ";" '{print $1"\t"$2"\t"$3}' $inputfile >temp
R --vanilla -q <$Rscript
rm temp
mv tempout $outputfile

