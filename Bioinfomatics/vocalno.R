vocalno.plot=function(lograt,pval,thresh_lr,thresh_pval,...)
{
up=(lograt>thresh_lr & pval<thresh_pval)
down=(lograt<(-thresh_lr) & pval<thresh_pval)
plot(lograt,-log10(pval),xlab="Log2(FoldChange)",ylab="-Log10(Pvalue)",yaxs="i",xaxs="i",xlim=c(-3,3),...)
points(lograt[up],-log10(pval)[up],col='red',pch=16)
points(lograt[down],-log10(pval)[down],col='green',pch=16)
abline(v=thresh_lr,lty=2)
abline(v=-thresh_lr,lty=2)
abline(h=-log10(thresh_pval),lty=2)
}
setwd("c:/tmp")
read.table("data.txt",head=T)->data



Pval=data[[3]]
Lograt=log2(data[[4]])
Lograt[data[[5]]=="down"]=-Lograt[data[[5]]=="down"]
vocalno.plot(-Lograt,Pval,1,0.05,pch=16,cex=0.5,main="PFNA2 VS Control")


Pval=data[[6]]
Lograt=log2(data[[7]])
Lograt[data[[8]]=="down"]=-Lograt[data[[8]]=="down"]
vocalno.plot(-Lograt,Pval,1,0.05,pch=16,cex=0.5,main="PFNA3 VS Control")


Pval=data[[9]]
Lograt=log2(data[[10]])
Lograt[data[[11]]=="down"]=-Lograt[data[[11]]=="down"]
vocalno.plot(Lograt,Pval,1,0.05,pch=16,cex=0.5,main="PFNA2 VS PFNA3")