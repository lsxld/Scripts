#names(cpg)=c(id,chr,start,stop)
#names(promoter)=c(id,chr,start,stop)
cpg2promoter=function(chr,cpg,promoter)
{
	cat(chr[1],"\n")
	cpg=cpg[cpg$chr==chr[1],]
	promoter=promoter[promoter$chr %in% chr[1],]
	cbind((cpg$start+cpg$stop)/2,cpg$stop-cpg$start)->cpg
	one2promoter=function(x,promoter)
	{
		cpgcenter=x[1]
		cpghalflen=x[2]
		promotercenter=(promoter$start+promoter$stop)/2
		promoterhalflen=promoter$stop-promoter$start
		promoterid="none"
		centerdis=abs(promotercenter-cpgcenter)
		halflendis=abs(promoterhalflen-cpghalflen)
		starti=which(centerdis<halflendis)
		startin=(length(starti)!=0)
		if(startin==T)
		{
			promoterid=promoter$id[starti[1]]
		}
		else
			promoterid="none"
		as.character(promoterid)->promoterid
	}
	cpg2promoter=apply(cpg,1,one2promoter,promoter=promoter)
}

read.table("cpg.tmp",head=T)->cpg
read.table("promoter.tmp",head=T)->promoter
cpg[order(cpg$chr,cpg$start),]->cpg
cpg[cpg$chr %in% promoter$chr ,]->cpg
chrlist=factor(cpg$chr)
cpg$chr=chrlist
tapply(cpg$chr,chrlist,cpg2promoter,cpg=cpg,promoter=promoter)->cpg$promoterid
write.table(cpg,"cpg2promoter.tmp",quote=F,row.names=F,col.names=F,sep="\t")
