#!usr/bin/bash

picard="/gpfs/projects/tmedicine/TBILAB/scripts/picard.jar"
ref="/gpfs/data_jrnas1/ref_data/Homo_sapiens/hs37d5/Sequences/WholeGenomeSequence/hs37d5.fa"

module load SAMtools/1.9


while getopts ":h:i:l:o:n:p:b:" opt; do
                case $opt in
                        h)
                                        usage
                                        #echo "$USAGE"
                                        exit 1
                                         ;;
                        i)
                                        inputFile=$OPTARG
                                        echo "input files are $inputFile" ;
                                        ;;
                        l)
                                        location=$OPTARG
                                        echo "Output folder $location"
                                        ;;
                        o)              output=$OPTARG
                                        echo "location of output file"
                                        ;;
			n)              thread=$OPTARG
					echo "number of nodes, by default 16"
					;;
			p)		projectname=$OPTARG
					echo "project name $projectname"
					;;
			b)		BAIT_INTERVALS=$OPTARG
					echo "bait Interval $BAIT_INTERVALS"
					;;
                esac	
        done


if [ -z "${location}" ]; then
	echo "Output location is not given so exiting"
	exit 1
fi

if [ -z "${BAIT_INTERVALS}" ]; then
	echo "Bait intervals files are not given"
	exit 1
fi 
 
if [ -z "${inputFile}" ]; then
	echo  "Please provide input bamFile Name"
	exit 1
fi

if [ ! -f "${inputFile}" ]; then
	echo "File doesn't exist"
	exit 1
fi   

if [ -z "${thread}" ]; then
	node="2"
else
	node=${thread}
fi

if [ -z "$output" ]; then	
	outname=$(basename ${inputFile} .bam)
else
	outname=${output}
fi

echo ${projectname}

# Calculating OxoMetrics:	
mkdir -p ${location}/CollectOxoGMetrics
echo "java -jar ${picard} CollectOxoGMetrics I=${inputFile} O=${location}/CollectOxoGMetrics/${outname}.txt R=${ref}" | bsub -P ${projectname} -n ${node} -R  span[hosts=1] -e ${outname}_oxo.err -o ${outname}_oxo.out

# Calculating CollectAlignmentSummaryMetrics
mkdir -p ${location}/CollectAlignmentSummaryMetrics
echo "java -jar ${picard} CollectAlignmentSummaryMetrics I=${inputFile} O=${location}/CollectAlignmentSummaryMetrics/${outname}.txt R=${ref}" | bsub -P ${projectname} -n ${node} -R span[hosts=1] -e ${outname}_AligSummary.err -o ${outname}_AligSummary.out 

# Calculating CollectSequencingArtifactMetrics
mkdir -p ${location}/CollectSequencingArtifactMetrics
echo "java -jar ${picard} CollectSequencingArtifactMetrics I=${inputFile} O=${location}/CollectSequencingArtifactMetrics/${outname}.txt R=${ref}" | bsub -P ${projectname} -n ${node} -R span[hosts=1] -e ${outname}_SeqArti.err -o ${outname}_SeqArti.out

# calcualting CollectHsMetrics
mkdir -p ${location}/CollectHsMetrics
echo "java -jar ${picard} CollectHsMetrics I=${inputFile} O=${location}/CollectHsMetrics/${outname}.txt R=${ref} BAIT_INTERVALS=${BAIT_INTERVALS} TARGET_INTERVALS=${BAIT_INTERVALS}" | bsub -P ${projectname} -n ${node} -R span[hosts=1] -e ${outname}_hsmetric.err -o ${outname}_hsmetric.out

# Calculating Flagstat
mkdir -p  ${location}/flagstat
echo "samtools flagstat ${inputFile} > ${location}/flagstat/${outname}.txt" | bsub -P ${projectname} -n ${node} -R span[hosts=1] -e ${outname}_flagstat.err -o ${outname}_flagstat.out
