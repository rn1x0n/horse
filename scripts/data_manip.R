#' # Data Manipulaiton
#' - Report generated `r date()`

#+ setup, echo = FALSE
source(file.path("..", "_setup.R"))
opts_chunk$set(warning = FALSE, error = FALSE, message = FALSE, echo = FALSE, results = "hide")

# Read in the source data
data <- read.csv(file.path(gv$data, "Complete Data_01.11.2013.csv"), stringsAsFactor = FALSE)

# DATA CHECKS
# Check primary key is unique
this.data0 <- ddply(data, .(HORSE, TREAT, STUDY.DAY.TARGET, PARAMETER, MEASURE.NUM), function(x){
  data.frame(x, nrow = nrow(x))
})
subset(this.data0, nrow != 1)

# Check there is always a baseline
this.data0 <- ddply(data, .(HORSE, TREAT, PARAMETER), function(x){
  baseline <- subset(x, subset = STUDY.DAY.TARGET == 0, select = VALUE)[,"VALUE"]
  data.frame(x, lenght.baseline = length(baseline))
})
subset(this.data0, lenght.baseline == 0)

# CLASS
# Make dates
data$DATE <- as.Date(data$DATE, format = "%m/%d/%y")
data <- transform(data, HORSE = paste("Horse", HORSE))
data$HORSE <- factor(data$HORSE, levels = paste("Horse", 1:9))

data$PARAMETER[data$PARAMETER == "TNF-_.ELISA"] <- "TNF-alpha_.ELISA"

# Make STUDY.DAY.TARGET.CAT which merge first weeks measures together
data$STUDY.DAY.TARGET.CAT <- NA
data$STUDY.DAY.TARGET.CAT[data$STUDY.DAY.TARGET == 0 ] <- "Day 0"
data$STUDY.DAY.TARGET.CAT[data$STUDY.DAY.TARGET >= 1  & data$STUDY.DAY.TARGET <= 7] <- "Week 1"
data$STUDY.DAY.TARGET.CAT[data$STUDY.DAY.TARGET == 14] <- "Day 14"
data$STUDY.DAY.TARGET.CAT[data$STUDY.DAY.TARGET == 30] <- "Day 30"
data$STUDY.DAY.TARGET.CAT[data$STUDY.DAY.TARGET == 60] <- "Day 60"
data$STUDY.DAY.TARGET.CAT[data$STUDY.DAY.TARGET == 90] <- "Day 90"

data$STUDY.DAY.TARGET.CAT <- factor(data$STUDY.DAY.TARGET.CAT,
                                    levels = c("Day 0", "Week 1", "Day 14", "Day 30", "Day 60", "Day 90")
                                    )

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

  this.data0 <- ddply(data, .(HORSE, TREAT, STUDY.DAY.TARGET, PARAMETER), function(x){
    new.row <- x[1, ]
    new.row$PARAMETER <- paste0(new.row$PARAMETER, '.mean')
    new.row$MEASURE.NUM <- NA
    new.row$VALUE <- mean(x$VALUE, na.rm = TRUE)
   return(new.row)
  })

# Add in the data with the average
data <- rbind(data, this.data0)

# MEAN OVER STUDY.DAY.TARGET.CAT (SDTC)
this.data0 <- ddply(data, .(HORSE, TREAT, STUDY.DAY.TARGET.CAT, PARAMETER), function(x){
  
  if(grepl('mean', unique(x$PARAMETER))) return(NULL) # Don't find for the ".mean" parameters
 
  new.row <- x[1, ]
  new.row$PARAMETER <- paste0(new.row$PARAMETER, '.meanSDTC')
  new.row$MEASURE.NUM <- NA
  new.row$VALUE <- mean(x$VALUE, na.rm = TRUE)
  return(new.row)
})

# Add in the data with the average
data <- rbind(data, this.data0)

# CHANGE FROM BASELINE for the mean parameters
# Baseline is STUDY.DAY.TARGET = 0

this.data0 <- ddply(data, .(HORSE, TREAT, PARAMETER, MEASURE.NUM), function(x){
 
 if(!grepl('mean', unique(x$PARAMETER))) return(NULL) # only find for the "mean" parameters
 
 baseline <- subset(x, subset = STUDY.DAY.TARGET == 0, select = VALUE)[,"VALUE"]
 if(length(baseline) == 0) return(NULL)
 
 new.rows <- x
 new.rows$PARAMETER <- paste0(new.rows$PARAMETER, '.deltabl')
 new.rows$VALUE <- x$VALUE - baseline
 return(new.rows)
 
})
data <- rbind(data, this.data0)

# WITHIN HORSE TREATMENT EFFECT for STUDY.DAY.TARGET

this.data0 <- ddply(data, .(HORSE, STUDY.DAY.TARGET, PARAMETER, MEASURE.NUM), function(x){
  
  if(!grepl("mean", x$PARAMETER[1])) return(NULL)
  if(grepl("meanSDTC", x$PARAMETER[1])) return(NULL)
  
  T0 <- subset(x, subset = TREAT == 0, select = VALUE)[,"VALUE"]
  T1 <- subset(x, subset = TREAT == 1, select = VALUE)[,"VALUE"]
  if(length(T0) !=1 | length(T1) != 1) return(NULL)
  
  new.rows <- x[1,]
  new.rows$TREAT <- NA
  new.rows$PARAMETER <- paste0(new.rows$PARAMETER, '.te')
  new.rows$VALUE <- T1 - T0
  return(new.rows)
  
})

data <- rbind(data, this.data0)

# WITHIN HORSE TREATMENT EFFECT for STUDY.DAY.TARGET.CAT

this.data0 <- ddply(data, .(HORSE, STUDY.DAY.TARGET.CAT, PARAMETER, MEASURE.NUM), function(x){
  
  if(!grepl("meanSDTC", x$PARAMETER[1])) return(NULL)
  
  T0 <- subset(x, subset = TREAT == 0, select = VALUE)[,"VALUE"]
  T1 <- subset(x, subset = TREAT == 1, select = VALUE)[,"VALUE"]
  if(length(T0) !=1 | length(T1) != 1) return(NULL)
  
  new.rows <- x[1,]
  new.rows$TREAT <- NA
  new.rows$PARAMETER <- paste0(new.rows$PARAMETER, '.te')
  new.rows$VALUE <- T1 - T0
  return(new.rows)
  
})

data <- rbind(data, this.data0)

# BASELINE VALUE, averaged over measures
this.data0 <- ddply(data, .(HORSE, TREAT, PARAMETER, MEASURE.NUM), function(x){
  BL <- na.omit(x[x$STUDY.DAY.TARGET == 0, "VALUE"])
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

#####################################################################
# DATA QUERIES

#+ results = "asis"

#' Extra measurements for lameness.flex, lameness.sys and lameness.sub. 
#' These are not used as there is no value for STUDY.DAY.TARGET

#+ results = "asis"
tmp <- subset(data, HORSE == "Horse 2" & TEST.TYPE == "lameness" & MEASURE.NUM != 1)
tmp <- transform(tmp, DATE = as.character(DATE))
print(xtable(tmp),type = "html", include.rownames = FALSE)

