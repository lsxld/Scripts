vocalno.plot=function(lograt,pval,thresh_lr,thresh_pval,linewd=1.7,col_line="black",col_down="blue",col_up="red",col_norm="black",...)
{
up=(lograt>thresh_lr & pval<thresh_pval)
down=(lograt<(-thresh_lr) & pval<thresh_pval)
plot(lograt,-log10(pval),xlab="Log2(Ratio)",ylab="-Lg(FDR)",yaxs="i",xaxs="i",col=col_norm,...)
points(lograt[up],-log10(pval)[up],col=col_up,pch=20)
points(lograt[down],-log10(pval)[down],col=col_down,pch=20)
abline(v=thresh_lr,col=col_line,lwd=linewd)
abline(v=-thresh_lr,col=col_line,lwd=linewd)
abline(h=-log10(thresh_pval),col=col_line,lwd=linewd)

}

read.table("c:/tmp/data.txt",head=T,sep="\t")->data



Pval=data[[3]]
Lograt=data[[1]]
col_point_norm="indianred3"
col_point_diff="steelblue3"
col_line_thresh="lightgreen"
vocalno.plot(Lograt,Pval,1,0.001,linewd=3,col_line=col_line_thresh,col_up=col_point_diff,
col_down=col_point_diff,col_norm=col_point_norm,pch=16,cex=0.7,main="Volcano plot",ylim=c(0,30),xlim=c(-10,10))
legend("topright",legend=c("Less reliable points","More reliable points"),pch=16,
col=c(col_point_norm,col_point_diff),bty='n')
