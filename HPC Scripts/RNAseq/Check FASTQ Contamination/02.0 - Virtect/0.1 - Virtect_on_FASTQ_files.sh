#Script virtect 
#Create Virtect folder and run inside that folder

module load VirTect/13Nov2019

#Test on a single sample 
#python $PYPATH/VirTect.py -t 12 -1 PD-1-01_R1_001.fastq.gz -2 PD-1-01_R2_001.fastq.gz -o Virtect/Test -ucsc_gene /gpfs/data_jrnas1/ref_data/Hsapiens/hg38/seq/hg38.fa -index gpfs/data_jrnas1/ref_data/Hsapiens/hg38/seq/hg38.fai -index_vir /gpfs/data_jrnas1/ref_data/viruses_reference/viruses_757.fasta -d 200
#python $PYPATH/VirTect.py -t 12 -1 FASTQ/PD-1-01.trimmed_1.fastq.gz -2 FASTQ/PD-1-01.trimmed_2.fastq.gz -o Virtect/Test -ucsc_gene /gpfs/data_jrnas1/ref_data/Hsapiens/hg38/seq/hg38.fa -index /gpfs/data_jrnas1/ref_data/Hsapiens/hg38/seq/hg38.fai -index_vir /gpfs/data_jrnas1/ref_data/viruses_reference/viruses_757.fasta -d 200
#python $PYPATH/VirTect.py -t 12 -1 FASTQ/PD-1-01.trimmed_1.fastq.gz -2 FASTQ/PD-1-01.trimmed_2.fastq.gz -o Virtect/Test -ucsc_gene /gpfs/data_jrnas1/ref_data/human_reference/gencode.v29.annotation.gtf -index /gpfs/data_jrnas1/ref_data/human_reference/GRCh38.p12.genome -index_vir /gpfs/data_jrnas1/ref_data/viruses_reference/viruses_757.fasta -d 200

mkdir Virtect
mkdir Virtect/LOG

for i in `ls FASTQ/*_1.fastq.gz`;
do
 echo $i
 name=$(basename "$i" _1.fastq.gz)
 echo processing : $name
 R1=FASTQ/${name}_1.fastq.gz
 R2=FASTQ/${name}_2.fastq.gz
 #Virtect output file name
 OUTPUT=Virtect/${name}.o
 #Virtect
 COMMAND="python $PYPATH/VirTect.py -t 12 -1 $R1 -2 $R2 -o $OUTPUT -ucsc_gene /gpfs/data_jrnas1/ref_data/human_reference/gencode.v29.annotation.gtf -index /gpfs/data_jrnas1/ref_data/human_reference/GRCh38.p12.genome -index_vir /gpfs/data_jrnas1/ref_data/viruses_reference/viruses_757.fasta -d 200"
 echo $COMMAND | bsub -n 8 -R "span[hosts=1]" -e Virtect/LOG/${name}_virtect.errors.txt -o Virtect/LOG/${name}_virtect.output.txt -P Virtect_JSREP1
done
