findsimilar=function(x,mid,half,l)
{
	xmid=x[1]
	xhalf=x[2]
	abs(mid-xmid)->dis
	half+xhalf->len
	which((dis-len)<l)->similarindex
	if(length(similarindex)==0)
		NA
	else
		similarindex[1]
}

compare=function(nimble,five)
{
	fiv.mid=(five$begin+five$end)/2
	nimble.mid=(nimble$begin+nimble$end)/2
	fiv.halflen=(five$end-five$begin)/2
	nimble.halflen=(nimble$end-nimble$begin)/2
	chr=factor(nimble$chr)
	cumsum(table(factor(five$chr)))->count
	l=length(levels(five$chr))
	count[2:(l+1)]=count
	count[1]=0
	chr=levels(chr)
	nimble.include=c()
	for(tmpchr in chr)
	{
		five.mid=fiv.mid[five$chr==tmpchr]
		nim.mid=nimble.mid[nimble$chr==tmpchr]
		nim.half=nimble.halflen[nimble$chr==tmpchr]
		five.half=fiv.halflen[five$chr==tmpchr]
		cbind(nim.mid,nim.half)->nim
		nim.len=length(nim.mid)
		five.len=length(five.mid)
		apply(nim,1,findsimilar,mid=five.mid,half=five.half,l=0)->result
		result=result+count[tmpchr]
		nimble.include=c(nimble.include,result)
	}
	nimble.include
}

cat("Comparing....\n")
nimble$infive=compare(nimble,five)
temp=nimble$infive[!is.na(nimble$infive)]
temp1=which(!is.na(nimble$infive))
five$innimble=rep(NA,length(five[[1]]))
five$innimble[temp]=temp1
rm(temp,temp1)

cat("Creating files....\n")
both=nimble[!is.na(nimble$infive),]
nimonly=nimble[is.na(nimble$infive),]
fiveonly=five[is.na(five$innimble),]

write.table(both,"../data/output/both.cpg",sep="\t",quote=F,row.names=F)
write.table(nimonly,"../data/output/nimonly.cpg",sep="\t",quote=F,row.names=F)
write.table(fiveonly,"../data/output/fiveonly.cpg",sep="\t",quote=F,row.names=F)

cat("Output file:\n")
cat("../data/output/\n\t")
cat("both.cpg","nimonly.cpg","five.cpg",sep="\n\t")
cat("\n")

cat("Creating image...\n")
pielabel=c("507 only","nimble only","both")
pievalue=c(length(fiveonly[[1]]),length(nimonly[[1]]),length(both[[1]]))
pie(pievalue,labels=pielabel,col=c(3,2,7))
data.frame(value=pievalue,row.names=pielabel)
rm(pielabel,pievalue)
