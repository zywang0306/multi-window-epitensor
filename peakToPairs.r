rm(list=ls())

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

  peakannofiles = dir(peakannopath,pattern="*.bed");
  for (i in 1:length(peakannofiles))
  {
    peakannofile = peakannofiles[i];
    if (file.info(paste(peakannopath,peakannofile,sep=""))$size>0)
    {
      peak = read.table(paste(peakannopath,peakannofile,sep=""),sep="\t");
      chr = as.character(peak[[1]]);
      start = as.numeric(as.character(peak[[2]]));
      stop = as.numeric(as.character(peak[[3]]));
      anno = as.character(peak[[4]]);
      strength = as.numeric(as.character(peak[[5]]));
      
      if (length(start)>=2)
      {
        pairchr1 = c();
        pairstart1 = c();
        pairstop1 = c();
        pairanno1 = c();
        pairstrength1 = c();
        pairchr2 = c();
        pairstart2 = c();
        pairstop2 = c();
        pairanno2 = c();
        pairstrength2 = c();
        for (j in 1:(length(start)-1))
        {
          for (k in (j+1):length(start))
          {
            pairchr1 = c(pairchr1,chr[j]);
            pairstart1 = c(pairstart1,start[j]);
            pairstop1 = c(pairstop1,stop[j]);
            pairanno1 = c(pairanno1,anno[j]);
            pairstrength1 = c(pairstrength1,strength[j]);
            pairchr2 = c(pairchr2,chr[k]);
            pairstart2 = c(pairstart2,start[k]);
            pairstop2 = c(pairstop2,stop[k]);
            pairanno2 = c(pairanno2,anno[k]);
            pairstrength2 = c(pairstrength2,strength[k]);
          }
        }
        pair = list(pairchr1=pairchr1,pairstart1=pairstart1,pairstop1=pairstop1,pairanno1=pairanno1,pairstrength1=pairstrength1,pairchr2=pairchr2,pairstart2=pairstart2,pairstop2=pairstop2,pairanno2=pairanno2,pairstrength2=pairstrength2);
        
        pairfile = sub("peak","pair",peakannofile);
        write.table(pair,file=paste(pairpath,pairfile,sep=""),quote=F,sep="\t",row.names=F,col.names=F);
      }
    }
  }
}

rm(list=ls())
