probe2CpG=function(inputfile,outfile,between=1000)
{
	cat("Reading \"",inputfile,"\" ...\n",sep="")
	read.table(inputfile,head=T)->probe
	newprobe=probe
	cat("Reading Completed!\n")
	ii=order(probe$CHROMOSOME,probe$POSITION)
	len=length(ii)
	cat(len," probes readed.\n")
	probe=probe[ii,]
	dis=diff(probe$POSITION)
	ord=which(dis>between|dis<0)
	beginord=c(1,ord+1)
	endord=c(ord,len)
	cpgcount=length(beginord)
	result=list()
	result$chr=probe$CHROMOSOME[beginord]
	result$begin=probe$POSITION[beginord]
	result$end=probe$POSITION[endord]
	result$probecount=endord-beginord+1
	probe2CpG=as.data.frame(result)
	CpGNo=rep(1:cpgcount,result$probecount)
	newprobe$CpGNo[ii]=CpGNo
	probe$CpGNo=CpGNo
	paste(outfile,".cpg",sep="")->outputfile
	paste(outfile,".No",sep="")->newprobefile
	write.table(probe2CpG,outputfile,quote=F,row.names=F,sep="\t")
	write.table(probe,newprobefile,quote=F,row.names=F,sep="\t")
	cat(length(ord)," CpGs had been found.\n")
	cat("Output file:\n")
	cat(outputfile,"\n")
	cat(newprobefile,"\n")
	probe2CpG
}
nimble=probe2CpG("../data/nimble.pos","../data/output/nimble",500)
#cat("\n")
#five=probe2CpG("../data/507.pos","../data/output/507",1000)
