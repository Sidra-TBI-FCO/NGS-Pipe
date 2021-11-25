# indel variant calling
module unload bcbio-nextgen/1.1.1
module load bcbio-nextgen/1.1.5_testing
cd /gpfs/projects/tmedicine/TBILAB/JSREP1/WGS/strelka2/Tumor_Normal_JSREP_1_50/work
COMMAND="bcbio_nextgen.py ../config/Tumor_Normal_WGS.yaml -n 100 --timeout 20000 -s lsf -q normal -r P=batch1_50_WGS"
echo $COMMAND | bsub -n 4 -P variant_calling_JSREP -e vc_error.txt -o vc_output.txt
