#!/bin/bash
if [ -z "$1" ];then
    echo "$(basename $0) outdir/
    concatenate all GoFDR GO prediction 'outdir/*/*_final.txt under outdir/
    output the result to outdir/result/COFACTOR_*.csv
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
mkdir -p $OUTDIR/result
MF_RESULT="$OUTDIR/result/GoFDR_MF.csv"
CC_RESULT="$OUTDIR/result/GoFDR_CC.csv"
BP_RESULT="$OUTDIR/result/GoFDR_BP.csv"
GO_RESULT="$OUTDIR/result/GOFDR_GO.csv"
rm -f $MF_RESULT $CC_RESULT $BP_RESULT $GO_RESULT

cat $OUTDIR/MF/*_final.txt > $MF_RESULT
cat $OUTDIR/BP/*_final.txt > $BP_RESULT
cat $OUTDIR/CC/*_final.txt > $CC_RESULT
sed -i "s/\t/\tF\t/g" $MF_RESULT
sed -i "s/\t/\tP\t/g" $BP_RESULT
sed -i "s/\t/\tC\t/g" $CC_RESULT
sed -i "s/F\tGO/GO/g" $MF_RESULT
sed -i "s/P\tGO/GO/g" $BP_RESULT
sed -i "s/C\tGO/GO/g" $CC_RESULT

EXCLUDEGO="GO:0005515
GO:0005488
GO:0003674
GO:0008150
GO:0005575"
for GO in $EXCLUDEGO;do
    grep -v "$GO" $MF_RESULT > "$MF_RESULT".tmp
    grep -v "$GO" $BP_RESULT > "$BP_RESULT".tmp
    grep -v "$GO" $CC_RESULT > "$CC_RESULT".tmp
    mv "$MF_RESULT".tmp $MF_RESULT
    mv "$BP_RESULT".tmp $BP_RESULT
    mv "$CC_RESULT".tmp $CC_RESULT
done

cat $MF_RESULT $BP_RESULT $CC_RESULT > $GO_RESULT
