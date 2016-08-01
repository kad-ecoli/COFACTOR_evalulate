#!/usr/bin/env python
docstring='''
calROC_COFACTOR.py UNIPROT_GOterms.is_a COFACTOR_GO.is_a ROC.csv ROC.png
    calculate precision, recall/TPR, FPR, F-measure for COFACTOR prediction
    
    UNIPROT_GOterms.is_a contains experimentally annotated for protein GO 
    terms (evidence code: EXP, IDA, IMP, IGI, IEP, TAS, IC) and their parent
    GO terms. This file is a tab-eliminated file in the following format:
accession	GOterm_list(comma seperated)
    example:
P40710	GO:0010810,GO:0030155,GO:0050789,GO:0050794,GO:0065007

    COFACTOR_GO.is_a contains GO terms assigned to proteins by COFACTOR 
    prediction and all their parent GO terms. This file is a tab-eliminated 
    file in the following format:
accesion	GOterm	Aspect	Cscore	name(optional)
    example
P40710	GO:0043167	F	0.07	ion binding

    ROC.csv is the output tab-eliminated file in the following format:
    threshold precision recall FPR Fmeasure tp fp tn fn MCC
    ROC.png is the output plot for ROC curve and precision recall curve

    print MCC using 0.5 as threshold, maximum F-measure, AUC, maximum MCC
'''
import sys,os
import numpy as np 
import matplotlib
matplotlib.use("agg")
from matplotlib import pylab
import pandas as pd
from create_PDB_GOterms import obo_url,wget
from backpropagate_parent_term import excludeGO
import obo2csv

def calROC_COFACTOR(UNIPROT_GOterms,COFACTOR_GO):
    '''calculate precision, recall, TPR, FPR, F-measure using experimental GO 
    annotation text "UNIPROT_GOterms" and COFACTOR prediction result text
    "COFACTOR_GO". Return a numpy array where each column correspondes to
    threshold precision recall FPR Fmeasure tp fp tn fn MCC
    '''
    ## parsing COFACTOR prediction result
    COFACTOR_df=pd.read_csv(COFACTOR_GO,sep='\t',header=None, 
        names=["accesion","GOterm","Aspect","Cscore"],usecols=[0,1,2,3])
    COFACTOR_df=COFACTOR_df.sort_index(by="Cscore",ascending=False)
    COFACTOR_df["accessionGO"]=COFACTOR_df.accesion +COFACTOR_df.GOterm
    Aspect=list(set(COFACTOR_df["Aspect"][0]))
    if len(Aspect)>1:
        sys.stderror.write("FATAL ERROR: More than one Aspect of MF/BP/CC!\n")
        exit()
    Aspect=Aspect[0]

    ## extract GO terms for one Aspect
    fp=open(wget(obo_url),'rU')
    obo_txt=fp.read()
    fp.close()
    obo_dict=obo2csv.parse_obo_txt(obo_txt)
    GOterms_all=set(obo_dict[Aspect]["Term"])-set(excludeGO)

    ## parsing ground truth
    accessionGO_positive=[]
    accessionGO_negative=[]
    fp=open(UNIPROT_GOterms,'rU')
    txt=fp.read()
    fp.close()
    accession_list=[]
    for line in txt.splitlines():
        accession,GOterm_list=line.split()
        accession_list.append(accession)
        GOterm_list=GOterm_list.split(',')
        accessionGO_positive+=[accession+GOterm for GOterm in GOterm_list]
        accessionGO_negative+=[accession+GOterm for GOterm in \
            GOterms_all if not GOterm in GOterm_list]
    accessionGO_positive=set(accessionGO_positive)
    accessionGO_negative=set(accessionGO_negative)
    condition_positive=1.*len(accessionGO_positive)
    condition_negative=1.*len(accessionGO_negative)
    total=condition_positive+condition_negative

    ## removing any prediction for targets not in ground truth
    COFACTOR_df=COFACTOR_df[COFACTOR_df.accesion.str.contains(
        '^'+'$|^'.join(accession_list)+'$')]

    cscore_list=sorted(set(list(COFACTOR_df.Cscore)))
    ROC_array=np.zeros((len(cscore_list)+2,10))
    #ROC_array=np.zeros((len(cscore_list),10))
    ROC_array[1:len(cscore_list)+1,0]=cscore_list
    #ROC_array[:,0]=cscore_list
    # add cscore==0 and cscore==1
    ROC_array[0,:]=[0,condition_positive/total,1,1,0,condition_positive,condition_negative,0,0,0]
    ROC_array[-1,:]=[1,1,0,0,0,0,0,condition_negative,condition_negative,0]

    for idx,threshold in enumerate(cscore_list):
        sys.stderr.write("cscore threshold=%.8f\n"%(threshold))
        predict_positiveGO=set(
            COFACTOR_df[COFACTOR_df["Cscore"]>=threshold]["accessionGO"])
        predict_positive=1.*len(predict_positiveGO)
        tp_GO=predict_positiveGO.intersection(accessionGO_positive)
        tp=len(tp_GO)
        fp=predict_positive-tp
        fn=condition_positive-tp
        tn=total-tp-fp-fn

        precision=tp/predict_positive
        recall=tp/condition_positive
        FPR=fp/condition_negative
        Fmeasure=2.*(precision*recall)/(precision+recall) if (precision+recall) else 0
        MCC=(tp+fp)*(tp+fn)*(tn+fp)*(tn+fn)
        MCC=(tp*tn-fp*fn)/MCC**.5 if MCC else 0
        ROC_array[idx+1,1:]=[precision,recall,FPR,Fmeasure,tp,fp,tn,fn,MCC]
        #ROC_array[idx  ,1:]=[precision,recall,FPR,Fmeasure,tp,fp,tn,fn,MCC]
    AUC=0.
    for idx in range(1,ROC_array.shape[0]):
        if idx==0:
            continue
        TPR_prev=ROC_array[idx-1,2]
        TPR_cur=ROC_array[idx,2]
        FPR_prev=ROC_array[idx-1,3]
        FPR_cur=ROC_array[idx,3]
        AUC+=(TPR_prev+TPR_cur)*(FPR_prev-FPR_cur)/2
    return ROC_array,AUC

if __name__=="__main__":
    if len(sys.argv)<3:
        sys.stderr.write(docstring)
        exit()

    ROC_array,AUC=calROC_COFACTOR(
        UNIPROT_GOterms=sys.argv[1],COFACTOR_GO=sys.argv[2])

    Fmeasure_max=ROC_array[:,4].max()
    MCC_max=ROC_array[:,9].max()
    sys.stdout.write("Fmax=%.4f\tAUC=%.4f\tMCC=%.4f\n"%(Fmeasure_max,AUC,MCC_max))

    csvfile=sys.argv[3] if len(sys.argv)>3 else "ROC.csv"
    np.savetxt(csvfile,ROC_array,delimiter='\t',fmt="%.4f",
        header="cscore_threshold\tprecision\trecall\tFPR\tFmeasure\ttp\tfp\ttn\tfn\tMCC")

    pngfile=sys.argv[4] if len(sys.argv)>4 else "ROC.png"
    fig= pylab.figure()
    pylab.subplot(1,2,1)
    pylab.plot(ROC_array[:,2],ROC_array[:,1],'b')
    pylab.axis([0,1,0,1])
    pylab.xlabel("Recall")
    pylab.ylabel("Precision")
    pylab.title("Precision-Recall\n(max{F-measure}=%.4f)"%Fmeasure_max)
    pylab.subplot(1,2,2)
    pylab.plot(ROC_array[:,3],ROC_array[:,2],'b')
    pylab.plot([0,1],[0,1],'k')
    pylab.axis([0,1,0,1])
    pylab.xlabel("FPR")
    pylab.ylabel("TPR")
    pylab.title("ROC curve\n(AUC=%.4f)"%AUC)
    pylab.savefig(pngfile)
    pylab.close()
