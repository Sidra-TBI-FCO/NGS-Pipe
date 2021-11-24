# Setup environment
rm(list=ls())
load("~/R.Config.Rdata")
setwd(master.location)
setwd(paste0(master.location,"/......./"))                                                  #set the project directory

#load data
load(.....)                                                                                 #load normalised matrix and sample annotation

#prepare result table
t.tests.results <- data.frame (gene=rownames(expression.matrix),
                                    p.value=0,
                                    p.value.fdr=0,
                                    fc=0,
                                    mean.A=0,mean.B=0,
                                    sd.A=0,sd.B=0,
                                    stringsAsFactors = FALSE)
t.tests.results [t.tests.results == 0] <-NA                                                 #make all values NA

#define conditions to test
condtions <- c("A","B")

#loop trough each gene in the expression matrix an perform ttest
for (i in 1:nrow(expression.matrix)){
  subset <- annotation                                                                      #create a test table
  subset$expression <- as.numeric(expression.matrix[i,])                                    #ensure the expression matrix is numeric    
  subset <- subset[subset$condition %in% condtions,]                                        
  if(length(unique(subset$expression[subset$condition==condtions[1]]))<2){next}             #test there is at least 1 of each condition OR skip gene
  if(length(unique(subset$expression[subset$condition==condtions[2]]))<2){next}
  p.value <- t.test(expression~condition,data=subset,var.equal = TRUE)$p.value              #TRUE or sign.var to assuma equal variance
  p.value.fdr <- p.adjust(p = p.value,method = "fdr",n = nrow(expression.matrix))           #fdr correction
  gene <- rownames(expression.matrix)[i]                                                    #fill out the results table
  means <- aggregate(subset$expression,list(subset$condition),mean)
  sd <- aggregate(subset$expression,list(subset$condition),sd)
  mean.A <- means[means$Group.1==condtions[1],2]
  mean.B <- means[means$Group.1==condtions[2],2]
  sd.A <- sd[sd$Group.1==condtions[1],2]
  sd.B <- sd[sd$Group.1==condtions[2],2]
  fc <- 2^(mean.B - mean.A)
  t.tests.results[t.tests.results$gene==gene,c(2:ncol(t.tests.results))] <- c(p.value,p.value.fdr,fc,mean.A,mean.B,sd.A,sd.B)
}
#drop NA genes and orde by significance
t.tests.results <- t.tests.results[-which(is.na(t.tests.results$p.value)),]
t.tests.results <- t.tests.results[order(t.tests.results$fc),]
t.tests.results$p.value.fdr <- p.adjust(p = t.tests.results$p.value,method = "fdr",n = nrow(t.tests.results))
t.tests.results.sign <- t.tests.results[t.tests.results$p.value < 0.05,]

#save as csv and Rdata
