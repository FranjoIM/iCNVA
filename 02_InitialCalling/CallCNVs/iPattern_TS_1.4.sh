#!/bin/bash
#SBATCH --job-name=PennCNV_TS_1.1                                                 # Job name
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

# Load Modules
module load python/2.7.18
module load R/4.1

# Export iPattern Paths
export IPNBASE=‘/home/njofrica/ipn_0.582’
export PYTHONPATH="${PYTHONPATH}:/home/njofrica/ipn_0.582/ipnlib"
export PATH=$PATH:/home/njofrica/ipn_0.582/preprocess/affy
export PATH=$PATH:/home/njofrica/ipn_0.582/preprocess/ilmn
export PATH=$PATH:/home/njofrica/ipn_0.582/ipn

# Move to CNV TRIO branch
cd /blue/carolmathews/njofrica/CNV_TRIO

# Specify the batch
BATCH="TS_1.4"

# Create necessary directories
mkdir -p /blue/carolmathews/njofrica/CNV_TRIO/02_InitialCalling/Files/${BATCH}/run_iPattern/results
mkdir -p /blue/carolmathews/njofrica/CNV_TRIO/02_InitialCalling/Files/${BATCH}/run_iPattern/data_aux


# Create variables and directory paths
PENNCNV_DIR=/apps/penncnv/1.0.5
workdir="/blue/carolmathews/njofrica/CNV_TRIO/02_InitialCalling/Files/${BATCH}/run_iPattern"
SNPpos="/blue/carolmathews/njofrica/CNV_TRIO/02_InitialCalling/Files/${BATCH}/run_PennCNV/SNP_pos_aut.txt"

#-----------------------------------------------------------------------------------------------------------------
# IPATTERN -------------------------------------------------------------------------------------------------------
#-----------------------------------------------------------------------------------------------------------------

PROJECT_NAME=${BATCH}
Rscript /blue/carolmathews/njofrica/CNV_TRIO/02_InitialCalling/CallCNVs/prepare_input_files_for_iPattern.R ${workdir} ${PROJECT_NAME}

${IPNBASE}/ipn_0.582/preprocess/ilmn/ilmn_run.py \
--data-file-list   ${workdir}/data_aux/${PROJECT_NAME}_data_file.txt \
--gender-file      ${workdir}/data_aux/${PROJECT_NAME}_gender_file.txt \
--bad-sample-file  ${workdir}/data_aux/${PROJECT_NAME}_bad_samples.txt \
--probe-file       /blue/carolmathews/njofrica/CNV_TRIO/02_InitialCalling/Files/${BATCH}/run_PennCNV/SNP_pos_aut.txt \
--experiment       $PROJECT_NAME \
--output-directory ${workdir}/01_initial_call/run_iPattern/results/ \
--do-log \
--do-cleanup \
--noqsub
