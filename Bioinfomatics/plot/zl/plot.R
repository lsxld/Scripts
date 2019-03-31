read.table("MEF_IPS.txt",sep="\t",head=T,stringsAsFactors=F)->data
xlabel="iPS"
ylabel="MEF"
data[,c(2,3)]=data[,c(3,2)];colnames(data)[c(2,3)]=colnames(data)[c(3,2)]   ##################If do not need swap, comment this line##############
Probe=c("1429388_at","1437752_at","1417394_at","1417395_at","1416967_at","1417945_at","1424942_a_at")
# Nanog Lin28 Klf4 Klf4 Sox2 Oct4 c-myc
line=match(Probe,data[[1]])
pdata=data[line,]
data=data[data[[4]]=="P" & data[[5]]=="P",]
log2(data[[2]])->data[[2]]
log2(data[[3]])->data[[3]]
log2(pdata[[2]])->pdata[[2]]
log2(pdata[[3]])->pdata[[3]]


red=(data[[2]]>data[[3]])
#par(xaxs="i",yaxs="i")
plot(data[red,2],data[red,3],xlim=c(3,17),ylim=c(3,17),xlab=xlabel,ylab=ylabel,col="red",cex=2,pch=".",axes=F,frame.plot=T)
axis(1,at=seq(4,16,2),labels=seq(4,16,2))
axis(2,at=seq(4,16,2),labels=seq(4,16,2))
points(data[!red,2],data[!red,3],col="blue",cex=2,pch=".")
abline(a=0,b=1,lwd=2)
abline(a=1,b=1,lwd=2)
abline(a=-1,b=1,lwd=2)

name=c("Nanog","Lin28","Klf4","Klf4","Sox2","Oct4","c-myc")
pos_x=c(16,	9,	15,	14,	16,	10,	5)
#pos_y=c(3,	4,	11,	8,	7,	3,	11)
pos_y=pdata[,3]
for(i in 1:7)
{
points(pdata[i,2],pdata[i,3],col="black",cex=1.2,pch=16)
points(pdata[i,2],pdata[i,3],col="darkgreen",cex=0.9,pch=16)
text(pos_x[i],pos_y[i],name[i])
lines(c(pdata[i,2],pos_x[i]),c(pdata[i,3],pos_y[i]),lwd=2)
}