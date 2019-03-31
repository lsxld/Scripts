read.table("temp",head=F)->exper
read.table("~/WorkFiles/data/output/nimble.tab",head=T)->nimble
i=match(exper[[10]],nimble$probeid)
if(length(i[i<0])!=0)
{
	w=which(i<0)
	cat("Error match line:","\n",w,"\n")
	q()
}
exper[[1]]=nimble$chr[i]
exper[[4]]=nimble$chrstart[i]
exper[[5]]=nimble$chrstop[i]
exper[[9]]=paste(exper[[9]],exper[[10]],exper[[11]],sep=";")
write.table(exper[,1:9],"tempout",row.names=F,col.names=F,quote=F,sep="\t")
