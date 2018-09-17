#!/bin/bash

##### Usage: ./macs2bdgpeakcall.bash -b $bedgraphpath -p $peakpath -w $workpath

while [[ $# > 1 ]]
do
key="$1"
shift

case $key in
    -b|--bedgraphpath)
    bedgraphpath="$1"
    shift
    ;;
    -p|--peakpath)
    peakpath="$1"
    shift
    ;;
    -w|--workpath)
    workpath="$1"
    shift
    ;;
    *)
            # unknown option
    ;;
esac
done

echo $workpath

cd $bedgraphpath;
tfiles=$(ls *.bedgraph | grep -v "bkgd");

for tfile in $tfiles; do
 echo $tfile;
 cfile=${tfile%.bedgraph}".bkgd.bedgraph";
 peakfile=${tfile%.bedgraph}".peak.bed";
 if [ ! -f $peakpath$peakfile ]; then
  macs2 bdgcmp -t $bedgraphpath$tfile -c $bedgraph$cfile -m ppois -o $workpath"pvalue1.bedgraph";
  macs2 bdgpeakcall -i $workpath"pvalue1.bedgraph" -c 10 -o $workpath"peak.bed";
  awk '{if (NR>1) print $1 "\t" $2 "\t" $3 "\t" 0 "\t" $5}' $workpath"peak.bed" > $peakpath$peakfile;
  rm $workpath"pvalue1.bedgraph";
  rm $workpath"peak.bed";
 fi
done
