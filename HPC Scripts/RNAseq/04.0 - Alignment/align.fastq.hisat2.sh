#script to align all fastq.gz files in the current directory
#creates identically named Bam files for each fastq file

#dependencies
module load hisat2/2.1.0
module load SAMtools/1.3

#the reference genome used
IDX="/gpfs/projects/tmedicine/TBILAB/tools/ref_genome/GRCh38/genome"

#create BAM dir if not existing
mkdir -p BAM
mkdir -p BAM/LOG

#alignment loop (creates jobs)
for i in FASTQ/*_1.fastq.gz;
do
 #echo $(basename $i);
 name=$(basename "$i" _1.fastq.gz)
 echo processing : $name
 R1=FASTQ/${name}_1.fastq.gz
 R2=FASTQ/${name}_2.fastq.gz
 #This keeps track of the messages printed during execution.
 RUNLOG=BAM/LOG/${name}.alignment.runlog.txt
 PREFIX=${name}.temp
 echo "Run by `whoami` on `date`" > $RUNLOG
 #BAM file name
 BAM=BAM/${name}.bam
 #HISAT2
 COMMAND="hisat2 $IDX -1 $R1 -2 $R2 | samtools sort -T $PREFIX > $BAM 2>> $RUNLOG"
 echo $COMMAND | bsub -n 8 -R "span[hosts=1]" -e BAM/LOG/${name}.alignment.errors.txt -o BAM/LOG/${name}.alignment.output.txt -P align_JSREP1
done

#bjobs to view running jobs and || bkill -u [user] 0 || to kill all jobs

