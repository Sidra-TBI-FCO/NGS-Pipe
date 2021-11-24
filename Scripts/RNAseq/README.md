## RNA-Seq pipeline
Here we provide the tools to process raw RNAseq paired end read from cancer samples using bash and python scripts. As input files, zipped fastq-files (.fastq.gz) are used. In case of paired end reads, corresponding fastq files should be named using .R1.fastq.gz and .R2.fastq.gz suffixes. Output files will be .bam files and then a text file with read counts.

### Pipeline Workflow
![RNAseq Pipeline](/Figures/RNAseq_pipeline.png)

## Pipeline Steps
### 01.0 Link/Concatenate FASTQ files
- The first step in the pipeline is to create renamed links or concatenated FASTQ files in a new folder called FASTQ. 

### 02.0 Quality control
- This step is done in the project folder. All fastq.gz files available in FASTQ folder will be QC'ed [FastqQ files quality](/Scripts/RNASeq/0.1-%20QC), then MultiQC will be run to agregate the results into one HTML report. All individual fastQC output files will be created in a new folder called QC, while the multiQC report will go in the project folder. 

### 03.0 Trimming
- [Trimming](/Scripts/RNASeq/0.2%20-%20Trimming/trimming.fastq.HPC.sh) of adapter sequences from short read data in the fastq files avilable in FASTQ folder. This step is done in the main project folder, and the output (trimmed fastq files) will be created in a new folder called TRIMMED/FASTQ. Quality control of the trimmed fastq files can be done following the previous step inside the TRIMMED folder.

### 04.0 Alignment
- Allign reads to the reference genome GRCH37 or GRCH38 using STAR or Hista2. Currently we are using reference genome GRCH38 and [Hisat2 aligner](/Scripts/RNASeq/0.3%20-%20Alignment/align.fastq.hisat2.sh). This step is done in TRIMMED folder and uses the trimmed fastq files generated from the previous step. The output files from this step will be .bam files and created in TRIMMED/BAM folder. 

#### 05.0 QC Post Alignment 
- Post alignment quality control of bam files created from the previous step is aggregated by running MultiQc in the TRIMMED folder. The output from this step will be an HTML multiqc report generated in the TRIMMED folder. 

#### 06.0 Expression Matrix
- Generate a raw counts matrix using subreads [featureCounts](/Scripts/RNASeq/0.4%20-%20Feature%20Counts/subreads.create.matrix.trimmed.HPC.sh). This step will uses all .bam files generated from step 4, and will be done in TRIMMED folder. The output file from this step is a gene expression matrix text file that will be created in TRIMMED/COUNT-p (p for paired) folder. Downstream analysis is done using R. 

#### 07.0 Normalization 
- Data normalization for expression matrix is done by reading raw counts data into R. Normalization can be performed in many ways, DESeq2 Has its own normalization build in, while [EDAseq](/../../r-toolbox/-/blob/master/Raw%20Data%20Processing/Normalization/gene_counts_normalization.R) uses a ["gccontent" file](/../../r-toolbox/-/blob/master/Raw%20Data%20Processing/Normalization/geneInfo.Sept2018.RData) to perform within and between lane normalization.

#### 08.0 Downstream analysis
- Further data analysis is performed in [R](/../../r-toolbox/-/tree/master/Data%20Analysis)

#### check FASTQ Contamination
This is an additional step that can be done to check the contamination of fastq files with:

A. Genome from other species using [FastQ screen](/Scripts/RNASeq/FASTQ%20Check%20Contamination/0.1%20-%20FASTQ%20Screen/fastq_screen_HPC.sh).
This step uses the trimmed fastq files and generates a text and html files for each sample in new folder called CONTAMINATION.  

B. [viral genome](/Scripts/RNASeq/FASTQ%20Check%20Contamination/0.2%20-%20Virtect). This step uses the trimmed fastq files and requires the run of three scrips in order [virtect in FASTQ](/Scripts/RNASeq/FASTQ%20Check%20Contamination/0.2%20-%20Virtect/0.1%20-%20Virtect_on_FASTQ_files.sh), [virtect A](/Scripts/RNASeq/FASTQ%20Check%20Contamination/0.2%20-%20Virtect/0.2%20-%20Virtect.fix.A.sh), and [virtect B](/Scripts/RNASeq/FASTQ%20Check%20Contamination/0.2%20-%20Virtect/0.3%20-%20Virtect.fix.B.sh). The output of this step is a text file for each sample called "continoues_region" created in Virtect folder. Rename each continoues_region file to the corresponding sample name and download to a local folder. Downstream analysis is done using R.

## Output Folders structure
Labname/Project (The project folder)
- FASTQ: Raw data (fastq files)
- QC: Quality control of fastq files 
- TRIMMED 
  - FASTQ: Trimmed fastq files
  - BAM: Aligned reads (.bam files)
  - QC: MultiQC report of all fastq files and bam files
  - COUNT-p: Gene expression matrix (text file)
  - CONTAMINATION
  - Virtect

## Method
### Transcriptomic Data Processing 
FastQC was run to perform quality control checks on the raw sequence data (python v.2.7.1, FastQC v.0.11.2). Trimming of adapter sequences was performed using flexbar (v.3.0.3) [(Dodt et al. 2012)](https://doi.org/10.3390/biology1030895) using Illumina primers FASTA file. Subsequently, reads were aligned to reference genome GRCh38.93 by Hisat2 (v.2.1.0) [(Kim et al. 2019)](https://doi.org/10.1038/s41587-019-0201-4) using SAMtools (v.1.3) [(Li et al. 2009)](https://doi.org/10.1093/bioinformatics/btp352). After alignment, QC was performed to verify quality of the alignment and paired-end mapping overlap (Bowtie2, v.2.3.4.2) [(Langmead and Salzberg 2012)](https://doi.org/10.1038/nmeth.1923). Finally, the featureCounts function [(Y. Liao, Smyth, and Shi 2014)](https://doi.org/10.1093/bioinformatics/btt656) of subreads (v.1.5.1) [(Yang Liao, Smyth, and Shi 2013)](https://doi.org/10.1093/nar/gkt214) was used to count paired reads per genes aligned with the [Ensembl GRHh37.87 reference](http://grch37.ensembl.org/index.html) gtf file. For the lncRNA expression subreads was used in combination with the [GRCh37.p13 gencode](https://www.gencodegenes.org/human/grch37_mapped_releases.html) lncRNA reference gtf file. Gene expression normalization was performed within lanes, to correct for gene-specific effects (including GC-content and gene length) and between lanes, to correct for sample-related differences (including sequencing depth) using EDASeq (Exploratory Data Analysis and Normalization for RNA-Seq) (R, v.2.12.0)[(Risso et al. 2011)](https://doi.org/10.1186/1471-2105-12-480). The resulting expression values were quantile normalized using preprocessCore (R, v.1.36.0) [(Bolstad 2016)](https://github.com/bmbolstad/preprocessCore). All downstream analysis of the expression data was performed using R (v.3.5.1, or later). 
