#Filtering using fpFilter,
module load bam-readcount/0.8.0
module load bedtools/2.28

CC=$1
mkdir -p Filter
mkdir -p Filter/var
mkdir -p Filter/readcount
mkdir -p Filter/fpfilter
mkdir -p Filter/filterVcf

for i in `ls *PASSED.vcf`; do name=$(basename $i .vcf); perl -ane 'print join("\t",@F[0,1,1])."\n" unless(m/^#/)' $i > Filter/var/${name}.var; done

## bam-readcount
# The purpose of this program is to generate metrics at single nucleotide positions.
# There are number of metrics generated which can be useful for filtering out false positive calls.
cat ${CC} | while read -r i ; do batchname=$(echo $i | cut -d',' -f3); tumorname=$(echo $i | cut -d',' -f1); bam-readcount -q1 -b15 -w1 -l Filter/var/${batchname}.var -f /gpfs/data_jrnas1/ref_data/Homo_sapiens/hs37d5/Sequences/WholeGenomeSequence/hs37d5.fa /gpfs/projects/tmedicine/TBILAB/JSREP1/WGS/BAMS/${tumorname}.bam > Filter/readcount/${batchname}.readcount ; done

## fpfilter.pl
#A false-positive filter for variants called from massively parallel sequencing
cat ${CC} | while read -r i ; do batchname=$(echo $i | cut -d',' -f3); tumorname=$(echo $i | cut -d',' -f1);  perl /gpfs/projects/tmedicine/TBILAB/tools/fpfilter.pl --var-file ${batchname}.vcf --readcount-file Filter/readcount/${batchname}.readcount --output-file Filter/fpfilter/${batchname}.fpfilter; done

##AWK -v
# AWK (awk) is a domain-specific language designed for text processing 
for i in `ls Filter/fpfilter/*.fpfilter`; do name=$(basename $i .fpfilter);(head -n1 ${i}; awk -v OFS='\t' '($8 ~ /PASS/){print $1, $2-1, $2}' ${i}) > Filter/fpfilter/${name}.bed; done

## intersectBed
#The tool intersectBed is part of the BEDTools suite of tools and performs an intersection between two BED files.
# this created the fp filtered VCF file
cat ${CC} | while read -r i ; do batchname=$(echo $i | cut -d',' -f3); tumorname=$(echo $i | cut -d',' -f1); intersectBed -a ${batchname}.vcf -b Filter/fpfilter/${batchname}.bed -header > Filter/filterVcf/${batchname}_filter.vcf ; done
  
