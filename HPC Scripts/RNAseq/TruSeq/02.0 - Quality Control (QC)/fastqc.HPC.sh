#script to do quality control (FastQC) files using all fastq.gz files in the FASTQ directory
#creates identically named html files for each fastq file

module load FastQC/0.11.2
module load python/2.7

mkdir -p QC
mkdir -p QC/LOG
# This keeps track of the messages printed during execution.
RUNLOG=QC/LOG/runlog.fastqc.txt
echo "Run by `whoami` on `date`" > $RUNLOG
#Fastqc
for i in `ls FASTQ/*.fastq.gz`;
do
echo processing $i
name=$(basename "$i" .fastq.gz)
echo $name
COMMAND="fastqc ${i} -o QC"
echo $COMMAND | bsub -n 8 -R "span[hosts=1]" -e QC/LOG/${name}.fastqc.errors.txt -o QC/LOG/${name}.fastqc.output.txt -P fastqc
done
