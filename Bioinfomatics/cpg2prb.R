#cpg need at least these 3 name:cpgid start stop
cpg2prb=function(cpg)
{
	splitpos=function(x)
	{
		splitpos=seq(from=x[2],to=x[3],by=50)
		splitpos=splitpos[1:length(splitpos)-1]
		splitpos=cbind(splitpos,rep(x[1],length(splitpos)))
#		t(splitpos)
	}

	cpgid=factor(cpg$cpgid)
	cpg$cpgid=cpgid
	position=cbind(1:length(cpg[[1]]),as.integer(cpg$start),as.integer(cpg$stop))
	apply(position,1,splitpos)->tmp
	tmp=lapply(tmp,t)
	unlist(tmp)->tmp
	dim(tmp)=c(2,length(tmp)/2)
	t(tmp)->tmp
	prb=data.frame(cpgid=cpg$cpgid[tmp[,2]],start=tmp[,1],stop=tmp[,1]+49)
	write.table(prb,"prb.tmp",quote=F,row.names=F,sep="\t",col.names=F)
}
read.table("cpg.tmp",head=T)->cpg
cpg2prb(cpg)

