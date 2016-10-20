#!/bin/bash
if [ -z "$1" ];then
    echo "$(basename $0) outdir/
    concatenate all COFACTOR3 GO prediction GOsearchresult_*_*.dat and
    COFACTOR_*_* under outdir/
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
cd $OUTDIR
mkdir -p $OUTDIR/result

#### data file for Ambrish's origin COFACTOR score ####
ASPECT_LIST="MF
BP
CC"

RESULT_PREFIX="$OUTDIR/result/COFACTOR_"

for ASPECT in $ASPECT_LIST;do
    rm -f "$RESULT_PREFIX$ASPECT".csv
    touch "$RESULT_PREFIX$ASPECT".csv
done
rm "$RESULT_PREFIX"GO.csv

SS=$(ls $OUTDIR/*/GOsearchresult_*_MF.dat| \
    grep -ohP "GOsearchresult_[\w]+?_MF\.dat$"| \
    sed 's/GOsearchresult_//g'| sed 's/_MF\.dat$//g')
for S in $SS;do
    echo $S
    for ASPECT in $ASPECT_LIST;do
        cat $S/GOsearchresult_"$S"_"$ASPECT".dat \
            |sed "s/GO:[0-9]* /&\t${ASPECT:1:2}\t/g"         \
            |sed 's/[01]\.[0-9][0-9] /&\t/g'     \
            |sed "s/^/$S\t/g" |sed 's/ \t/\t/g' \
            >> "$RESULT_PREFIX$ASPECT".csv
    done
done

EXCLUDEGO="GO:0005515
GO:0005488
GO:0003674
GO:0008150
GO:0005575"
for ASPECT in $ASPECT_LIST;do
    for GO in $EXCLUDEGO;do
        grep -v "$GO" "$RESULT_PREFIX$ASPECT".csv > "$RESULT_PREFIX$ASPECT".tmp
        mv "$RESULT_PREFIX$ASPECT".tmp "$RESULT_PREFIX$ASPECT".csv
    done
    cat "$RESULT_PREFIX$ASPECT".csv >> "$RESULT_PREFIX"GO.csv
done

#### data file for new COFACTOR score ####
#SCORING_LIST="GOfreq
#FCwGOfreq
#maxFC
#meanFC
#dist
#"

SCORING_LIST="GOfreq"
for ASPECT in $ASPECT_LIST;do
    for SCORE in $SCORING_LIST;do
        echo "$SCORE score for Aspect $ASPECT"
        rm -f "$RESULT_PREFIX$SCORE"_"$ASPECT".csv
        touch "$RESULT_PREFIX$SCORE"_"$ASPECT".csv

        for S in $SS;do
            echo $S
            sed "s/^/$S\t/g" $S/COFACTOR_"$SCORE"_"$ASPECT" \
                >> "$RESULT_PREFIX$SCORE"_"$ASPECT".csv
        done

        for GO in $EXCLUDEGO;do
            grep -v "$GO" "$RESULT_PREFIX$SCORE"_"$ASPECT".csv \
                        > "$RESULT_PREFIX$SCORE"_"$ASPECT".tmp
            mv "$RESULT_PREFIX$SCORE"_"$ASPECT".tmp \
               "$RESULT_PREFIX$SCORE"_"$ASPECT".csv
        done
    done
done
