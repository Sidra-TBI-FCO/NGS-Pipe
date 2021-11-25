#script to allign all fastq.gz files in the current directory
#creates identically named Bam files for each fastq file

#dependencies
module load flexbar/3.0.3

#the reference ilumina file
IDX="/gpfs/projects/tmedicine/TBILAB/tools/ref_genome/Illumina.primers.fasta"

#create TRIMMED dir if not existing
mkdir -p TRIMMED
mkdir -p TRIMMED/FASTQ
mkdir -p TRIMMED/FASTQ/LOG

#trimming loop (creates jobs)
for i in FASTQ/*_R1.fastq.gz;
do
 #echo $(basename $i);
 name=$(basename "$i" _R1.fastq.gz)
 echo processing : $name
 R1=FASTQ/${name}_R1.fastq.gz
 R2=FASTQ/${name}_R2.fastq.gz
 #This keeps track of the messages printed during execution.
 RUNLOG=TRIMMED/FASTQ/LOG/${name}.trim.runlog.txt
 echo "Run by `whoami` on `date`" > $RUNLOG
 #TRIMMED file name
 TRIMMED=TRIMMED/FASTQ/${name}.trimmed
 #FLEXBAR
 COMMAND="flexbar --reads $R1 --reads2 $R2 --target $TRIMMED --adapters $IDX --adapter-min-overlap 7 --adapter-trim-end RIGHT --pre-trim-left 13 --max-uncalled 300 --min-read-length 25 --threads 8 --zip-output GZ >> $RUNLOG"
 echo $COMMAND | bsub -n 8 -R "span[hosts=1]" -e TRIMMED/FASTQ/LOG/${name}.trim.errors.txt -o TRIMMED/FASTQ/LOG/${name}.trim.output.txt -P JSREP_trimming
done
