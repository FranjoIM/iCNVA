#!/usr/bin/env Rscirpt

## NOTE: The scripts embraced by "##<<<... ##>>>..." need to be specified based on your system

## The script was used to run MarkerMatch on HiPerGator/Slurm. Modifications might be necessary for your use.

# Load packages ------------------------------------------------------------------------------------------------------------------------

suppressMessages({require(optparse, quietly = TRUE)})
suppressMessages({require(readr, quietly = TRUE)})
suppressMessages({require(tidyr, quietly = TRUE)})
suppressMessages({require(dplyr, quietly = TRUE)})

# Parse input --------------------------------------------------------------------------------------------------------------------------

option_list <- list(
  make_option(c("-r", "--ref"), action = "store", default = NA, type = "character",
              help = "name of the reference Illumina manifest csv file to be matched with."),  
  make_option(c("-m", "--mat"), action = "store", default = NA, type = "character",
              help = "path to directory with Illumina manifest csv files to match to reference."),
  make_option(c("-d", "--dist"), action = "store", default = 10000, type = "integer",
              help = "maximum tolerable distance in bp for the matches. Default is 10000bp."),
  make_option(c("-o", "--out"), action = "store", default = "./", type = "character",
              help = "output prefix.")
)

opt = parse_args(OptionParser(option_list = option_list))

Refer <- opt$ref
Match <- opt$mat
Dist <- opt$dist
Out <- opt$out

if (any(is.na(c(Refer, Match)))) {
  stop("All parameters must be supplied. (--help for details)")
}

# Define functions ---------------------------------------------------------------------------------------------------------------------

LoadManifest <- function(File = File){
  ReadF <- readLines(File)
  SkipL <- grep("^\\[Assay\\]", ReadF)
  EndR <- grep("^\\[Controls\\]", ReadF)

  ReadDF <- read_csv(File, 
    skip = SkipL, 
    col_types = cols_only(Name = col_character(), 
      Chr = col_character(), 
      MapInfo = col_integer()),
    n_max = EndR-SkipL-2)
}

MarkerMatch <- function(Reference = Reference, Matching = Matching, MaxD = MaxD) {
  # Import list of chromosomes
  Chromosomes <- unique(Reference$Chr)
  
  # Create holding dataframe
  DF <- data.frame(Name.x=as.character(NULL),
     Chr.x=as.character(NULL),
     MapInfo.x=as.integer(NULL),
     Name.y=as.character(NULL),
     Chr.y=as.character(NULL),
     MapInfo.y=as.integer(NULL),
     Distance=as.integer(NULL),
     INFO=as.character(NULL),
     stringsAsFactors = FALSE)
  
  # Match markers
  for(chr in 1:length(Chromosomes)) {
    message("====================================================================")
    message("Processing chromosome ", Chromosomes[chr], "...")

    Ref <- Reference %>% 
      filter(Chr==Chromosomes[chr]) %>%
      mutate(Add=paste0(Chr,"-",MapInfo))
    
    Mat <- Matching %>% 
      filter(Chr==Chromosomes[chr]) %>%
      mutate(Add=paste0(Chr,"-",MapInfo))
    
    PerfectMatch <- full_join(Ref, Mat, by=("Add"="Add"), keep=TRUE) %>% 
      drop_na() %>% 
      mutate(Distance=abs(MapInfo.x-MapInfo.y),
             INFO=ifelse(Name.x==Name.y,"SPSN","SPDN"))
    
    Ref <- Ref %>% filter(!Name %in% PerfectMatch$Name.x) %>% select(-Add) %>% arrange(MapInfo)
    Mat <- Mat %>% filter(!Name %in% PerfectMatch$Name.y) %>% select(-Add) %>% arrange(MapInfo)
    
    PerfectMatch <- PerfectMatch %>% select(-c(Add.x, Add.y))
    message("
Found ", nrow(PerfectMatch), " matches at distance = 0.")
    
    n <- 0
    
    for(i in 1:nrow(Ref)) {
      Match <- full_join(Ref[i,], Mat, by = character()) %>%
        mutate(Distance=abs(MapInfo.x-MapInfo.y)) 
      
      if(nrow(Match) > 0) {
        Match <- Match %>%
          slice_min(Distance) %>%
          mutate(INFO=Name.x==Name.y) %>%
          filter(!INFO & Distance<=MaxD) %>%
          mutate(INFO="DPDN")
        
        if(nrow(Match) > 0) {
          DF <- rbind(DF, Match)
        }
        Mat <- Mat %>% filter(!Name %in% Match$Name.x)
      }
      
      n <- n+nrow(Match)
    }
    
    message("Found additional ", n, " matches at distance > 0 and < ", MaxD+1, ".
====================================================================")  
    if(nrow(PerfectMatch) > 0) {DF <- rbind(DF, PerfectMatch)}   
  }
  
  message("
====================================================================
Final match counts:
Found ", table(DF$INFO)["SPSN"], " matches with same positions and names.
Found ", table(DF$INFO)["SPDN"], " matches with same positions and different names.
Found ", table(DF$INFO)["DPDN"], " matches with different positions and different names.
          
Matched ", length(unique(DF$Name.x)), " SNPs on reference and ", length(unique(DF$Name.y)), " matched dataset.
====================================================================")
  return(DF)
}

# Match markers ------------------------------------------------------------------------------------------------------------------------

Fil <- list.files(path = Match)
if (!endsWith(Refer, ".csv")) {Refer <- paste0(Refer, ".csv", collapse = "")}
Fil <- Fil[!grepl(Refer, Fil)]

if (!endsWith(Match, "/")) {Match <- paste0(Match, "/", collapse = "")}
if (!endsWith(Out, "/")) {Out <- paste0(Out, "/", collapse = "")}

for(i in 1:length(Fil)){
  Reference <- LoadManifest(File = paste0(Match, Refer, collapse = ""))
  Matching <- LoadManifest(File = paste0(Match, Fil[i], collapse = ""))

  MatchedDF <- MarkerMatch(Reference = Reference, Matching = Matching, MaxD = Dist)
  
  MatchedDF %>%
    write_delim(file=paste0(Out, "Matched_", gsub(".csv","",Refer), "_", gsub(".csv","",Fil[i]),".txt", collapse = ""),
                delim="\t",
                na="",
                col_names=FALSE,
                quote="none",
                eol="\n")
              
  PruneMat <- distinct(select(MatchedDF, Name.y))
                
  Matching %>%
    select(Name) %>%
    mutate(Keep = ifelse(Name %in% PruneMat$Name.x, 1, 0)) %>%
    write_delim(file=paste0(Out, "MatchDist_", gsub(".csv","",Fil[i]), ".txt", collapse = ""),
                delim="\t",
                na="",
                col_names=FALSE,
                quote="none",
                eol="\n")
  
  png(file=paste0(Out, "MatchedDist_", gsub(".csv","",Refer), "_", gsub(".csv","",Fil[i]),".png", collapse = ""),
     width=800, height=550)
  hist(MatchedDF$Distance[MatchedDF$Distance>0], 
     breaks=100, 
     main=paste0("Distribution of non-idential matches from \n",
                 gsub(".csv","",Fil[i]), " to ", 
                 gsub(".csv","",Refer), collapse=""),
     xlab="Distance",
     ylab="Frequency",
     col="#007EA7")
  dev.off()              
}
