#' # Analysis
#' - Report generated `r date()`

#+ setup, echo = FALSE
source(file.path("..", "_setup.R"))
data <- dget(file.path(gv$data, 'data.dput'))
opts_chunk$set(warning = FALSE, error = FALSE, message = FALSE, echo = FALSE)

#####################################################################
#' ## Average treatment differences over horses
#+
#####################################################################

par.list <- c(
  #"algometry.2",
  "algometry.3",
  #"algometry.5",
  #"goniometry.1",
  #"circumference.1",
  "lameness.sym",
  "Aggrecan.ELISA",
  "IL-1_.ELISA",
  "TNF-alpha_.ELISA",
  "Substance P.ELISA"
)

#####################################################################
# Manipulate data

parameter.name <- sapply(par.list, function(x){
  parameter.name <- par.rename(x, c("-_.ELISA", "_", "ELISA"))
  unit <- na.omit(unique(data[data$PARAMETER == x, "UNIT"]))
  parameter.name <- paste0(parameter.name, ' (', unit, ')') 
})

# Data averaged over measurments of SDTC
PARAMETER.meanSDTC <- paste0(par.list, ".meanSDTC")  
data.SDTC <- subset(data, PARAMETER %in% PARAMETER.meanSDTC)
data.SDTC$PARAMETER <- factor(data.SDTC$PARAMETER, 
                             levels = PARAMETER.meanSDTC,
                             labels = parameter.name)
data.SDTC$SDT <- "CAT"

# Data averaged over measurements of SDT
PARAMETER.meanSDT <- paste0(par.list, ".mean")  
data.SDT <- subset(data, PARAMETER %in% PARAMETER.meanSDT)
data.SDT$PARAMETER <- factor(data.SDT$PARAMETER, 
                              levels = PARAMETER.meanSDT,
                              labels = parameter.name)
data.SDT$SDT <- "DAY"

# Merged data
data.all <- rbind(data.SDTC, data.SDT)

data.all$TREAT.LAB <- data.all$TREAT
data.all$TREAT.LAB[is.na(data.all$TREAT.LAB)] <- "Whole horse"
data.all$TREAT.LAB <- factor(data.all$TREAT.LAB, 
                                levels = c("0", "1", "Whole horse"),
                                labels = c("Sham treated", "Treated", "Whole horse"))


#suppressMessages(print(p, vp = viewport(width = 18, height = 8, default.units = "inches")))

#####################################################################

#' ### Table and plot of summary data
digits <- 3; nsmall <- NULL
   
    # Summary over horse, by treat and time
    results.sum <- ddply(
      subset(data.all, SDT == "CAT"), # For the results by SDTC 
      .(PARAMETER, TREAT.LAB, STUDY.DAY.TARGET.CAT), function(x){
     
      if(is.na(unique(x$STUDY.DAY.TARGET.CAT))) return(NULL)
      
      Range.low <- min(x$VALUE, na.rm = TRUE)
      Range.upp <- max(x$VALUE, na.rm = TRUE)
      
      return(data.frame(
        Outcome = unique(x$PARAMETER),
        Treatment = unique(x$TREAT.LAB),
        Time = unique(x$STUDY.DAY.TARGET.CAT),
        Median = median(x$VALUE, na.rm = TRUE),
        Mean = mean(x$VALUE, na.rm = TRUE),
        Range.low = Range.low,
        Range.upp = Range.upp
        
        ))
    })

results.sum$PARAMETER <- NULL
results.sum$TREAT.LAB <- NULL
results.sum$STUDY.DAY.TARGET.CAT <- NULL
      
# Printable
results.sum.print <- ddply(results.sum, .(Outcome, Treatment, Time), function(x){
  Range.low <- format(x$Range.low, digits = digits)#, nsmall = nsmall)
  Range.upp <- format(x$Range.upp, digits = digits)#, nsmall = nsmall)
  
  data.frame(
    Median = format(x$Median, digits = digits),#, nsmall = nsmall),
    Mean = format(x$Mean, digits = digits),#, nsmall = nsmall),
    Range = paste0('(', Range.low, ', ', Range.upp, ')')
    #Range = paste0('(', paste(format(c(x$Range.low, x$Range.upp), digits = digits, nsmall = nsmall), collapse = ", "), ')')
  )
})
  
# Wide format
results.sum.print <- reshape(results.sum.print, 
                       timevar = "Time", 
                       idvar = c("Outcome", "Treatment"), 
                       direction = "wide")
names(results.sum.print) <- gsub('\\.', ' ', names(results.sum.print))

#+ summary_results_table, results = "asis"
print(xtable(results.sum.print, align = c("l", "l", rep("r", ncol(results.sum.print)-1) )),
      type = "html",
      include.rownames = FALSE
)

#+ summary_results_plot, fig.width = 18, fig.height = 7
p <- ggplot(results.sum, aes(x = Time)) +
  facet_wrap(~ Outcome, nrow = 2, scale = "free_y") +
  #geom_point(aes(y = Mean, shape = Treatment),  position = position_dodge(width = 0.7)) +
  geom_point(aes(y = Median, shape = Treatment),  position = position_dodge(width = 0.7)) +
  #geom_line(aes(y = Mean, line.type = Treatment), position = "dodge") +
  geom_errorbar(aes(ymin = Range.low, ymax = Range.upp, linetype = Treatment), position = position_dodge(width = 0.7), width = 0.2) +
  #geom_hline(y = 0) +
  xlab("Target study day") + ylab("")

print(p, vp = viewport(width = 18, height = 7, default.units = "inches"))

#####################################################################

#' ### Model average treatment differences over horses
#' #### Model each time point
#' Fit a linear regression model, stratified by horse to acknowledge that each horse 
#' is both treated and not treated. 
#' $$ y_{ijk} = \mu_i + \beta x_j + \gamma b_{ij0} + \epsilon_{ijk} $$
#' where $y_{ijk}$ is the outcome measure $k$ for horse $i$ on the leg with treatment $x_j$.
#' $x_j = 0$ for not treated, and 1 for treated. $b_{ij0}$ is the baseline of horse $i$, on the leg with treatment $x_j$, averaged over the measurements $k$.
#' $\epsilon_{ijk}$ is random error which we assume is normally distributed. 
#' $\beta$ is the mean treatment difference between treated and non-treated leg.
#' 
#' Perform this analysis for every time point for each variable
#' 
#' #### Longitudinal model
#' Fit a linear regression model.
#' Stratify by horse to acknowledge that each horse is both treated and not treated, 
#' Include a between horse random effects for the treatment effect to
#' acknowledge that treatment effects from one horse over time are more similar than treatment effects from a different horse.
#' $$
#' \begin{aligned}
#'   y_{ijkl} &= \mu_i + (\beta + \beta_i) x_j + \gamma b_{ij0} + \epsilon_{ijkl} \\
#'   \beta_i &\sim N(0, \sigma_\beta^2) \\
#'   \epsilon_{ijkl} &\sim N(0, \sigma^2)
#' \end{aligned}
#' $$
#' 
#' where $y_{ijkl}$ is the outcome measure $k$ for horse $i$ on the leg with treatment $x_j$, at time $l$.
#' $x_j = 0$ for not treated, and 1 for treated. $b_{ij0}$ is the baseline measurement of horse $i$, on the leg with treatment $x_j$, averaged over the measurements $k$.
#' $\epsilon_{ijk}$ is random error which we assume is normally distributed. 
#' $\beta$ is the mean treatment difference between treated and non-treated leg.
#' $\beta_i$ is the horse specific random effect, giving the treatment difference between treated and non-treated leg over time for horse $i$.
#' 
#' Perform this analysis for each variable.
 
digits <- 3; nsmall <- 0

# Data for analysis
data0 <- subset(data, PARAMETER %in% par.list)
data0 <- subset(data0, !is.na(data0$TREAT)) # Must have treatment
data0 <- subset(data0, STUDY.DAY.TARGET != 0) # Remove baseline

data0$PARAMETER <- factor(data0$PARAMETER, 
                              levels = par.list,
                              labels = parameter.name)


# Analysis by time point (STUDY.DAY.TARGET.CAT)
# PARAMETER <- "IL-1 (ng/mL)"
# STUDY.DAY.TARGET.CAT <- "Day 30"
results <-  NULL  

for(PARAMETER in unique(data0$PARAMETER)){
  
  for(STUDY.DAY.TARGET.CAT in na.omit(unique(
    data0[data0$PARAMETER == PARAMETER, "STUDY.DAY.TARGET.CAT"])) ){
      
    data1 <- data0[data0$PARAMETER == PARAMETER & data0$STUDY.DAY.TARGET.CAT == STUDY.DAY.TARGET.CAT,]
    
    mod <- lm(VALUE ~ -1 + HORSE + TREAT + BL.mean, data = data1)
    
    coeff <- summary(mod)$coeff
    ci <- coeff["TREAT","Estimate"] + c(-1, 1) * qt(0.975, df = mod$df) * coeff["TREAT","Std. Error"]
   # ci <- coeff["TREAT","Estimate"] + c(-1, 1) * qnorm(0.975) * coeff["TREAT","Std. Error"]
    #   ci <- confint(mod, "TREAT")
        
    # Outputs
    out <- data.frame(
      Outcome = PARAMETER,
      Time = STUDY.DAY.TARGET.CAT,
      Treatment.difference = coeff[rownames(coeff) == "TREAT", "Estimate"],
      low.CI = as.numeric(ci[1]),
      upp.CI = as.numeric(ci[2]),
      P.value = coeff[rownames(coeff) == "TREAT", "Pr(>|t|)"]
    )
    results <- rbind(results, out)
    
  } # PARAMETER
} # STUDY.DAY.TARGET

####################################################################

# Analysis over time points
# PARAMETER <- "Algometry 3 (kg)"
# STUDY.DAY.TARGET.CAT <- "Day 30"

for(PARAMETER in unique(data0$PARAMETER)){
      data1 <- data0[data0$PARAMETER == PARAMETER,]  
     #mod <- lmer(VALUE ~ -1 + HORSE + TREAT + BL.mean + (1|TREAT), data = data1)
    mod <- lme(VALUE ~ -1 + HORSE + TREAT + BL.mean, random = ~ -1+TREAT|HORSE, data = data1)
      #summary(mod)
      
    coeff <- summary(mod)$tTable
    ci <- coeff["TREAT","Value"] + c(-1, 1) * qnorm(0.975) * coeff["TREAT","Std.Error"]
    
    # Outputs
    out <- data.frame(
      Outcome = PARAMETER,
      Time = "All",
      Treatment.difference = coeff[rownames(coeff) == "TREAT", "Value"],
      low.CI = as.numeric(ci[1]),
      upp.CI = as.numeric(ci[2]),
      P.value = coeff[rownames(coeff) == "TREAT", "p-value"]
    )
        
    results <- rbind(results, out)
     
  } # PARAMETER

#####################################################################
# Printable
results.print <- ddply(results, .(Outcome, Time), function(x){
  low.CI <- format(x$low.CI, digits = digits)#, nsmall = nsmall)
  upp.CI <- format(x$upp.CI, digits = digits)#, nsmall = nsmall)
  
  data.frame(
    Treatment.difference = format(x$Treatment.difference, digits = digits),#, nsmall = nsmall),
    CI = paste0('(', low.CI, ', ', upp.CI, ')'),    #Range = paste0('(', paste(format(c(x$Range.low, x$Range.upp), digits = digits, nsmall = nsmall), collapse = ", "), ')')
    P.value = format(x$P.value, digits = digits)
    )
})

# Wide format
results.print <- reshape(results.print, 
                             timevar = "Time", 
                             idvar = c("Outcome"), 
                             direction = "wide")
names(results.print) <- gsub('\\.', ' ', names(results.print))

#####################################################################

#+ results_table, results = "asis"
print(xtable(results.print, align = c("l", "l", rep("r", ncol(results.print)-1))),
      type = "html",
      include.rownames = FALSE
)


#+ results_plot, fig.width = 18, fig.height = 7
p <- ggplot(results, aes(x = Time)) +
  facet_wrap(~ Outcome, nrow = 2, scale = "free_y") +
  geom_point(aes(y = Treatment.difference)) +
  #geom_line(aes(y = Treatment.difference)) +
  geom_errorbar(aes(ymin = low.CI, ymax = upp.CI), linetype = 1, width = 0.2) +
  geom_hline(y = 0, linetype = 2) +
  xlab("Target study day") + ylab("Treatment difference")

print(p, vp = viewport(width = 18, height = 7, default.units = "inches"))
