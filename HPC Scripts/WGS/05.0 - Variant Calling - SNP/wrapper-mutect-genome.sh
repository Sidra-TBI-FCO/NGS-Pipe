 #!/bin/bash

### Arguments
## Usage : sh wrapper-mutect.sh /gpfs/projects/tmedicine/TBILAB/JSREP1/WES_Tumor_Normal_150PE/BAMS/WES_COAD_LUMC_SIDRA_280N_H3FCKBBXY.sorted.bam /gpfs/projects/tmedicine/TBILAB/JSREP1/WES_Tumor_Normal_150PE/BAMS/WES_COAD_LUMC_SIDRA_280T_H3HMCBBXY.sorted.bam /gpfs/ngsdata/scratch/fazulur/testcases/test-wf-mutect /gpfs/data_jrnas1/ref_data/Hsapiens/GRCh37/seq/GRCh37.fa 32 WES_COAD_LUMC_SIDRA_280

### Arguments

normalbam=$1
tumorbam=$2
output=$3
ref=$4
ncores=$5
outprefix=$6

## Modules
module load bcbio-nextgen/1.1.5_testing \
tabix/0.2.6 \
bcftools/1.9 \
SAMtools/1.9 \
SnpEff/4.3T/4.3T 

mkdir -p $output
logs=$output/logs
mkdir -p $logs
bamlist1=()
prefix2=()
vcflist=()

bamlist=($normalbam $tumorbam)


## Getting working directory of wrapper

WD="$(dirname "$0")"

### remove extra-contigs from bam
	
	for i in ${bamlist[@]}
	do
		prefix1=`basename $i`
                prefix=${prefix1%.*}
                prefix2+=($prefix)

                readgroup="@RG\tID:$prefix\tPL:illumina\tPU:$prefix\tSM:$prefix"
                cmd="samtools view \
                -b -h $i \
                1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 X Y \
                | samtools view -u - | samtools addreplacerg -r '${readgroup}' \
                -m overwrite_all -O bam \
                -o $output/$prefix.bam -"

		echo $cmd | bsub -P test \
		-J $prefix-samtools \
		-e $logs/$prefix-samtools.e \
		-o $logs/$prefix-samtools.o \
		-n $ncores

		echo "samtools index -@ $ncores $output/$prefix.bam $output/$prefix.bam.bai"| bsub -P test -w $prefix-samtools -J $prefix-index -e $logs/$prefix-index.e -o $logs/$prefix-index.o -n $ncores

		## Markduplicate BAM

		#cmd="/gpfs/software/genomics/BCBIO/v1.1.5/anaconda/bin/bammarkduplicates \
		#tmpfile=WES_COAD_LUMC_SIDRA_281T.sorted-noextras-dedup-markdup \
		#markthreads=$ncores \
		#I=$output/$prefix.bam \
		#O=$output/$prefix.dedup.bam" 

		bamlist1+=($output/$prefix.bam)

		#echo $cmd |  bsub -P test \
		#-w $prefix-index \
		#-J $prefix-bammarkdup \
		#-e $logs/bammarkdup.e \
		#-o $logs/bammarkdup.o \
		#-n $ncores

		### Index bam

		#echo "samtools index -@ $ncores $output/$prefix.dedup.bam $output/$prefix.dedup.bam.bai" | bsub -P test -w $prefix-bammarkdup -J $prefix-dedup-index -e  $logs/$prefix-dedup-index.e -o $logs/$prefix-dedup-index.o -n $ncores

	done


## Run mutect per chromocome separately

	for i in $(seq 1 22) X Y
	do
		if [[ ${#jobnames[@]} == 0 ]]
		then
			jobnames=(mutect-$outprefix-$i)
		else
			jobnames+=( "&&" mutect-$outprefix-$i)
		fi

		cmd="/gpfs/software/tools/java/1.7.0/bin/java -Xms454m -Xmx9g -XX:+UseSerialGC -Djava.io.tmpdir=$output \
		-jar /gpfs/software/tools/Mutect/mutect-1.1.7.jar \
		-R $ref \
		-T MuTect \
		-U ALLOW_N_CIGAR_READS \
		--read_filter NotPrimaryAlignment \
		-I:tumor ${bamlist1[1]} \
		--tumor_sample_name ${prefix2[1]} \
		-I:normal ${bamlist1[0]} \
		--normal_sample_name ${prefix2[0]} \
		--dbsnp /gpfs/data_jrnas1/ref_data/Hsapiens/GRCh37/variation/dbsnp-151.vcf.gz \
		--cosmic /gpfs/data_jrnas1/ref_data/Hsapiens/GRCh37/variation/cosmic-v68-GRCh37.vcf.gz \
		-L $i \
		--interval_set_rule INTERSECTION \
		--enable_qscore_output \
		--vcf $output/$outprefix-$i.mutect.vcf.gz \
		-o /dev/null"

		vcflist+=($output/$outprefix-$i.mutect.vcf.gz)
		
		echo $cmd | bsub -w "${prefix2[0]}-index && ${prefix2[1]}-index" -P test -J mutect-$outprefix-$i -e $logs/mutect-$outprefix-$i.e \
        	-o $logs/mutect-$outprefix-$i.o \
        	-n $ncores
	done


## Concat per-chromosome vcf files to final vcf


	cmd="bcftools concat \
	--threads $ncores \
	-o $output/$outprefix.mutect.vcf.gz \
	-Oz \
	${vcflist[@]}"

	jobnames1=${jobnames[@]}

	echo "${cmd}" | bsub -P test \
	-w "$jobnames1" \
        -J bcftools-$outprefix \
        -e $logs/bcftools-$outprefix.e \
        -o $logs/bcftools-$outprefix.o \
        -n $ncores

### Run SNPEFF

	cmd="/gpfs/software/tools/java/1.8.121/bin/java -Xms454m -Xmx9g -XX:+UseSerialGC \
	-Djava.io.tmpdir=$output -jar /gpfs/software/genomics/snpEff/4.3T/snpEff/snpEff.jar -cancer \
	-i vcf -o vcf \
	-csvStats $output/$outprefix.effects-stats.csv \
	-s $output/$outprefix.effects-stats.html \
	GRCh37.75 \
	$output/$outprefix.mutect.vcf.gz |\
	bgzip -c > $output/$outprefix.mutect.snpeff.vcf.gz;tabix -p vcf $output/$outprefix.mutect.snpeff.vcf.gz"

	echo $cmd | bsub -P test \
        -w bcftools-$outprefix \
        -J snpeff-$outprefix \
        -e $logs/snpeff-$outprefix.e \
        -o $logs/snpeff-$outprefix.o \
        -n $ncores
