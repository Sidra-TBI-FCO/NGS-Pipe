### Merging MAF Files 
This step is done to merge all MAF files from each sample into one MAF, and to create a seperate text file with the column names of MAF file by running the following commands in the terminal in MAF folder

* Variants Calling - SNP 
   * cat *.maf | egrep -v "^#|^Hugo_Symbol" >> samples.maf
   * cat *.maf | egrep "^#|^Hugo_Symbol" | head -2 >> head.txt
 
* Variants Calling - INDEL 
   * cat *PASSED.maf | egrep -v "^#|^Hugo_Symbol" >> strelka2_all_samples.maf
   * cat *.maf | egrep "^#|^Hugo_Symbol" | head -2 >> header_strelka2_all_samples.maf
 
