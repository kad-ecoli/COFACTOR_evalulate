#!/bin/bash
if [ -z "$1" ];then
    echo "$(basename $0) outdir/
    concatenate all combined GOfreq prediction 'outdir/*/combine_GOfreq_*_ under outdir/
    output the result to outdir/result/blastp_*_*.csv
    The following GO terms are excluded:
        GO:0005515 ! protein binding
        GO:0005488 ! binding
        GO:0003674 ! molecular_function
        GO:0008150 ! biological_process
        GO:0005575 ! cellular_component
"
    exit
fi
T_LIST="0.5
1.0
2.0"

ASPECT_LIST="MF
BP
CC"

EXCLUDEGO="GO:0005515
GO:0005488
GO:0003674
GO:0008150
GO:0005575"

OUTDIR=$(readlink -m $1)
echo $OUTDIR
cd $OUTDIR
mkdir -p $OUTDIR/result

for ASPECT in $ASPECT_LIST;do
    #for T in $T_LIST;do
        #FILE_GOfreq="combine_GOfreq_$ASPECT.$T"
        FILE_GOfreq="combine_GOfreq_$ASPECT"
        RESULT_GOfreq="$OUTDIR/result/$FILE_GOfreq".csv
        rm -f $RESULT_GOfreq
        touch $RESULT_GOfreq
        echo $RESULT_GOfreq

        for S in `ls`;do
            if [ -s "$S/$FILE_GOfreq" ];then
                cat "$S/$FILE_GOfreq"|sed "s/^/$S\t/g" >> $RESULT_GOfreq
                echo $S
            fi
        done

        for GO in $EXCLUDEGO;do
            grep -v "$GO" $RESULT_GOfreq > "$RESULT_GOfreq".tmp
            mv "$RESULT_GOfreq".tmp "$RESULT_GOfreq"
        done
    #done
done
