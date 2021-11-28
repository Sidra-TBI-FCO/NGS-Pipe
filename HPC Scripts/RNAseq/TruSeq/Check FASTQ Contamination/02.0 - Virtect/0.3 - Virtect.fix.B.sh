#Script virtect 
#Fix last step

module load python/2.7


for i in `ls FASTQ/*_1.fastq.gz`;
do
 name=$(basename "$i" _1.fastq.gz)
 echo processing : $name
 cd Virtect
 cd ${name}.o
 python /gpfs/projects/tmedicine/TBILAB/tools/continous.py
 cd ..
 cd ..
done
