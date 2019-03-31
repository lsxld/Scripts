#!/bin/bash
cpginput=$1
geneinput=$2
output=$3
Rscript=~/WorkFiles/script/cpg2gene.R
cp $cpginput cpg.tmp
cp $geneinput gene.tmp
R --vanilla -q <$Rscript
rm cpg.tmp gene.tmp
mv cpg2gene.tmp $output
