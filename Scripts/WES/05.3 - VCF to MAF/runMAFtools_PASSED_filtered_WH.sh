module load SAMtools/1.9 
module load htslib/1.9
module load vcf2maf/v1.6.18
module load VEP/release-83
module load perl/5.28.0

mkdir MAF

while read line; do
	name=$(echo $line | cut -d',' -f3)
	#name=$(echo ${name} | sed 's/^M//')	
	tumor=$(echo $line | cut -d',' -f1)
	normal=$(echo $line | cut -d',' -f2)
	echo ${normal}, ${tumor}, ${name}
	
	 echo "vcf2maf.pl --input Filter/filterVcf/${name}_filter.vcf \
	 		--output-maf MAF/${name}_filter.maf \
			--tumor-id ${tumor} \
			--normal-id ${normal} \
			--vcf-tumor-id TUMOR \
	 		--vcf-normal-id NORMAL \
			--ref-fasta /gpfs/data_jrnas1/ref_data/Hsapiens/GRCh37/seq/GRCh37.fa \
	 		--filter-vcf /gpfs/data_jrnas1/ref_data/Hsapiens/GRCh37/variation/ExAC.r0.3.1.sites.vep.vcf.gz \
	 		--vep-path /gpfs/software/genomics/VEP/ensembl-tools-release-99/ensembl-vep/ \
			--vep-data /gpfs/software/genomics/VEP/ensembl-tools-release-99/ensembl-vep/" | bsub -n 8 -e ${name}.e -o ${name}.o -P VCFtoMAF
	 	done < tumor_normal_vcf.txt

