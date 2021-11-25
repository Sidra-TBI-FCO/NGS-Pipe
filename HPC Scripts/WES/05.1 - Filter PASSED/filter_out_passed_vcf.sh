module load bcftools/1.8
module load tabix/0.2.6

mkdir PASSED

for i in `ls *.mutect.vcf.gz`; do name=$(basename $i .vcf.gz); echo "bcftools view -f PASS ${i} | bgzip -c > PASSED/${name}_PASSED.vcf.gz" | bsub -P test -J $name -e $name.e -o $name.o; done
# Check output files (if all contain success)
find ./ -name "*.o" -type f | xargs grep Success | wc -l
# Check if all error files are empty (file size is zero)
ls -ltr *.e
# Carefully check and only remove error files and output files from working directory
ls *.e
rm *.e
ls *.o
rm *.o
