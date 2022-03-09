# iCNVA: An Integrated CNV Analysis Pipeline

iCNVA is an integratad CNV analysis pipeline, intended for a seamless analysis workflow from Illumina final report stage to phenotype association analysis. The analysis integrates MarkerMatch algorithm ([@FranjoIM](https://github.com/FranjoIM))<sup>1</sup> with ensembleCNV<sup>2</sup>, PennCNV<sup>3</sup>, QuantiSNP<sup>4</sup>, iPattern<sup>5</sup>, FRAPOSA<sup>6</sup>, GenomeStudio and Slurm scheduler to run the analaysis of copy-number variation with respect to a case-control phenotype.

## Marker Match
If batches were genotyped on different arrays, run marker match on array manifests to get concensus markers for CNV analysis. 
```bash
WorkDir=$(pwd)
sbatch ${WorkDir}/00_Resources/SLURM_Scripts/01_MarkerMatch.sh
```

## Sample Clustering
Cluster samples in Illumina GenomeStudio.

## Extract FinalReport files
```bash
WorkDir=$(pwd)
sbatch ${WorkDir}/02_InitialCalling/FinalReport/UnpackFinalReports.sh
```

## References
1. Ivankovic, F. (nd). Marker match. Unpublished. Doi: [NA](#)  
2. Zhang, Z., Cheng, H., Hong, X., Di Narzo, A.F., Franzen, O., Peng, S., ... & Hao, K. (2019). EnsembleCNV: an ensemble machine learning algorithm to identify and genotype copy number variation using SNP array data. *Nucleic Acids Research*, 47(7), e39. Doi: [10.1093/nar/gkz068](https://doi.org/10.1093/nar/gkz068)  
3. Wang, K., Li, M., Hadley, D., Liu, R., Glessner, J., Grant, S.F., ... & Bucan, M. (2007). PennCNV: An integrated hidden Markov model designed for high-resolution copy number variation detection in whole-genome SNP genotyping data. *Genome Research*, 17(11), 1665-74. Doi: [10.1101/gr.6861907](https://doi.org/10.1101/gr.6861907)  
4. Colella, S., Yau, C., Taylor, J.M., Mirza, G., Butler, H., Clouston, P., ... & Ragoussis, J. (2007). QuantiSNP: an Objective Bayes Hidden-Markov Model to detect and accurately map copy number variation using SNP genotyping data. *Nucleic Acids Research*, 35(6), 2013-25. Doi: [10.1093/nar/gkm076](https://doi.org/10.1093/nar/gkm076)  
5. Pinto, D., Darvishi, K., Shi, X., Rajan, D., Rigler, D., Fitzgerald, T., ... & Feuk, L. (2011). Comprehensive assessment of array-based platforms and calling algorithms for detection of copy number variants. *Nature Biotechnology*, 29(6), 512-20. Doi: [10.1038/nbt.1852](https://doi.org/10.1038/nbt.1852)  
6. Zhang, D., Dey, R., & Lee, S. (2020). Fast and robust ancestry prediction using principal component analysis. *Bioinformatics*, 36(11), 3439-46. Doi: [10.1093/bioinformatics/btaa152](https://doi.org/10.1093/bioinformatics/btaa152)
