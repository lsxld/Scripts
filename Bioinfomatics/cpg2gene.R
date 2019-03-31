#names(cpg)=c(id,chr,start,stop)
#names(gene)=c(name,chr,start,stop)
cpg2gene=function(chr,cpg,gene)
{
	cat(chr[1],"\n")
	cpg=cpg[cpg$chr==chr[1],]
	gene=gene[gene$chr %in% chr[1],]
	cbind(cpg$start,cpg$stop)->cpg
	one2gene=function(x,gene)
	{
		cpgstart=x[1]
		cpgstop=x[2]
		genestart=gene$start
		genestop=gene$stop
		genename="none"
		starti=which(genestart<cpgstart & genestop>cpgstart)
		startin=(length(starti)!=0)
		if(startin==T)
		{
			genename=gene$name[starti[1]]
		}
		stopi=which(genestart<cpgstop & genestop>cpgstop)
		stopin=(length(stopi)!=0)
		if(stopin==T)
		{
			genename=gene$name[stopi[1]]
		}
		if((startin && stopin)==T)
		{
			i=starti[1]
			cpgpos="In"
			startdis=cpgstart-genestart[i]
			stopdis=genestop[i]-cpgstop
			dis=min(startdis,stopdis)
		}
		else if((startin || stopin)==T)
		{
			cpgpos="On"
			if(startin==T)
			{
				i=starti[1]
				startdis=genestop[i]-cpgstart
				stopdis=cpgstop-genestop[i]
				dis=min(startdis,stopdis)
			}
			else
			{
				i=stopi[1]
				startdis=genestart[i]-cpgstart
				stopdis=cpgstop-genestart[i]
				dis=min(startdis,stopdis)
			}
		}
		else
		{
			cpgpos="Out"
			outstartdis=abs(genestop-cpgstart)
			outstopdis=abs(genestart-cpgstop)
			iistart=order(outstartdis)[1]
			iistop=order(outstopdis)[1]
			if(outstartdis[iistart]>outstopdis[iistop])
			{
				genename=gene$name[iistop]
				startdis=genestart[iistop]-cpgstart
				stopdis=genestart[iistop]-cpgstop
				dis=startdis
			}
			else
			{
				genename=gene$name[iistart]
				startdis=cpgstart-genestop[iistart]
				stopdis=cpgstop-genestop[iistart]
				dis=stopdis
			}
		}
		as.character(genename)->genename
		c(startin,stopin,cpgpos,genename,startdis,stopdis,dis)
	}
	cpg2gene=apply(cpg,1,one2gene,gene=gene)
	cpg2gene=as.data.frame(t(cpg2gene))
	cpg2gene[[1]]=as.logical(as.character(cpg2gene[[1]]))
	cpg2gene[[2]]=as.logical(as.character(cpg2gene[[2]]))
	cpg2gene[[5]]=as.integer(as.character(cpg2gene[[5]]))
	cpg2gene[[6]]=as.integer(as.character(cpg2gene[[6]]))
	cpg2gene[[7]]=as.integer(as.character(cpg2gene[[7]]))
	cpg2gene
}

read.table("cpg.tmp",head=T,sep="\t",quote="")->cpg
read.table("gene.tmp",head=T,sep="\t",quote="")->gene
cpg[order(cpg$chr,cpg$start),]->cpg
cpg[cpg$chr %in% gene$chr ,]->cpg
chrlist=factor(cpg$chr)
cpg$chr=chrlist
tapply(cpg$chr,chrlist,cpg2gene,cpg=cpg,gene=gene)->temp
result=data.frame()
length(result)=7
for(i in 1:length(temp))
{
	rbind(result,temp[[i]])->result
}

result$chr=cpg$chr
names(result)=c("startin","stopin","cpgpos","genename","startdis","stopdis","dis","chr")
result$side[result$cpgpos=="In" & result$startdis<result$stopdis]="Left"
result$side[result$cpgpos=="In" & result$startdis>=result$stopdis]="Right"
result$side[result$cpgpos=="On" & result$stopin==T]="Left"
result$side[result$cpgpos=="On" & result$startin==T]="Right"
result$side[result$cpgpos=="Out" & result$startdis>result$stopdis]="Left"
result$side[result$cpgpos=="Out" & result$startdis<result$stopdis]="Right"
data.frame(chr=result$chr,label=result$cpgpos,start=cpg$start,stop=cpg$stop,
cpgname=cpg$id,nearestgene=result$genename,side=result$side,
distance=result$dis)->output
write.table(output,"cpg2gene.tmp",quote=F,row.names=F,col.names=F,sep="\t")
