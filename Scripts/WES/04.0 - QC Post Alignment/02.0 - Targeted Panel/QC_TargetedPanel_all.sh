module load java/1.8.0
for i in BAMS/*.sorted.bam; do name=$(basename "$i" .sorted.bam); sh QC_TargetedPanel.sh -i $i -l BAMS/QC -o $name -n 16 -p JSREP -b /gpfs/projects/tmedicine/TBILAB/scripts/S07604514_AllTrack.intervals; done
