#!/bin/bash
#SBATCH --job-name=MarkerMatch              # Job name	
#SBATCH --mail-type=END,FAIL                # Mail events
#SBATCH --mail-user=njofrica@ufl.edu        # Where to send mail	
#SBATCH --ntasks=1                          # Number of tasks
#SBATCH --mem=15gb                          # Per processor memory
#SBATCH --time=05:00:00                     # Walltime

date; hostname; pwd

# Create holding directory --------------------------------------------
mkdir -p ${WorkDir}/01_MarkerMatch/Outputs

# Load modules --------------------------------------------------------
module load R/4.1

# Run R Marker Match script ------------------------------------------- 
Rscript myRscript.R
