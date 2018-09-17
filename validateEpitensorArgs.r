rm(list=ls())

library("R.matlab")

args = commandArgs(trailingOnly=T);

datamatrixfile = "";
annofile = "";
outpath = "";
workpath = "";
genome = "";
chr = "";

##### Extract argument values #####

for (i in 1:length(args))
{
  arg = args[i];
  if (grepl("-datamatrix=",arg)==T)
  {
    k = regexpr("-datamatrix=",arg);
    k1 = k[[1]] + attr(k,"match.length"); # parameter starting position
    k2 = nchar(arg); # parameter stoping position
    datamatrixfile = substr(arg,k1,k2);
  } else if (grepl("-anno=",arg)==T)
  {
    k = regexpr("-anno=",arg);
    k1 = k[[1]] + attr(k,"match.length"); # parameter starting position
    k2 = nchar(arg); # parameter stoping position
    annofile = substr(arg,k1,k2);
  } else if (grepl("-outpath=",arg)==T)
  {
    k = regexpr("-outpath=",arg);
    k1 = k[[1]] + attr(k,"match.length"); # parameter starting position
    k2 = nchar(arg); # parameter stoping position
    outpath = substr(arg,k1,k2);
  } else if (grepl("-workpath=",arg)==T)
  {
    k = regexpr("-workpath=",arg);
    k1 = k[[1]] + attr(k,"match.length"); # parameter starting position
    k2 = nchar(arg); # parameter stoping position
    workpath = substr(arg,k1,k2);
  } else if (grepl("-Genome=",arg)==T)
  {
    k = regexpr("-Genome=",arg);
    k1 = k[[1]] + attr(k,"match.length"); # parameter starting position
    k2 = nchar(arg); # parameter stoping position
    genome = substr(arg,k1,k2);
  } else if (grepl("-chr=",arg)==T)
  {
    k = regexpr("-chr=",arg);
    k1 = k[[1]] + attr(k,"match.length"); # parameter starting position
    k2 = nchar(arg); # parameter stoping position
    chr = substr(arg,k1,k2);
  } else if (grepl("-scriptpath=",arg)==T)
  {
    k = regexpr("-scriptpath=",arg);
    k1 = k[[1]] + attr(k,"match.length"); # parameter starting position
    k2 = nchar(arg); # parameter stoping position
    scriptpath = substr(arg,k1,k2);
  } else if (grepl("-arglistfile=",arg)==T)
  {
    k = regexpr("-arglistfile=",arg);
    k1 = k[[1]] + attr(k,"match.length"); # parameter starting position
    k2 = nchar(arg); # parameter stoping position
    arglistfile = substr(arg,k1,k2);
  }
}


##### validate arguments #####

ret = T;
if (datamatrixfile=="" || file.exists(datamatrixfile)==F)
{
  print("-f|--datamatrix is empty or does not exist!\n");
  ret = F;
} else if (annofile=="" || file.exists(annofile)==F)
{
  print("-h|--anno is empty or does not exist!\n");
  ret = F;
} else if (outpath=="")
{
  print("-o|--outpath is empty!\n");
  ret = F;
} else if (workpath=="")
{
  print("-w|--workpath is empty!\n");
  ret = F;
} else if (genome!="hg19" && genome!="test")
{
  print("-g|--Genome must be hg19 or test!\n");
  ret = F;
} else if (chr=="")
{
  print("-c|--chr is empty!\n");
  ret = F;
} 

##### if the arguments are valid, output these arguments to a file #####

if (ret==T)
{
  if (is.na(file.info(workpath)$isdir==T))
  {
    command = paste("mkdir --parent ",workpath,sep="");
    system(command);
  }
  
  inputpath = paste(workpath,"input/",sep="");
  if (is.na(file.info(inputpath)$isdir)==T)
  {
    command = paste("mkdir --parent ",inputpath,sep="");
    system(command);
  }
  
  mpcapath = paste(workpath,"mpca/",sep="");
  if (is.na(file.info(mpcapath)$isdir)==T)
  {
    command = paste("mkdir --parent ",mpcapath,sep="");
    system(command);
  }
  
  bedgraphpath = paste(workpath,"bedgraph/",sep="");
  if (is.na(file.info(bedgraphpath)$isdir)==T)
  {
    command = paste("mkdir --parent ",bedgraphpath,sep="");
    system(command);
  }
  
  peakpath = paste(workpath,"peak/",sep="");
  if (is.na(file.info(peakpath)$isdir)==T)
  {
    command = paste("mkdir --parent ",peakpath,sep="");
    system(command);
  }
  
  peakannopath = paste(workpath,"peakanno/",sep="");
  if (is.na(file.info(peakannopath)$isdir)==T)
  {
    command = paste("mkdir --parent ",peakannopath,sep="");
    system(command);
  }
  
  pairpath = paste(workpath,"pair/",sep="");
  if (is.na(file.info(pairpath)$isdir)==T)
  {
    command = paste("mkdir --parent ",pairpath,sep="");
    system(command);
  }

  if (is.na(file.info(outpath)$isdir)==T)
  {
    command = paste("mkdir --parent ",outpath,sep="");
    system(command);
  }
  
  if (genome=="hg19")
  {
    domainfile=paste(scriptpath,"/hg19domain.bed",sep="");
    chromsizefile = paste(scriptpath,"/hg19chromsize.txt",sep="");
  } else if (genome=="test")
  {
    domainfile=paste(scriptpath,"/testdomain.bed",sep="");
    chromsizefile = paste(scriptpath,"/testchromsize.txt",sep="");
  }
  
  varnames = c("datamatrixfile","annofile","workpath","inputpath","mpcapath","bedgraphpath","peakpath","peakannopath","pairpath","outpath","chr","domainfile","chromsizefile","scriptpath");
  vals = c(datamatrixfile,annofile,workpath,inputpath,mpcapath,bedgraphpath,peakpath,peakannopath,pairpath,outpath,chr,domainfile,chromsizefile,scriptpath);
  arglist = list(varnames,vals);
  write.table(arglist,file=arglistfile,quote=F,row.names=F,col.names=F,sep="\t");
}

rm(list=ls())
