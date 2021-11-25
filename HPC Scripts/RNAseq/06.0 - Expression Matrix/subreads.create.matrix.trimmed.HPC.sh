START=$(date +%s.%N)

module load subread/v1.6.2

mkdir -p COUNTS_p

featureCounts -p -a /gpfs/projects/tmedicine/TBILAB/tools/ref_genome/GRCh38/Homo_sapiens.GRCh38.93.gtf -g gene_name -o COUNTS_p/counts.txt BAM/*.bam -T 28

END=$(date +%s.%N)

DIFF=$(echo "$END - $START" | bc)

# echo $DIFF
