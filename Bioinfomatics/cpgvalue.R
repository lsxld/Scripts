read.table("temp",head=F)->probevalue
cpg=factor(probevalue[[5]])
tapply(probevalue[[4]],cpg,mean)->cpgvalue
cpgvalue=round(cpgvalue,2)
as.data.frame(cpgvalue)->cpgvalue
cpgvalue$begin=tapply(probevalue[[2]],cpg,min)
cpgvalue$end=tapply(probevalue[[3]],cpg,max)
cpgvalue$cpgid=row.names(cpgvalue)
probevalue[[1]][match(cpgvalue[[4]],probevalue[[5]])]->cpgvalue$chr
write.table(cpgvalue[,c(5,2,3,1,4)],"temp.cpg",quote=F,row.names=F,col.names=F,sep="\t")

