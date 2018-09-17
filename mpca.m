function mpca(arglistfile)

fid = fopen(arglistfile,'r');
arglist = textscan(fid,'%s\t%s');
for i = 1:length(arglist{1})
    varname = arglist{1}{i};
    val = arglist{2}{i};
    [valnum,status] = str2num(val);
    if status==1
        command = strcat(varname,'=',val,';');
    else
        command = strcat(varname,'=''',val,'''',';');
    end
    eval(command);
end

if (exist(mpcapath,'dir')==0)
    mkdir(mpcapath);
end

inputfiles = dir(fullfile(inputpath,'*.mat'));
for i = 1:length(inputfiles)
    inputfile = inputfiles(i).name;
    mpcafile = strrep(inputfile,'input','mpca');
    if (exist(strcat(mpcapath,mpcafile),'file')==0)
        mpca1(strcat(inputpath,inputfile),strcat(mpcapath,mpcafile));
    end
end

return

function mpca1(inputfile,mpcafile)

load(inputfile);

I = size(X,1);
J = size(X,2);
K = size(X,3);

Z = zeros(I,J);
for i = 1:I
    for j = 1:J
        Z(i,j) = prctile(X(i,j,:),0.75) + 1e-6;
        X(i,j,:) = X(i,j,:)/ Z(i,j);
    end
end

M = mean(X,1);
try
    X = X - repmat(M,[size(X,1),1,1]);
    
    A = size(X,1)-1;
    B = size(X,2);
    C = min(20,A*B);
    T = tucker_als(tensor(X),[A,B,C]);
    G = T.core;
    U1 = T.U{1};
    U2 = T.U{2};
    U3 = T.U{3};
    
    success = 1;

catch err
    G = 0;
    U1 = 0;
    U2 = 0;
    U3 = 0;
    success = 0;
end

save(mpcafile,'cellnames','assaynames','chr','start','stop','G','U1','U2','U3','success');

return
