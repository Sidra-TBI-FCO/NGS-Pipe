#!usr/bin/bash
ref="/gpfs/data_jrnas1/ref_data/Homo_sapiens/hs37d5/Sequences/WholeGenomeSequence/hs37d5.fa"
module load bcbio-nextgen/1.1.1
#export PYTHONPATH="/usr/bin/python2.7"
export PYTHONPATH="/gpfs/software/tools/python2.7/bin/python"
export CONPAIR_DIR="/gpfs/projects/tmedicine/TBILAB/tools/Conpair"
export GATK_JAR="/gpfs/software/genomics/GATK/3.4/GenomeAnalysisTK.jar"
export PYTHONPATH="${PYTHONPATH}://gpfs/projects/tmedicine/TBILAB/tools/Conpair/modules/"
#/gpfs/software/tools/python2.7/bin/python
while getopts ":t:n:o:p:"## opt; do
                case $opt in
                        h)
                                        usage
                                        #echo "$USAGE"
                                        exit 1
                                         ;;
                        t)
                                        tumorFile=$OPTARG
                                        echo "input files are $tumorFile" ;
                                        ;;
                        n)
                                        normalFile=$OPTARG
                                        echo "Output folder $normalFile"
                                        ;;
                        o)              location=$OPTARG
                                        echo "location of output file $output"
                                        ;;    
            p)         project=$OPTARG
                                        echo "name of Proeject $project"
                                        ;;
                esac
        done

if [ -z "${tumorFile}" ]; then
    echo  "Please provide input bamFile Name"
    exit 1
fi

if [[ -f "${normalFile}" && -f "${tumorFile}" ]]; then
    echo "Both File do exist"
else
    exit 1
fi   

if [ -z "$location" ]; then    
    outname=`pwd`
fi

outTumor=$(basename ${tumorFile} .bam)
echo ${projectname}
outNormal=$(basename ${normalFile} .bam)

## This part will take all input and will do preprocesing of BAM files.
echo "${CONPAIR_DIR}/scripts/run_gatk_pileup_for_sample.py -B ${tumorFile} -O ${outname}/${outTumor}.pileup --reference ${ref}" | bsub -n 2 -e ${outTumor}.err -o ${outTumor}.out -J ${outTumor}.job -P ${project}

echo "${CONPAIR_DIR}/scripts/run_gatk_pileup_for_sample.py -B ${normalFile} -O ${outname}/${outNormal}.pileup --reference ${ref}" | bsub -n 2 -e ${outNormal}.err -o ${outNormal}.out -J ${outNormal}.job -P ${project}

##
echo "${CONPAIR_DIR}/scripts/verify_concordance.py -H -T ${outname}/${outTumor}.pileup -N ${outname}/${outNormal}.pileup --outfile ${outNormal}_${outTumor}.txt" | bsub -n 2 -e ${outNormal}_${outTumor}.err -o ${outNormal}_${outTumor}.out -w ${outTumor}.job -w ${outNormal}.job -P ${project} 
#${CONPAIR_DIR}/scripts/verify_concordance.py -H -T ${outname}/QC/ConPair/pileup/${outTumor}.pileup -N ${outname}/QC/ConPair/pileup/${outNormal}.pileup --outfile ${outNormal}_${outTumor}_H_flag.txt
