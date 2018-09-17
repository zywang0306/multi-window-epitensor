rm(list=ls())

library("R.matlab")

# arglistfile = "/mnt/hgfs/ucsd/mywork/summer2014/mpca/package/demo2/tmp/epitensorarglist.mat";

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
  
  dyn.load(paste(scriptpath,"/est_bkgd_lambda.so",sep=""));
  
  bedgraphfiles = dir(bedgraphpath,pattern="[^bkgd].bedgraph$");
  
  for (i in 1:length(bedgraphfiles))
  {
    bedgraphfile = bedgraphfiles[i];
    bkgdfile = sub(".bedgraph",".bkgd.bedgraph",bedgraphfile,ignore.case=T);
    
    if (file.exists(paste(bedgraphpath,bkgdfile,sep=""))==F && file.info(paste(bedgraphpath,bedgraphfile,sep=""))$size>0)
    {
      bedgraph = read.table(paste(bedgraphpath,bedgraphfile,sep=""),sep="\t");
      chr = as.character(bedgraph[[1]]);
      start = as.numeric(as.character(bedgraph[[2]]));
      stop = as.numeric(as.character(bedgraph[[3]]));
      value = as.numeric(as.character(bedgraph[[4]]));
      
      N = length(value);
      L = 500;  # in the neighorhood of 500 bins (i.e. 500*200=100000 bps)
      S = 250;  # sliding window step size = 250 bins (i.e. 250*200=50000 bps)
      q = 0.5;  # quantile =0.5
      lambda = rep(0,N);
      out= .C("est_bkgd_lambda",x=as.double(value),lambda=as.double(lambda),n=as.integer(N),l=as.integer(L),s=as.integer(S),q=as.double(q));
      lambda = out$lambda;
      
      bkgd = list(chr=chr,start=start,stop=stop,value=lambda);
      write.table(bkgd,file=paste(bedgraphpath,bkgdfile,sep=""),quote=F,sep="\t",row.names=F,col.names=F);
    }
  }
}

rm(list=ls())
