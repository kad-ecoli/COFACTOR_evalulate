#!/bin/bash
if [ -z "$1" ];then
    echo "$(basename $0) outdir/
    concatenate all PPI2GO prediction 'outdir/*/string_GOfreq_*_ under outdir/
    output the result to outdir/result/string_GOfreq_*.csv
    The following GO terms are excluded:
        GO:0005515 ! protein binding
        GO:0005488 ! binding
        GO:0003674 ! molecular_function
        GO:0008150 ! biological_process
        GO:0005575 ! cellular_component
"
    exit
fi

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
    PRED_FILE="string_GOfreq_$ASPECT"
    RESULT_FILE="$OUTDIR/result/$PRED_FILE".csv
    rm -f $RESULT_FILE
    touch $RESULT_FILE

    for S in `ls`;do
        if [ -s "$S/$PRED_FILE" ];then
            cat "$S/$PRED_FILE"|sed "s/^/$S\t/g" >> $RESULT_FILE
            echo $S
        fi
    done

    for GO in $EXCLUDEGO;do
        grep -v "$GO" $RESULT_FILE > "$RESULT_FILE".tmp
        mv "$RESULT_FILE".tmp "$RESULT_FILE"
    done
done
