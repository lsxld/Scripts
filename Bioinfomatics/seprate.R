#find the seprate number in a vector
#for example
#c(1,2,2,1,2,1,10,15,14,17)
#sepvalue=10
sepval=function(x)
{
	iord=order(x)
	ord=x[iord]
	diff(ord)->dif
	sepval=ord[order(dif,decreasing=T)[1]+1]
	sepval
}

#find the index of super high number in a vector
#for example
#c(1,2,10,1,2,20,1,2)
#result=c(3,5)
superhigh=function(x,e)
{
	xfor=x*e;
	xlen=length(x)
	xfor=c(100,xfor[1:xlen-1])
	xaft=x*e;
	xaft=c(xaft[2:xlen],100)
	result=which(x>xfor & x>xaft)
	result
}
