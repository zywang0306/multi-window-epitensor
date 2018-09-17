#!/bin/bash

##### Usage: ./preprocessing.bash -c $chipfile -i $inputfile -o $covpath -r $covfile -g $genome

codepath="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )";
cd $codepath;

chipfile="";
inputfile="";
covpath="";
covfile="";
genome="";

while [[ $# > 1 ]]
do
key="$1"
shift

case $key in
    -c|--chipfile)
    chipfile="$1"
    shift
    ;;
    -i|--inputfile)
    inputfile="$1"
    shift
    ;;
    -o|--covpath)
    covpath="$1"
    shift
    ;;
    -r|--covfile)
    covfile="$1"
    shift
    ;;
    -g|--genome)
    genome="$1"
    shift
    ;;
    *)
            # unknown option
    ;;
esac
done

# validate arguments
preprocessingarglistfile=$covpath"preprocessingarglist.mat";
if [ -e $covpath ]; then
  mkdir --parent $covpath;
fi
Rscript "validatePreprocessingArgs.r" -chipfile=$chipfile -inputfile=$inputfile -covpath=$covpath -covfile=$covfile -Genome=$genome -codepath=$codepath -arglistfile=$preprocessingarglistfile;

if [ -e $preprocessingarglistfile ]; then
  # convert bam to rdata file
  Rscript "preprocessing.r" -arglistfile=$preprocessingarglistfile;
fi
