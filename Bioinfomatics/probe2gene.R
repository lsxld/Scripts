##Help you map short seq to long seq by there position and chr
	one2gene=function(x,gene)
	{
		probecenter=x[1]
		probehalflen=x[2]
		genecenter=gene[,1]
		genehalflen=gene[,2]
		geneid="none"
		centerdis=abs(genecenter-probecenter)
		halflendis=abs(genehalflen+probehalflen)
		starti=which(centerdis<halflendis)
		startin=(length(starti)!=0)
		if(startin==T)
		{
			geneid=gene[,3][starti[1]]
		}
		else
			geneid="none"
		as.character(geneid)->geneid
	}
probe2gene=function(chr,probe,gene)
{
	cat(chr[1],"\n")
	probe=probe[probe$chr==chr[1],]
	gene=gene[gene$chr %in% chr[1],]
	cbind((probe$start+probe$stop)/2,(probe$stop-probe$start)/2)->probe
	cbind((gene$start+gene$stop)/2,(gene$stop-gene$start)/2,gene$id)->gene
	probe2gene=apply(probe,1,one2gene,gene=gene)
}
exon->gene
probeset->probe
probe[order(probe$chr,probe$start),]->probe
probe[probe$chr %in% gene$chr ,]->probe
chrlist=factor(probe$chr)
tapply(probe$chr,chrlist,probe2gene,probe=probe,gene=gene)->temp
write.table(probe,"probe2gene.tmp",quote=F,row.names=F,col.names=F,sep="\t")
