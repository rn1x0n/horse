

par.rename <- function(
  par,   # vector of parameters
  remove = NULL# vector of reg exp to remove from the name
# VALUE : par has parts of names that match with "remove" removed, 
#  has "." replaced by sapce.
# capitalize first letter  
  ){
 
if(!is.null(remove)){
  for(r in remove){
    par <- gsub(r, "", par) 
  }
}

# replace . with space and capitalize  
par <- gsub("\\.", " ", par)
par <- gsub(" $", "", par)
par <- paste0(toupper(substring(par, 1, 1)), substring(par, 2))
  
  return(par)
}

#####################################################################

make.labels <- function(
  
  ){
  
  codes <- read.csv(file.path(gv$data, "Complete Data_31.10.2013_codes.csv"), stringsAsFactor = FALSE)
  
  
}