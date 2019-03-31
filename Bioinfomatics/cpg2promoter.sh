#!/bin/bash
cpginput=$1
promoterinput=$2
output=$3
Rscript=~/WorkFiles/script/cpg2promtoer.R
cp $cpginput cpg.tmp
cp $promoterinput promoter.tmp
R --vanilla -q <$Rscript
rm cpg.tmp promoter.tmp
mv cpg2promoter.tmp $output
