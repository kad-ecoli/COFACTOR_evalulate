#!/bin/bash
if [ -z "$1" ];then
    echo "$(basename $0) outdir/
    copy all outdir/*/model1/cofactor/GOsearchresult_model1_*.dat
    to outdir/*/GOsearchresult_*_MF.dat
"
    exit
fi

OUTDIR=$(readlink -m $1)
echo $OUTDIR

SS=$(ls $OUTDIR/*/model1/cofactor/GOsearchresult_model1_MF.dat| \
    grep -ohP "[\w]+?\/model1\/cofactor"| \
    sed 's/\/model1\/cofactor//g')
for S in $SS;do
    echo $S
    cp $OUTDIR/$S/model1/cofactor/GOsearchresult_model1_MF.dat \
       $OUTDIR/$S/GOsearchresult_"$S"_MF.dat
    cp $OUTDIR/$S/model1/cofactor/GOsearchresult_model1_BP.dat \
       $OUTDIR/$S/GOsearchresult_"$S"_BP.dat
    cp $OUTDIR/$S/model1/cofactor/GOsearchresult_model1_CC.dat \
       $OUTDIR/$S/GOsearchresult_"$S"_CC.dat
done
