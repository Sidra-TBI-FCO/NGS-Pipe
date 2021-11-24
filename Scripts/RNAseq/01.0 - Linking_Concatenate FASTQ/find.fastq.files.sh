count=1
basepath="/gpfs/projects/ngs_projects/SDR100029_WH_MRNA_CGL_JSREP_JESSICA/raws/"
destination="/gpfs/projects/tmedicine/TBILAB/JSREP1/RNASeq_N_GRCh38/FASTQ/"
while read project_name LIMS_ID Lane FC platform sample_name hello; do
if [ $project_name = "SDR100029_WH_MRNA_CGL_JSREP_JESSICA" ]
then
echo $count
echo $sample_name
samplepath="$basepath""$LIMS_ID"
echo $samplepath
echo $FC
echo $Lane
FCfolder=$(ls $samplepath | grep -e "$FC" | grep -e "$Lane")
echo $FCfolder
filepath="$samplepath""/""$FCfolder"
echo $filepath
R1file=$(ls $filepath | grep -e "R1")
R2file=$(ls $filepath | grep -e "R2")
echo $R1file
echo $R2file
ln -s "$filepath""/""$R1file" "$destination""RNASeq_N_COAD_SILU_""$sample_name""_R1.fastq.gz"
ln -s "$filepath""/""$R2file" "$destination""RNASeq_N_COAD_SILU_""$sample_name""_R2.fastq.gz"
count=$(expr $count + 1)
fi
done <CoreDocTable_03042021.txt 
