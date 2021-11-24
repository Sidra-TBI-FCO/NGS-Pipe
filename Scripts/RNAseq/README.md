## RNA-Seq pipeline
Here we provide the tools to process raw RNAseq paired end read from cancer samples using bash and python scripts. As input files, zipped fastq-files (.fastq.gz) are used. In case of paired end reads, corresponding fastq files should be named using .R1.fastq.gz and .R2.fastq.gz suffixes. Output files will be .bam files and then a text file with read counts.

### Pipeline Workflow
![RNAseq Pipeline](/Figures/RNAseq_pipeline.png)
