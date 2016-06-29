#!/usr/bin/env python
docstring='''backpropagate_parent_term.py COFACTOR_GO.csv
    backpropagate parent GO terms for child GO terms in COFACTOR result
    The following GO terms were not backpropagated:
        GO:0005515 ! protein binding
        GO:0005488 ! binding
        GO:0003674 ! molecular_function
        GO:0008150 ! biological_process
        GO:0005575 ! cellular_component
'''
import sys
import obo2csv # parsing GO hierachy
from create_PDB_GOterms import obo_url,wget

excludeGO=[ # GO to be excluded
    "GO:0005515", # protein binding
    "GO:0005488", # binding
    "GO:0003674", # molecular_function
    "GO:0008150", # biological_process
    "GO:0005575", # cellular_component
    ]

def backpropagate_parent_term(COFACTOR_GO):
    '''COFACTOR_GO COFACTOR3 result file
    return COFACTOR result text with parent GO terms backprogated'''
    fp=open(wget(obo_url),'rU')
    obo_txt=fp.read()
    fp.close()
    obo_dict=obo2csv.parse_obo_txt(obo_txt)

    fp=open(COFACTOR_GO,'rU')
    cofactor_txt=fp.read()
    fp.close()
    return backpropagate_parent_term_txt(cofactor_txt,obo_dict)

def backpropagate_parent_term_txt(cofactor_txt,obo_dict):
    '''cofactor_txt COFACTOR result text
    obo_dict GO term hierachy structure parsed by obo2csv
    return COFACTOR result text with parent GO terms backprogated'''
    cofactor_dict={'F':dict(),'C':dict(),'P':dict()}
    for line in cofactor_txt.splitlines():
        line=line.split('\t')
        DB_Object_ID,GO_ID,Aspect,Cscore=line[:4]
        if GO_ID in excludeGO:
            continue
        if not GO_ID in obo_dict[Aspect]["Term"]:
            sys.stderr.write("ERROR! Cannot find GO Term %s\n"%GO_ID)
            continue
        name=line[4] if len(line)>4 else \
            obo_dict[Aspect]["Term"][GO_ID].short().split(' ! ')[1]
        if not DB_Object_ID in cofactor_dict[Aspect]:
            cofactor_dict[Aspect][DB_Object_ID]=dict()
        if not GO_ID in cofactor_dict[Aspect][DB_Object_ID]:
            cofactor_dict[Aspect][DB_Object_ID][GO_ID]=[Cscore,name]
        else:
            cofactor_dict[Aspect][DB_Object_ID][GO_ID][0]=max(Cscore,
            cofactor_dict[Aspect][DB_Object_ID][GO_ID][0])

        for parent_GO in obo_dict.is_a( Term_id=GO_ID, direct=False,
            name=True, number=False).split('\t'):
            GO_ID,name=parent_GO.split(" ! ")
            if GO_ID in excludeGO:
                continue
            if not GO_ID in cofactor_dict[Aspect][DB_Object_ID]:
                cofactor_dict[Aspect][DB_Object_ID][GO_ID]=[Cscore,name.strip()]
            else:
                cofactor_dict[Aspect][DB_Object_ID][GO_ID][0]=max(Cscore,
                cofactor_dict[Aspect][DB_Object_ID][GO_ID][0])
    
    cofactor_is_a_txt=''
    for Aspect in cofactor_dict:
        for DB_Object_ID in cofactor_dict[Aspect]:
            for GO_ID in cofactor_dict[Aspect][DB_Object_ID]:
                cofactor_is_a_txt+='\t'.join([DB_Object_ID,GO_ID,Aspect] \
                    +cofactor_dict[Aspect][DB_Object_ID][GO_ID])+'\n'
    return cofactor_is_a_txt

if __name__=="__main__":
    if len(sys.argv)<2:
        sys.stderr.write(docstring)
        exit()

    sys.stdout.write(backpropagate_parent_term(sys.argv[1]))
