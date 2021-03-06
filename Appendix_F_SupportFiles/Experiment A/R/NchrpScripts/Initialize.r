# +---------------------------------------------------------+
# | NCHRP 08-89 R Scripts - Implemented by Westat,  Inc     |
# +---------------------------------------------------------+

# Utility functions

# Inspired by "best of both worlds" on http://stackoverflow.com/questions/1815606/rscript-determine-path-of-the-executing-script
thisFile <- function() {
  cmdArgs <- commandArgs(trailingOnly = FALSE)
  needle <- "--file="
  match <- grep(needle, cmdArgs)
  if (length(match) > 0) {
    # Rscript
    return(sub(needle, "", cmdArgs[match]))
  } else {
    # 'source'd via R console
    filename <- sys.frames()[[1]]$ofile
    if (!is.null(filename)) {
      return(normalizePath(filename))
    } else {
      # running as a temp file in RStudio - real path is temporary and useless
      return(NULL)
    }
  }
}

fileName <- dirname(thisFile())
if (!is.null(fileName)) {
  # Set working directory so later scripts can just "source('file.r')"
  setwd(dirname(thisFile()))  
}

# Clear workspace
rm(list=ls())

# Shared Modules
source('Distance.r')
source('LoadData.r')
source('Mapping.r')

# Noise Filtering
source('Noise Filtering/Lawson.r')
source('Noise Filtering/Schuessler_Axhausen.r')
source('Noise Filtering/Stopher.r')

# Mode Transition
source('Mode Transition Identification/Oliveira.r')
source('Mode Transition Identification/TsuiShalaby_SchuesslerAxhausen.r')

#Trip Identification
source('Trip Identification/Schuessler_Axhausen.r')
source('Trip Identification/Wolf.r')

#Travel Mode Identification
source('Travel Mode Identification/Gonzalez.r')

getAggregateColumn <- function(func, column, rawdata, indextable, ...)
{
  getDataInRange <- function(startindex, endindex)
  {
    return(func(rawdata[startindex:endindex, column], ...))
  }
  return(mapply(getDataInRange, indextable$startindex, indextable$endindex))
}

characterAt <- function(s, c) which(strsplit(s, '')[[1]]==c)

printNow <- function(...) {
  print(paste0(...))
  flush.console()
}

loadScripts <- function(dir, scripts) {
  for(i in 1:length(scripts)) {
    source(paste0(dir, '/', scripts[i], '.r'))
  }
}

# Added okiAndrew
# Projection string for local projection - example below is NAD83 Georgia State Plane West Feet
# Get yours from http://spatialreference.org/ (search in the upper-right corner, select the correct,
#  and get the proj4 projection string)
#
proj4="+proj=tmerc +lat_0=30 +lon_0=-84.16666666666667 +k=0.9999 +x_0=700000 +y_0=0 +ellps=GRS80 +datum=NAD83 +to_meter=0.3048006096012192 +no_defs"
