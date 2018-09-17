#!/bin/bash

##### Usage: ./extract_tss_tss_pairs.bash -a $arglistfile

while [[ $# > 1 ]]
do
key="$1"
shift

case $key in
    -a|--arglistfile)
    arglistfile="$1"
    shift
    ;;
     *)
            # unknown option
    ;;
esac
done

# parse arglistfile

while IFS=$'\t' read -r -a items
do
 if [ "${items[0]}" = "pairpath" ]; then
   pairpath=${items[1]}
 elif [ "${items[0]}" = "outpath" ]; then
   outpath=${items[1]}
 fi
done < $arglistfile;

awk '{if ($5>=500 && $10>500 && $4~"tss" && $9~"tss") {if ($2<$7) print $1 "\t" $2 "\t" $3 "\t" $6 "\t" $7 "\t" $8; else if ($2>$7) print $6 "\t" $7 "\t" $8 "\t" $1 "\t" $2 "\t" $3}}' $pairpath"/peak_pair_merged.bed" | sort -k1,1 -k2,2g -k3,3g -k4,4 -k5,5g -k6,6g | uniq | awk '{print $1 "\t" $2 "\t" $3 "\t" $4 "\t" $5 "\t" $6}' > $outpath"/tss_tss_interaction.bed";




















