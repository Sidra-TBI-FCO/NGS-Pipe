module load SAMtools/1.9
for i in `ls FASTQ/*_1.fastq.gz`;
do
 name=$(basename "$i" _1.fastq.gz)
 echo processing : $name
 INPUT=Virtect/${name}.o/unmapped_aln_sorted.bam
 OUTPUT=Virtect/${name}.o/continuous_region.txt
samtools depth $INPUT | awk '{if ($3>=5) print $0}' | awk '{ if ($2!=(ploc+1)) {if (ploc!=0){printf("%s %d-%d\n",$1,s,ploc);}s=$2} ploc=$2; }' > $OUTPUT


done
