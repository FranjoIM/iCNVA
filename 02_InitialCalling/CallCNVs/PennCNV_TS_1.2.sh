#!/bin/bash
#SBATCH --job-name=PennCNV_TS_1.2                                                 # Job name
#SBATCH --mail-type=END,FAIL                                                      # Mail events (NONE, BEGIN, END, FAIL, ALL)
#SBATCH --mail-user=njofrica@ufl.edu                                              # Where to send mail
#SBATCH --ntasks=1                                                                # Run a single task
#SBATCH --cpus-per-task=1                                                         # Number of CPU cores per task
#SBATCH --mem=8gb                                                                 # Total memory limit
#SBATCH --time=96:00:00                                                           # Time limit hrs:min:sec
#SBATCH --output=/blue/carolmathews/njofrica/CNV_TRIO/LogFiles/%x-%j.log          # Standard output and error log

#-----------------------------------------------------------------------------------------------------------------
# SETUP THE ENVIRONMENT ------------------------------------------------------------------------------------------
#-----------------------------------------------------------------------------------------------------------------

# Print date, hostname, and working directory
date;hostname;pwd

# Move to CNV TRIO branch
cd /blue/carolmathews/njofrica/CNV_TRIO

# Specify the batch
BATCH="TS_1.2"

# Create necessary directories
mkdir -p /blue/carolmathews/njofrica/CNV_TRIO/02_InitialCalling/Files/${BATCH}/run_PennCNV/results/adjusted
mkdir -p /blue/carolmathews/njofrica/CNV_TRIO/02_InitialCalling/Files/${BATCH}/run_PennCNV/results/raw
mkdir -p /blue/carolmathews/njofrica/CNV_TRIO/02_InitialCalling/Files/${BATCH}/run_PennCNV/results/logs

# Create variables and directory paths
PENNCNV_DIR=/apps/penncnv/1.0.5
workdir="/blue/carolmathews/njofrica/CNV_TRIO/02_InitialCalling/Files/${BATCH}/run_PennCNV"
frPath="/blue/carolmathews/njofrica/CNV_TRIO/02_InitialCalling/Files/${BATCH}/run_PennCNV/data"
outputdir="/blue/carolmathews/njofrica/CNV_TRIO/02_InitialCalling/Files/${BATCH}/run_PennCNV/results"
SNPpos="/blue/carolmathews/njofrica/CNV_TRIO/02_InitialCalling/Files/${BATCH}/run_PennCNV/SNP_pos_aut.txt"

#-----------------------------------------------------------------------------------------------------------------
# PENN CNV -------------------------------------------------------------------------------------------------------
#-----------------------------------------------------------------------------------------------------------------

# Create a list of SNPs
awk '{ if((NR == 1) || ($2 >= 1 && $2 <= 22)) { print } }' \
  /blue/carolmathews/njofrica/CNV_TRIO/02_InitialCalling/Files/${BATCH}/IntensityMatrices/SNP_pos.txt > \
  ${SNPpos}

# Create a list of samples from frPath
ls ${frPath} > ${workdir}/samples
samples="${workdir}/samples"

# Load PennCNV Module
module load penncnv/1.0.5

# define sample information for running
sample=$1
N=$(ls ${samples} | wc -l)

echo "1. Decompress the input gc file"
time zcat ${PENNCNV_DIR}/gc_file/hg19.gc5Base.txt.gz |\
  sort -k2,2 -k3,3n \
  > ${workdir}/hg19.gc5Base_sorted.txt
 
echo "2. Make a gcmodel file for dataset..."
time (
  ${PENNCNV_DIR}/cal_gc_snp.pl \
    --output ${workdir}/input.hg19.gcmodel \
    ${workdir}/hg19.gc5Base_sorted.txt \
    ${SNPpos}
  )
 
echo "3. Make a pfb file for dataset..."
time (
  ls ${frPath}/* > ${workdir}/intensity_data.adjusted.list
  ${PENNCNV_DIR}/compile_pfb.pl \
    --output ${workdir}/dataset.pfb \
    --snpposfile ${SNPpos} \
    --listfile ${workdir}/intensity_data.adjusted.list
  )

cat ${samples} | while read item || [[ -n $line ]]
do
  echo "4. Adjust for genomic wave..."
  time (
    ${PENNCNV_DIR}/genomic_wave.pl \
    --prefix ${outputdir}/adjusted/ \
    -adjust \
    -gcmodel ${workdir}/input.hg19.gcmodel \
    ${frPath}/${item}
    )
    
  echo "5. call cnv using penncnv..."
  time (
    ${PENNCNV_DIR}/detect_cnv.pl \
    -test \
    -hmm ${PENNCNV_DIR}/lib/hhall.hmm \
    -pfb ${workdir}/dataset.pfb \
    --gcmodelfile ${workdir}/input.hg19.gcmodel \
    -log ${outputdir}/logs/${item}.log \
    -out ${outputdir}/raw/${item}.raw \
    ${outputdir}/adjusted/${item}.adjusted
    )
done;
