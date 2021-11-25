START=$(date +%s.%N)
module load FastQ_Screen/0.14.0
mkdir -p CONTAMINATION
mkdir -p CONTAMINATION/LOG

#submission loop (creates jobs)
for i in FASTQ/*.fastq.gz;
do
echo $i
 name=$(basename $i .fastq.gz);
 echo processing : $name
 #This keeps track of the messages printed during execution.
 RUNLOG=CONTAMINATION/LOG/${name}.allignment.runlog.txt
 echo "Run by `whoami` on `date`" > $RUNLOG
 #FastQ_Screen
 COMMAND="fastq_screen $i --aligner bowtie2 --outdir ../TRIMMED/CONTAMINATION >> $RUNLOG"
 echo $COMMAND | bsub -n 8 -R "span[hosts=1]" -e CONTAMINATION/LOG/${name}.errors.txt -o CONTAMINATION/LOG/${name}.output.txt -P FASTQSCREEN
done

END=$(date +%s.%N)
DIFF=$(echo "$END - $START" | bc)
echo $DIFF
