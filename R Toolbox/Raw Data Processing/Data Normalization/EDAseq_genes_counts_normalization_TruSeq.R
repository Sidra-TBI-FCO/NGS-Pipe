#clean global environment
rm(list=ls()) 

#Set working directory 

#load required pakages 
required.packages = c("EDASeq", "base64enc", "preprocessCore", "openxlsx")

# Read text file for row counts
counts = "./Raw Data/counts.txt"
sub.reads = readLines(counts, n=1)  
raw.counts = read.csv(counts, sep = "\t", skip=1, stringsAsFactors = F)

# Load required files
load(paste0(toolbox.path,"./GeneInfo/geneInfo.Sept2018.RData"))

# Extract data related to genes and samples 
genes.info = raw.counts[,c(1:6)]         #row=55882, col=6
samples.data = raw.counts[,-c(2:6)]  #row=55882, col=15

#Edit samples.data format
#Rownames 
rownames(samples.data) = samples.data$Geneid
samples.data$Geneid = NULL

#convert samples.data into matrix 
samples.matrix = as.matrix(samples.data)

#Save data as Rdata file
save(samples.matrix, genes.info,sub.reads, file = "./Analysis/Normalization/Unnormalized_counts.Rdata")

# Set geneInfo as data.freme 
geneInfo = as.data.frame(geneInfo)

# Filter geneInfo
#check if there is NA in rows and Remove from the first column 
#(function is applied for rows, values from first columns)
geneInfo = geneInfo[!is.na(geneInfo[,1]),] #row = 19,513 col=10

#Extract genes from geneInfo that matches genes in samples.matrix
common.genes = unique(rownames(samples.matrix)[which(rownames(samples.matrix) %in% rownames(geneInfo))])

# Extract the common genes for geneInfo and samples.matrix
geneInfo = geneInfo[common.genes,]
samples.filtered = samples.matrix[common.genes,]

mode(samples.filtered) = "numeric"
dim(samples.filtered)  #rows = 18869, columns = 14

#samples.filtered; the final file before normalization 
save(samples.filtered, file = "./Analysis/Normalization/unnormalized_counts_geneInfo_filtered.Rdata")

# Data Normalization using EDASeq
samples.exp.norm = newSeqExpressionSet(samples.filtered, featureData = geneInfo)

#Make sure gcContenet is numeric 
fData(samples.exp.norm)[,"gcContent"] = as.numeric(geneInfo[,"gcContent"])

#within and between lane normalization
# removes lane gene-specific effects, for example effects related to gene length or GC content
samples.exp.norm = withinLaneNormalization(samples.exp.norm, "gcContent", which = "upper", offset = T)

# removes effect related to between lane distributional differences, as sequencing depth
samples.exp.norm = betweenLaneNormalization(samples.exp.norm, which = "upper", offset = T)

# Take= log (unnormalized + .1) + offst(normalized)
samples.norm.log = log(samples.filtered +.1) + offst(samples.exp.norm)
samples.norm.log = floor(exp(samples.norm.log) - .1)  #return non decimal values

# Quantile Normalization
samples.quantiles.norm = normalize.quantiles(samples.norm.log)
samples.quantiles.norm = floor(samples.quantiles.norm)

rownames(samples.quantiles.norm) = rownames(samples.norm.log)
colnames(samples.quantiles.norm) = colnames(samples.norm.log)

#Log transformation (final normalized-transformed file)
quant.Log2.transformed = log(samples.quantiles.norm+1,2) #log base 2

save(quant.Log2.transformed, samples.quantiles.norm, geneInfo, file="./Analysis/Normalization/normalized_counts.Rdata")


