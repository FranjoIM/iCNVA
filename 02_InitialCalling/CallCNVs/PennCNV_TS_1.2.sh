#!/bin/bash
#SBATCH --job-name=PennCNV_TS_1.2                                                 # Job name
#SBATCH --mail-type=END,FAIL                                                      # Mail events (NONE, BEGIN, END, FAIL, ALL)
#SBATCH --mail-user=njofrica@ufl.edu                                              # Where to send mail
#SBATCH --ntasks=1                                                                # Run a single task
#SBATCH --cpus-per-task=1                                                         # Number of CPU cores per task
#SBATCH --mem=8gb                                                                 # Total memory limit
#SBATCH --time=48:00:00                                                           # Time limit hrs:min:sec
#SBATCH --output=/blue/carolmathews/njofrica/CNV_TRIO/LogFiles/%x-%j.log          # Standard output and error log

#-----------------------------------------------------------------------------------------------------------------
# SETUP THE ENVIRONMENT ------------------------------------------------------------------------------------------
#-----------------------------------------------------------------------------------------------------------------

# Print date, hostname, and working directory
date;hostname;pwd

# Move to CNV TRIO branch
cd /blue/carolmathews/njofrica/CNV_TRIO

# Declare CNV TRIO branch a working directory
WKDIR="/blue/carolmathews/njofrica/CNV_TRIO"

# Specify the batch
BATCH="TS_1.2"

# Define the batch stem
FR="${WKDIR}/02_InitialCalling/Files/${BATCH}"

# Create necessary directories
mkdir -p ${FR}/run_PennCNV/data_aux
mkdir -p ${FR}/run_PennCNV/results/adjusted
mkdir -p ${FR}/run_PennCNV/results/raw
mkdir -p ${FR}/run_PennCNV/results/logs

# Load necessary modules
module load perl/5.24.1
module load penncnv/1.0.5

# Export necessary paths
export PENNCNV=${HPC_PENNCNV_DIR}

#-----------------------------------------------------------------------------------------------------------------
# PENN CNV -------------------------------------------------------------------------------------------------------
#-----------------------------------------------------------------------------------------------------------------

# Create a list of files for processing
ls ${FR}/run_PennCNV/data/* > ${FR}/run_PennCNV/data_aux/list_pfb.txt

# Remove non-autosomes from analysis
awk '$2>0 && $2<23 {print}' ${FR}/IntensityMatrices/SNP_pos.txt > ${FR}/IntensityMatrices/SNP_pos_aut.txt

# Decompress the input GC file
zcat ${PENNCNV_DIR}/gc_file/hg19.gc5Base.txt.gz | \
  sort -k2,2 -k3,3n > \
  ${FR}/run_PennCNV/data_aux/hg19.gc5Base_sorted.txt
  
# Make GC model
perl ${PENNCNV}/cal_gc_snp.pl \
  --output ${FR}/run_PennCNV/data_aux/input.hg19.gcmodel \
  ${FR}/run_PennCNV/data_aux/hg19.gc5Base_sorted.tx \
  ${FR}/IntensityMatrices/SNP_pos_aut.txt

# Compile PFB
perl ${PENNCNV}/compile_pfb.pl \
  -snpposfile ${FR}/IntensityMatrices/SNP_pos_aut.txt \
  -listfile ${FR}/run_PennCNV/data_aux/list_pfb.txt \
  -output ${FR}/run_PennCNV/data_aux/SNP.pfb

# GC adjust files and call CNVs
cat ${FR}/run_PennCNV/data_aux/list_pfb.txt | while read item || [[ -n $line ]]
do
  time (
    ${HPC_PENNCNV_DIR}/genomic_wave.pl \
    --prefix ${FR}/run_PennCNV/results/adjusted \
    -adjust \
    -gcmodel ${FR}/run_PennCNV/data_aux/input.hg19.gcmodel \
    ${FR}/run_PennCNV/data/${item}
    )
    
  time (
    ${HPC_PENNCNV_DIR}/detect_cnv.pl \
    -test \
    -hmm ${HPC_PENNCNV_DIR}/lib/hhall.hmm \
    -pfb ${FR}/run_PennCNV/data_aux/SNP.pfb \
    --gcmodelfile ${FR}/run_PennCNV/data_aux/input.hg19.gcmodel \
    -log ${FR}/run_PennCNV/results/logs/${item}.log \
    -out ${FR}/run_PennCNV/results/raw/${item}.raw \
    ${FR}/run_PennCNV/results/adjusted/${item}.adjusted
    )
done;
