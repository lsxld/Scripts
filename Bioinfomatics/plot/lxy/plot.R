setwd("j:/plot/")
read.table("tmp.txt",row.names=1)->data
data[,c(2,6)]->fold1
data[,c(4,8)]->fold2
t(as.matrix(fold1))->fold1
t(as.matrix(fold2))->fold2
read.table("err.txt")->err
err[,c(1,3)]->err1
err[,c(2,4)]->err2
t(as.matrix(err1))->err1
t(as.matrix(err2))->err2
pos1=seq(1,39,3)
pos2=seq(2,39,3)
pos=as.vector(rbind(pos1,pos2))

par(family="serif",cex=1.2)
barplot(log2(fold1),beside=T,las=3,axes=F,frame.plot=T,ylim=c(-5,5),
ylab="Fold Increase",main="Saline VS Control")->pp
axis(2,at=c(-5:5),labels=c(-(2^c(5:1)),2^c(0:5)),las=1)
for(n in 1:length(pp))
arrows(pp[n],log2(fold1[n])+err1[n],pp[n],log2(fold1[n])-err1[n],code=3,angle=90,length=0.03)
legend("topright",c("Array","PCR"),bty="n",col=c("black","grey"),lwd=8,cex=1)
axis(1,at=apply(pp,2,mean),labels=NA)

par(family="serif",cex=1.2)
barplot(log2(fold2),beside=T,las=3,axes=F,frame.plot=T,ylim=c(-6,6),
ylab="Fold Increase",main="Gabapentin VS Saline")->pp
axis(2,at=c(-6:6),labels=c(-(2^c(6:1)),2^c(0:6)),las=1)
for(n in 1:length(pp))
arrows(pp[n],log2(fold2[n])+err2[n],pp[n],log2(fold2[n])-err2[n],code=3,angle=90,length=0.03)
legend("topright",c("Array","PCR"),bty="n",col=c("black","grey"),lwd=8,cex=1)
axis(1,at=apply(pp,2,mean),labels=NA)

legend("topright",c("¡ñ  Array-Saline/Con","-  Array-gabapentin/Saline",
"*  PCR-Saline/Con","¡ð  PCR-gabapentin/Saline"),bty="n",cex=0.7)

lines(c(0,100),c(0,0))