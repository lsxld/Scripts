read.table("c:/tmp/data.txt",sep="\t",head=T)->data
data[[1]]=log2(data[[1]])
data[[2]]=log2(data[[2]])
P_thresh=0.0001
LR_thresh=1
data_up=data[data[[3]]>LR_thresh & data[[4]]<P_thresh,];nrow(data_up)
data_down=data[data[[3]]<(-LR_thresh) & data[[4]]<P_thresh,];nrow(data_down)
plot(data[[1]],data[[2]],pch='.',col="blue",cex=2,
main="Gene Expression Level 96S vs BtR120",
xlab="Lg(96S)",
ylab="Lg(BtR120)")
points(data_up[[1]],data_up[[2]],pch='.',col='red',cex=2)
points(data_down[[1]],data_down[[2]],pch='.',col='green',cex=2)
legend("topleft",legend=c("Up-regulated genes","Down regulated genes","Not DEGs"),
pch=15,col=c("red","green","blue"))

