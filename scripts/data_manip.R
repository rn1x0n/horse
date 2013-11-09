# Read in the source data
data <- read.csv(file.path(gv$data, "Complete Data_01.11.2013.csv"), stringsAsFactor = FALSE)

# DATA CHECKS
# Check primary key is unique
this.data0 <- ddply(data, .(HORSE, TREAT, STUDY.DAY.TARGET, PARAMETER, MEASURE.NUM), function(x){
  data.frame(x, nrow = nrow(x))
})
subset(this.data0, nrow != 1)

# Check there is always a baseline
this.data0 <- ddply(data, .(HORSE, TREAT, PARAMETER, MEASURE.NUM), function(x){
  baseline <- subset(x, subset = STUDY.DAY.TARGET == 0, select = VALUE)[,"VALUE"]
  data.frame(x, lenght.baseline = length(baseline))
})
subset(this.data0, lenght.baseline != 1)

# CLASS
# Make dates
data$DATE <- as.Date(data$DATE, format = "%m/%d/%y")
data <- transform(data, HORSE = paste("Horse", HORSE))
data$HORSE <- factor(data$HORSE, levels = paste("Horse", 1:9))

# Check the varaible names
table(data$HORSE, exclude = NA)
table(data$SIDE, exclude = NA)
table(data$TREAT, exclude = NA)
table(data$STUDY.DAY, exclude = NA)
table(data$STUDY.DAY.TARGET, exclude = NA)
table(data$TEST.TYPE, exclude = NA)
table(data$PARAMETER, exclude = NA)
table(data$MEASURE.NUM, exclude = NA)
table(data$UNIT, exclude = NA)

# Replace degr. with C
#data$UNIT[!is.na(data$UNIT) & data$UNIT == "degr."] <- "C"

# MEANS OF MULTIPLE MEASURES
# Which parameters have multiple measure?
tmp <- subset(data, MEASURE.NUM != 1)
table(tmp$PARAMETER)

# Average over all parameters 
# names <- c( paste("algometry", 1:7, sep = "."), 
#             "thermography.1", 
#             paste("lameness", c("flex", "sub", "sym"), sep = "."))

#this.data0 <- subset(data, PARAMETER %in% names)
this.data0 <- data

  this.data1 <- ddply(this.data0, .(HORSE, TREAT, STUDY.DAY.TARGET, PARAMETER), function(x){
    new.row <- x[1, ]
    new.row$PARAMETER <- paste0(new.row$PARAMETER, '.mean')
    new.row$MEASURE.NUM <- NA
    new.row$VALUE <- mean(x$VALUE, na.rm = TRUE)
   return(new.row)
  })

# Add in the data with the average
data <- rbind(data, this.data1)

# CHANGE FROM BASELINE
# Baseline is STUDY.DAY.TARGET = 0

this.data0 <- ddply(data, .(HORSE, TREAT, PARAMETER, MEASURE.NUM), function(x){
 baseline <- subset(x, subset = STUDY.DAY.TARGET == 0, select = VALUE)[,"VALUE"]
 if(length(baseline) == 0) return(NULL)
 
 new.rows <- x
 new.rows$PARAMETER <- paste0(new.rows$PARAMETER, '.deltabl')
 new.rows$VALUE <- x$VALUE - baseline
 return(new.rows)
 
})
data <- rbind(data, this.data0)

# WITHIN HORSE TREATMENT EFFECT

this.data0 <- ddply(data, .(HORSE, STUDY.DAY.TARGET, PARAMETER, MEASURE.NUM), function(x){
  
  if(!grepl("mean", x$PARAMETER[1])) return(NULL)
  
  T0 <- subset(x, subset = TREAT == 0, select = VALUE)[,"VALUE"]
  T1 <- subset(x, subset = TREAT == 1, select = VALUE)[,"VALUE"]
  if(length(T0) !=1 | length(T1) != 1) return(NULL)
  
  new.rows <- x[1,]
  new.rows$TREAT <- NA
  new.rows$PARAMETER <- paste0(new.rows$PARAMETER, '.te')
  #new.rows$numT0 <- length(T0)
  #new.rows$numT1 <- length(T1)
  new.rows$VALUE <- T1 - T0
  return(new.rows)
  
})

data <- rbind(data, this.data0)

# BASELINE VALUE
this.data0 <- ddply(data, .(HORSE, TREAT, PARAMETER, MEASURE.NUM), function(x){
  BL <- na.omit(x[x$STUDY.DAY.TARGET == 0, "VALUE"])
#data.frame(LEN = length(BL), VAL = paste(BL, collapse = ", "))
  data.frame(x, BL = rep(BL, length = nrow(x)))
})

data <- this.data0

this.data0 <- ddply(data, .(HORSE, TREAT, STUDY.DAY.TARGET, PARAMETER), function(x){
  BL.mean <- mean(x$BL, na.rm = TRUE)
  return(data.frame(x, BL.mean = rep(BL.mean, nrow(x))))
})
data <- this.data0


# SORT
data <- ddply(data, .(HORSE, STUDY.DAY.TARGET, PARAMETER, TREAT, MEASURE.NUM), function(x){x})

dput(data, file.path(gv$data, 'data.dput'))
