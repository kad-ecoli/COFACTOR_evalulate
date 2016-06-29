#!/bin/bash
if [ -z "$1" ];then
    echo "$(basename $0) outdir/
    concatenate all COFACTOR3 GO prediction 'GOsearchresult_*_*.dat under outdir/
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

MF_RESULT="$OUTDIR/result/COFACTOR_MF.csv"
CC_RESULT="$OUTDIR/result/COFACTOR_CC.csv"
BP_RESULT="$OUTDIR/result/COFACTOR_BP.csv"
GO_RESULT="$OUTDIR/result/COFACTOR_GO.csv"
rm -f $MF_RESULT $CC_RESULT $BP_RESULT $GO_RESULT
touch $MF_RESULT
touch $CC_RESULT
touch $BP_RESULT

SS=$(ls $OUTDIR/*/GOsearchresult_*_MF.dat| \
    grep -ohP "GOsearchresult_[\w]+?_MF\.dat$"| \
    sed 's/GOsearchresult_//g'| sed 's/_MF\.dat$//g')
for S in $SS;do
    echo $S
    cat $S/GOsearchresult_"$S"_MF.dat \
        |sed 's/GO:[0-9]* /&\tF\t/g' |sed 's/[01]\.[0-9][0-9] /&\t/g' \
        |sed "s/^/$S\t/g" |sed 's/ \t/\t/g' >> $MF_RESULT
    cat $S/GOsearchresult_"$S"_CC.dat \
        |sed 's/GO:[0-9]* /&\tC\t/g' |sed 's/[01]\.[0-9][0-9] /&\t/g' \
        |sed "s/^/$S\t/g" |sed 's/ \t/\t/g' >> $CC_RESULT
    cat $S/GOsearchresult_"$S"_BP.dat \
        |sed 's/GO:[0-9]* /&\tP\t/g' |sed 's/[01]\.[0-9][0-9] /&\t/g' \
        |sed "s/^/$S\t/g" |sed 's/ \t/\t/g' >> $BP_RESULT
done

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

cat $MF_RESULT $CC_RESULT $BP_RESULT > $GO_RESULT
