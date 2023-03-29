# Started: 2021-06-07
# by Rodrigo García-López for Carlos Arias's Viromics Group at IBt, UNAM, Cuernavaca, Mexico as part of the CoViGen-Mex SARS-CoV-2 survillance in Mexico.
# Under GNU GPLv3 license
# Disclamer: This script was written for use with specific data and are not therefore warrantied to be usable with different sets. They were created to carry out particular analyses and were originally intended for the lab's requirements, not commercial nor distribution.
# This script was tested with R version 4.0.5 (2021-03-31) -- "Shake and Throw"

# It is intended to create a single table from multiple tsv tables passed as input
# The input is a two-column table containing a names and counts as columns.
# No repeted rows are allowed
# If an empty feature (category name) is found, this program will output this as "undefined"
# If the user appends an optional TRUE parameter, then the sum of the table is presented instead of the regular output

# Run as follows:
# Rscript Mege_tables.R <file_list(txt)>  <output_prefix> [optional:sum_flag]

# Test in R
# files_list <- "Todos_taxonomy.txt"
# prefix <- "test2"
# sums <- TRUE


 ### Pre-load files and parameters ###
args <- commandArgs(trailingOnly=TRUE)
if (length(args) < 2) { # at least, 2 arguments should be included: <file_list(txt)>  <output_prefix> [optional:sum_flag]
  stop("A minimum of 4 arguments are mandatory: Rscript
       Mege_tables.R <files_list(txt)> <output_prefix> [optional:sum_flag]", call.=FALSE)
}
files_list <- as.character(args[1]) # Get a string handle for the input txt file with names of the target tables
prefix <- as.character(args[2]) # Get a string handle prefix used to create outputs
sums <- as.logical(args[3]) # Get a boolean TRUE if the row sum is required instead of the table output
if(!file.exists(files_list)){stop(paste0("Aborting... Missing file ",infile), call.=FALSE)} # abort if the list of files is missing

 ### Define Functions ###
extract_table <- function(infile) { # from a list of files, abort if any of them are missing, then load table as dataframe
  if(!file.exists(infile)){stop(paste0("Aborting... Missing file ",infile), call.=FALSE)} # abort if the file is missing
  df <- read.table(infile,header=F, sep='\t', skip=0, comment.char='',fill=F, check.names=FALSE, row.names=1)
  rownames(df)[rownames(df)==""] <- "undefined" # change the name to empty values
  return(df)
}
list_unique_items <- function(inlist){ # from a list of dataframes, get an ordered list of unique items
  vect <- as.character(sort(unique(unlist(lapply(inlist, rownames))))) # subset the names, unlist, get uniques and sort output list
  vect[vect==""] <- "undefined"
  return(vect)
}
place_counts <- function(df, strings){ # get table (items as names) and target strings
  outvect <- df[match(strings,rownames(df)),]
  outvect[is.na(outvect)]=0
  return(outvect)
}

 ### MAIN ###
files <- scan(files_list, what = character()) # Read the file list
# nfiles <- length(files) # count the total expected files
all_tables <- lapply(files, extract_table) # load all tables
unique_items <- list_unique_items(all_tables) # get the unique items (string vector)
merged_table <- sapply(all_tables, function(x){place_counts(x,unique_items)})
colnames(merged_table) <- gsub("_Hits-taxonomy\\.txt","",basename(files)) # Change accordingly
colnames(merged_table) <- gsub("_sums\\.tsv","",colnames(merged_table))
# unique_items[unique_items==""]="Undefined"
if(is.na(sums)){
  write.table(cbind("Features"=unique_items,merged_table),paste(prefix,"merged_table.tsv", sep="_"), sep="\t", quote=FALSE, row.names=FALSE, col.names=TRUE) # output the merged table
}else{
  if(sums==TRUE){ # If the user specified that sums are preferred to all_sample tables
    out <- cbind("Features"=unique_items,rowSums(merged_table))
    colnames(out)[2] <- gsub("\\.txt","",basename(prefix))
    write.table(out,paste(prefix,"sums.tsv", sep="_"), sep="\t", quote=FALSE, row.names=FALSE, col.names=FALSE) 
  } 
}