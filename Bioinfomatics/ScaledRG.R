ScaledRG=function(x,mid=0,len=256)
{
as.vector(x)->x
abs(max(x)-mid)->M
abs(min(x)-mid)->m
RGvec=0
if(M>=m)
{
s=seq(m/M,0,length.out=m/(M+m)*len)
#s=s[seq(1,length(s)-1)]
S=seq(0,1,length.out=M/(m+M)*len)
RGvec=c(rgb(0,s,0),rgb(S,0,0))
}
if(m>M)
{
s=seq(1,0,length.out=m/(M+m)*len)
#s=s[seq(1,length(s)-1)]
S=seq(0,M/m,length.out=M/(m+M)*len)
RGvec=c(rgb(0,s,0),rgb(S,0,0))
}
RGvec
}
