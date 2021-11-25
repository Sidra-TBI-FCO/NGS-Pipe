bamlist=$1
outdir=$2
ncores=$3

mkdir -p $outdir

if [[ -d $bamlist ]]
then
	normalbam=($bamlist/*_*[0-9]N.recal.bam)
	tumorbam=($bamlist/*_*[0-9]T.recal.bam)
fi

### get common id prefix  from normal & tumor bam

for i in ${normalbam[@]}; 
do 
	prefix1=`basename $i`; 
	prefix2=${prefix1%%.*}; 
	#prefix3=${prefix2%.*}; 
	prefix=${prefix2%N*}; 
	echo -e "$prefix" 
done > $outdir/sampleids.list

## call mutect workflow for a set of fastq files

for i in `cat $outdir/sampleids.list`
do
        #outprefix1=`basename ${bam[$i]}`
        #outprefix=${outprefix1%%.*}

	nbam=`ls $bamlist/$i"N.recal.bam"`
	tbam=`ls $bamlist/$i"T.recal.bam"`

	echo "sh /gpfs/projects/tmedicine/TBILAB/tools/mutect/wrapper-mutect.sh $nbam $tbam $outdir/$i /gpfs/data_jrnas1/ref_data/Hsapiens/GRCh37/seq/GRCh37.fa $ncores $i"
	
done
