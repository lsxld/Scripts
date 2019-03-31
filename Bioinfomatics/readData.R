readData=function(targets,datacolumns,infocolumns,...)  ###targets is a dataframe containing "Names" and "FileNames"
{
names=as.character(targets$Names)
filenames=as.character(targets$FileNames)
data=list()
length(data)=length(datacolumns)
if(is.null(names(datacolumns)))
names(data)=datacolumns
else
names(data)=names(datacolumns)
for(i in seq(1,length(filenames)))
{
cat(i," :Reading",filenames[i],"\n")
read.table(filenames[i],...)->temp
for(j in seq(1,length(datacolumns)))
{
temp[[datacolumns[j]]]->tempdata
cbind(data[[j]],tempdata)->data[[j]]
colnames(data[[j]])[i]=names[i]
}
}
