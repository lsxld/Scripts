#!/bin/bash
#names(cpg)= cpgid start stop
cpgfile=$1
prbfile=$2
Rscript=~/WorkFiles/script/cpg2prb.R
cp $cpgfile cpg.tmp
R --vanilla -q <$Rscript
rm cpg.tmp
mv prb.tmp $prbfile
