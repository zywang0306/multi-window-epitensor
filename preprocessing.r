rm(list=ls())

library('spp')
library('R.matlab')

options(warn=-1)

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
  arglist = readMat(arglistfile);
  chipfile = as.character(arglist$chipfile);
  inputfile = as.character(arglist$inputfile);
  covpath = as.character(arglist$covpath);
  covfile = as.character(arglist$covfile);
  chromsizefile = as.character(arglist$chromsizefile);
  
  chrs = read.table(chromsizefile,header=F,sep="\t",quote="");
  chrname = as.character(chrs[[1]]);
  chrsize = as.numeric(as.character(chrs[[2]]));
  
  binsize =200;
  
  chip.tags = read.bam.tags(chipfile);
  chip.tags = chip.tags$tags;
  chip.tags = remove.local.tag.anomalies(chip.tags); 
  
  if(inputfile!="")
  {
    bkgd.tags = read.bam.tags(inputfile);
    bkgd.tags = bkgd.tags$tags;
    bkgd.tags = remove.local.tag.anomalies(bkgd.tags);
    cov = get.smoothed.tag.density(chip.tags,control.tags=bkgd.tags,bandwidth=binsize,step=binsize,tag.shift=0);
  } else if (inputfile=="")
  {
    cov = get.smoothed.tag.density(chip.tags,bandwidth=binsize,step=binsize,tag.shift=0);
  }
  
  cov = cov[names(cov)%in%chrname];
  
  seq_depth = 0;
  cov_norm = vector(mode="list",length(cov));
  for (j in 1:length(cov))
  {
    x1 = cov[[j]]$x;
    y1 = cov[[j]]$y;
    chr1 = which(names(cov[j])==chrname);
    
    xout1 = seq(1,chrsize[chr1],by=binsize);
    yout1 = approx(x1,y1,xout1,yleft=0,yright=0);
    yout1$y[yout1$y<0] = 0;
    
    cov_norm1 = data.frame(x=yout1$x,y=yout1$y);
    cov_norm1 = list(cov_norm1);
    
    cov_norm[j] = cov_norm1;
    names(cov_norm)[j] = chrname[chr1];
    seq_depth = seq_depth + sum(yout1$y);
  }
  
  for (j in 1:length(cov_norm))
  {
    cov_norm[[j]]$y = cov_norm[[j]]$y / seq_depth * sum(chrsize) / 100;
  }
  
  cov = cov_norm;
  save(cov,file=paste(covpath,covfile,sep=""));
}

rm(list=ls())