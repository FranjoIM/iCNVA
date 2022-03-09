#!/bin/bash
#SBATCH --job-name=ExtractData          # Job name
#SBATCH --mail-type=END,FAIL                        # Mail events (NONE, BEGIN, END, FAIL, ALL)
#SBATCH --mail-user=njofrica@ufl.edu                # Where to send mail
#SBATCH --ntasks=1                                  # Run a single task
#SBATCH --cpus-per-task=1                           # Number of CPU cores per task
#SBATCH --mem=20gb                                  # Total memory limit
#SBATCH --time=48:00:00                             # Time limit hrs:min:sec
#SBATCH --output=/blue/carolmathews/njofrica/CNV_TRIO/LogFiles/%x-%j.log   # Standard output and error log

date;hostname;pwd

cd /blue/carolmathews/njofrica/CNV_TRIO
mkdir -p 02_InitialCalling/Files/FinalReports

module load p7zip/9.20.1

7za x -o02_InitialCalling/Files/FinalReports /orange/carolmathews/njofrica/IlluminaFinalReports/TS_1.1.7z
7za x -o02_InitialCalling/Files/FinalReports /orange/carolmathews/njofrica/IlluminaFinalReports/TS_1.2.7z
7za x -o02_InitialCalling/Files/FinalReports /orange/carolmathews/njofrica/IlluminaFinalReports/TS_1.3.7z
7za x -o02_InitialCalling/Files/FinalReports /orange/carolmathews/njofrica/IlluminaFinalReports/TS_1.4.7z
7za x -o02_InitialCalling/Files/FinalReports /orange/carolmathews/njofrica/IlluminaFinalReports/ASD_1.1.7z
7za x -o02_InitialCalling/Files/FinalReports /orange/carolmathews/njofrica/IlluminaFinalReports/ASD_1.2.7z
