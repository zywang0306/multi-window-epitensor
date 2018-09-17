#!/bin/bash

##### Usage: ./extract_active_tss_active_tss_pairs.bash -a $all_tss_tss_file -t $anno_active_tss_file -e $anno_active_enh_file -o $active_tss_enh_file

scriptpath="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )";
cd $scriptpath;

all_tss_enh_file=""
anno_active_tss_file=""
anno_active_enh_file=""
active_tss_enh_file=""

while [[ $# > 1 ]]
do
key="$1"
shift

case $key in
    -a|--all)
    all_tss_enh_file="$1"
    shift
    ;;
    -t|--tss)
    anno_active_tss_file="$1"
    shift
    ;;
    -e|--enh)
    anno_active_enh_file="$1"
    shift
    ;;
    -o|--outpath)
    active_tss_enh_file="$1"
    shift
    ;;
   *)
            # unknown option
    ;;
esac
done

intersectBed -a $all_tss_enh_file -b $anno_active_tss_file -wa | awk '{print $4 "\t" $5 "\t" $6 "\t" $1 "\t" $2 "\t" $3}' | intersectBed -a - -b $anno_active_enh_file -wa | awk '{print $4 "\t" $5 "\t" $6 "\t" $1 "\t" $2 "\t" $3}' > $active_tss_enh_file;








