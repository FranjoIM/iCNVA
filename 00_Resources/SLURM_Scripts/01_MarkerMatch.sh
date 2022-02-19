#!/bin/bash
#SBATCH --job-name=01_MarkerMatch
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=njofrica@ufl.edu
#SBATCH --ntasks=1
#SBATCH --mem=15gb
#SBATCH --time=10:00:00
#SBATCH --output=/blue/carolmathews/njofrica/CNV_TRIO/00_Resources/SLURM_Logs/LOG_%j-%x.log

date; hostname; pwd
WorkDir=$(pwd)

# Create holding directory --------------------------------------------
mkdir -p ${WorkDir}/01_MarkerMatch/Outputs

# Load modules --------------------------------------------------------
module load R/4.1

# Run R Marker Match script ------------------------------------------- 
Rscript ${WorkDir}/01_MarkerMatch/MarkerMatch.R \
  --ref GSA-24v1-0_C1.csv \
  --mat ${WorkDir}/00_Resources/Manifests \
  --dist 10000 \
  --out ${WorkDir}/01_MarkerMatch/Outputs
