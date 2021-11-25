module load mosdepth/v0.2.8
#mkdir /gpfs/projects/tmedicine/TBILAB/JSREP1/WGS/BAMS/QC/mosdepth
for i in `ls /gpfs/projects/tmedicine/TBILAB/JSREP1/WGS/BAMS/*.sorted.bam`
do name=$(basename $i .sorted.bam)
echo "mosdepth -t 4 -b /gpfs/projects/tmedicine/TBILAB/scripts/S07604514_Covered_withoutChr.bed ${name} ${i}" | bsub -n 4 -e ${name}.err -o ${name}.out -P JSREP1
done
#module load python/3.6.6
#python /gpfs/software/genomics/mosdepth/scripts/plot-dist.py *.dist

#Commnad syntax : mosdepth -t [number of cores] -b [bed file in case of WES] [output prefix] [your input bam]
#Eg: mosdepth -t 4 -b targetintervals.bed mosdepthresult test.bam
#mosdepth -t 8 -b /gpfs/projects/tmedicine/TBILAB/scripts/S07604514_Covered_withoutChr.bed ${name} ${i}
