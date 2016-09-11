#!/bin/bash
if [ -z "$1" ];then
    echo "$(basename $0) outdir/
    concatenate all blastp baseline GO prediction 'outdir/*/blastp_*_ under outdir/
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
OUTDIR=$(readlink -m $1)
echo $OUTDIR
cd $OUTDIR
mkdir -p $OUTDIR/result
MF_RESULT_globalID="$OUTDIR/result/blastp_globalID_MF.csv"
CC_RESULT_globalID="$OUTDIR/result/blastp_globalID_CC.csv"
BP_RESULT_globalID="$OUTDIR/result/blastp_globalID_BP.csv"
rm -f $MF_RESULT_globalID $CC_RESULT_globalID $BP_RESULT_globalID
touch $MF_RESULT_globalID $CC_RESULT_globalID $BP_RESULT_globalID
MF_RESULT_localID="$OUTDIR/result/blastp_localID_MF.csv"
CC_RESULT_localID="$OUTDIR/result/blastp_localID_CC.csv"
BP_RESULT_localID="$OUTDIR/result/blastp_localID_BP.csv"
rm -f $MF_RESULT_localID $CC_RESULT_localID $BP_RESULT_localID
touch $MF_RESULT_localID $CC_RESULT_localID $BP_RESULT_localID
MF_RESULT_GOfreq="$OUTDIR/result/blastp_GOfreq_MF.csv"
CC_RESULT_GOfreq="$OUTDIR/result/blastp_GOfreq_CC.csv"
BP_RESULT_GOfreq="$OUTDIR/result/blastp_GOfreq_BP.csv"
rm -f $MF_RESULT_GOfreq $CC_RESULT_GOfreq $BP_RESULT_GOfreq
touch $MF_RESULT_GOfreq $CC_RESULT_GOfreq $BP_RESULT_GOfreq
MF_RESULT_evalue="$OUTDIR/result/blastp_evalue_MF.csv"
CC_RESULT_evalue="$OUTDIR/result/blastp_evalue_CC.csv"
BP_RESULT_evalue="$OUTDIR/result/blastp_evalue_BP.csv"
rm -f $MF_RESULT_evalue $CC_RESULT_evalue $BP_RESULT_evalue
touch $MF_RESULT_evalue $CC_RESULT_evalue $BP_RESULT_evalue

MF_RESULT_gwGOfreq="$OUTDIR/result/blastp_gwGOfreq_MF.csv"
CC_RESULT_gwGOfreq="$OUTDIR/result/blastp_gwGOfreq_CC.csv"
BP_RESULT_gwGOfreq="$OUTDIR/result/blastp_gwGOfreq_BP.csv"
rm -f $MF_RESULT_gwGOfreq $CC_RESULT_gwGOfreq $BP_RESULT_gwGOfreq
touch $MF_RESULT_gwGOfreq $CC_RESULT_gwGOfreq $BP_RESULT_gwGOfreq
MF_RESULT_lwGOfreq="$OUTDIR/result/blastp_lwGOfreq_MF.csv"
CC_RESULT_lwGOfreq="$OUTDIR/result/blastp_lwGOfreq_CC.csv"
BP_RESULT_lwGOfreq="$OUTDIR/result/blastp_lwGOfreq_BP.csv"
rm -f $MF_RESULT_lwGOfreq $CC_RESULT_lwGOfreq $BP_RESULT_lwGOfreq
touch $MF_RESULT_lwGOfreq $CC_RESULT_lwGOfreq $BP_RESULT_lwGOfreq
MF_RESULT_ewGOfreq="$OUTDIR/result/blastp_ewGOfreq_MF.csv"
CC_RESULT_ewGOfreq="$OUTDIR/result/blastp_ewGOfreq_CC.csv"
BP_RESULT_ewGOfreq="$OUTDIR/result/blastp_ewGOfreq_BP.csv"
rm -f $MF_RESULT_ewGOfreq $CC_RESULT_ewGOfreq $BP_RESULT_ewGOfreq
touch $MF_RESULT_ewGOfreq $CC_RESULT_ewGOfreq $BP_RESULT_ewGOfreq

for S in `ls`;do
    if [ -s $S/blastp_globalID_MF ];then
        cat $S/blastp_globalID_MF|sed "s/^/$S\t/g" >> $MF_RESULT_globalID
        cat $S/blastp_localID_MF |sed "s/^/$S\t/g" >> $MF_RESULT_localID
        cat $S/blastp_GOfreq_MF  |sed "s/^/$S\t/g" >> $MF_RESULT_GOfreq
        cat $S/blastp_evalue_MF  |sed "s/^/$S\t/g" >> $MF_RESULT_evalue
        cat $S/blastp_gwGOfreq_MF|sed "s/^/$S\t/g" >> $MF_RESULT_gwGOfreq
        cat $S/blastp_lwGOfreq_MF|sed "s/^/$S\t/g" >> $MF_RESULT_lwGOfreq
        cat $S/blastp_ewGOfreq_MF|sed "s/^/$S\t/g" >> $MF_RESULT_ewGOfreq
    fi
    if [ -s $S/blastp_globalID_BP ];then
        cat $S/blastp_globalID_BP|sed "s/^/$S\t/g" >> $BP_RESULT_globalID
        cat $S/blastp_localID_BP |sed "s/^/$S\t/g" >> $BP_RESULT_localID
        cat $S/blastp_GOfreq_BP  |sed "s/^/$S\t/g" >> $BP_RESULT_GOfreq
        cat $S/blastp_evalue_BP  |sed "s/^/$S\t/g" >> $BP_RESULT_evalue
        cat $S/blastp_gwGOfreq_BP|sed "s/^/$S\t/g" >> $BP_RESULT_gwGOfreq
        cat $S/blastp_lwGOfreq_BP|sed "s/^/$S\t/g" >> $BP_RESULT_lwGOfreq
        cat $S/blastp_ewGOfreq_BP|sed "s/^/$S\t/g" >> $BP_RESULT_ewGOfreq
    fi
    if [ -s $S/blastp_globalID_CC ];then
        cat $S/blastp_globalID_CC|sed "s/^/$S\t/g" >> $CC_RESULT_globalID
        cat $S/blastp_localID_CC |sed "s/^/$S\t/g" >> $CC_RESULT_localID
        cat $S/blastp_GOfreq_CC  |sed "s/^/$S\t/g" >> $CC_RESULT_GOfreq
        cat $S/blastp_evalue_CC  |sed "s/^/$S\t/g" >> $CC_RESULT_evalue
        cat $S/blastp_gwGOfreq_CC|sed "s/^/$S\t/g" >> $CC_RESULT_gwGOfreq
        cat $S/blastp_lwGOfreq_CC|sed "s/^/$S\t/g" >> $CC_RESULT_lwGOfreq
        cat $S/blastp_ewGOfreq_CC|sed "s/^/$S\t/g" >> $CC_RESULT_ewGOfreq
    fi
done


EXCLUDEGO="GO:0005515
GO:0005488
GO:0003674
GO:0008150
GO:0005575"
for GO in $EXCLUDEGO;do
    grep -v "$GO" $MF_RESULT_globalID > "$MF_RESULT_globalID".tmp
    grep -v "$GO" $BP_RESULT_globalID > "$BP_RESULT_globalID".tmp
    grep -v "$GO" $CC_RESULT_globalID > "$CC_RESULT_globalID".tmp
    mv "$MF_RESULT_globalID".tmp $MF_RESULT_globalID
    mv "$BP_RESULT_globalID".tmp $BP_RESULT_globalID
    mv "$CC_RESULT_globalID".tmp $CC_RESULT_globalID

    grep -v "$GO" $MF_RESULT_localID > "$MF_RESULT_localID".tmp
    grep -v "$GO" $BP_RESULT_localID > "$BP_RESULT_localID".tmp
    grep -v "$GO" $CC_RESULT_localID > "$CC_RESULT_localID".tmp
    mv "$MF_RESULT_localID".tmp $MF_RESULT_localID
    mv "$BP_RESULT_localID".tmp $BP_RESULT_localID
    mv "$CC_RESULT_localID".tmp $CC_RESULT_localID

    grep -v "$GO" $MF_RESULT_GOfreq > "$MF_RESULT_GOfreq".tmp
    grep -v "$GO" $BP_RESULT_GOfreq > "$BP_RESULT_GOfreq".tmp
    grep -v "$GO" $CC_RESULT_GOfreq > "$CC_RESULT_GOfreq".tmp
    mv "$MF_RESULT_GOfreq".tmp $MF_RESULT_GOfreq
    mv "$BP_RESULT_GOfreq".tmp $BP_RESULT_GOfreq
    mv "$CC_RESULT_GOfreq".tmp $CC_RESULT_GOfreq

    grep -v "$GO" $MF_RESULT_evalue > "$MF_RESULT_evalue".tmp
    grep -v "$GO" $BP_RESULT_evalue > "$BP_RESULT_evalue".tmp
    grep -v "$GO" $CC_RESULT_evalue > "$CC_RESULT_evalue".tmp
    mv "$MF_RESULT_evalue".tmp $MF_RESULT_evalue
    mv "$BP_RESULT_evalue".tmp $BP_RESULT_evalue
    mv "$CC_RESULT_evalue".tmp $CC_RESULT_evalue
done
