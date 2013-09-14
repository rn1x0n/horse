

par.rename <- function(
  par,   # vector of parameters
  remove # vector of reg exp to remove from the name
# VALUE : par has parts of names that match with "remove" removed, 
#  has "." replaced by sapce.
# capitalize first letter  
  ){
 

  for(r in remove){
    par <- gsub(r, "", par) 
  }
  
 par <- gsub("\\.", " ", par)
  par <- paste0(toupper(substring(par, 1, 1)), substring(par, 2))
  
  return(par)
}
