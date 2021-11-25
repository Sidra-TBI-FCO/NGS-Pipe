## to run this as a job
#run_gatk_only.sh inputBamFile outputDir
echo "To run > this_script fastQ1 fastq2 prefix ref readGroups output"
echo "You are running the run_bwamem_mapping script, you need to supply fastq1:$1 fastq2:$2 prefix:$3 reference:$4  readgroups:$5 and output:$6"

fastaQ1=$1
fastaQ2=$2
prefix=$3 ##Will be added to the outputfile name (i.e GenomeArabia etc)
ref=$4 ##for example hg19 hs37d5
readGroups=$5 #"@RG\tID:E01\tSM:E01\tPL:Illumina"
output=$6
#
threads=$7

#refDir="/gpfs/test_fs_4m/ref_data/indices/Homo_sapiens/ncbi/hs37d5/bwa/0.7.12/hs37d5.fa"
export PROGRAM_PATH="/gpfs/software/genomics/bwakit/v0.7.15/bwa.kit"
export RefDir="/gpfs/data_jrnas1/ref_data/Homo_sapiens/${ref}/Sequences/BWAIndex/${ref}.fa"
export samtools="$PROGRAM_PATH/samtools"
export seqtk="$PROGRAM_PATH/seqtk"
export trimadap="$PROGRAM_PATH/trimadap"
export bwa="$PROGRAM_PATH/bwa"
export samblaster="$PROGRAM_PATH/samblaster"
picardJars="/gpfs/software/genomics/Picard/1.117/"
javaParams="/usr/bin/java -Djava.io.tmpdir=/gpfs/ngsdata/scratch/tmp/"

##outputdir
outputdir=${output}

bamFile=${outputdir}/${prefix}
log="${outputdir}/logs"


#Create output directory.  If it does not exist then it creates it 
mkdir ${outputdir}
mkdir ${log}

${seqtk} mergepe ${fastaQ1} ${fastaQ2} \
  | ${trimadap} 2> ${log}/${prefix}.bwa.log.trim \
  | ${bwa} mem -p -t $threads  -R ${readGroups} ${RefDir} - 2> ${log}/${prefix}.bwa.log.bwamem \
  | ${samblaster} 2> ${log}/${prefix}.bwa.log.dedup \
  | ${samtools} sort -@ $threads -m1G -T ${log}/$prefix.bwa.tmp -o ${bamFile}.sorted.bam -

echo "1) mapping the fastq files 2
${seqtk} mergepe ${fastaQ1} ${fastaQ2} \
  | ${trimadap} 2> ${log}/${prefix}.bwa.log.trim \
  | ${bwa} mem -p -t $threads -R ${readGroups} ${RefDir} - 2> ${log}/${prefix}.bwa.log.bwamem \
  | ${samblaster} 2> ${log}/${prefix}.bwa.log.dedup \
  | ${samtools} sort -@ $threads -m1G -T ${log}/$prefix.bwa.tmp -o ${bamFile}.sorted.bam -"
${samtools} index  ${bamFile}.sorted.bam


