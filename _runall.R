rm(list = ls())
# Change this path to the location of this file
root <- "/Users/Richard/Documents/R/horse"


#####################################################################
source("_setup.R")
source(file.path(gv$script, "data_manip.R"))

# Run scripts

setwd(gv$scripts)
spin("exploratory_plots.R")
spin("analysis.R")

unlink("*.Rmd")
unlink("*.md")

setwd(gv$root)

unlink(file.path(gv$script, "figure"), recursive = TRUE)
