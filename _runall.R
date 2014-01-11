
#####################################################################
source("_setup.R")

# Run scripts

setwd(gv$scripts)
source(file.path(gv$script, "data_manip.R"))
spin("exploratory_plots.R")
spin("analysis.R")

unlink("*.Rmd")
unlink("*.md")
unlink(file.path(gv$script, "figure"), recursive = TRUE)
