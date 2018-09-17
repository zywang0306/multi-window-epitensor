rm(list=ls())

library("R.matlab")

args = commandArgs(trailingOnly=T);
for (i in 1:length(args))
{
  arg = args[i];
  if (grepl("-arglistfile=",arg)==T)
  {
    k = regexpr("-arglistfile=",arg);
    k1 = k[[1]] + attr(k,"match.length"); # parameter starting position
    k2 = nchar(arg); # parameter stoping position
    arglistfile = substr(arg,k1,k2);
  }
}

if (file.exists(arglistfile)==T)
{
  arglist = read.table(arglistfile,sep="\t");
  varnames = as.character(arglist[[1]]);
  vals = as.character(arglist[[2]]);
  
  for (i in 1:length(varnames))
  {
    varname = varnames[i];
    val = vals[i];
    if (is.numeric(val)==T)
    {
      val = as.numeric(val);
      command = paste(varname,"=",val,sep="");
      eval(parse(text=command));
    } else {
      command = paste(varname,"=\"",val,"\"",sep="");
      eval(parse(text=command));
    }
  }
  
  if (is.na(file.info(bedgraphpath)$isdir)==T)
  {
    command = paste("mkdir --parent ",bedgraphpath,"");
    system(command);
  }
  
  matpath = mpcapath;
  matfiles = dir(matpath,"*.mat",ignore.case=T);
  for (i in 1:length(matfiles))
  {
    matfile = matfiles[i];
    mat = readMat(paste(matpath,matfile,sep=""));
    U3 = mat$U3;
    chr = as.character(mat$chr);
    start = as.numeric(mat$start);
    stop = as.numeric(mat$stop);
    
    K = dim(U3)[1];
    C = dim(U3)[2];
    for (c in 1:C)
    {
      xx = round(seq(start,stop,length.out=K));
      yy = U3[,c];
      yy = abs(500*yy);
      yy = round(yy,2);
      bedgraphfile = sub(".mat","",matfile);
      bedgraphfile = paste(bedgraphfile,"_U3_",c,".bedgraph",sep="");
      
      bedgraph = list(chr=chr,start=xx,stop=xx+200,value=yy);
      write.table(bedgraph,file=paste(bedgraphpath,bedgraphfile,sep=""),quote=F,sep="\t",row.names=F,col.names=F);
    }
  }
}

rm(list=ls())
