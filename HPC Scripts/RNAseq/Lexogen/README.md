## RNA-Seq Lexogen
The pipeline for RNAseq using lexogen is different from the standard RNAseq using [illumina TruSeq](/HPC%20Scripts/RNAseq/TruSeq). Raw data is processed by Sidra bioinformatics core following the pipeline described in [Lexogen QuantSeq user guide](https://www.lexogen.com/wp-content/uploads/2021/05/015UG108V0311_QuantSeq-Data-Analysis-Pipeline_2021-05-04.pdf). 

## Method
### Processing RANseq and Normalization with EDASeq
mRNA-sequencing was performed using QuantSeq 3’ mRNA-Seq Library Prep Kit FWD for Illumina (75 single-end) with a read depth of average 8.76 M, and average read alignment of 79.60%. 
Single samples were sequenced across four lanes, and the resulting FASTQ files were merged by sample. All FASTQ passed QC and were aligned to the reference genome GRChg38/hg19 using STAR 2.7.9a. 
BAM files were converted to a raw counts expression matrix using HTSeq-count. Then “betweenLaneNormalization” normalized data (EDAseq) was quantiled normalization and log2 transformed (total transcript mapped to genes = 19,959 genes). 
All downstream analysis was performed using RStudio (Version 4.1., RStudio Inc.). 
