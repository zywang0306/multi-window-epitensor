rm(list=ls())

library("R.matlab")

options(warn=-1)

args = commandArgs(trailingOnly=T);

chipfile = "";
inputfile = "";
covpath = "";
covfile = "";
genome = "";

##### Extract argument values #####

for (i in 1:length(args))
{
  arg = args[i];
  if (grepl("-chipfile=",arg)==T)
  {
    k = regexpr("-chipfile=",arg);
    k1 = k[[1]] + attr(k,"match.length"); # parameter starting position
    k2 = nchar(arg); # parameter stoping position
    chipfile = substr(arg,k1,k2);
  } else if (grepl("-inputfile=",arg)==T)
  {
    k = regexpr("-inputfile=",arg);
    k1 = k[[1]] + attr(k,"match.length"); # parameter starting position
    k2 = nchar(arg); # parameter stoping position
    inputfile = substr(arg,k1,k2);
  } else if (grepl("-covpath=",arg)==T)
  {
    k = regexpr("-covpath=",arg);
    k1 = k[[1]] + attr(k,"match.length"); # parameter starting position
    k2 = nchar(arg); # parameter stoping position
    covpath = substr(arg,k1,k2);
  } else if (grepl("-covfile=",arg)==T)
  {
    k = regexpr("-covfile=",arg);
    k1 = k[[1]] + attr(k,"match.length"); # parameter starting position
    k2 = nchar(arg); # parameter stoping position
    covfile = substr(arg,k1,k2);
  } else if (grepl("-Genome=",arg)==T)
  {
    k = regexpr("-Genome=",arg);
    k1 = k[[1]] + attr(k,"match.length"); # parameter starting position
    k2 = nchar(arg); # parameter stoping position
    genome = substr(arg,k1,k2);
  } else if (grepl("-codepath=",arg)==T)
  {
    k = regexpr("-codepath=",arg);
    k1 = k[[1]] + attr(k,"match.length"); # parameter starting position
    k2 = nchar(arg); # parameter stoping position
    codepath = substr(arg,k1,k2);
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
if (chipfile=="" || file.exists(chipfile)==F)
{
  print("-c|--chipfile is empty or does not exist!\n");
  ret = F;
} else if (covpath=="")
{
  print("-o|--covpath is empty!\n");
  ret = F;
} else if (covfile=="")
{
  print("-r|--covfile is empty!\n");
  ret = F;
} else if (genome!="hg19" && genome!="test")
{
  print("-g|--Genome must be hg19 or test!\n");
  ret = F;
}

##### if the arguments are valid, output these arguments to a file #####

if (ret==T)
{
  if (is.na(file.info(covpath)$isdir==T))
  {
    command = paste("mkdir --parent ",covpath,sep="");
    system(command);
  }
  
  if (genome=="hg19")
  {
    chromsizefile = paste(codepath,"/hg19chromsize.txt",sep="");
  } else if (genome=="test")
  {
    chromsizefile = paste(codepath,"/testchromsize.txt",sep="");
  }
  
  writeMat(arglistfile,chipfile=chipfile,inputfile=inputfile,covpath=covpath,covfile=covfile,chromsizefile=chromsizefile);
}
  
rm(list=ls())
  