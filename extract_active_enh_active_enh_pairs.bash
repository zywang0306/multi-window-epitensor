#!/bin/bash

##### Usage: ./extract_active_enh_active_enh_pairs.bash -a $all_enh_enh_file -e $anno_active_enh_file -o $active_enh_enh_file

scriptpath="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )";
cd $scriptpath;

all_enh_enh_file="";
anno_active_enh_file="";
active_enh_enh_file="";

while [[ $# > 1 ]]
do
key="$1"
shift

case $key in
    -a|--all)
    all_enh_enh_file="$1"
    shift
    ;;
    -e|--enh)
    anno_active_enh_file="$1"
    shift
    ;;
    -o|--outpath)
    active_enh_enh_file="$1"
    shift
    ;;
   *)
            # unknown option
    ;;
esac
done

intersectBed -a $all_enh_enh_file -b $anno_active_enh_file -wa | awk '{print $4 "\t" $5 "\t" $6 "\t" $1 "\t" $2 "\t" $3}' | intersectBed -a - -b $anno_active_enh_file -wa | awk '{if ($2<=$5) {print $1 "\t" $2 "\t" $3 "\t" $4 "\t" $5 "\t" $6;} else if ($2>$5) {print $4 "\t" $5 "\t" $6 "\t" $1 "\t" $2 "\t" $3}}' > $active_enh_enh_file;








