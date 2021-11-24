# Set-up environment
rm(list = ls())

# Set working directiry 

# Load required Packages 
required.packages = c("stringr", "ggplot2")
ipak(required.packages)

# Load data
merged_txt = read.csv("./insert file path/samples.maf", sep = "\t") # read maf file called "samples.maf"
head.txt = read.table("./insert file path/head_samples.txt", sep = "\t", stringsAsFactors = FALSE) # read header file called "head_samples.txt" 

# Set colnames
colnames(merged_txt) = head.txt[1,]

MAF_df = merged_txt

# Add sample_ID and Patient ID columns
MAF_df$Sample_ID = gsub("WES_COAD_LUMC_SIDRA_", "", MAF_df$Tumor_Sample_Barcode) # Example
MAF_df$Sample_ID = gsub("_sorted", "", MAF_df$Sample_ID)
MAF_df$Patient_ID = gsub("T", "", MAF_df$Sample_ID) 
MAF_df$Sample_ID = paste(MAF_df$Patient_ID, MAF_df$Tissue, sep = "")

# Add tissue column
MAF_df$Tissue = str_sub(MAF_df$Sample_ID,-1,-1)


mutect_MAF_df = MAF_df

# Save as R data file
dir.create("./Processed_Data/WES/MAF", showWarnings = FALSE)
save(mutect_MAF_df, file = "./Processed_Data/WES/MAF/MAF_mutect_all_version.Rdata")