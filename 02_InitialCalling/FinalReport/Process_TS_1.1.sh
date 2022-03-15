#!/bin/bash
#SBATCH --job-name=Process_TS_1.1                     # Job name
#SBATCH --mail-type=END,FAIL                        # Mail events (NONE, BEGIN, END, FAIL, ALL)
#SBATCH --mail-user=njofrica@ufl.edu                # Where to send mail
#SBATCH --ntasks=1                                  # Run a single task
#SBATCH --cpus-per-task=1                           # Number of CPU cores per task
#SBATCH --mem=20gb                                  # Total memory limit
#SBATCH --time=48:00:00                             # Time limit hrs:min:sec
#SBATCH --output=/blue/carolmathews/njofrica/CNV_TRIO/LogFiles/%x-%j.log   # Standard output and error log

date;hostname;pwd

cd /blue/carolmathews/njofrica/CNV_TRIO

WKDIR="/blue/carolmathews/njofrica/CNV_TRIO"
BATCH="TS_1.1"

FR="${WKDIR}/02_InitialCalling/Files/FinalReports/${BATCH}.txt"

mkdir -p 02_InitialCalling/Files/${BATCH}/IntensityMatrices
mkdir -p 02_InitialCalling/Files/${BATCH}/run_iPattern/data
mkdir -p 02_InitialCalling/Files/${BATCH}/run_PennCNV/data
mkdir -p 02_InitialCalling/Files/${BATCH}/run_QuantiSNP/data

module load perl/5.24.1

# Extract intensity metrics  ---------------------------------------------------------------

perl ${WKDIR}/02_InitialCalling/FinalReport/finalreport_matrix_LRR_BAF.pl \
	${FR} \
	${WKDIR}/02_InitialCalling/Files/${BATCH}/IntensityMatrices

# Prepare for calling  ---------------------------------------------------------------

perl ${WKDIR}/02_InitialCalling/FinalReport/finalreport_to_iPattern.pl \
	-prefix ${WKDIR}/02_InitialCalling/Files/${BATCH}/run_iPattern/data/ \
	-suffix .txt \
	${FR}

perl ${WKDIR}/02_InitialCalling/FinalReport/finalreport_to_PennCNV.pl \
	-prefix ${WKDIR}/02_InitialCalling/Files/${BATCH}/run_PennCNV/data/ \
	-suffix .txt \
	${FR}

perl ${WKDIR}/02_InitialCalling/FinalReport/finalreport_to_QuantiSNP.pl \
	-prefix ${WKDIR}/02_InitialCalling/Files/${BATCH}/run_QuantiSNP/data \
	-suffix .txt \
	${FR}

# Convert Intensity data to RDS ---------------------------------------------------------------

module load R

Rscript ${WKDIR}/02_InitialCalling/FinalReport/transform_from_tab_to_rds.R \
  --input ${WKDIR}/02_InitialCalling/Files/${BATCH}/IntensityMatrices \
  --output ${WKDIR}/02_InitialCalling/Files/${BATCH}/IntensityMatrices/RDS \
  --startChr 1 \
  --endChr 22
