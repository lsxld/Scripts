#names(prb)=cpgid pos
moveprb=function(prb)
{
	len=length(prb[[1]])
	rand=round(runif(len,-5,5),0)
	prb$pos=prb$pos+rand
	prb$stop=prb$pos+49
	write.table(prb,"newprb.tab",quote=F,row.names=F,col.names=F,sep="\t")
}
	
