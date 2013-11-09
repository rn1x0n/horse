#' # Summary Statistics and Plots
#' - Report generated `r date()`

#+ setup, echo = FALSE
source(file.path("..", "_setup.R"))
data <- dget(file.path(gv$data, 'data.dput'))
opts_chunk$set(warning = FALSE, error = FALSE, message = FALSE, echo = FALSE)

#####################################################################
#' ## Average treatment differences over horses
#+
#####################################################################
#' ### Average treatment differences over horses
#' Fit a linear regression model, stratified by horse to acknowledge that each horse 
#' is both treated and not treated. 
#' $$ y_{ijk} = \mu_i + \beta x_j + \gamma b_{ij0} + \epsilon_{ijk} $$
#' where $y_{ijk}$ is the outcome measure $k$ for horse $i$ on the leg with treatment $x_j$.
#' $x_j = 0$ for not treated, and 1 for treated. $b_{ij0}$ is the baseline measurement of $y_{ijk}$, averaged over the measurements $k$.
#' $\epsilon_{ijk}$ is random error which we assume is normally distributed. 
#' $\beta$ is the mean treatment difference between treated and non-treated leg.
#' 
#' Perform this analysis for every time point for each variable
digits <- 3; nsmall <- 0
results <- results.print <- NULL

for(PARAMETER in c(
  "Aggrecan.ELISA",
  "IL-1_.ELISA",
  "algometry.2",
  "algometry.3",
  "algometry.5"
  )){
  
  for(STUDY.DAY.TARGET in as.numeric(na.omit(unique(
    data[data$PARAMETER == PARAMETER, "STUDY.DAY.TARGET"]))) ){

    if(STUDY.DAY.TARGET == 0) next
    
# PARAMETER <- "IL-1_.ELISA"
# STUDY.DAY.TARGET <- 14
  
data0 <- data[data$PARAMETER == PARAMETER & data$STUDY.DAY.TARGET == STUDY.DAY.TARGET,]
    
    parameter.name <- par.rename(PARAMETER, c("_", "ELISA"))
    parameter.name <- paste0(parameter.name, ' (', unique(data0$UNIT), ')') 
    
    mod <- glm(VALUE ~ -1 + HORSE + TREAT + BL.mean, data = data0)

coeff <- summary(mod)$coeff
ci <- confint(mod, "TREAT")

# Outputs
out <- data.frame(
  Outcome = parameter.name,
  Target.study.day = STUDY.DAY.TARGET,
  Treatment.difference = coeff[rownames(coeff) == "TREAT", "Estimate"],
  low.CI = as.numeric(ci[1]),
  upp.CI = as.numeric(ci[2]),
  P.value = coeff[rownames(coeff) == "TREAT", "Pr(>|t|)"]
  )

out.print <- data.frame(
  Outcome = out$Outcome,
  Target.study.day = format(out$Target.study.day, nsmall = 0),
  Treatment.difference = format(out$Treatment.difference, digits = digits, nsmall = nsmall),
  CI = paste0('(', paste(format(c(out$low.CI, out$upp.CI), digits = digits, nsmall = nsmall), collapse = ", "), ')'),
  P.value = format(out$P.value, digits = digits, nsmall = nsmall)
)

names(out.print) <- gsub('\\.', ' ', names(out.print))

results <- rbind(results, out)
results.print <- rbind(results.print, out.print)

} # PARAMETER
} # STUDY.DAY.TARGET

#+ results_table, results = "asis"
print(xtable(results.print, align = c("l", "l", "r", "r", "r", "r")),
      type = "html",
      include.rownames = FALSE
)


#+ results_plot, fig.width = 18, fig.height = 5
p <- ggplot(results, aes(x = Target.study.day)) +
  facet_wrap(~ Outcome, nrow = 1, scale = "free_y") +
  geom_point(aes(y = Treatment.difference)) +
  geom_line(aes(y = Treatment.difference)) +
  geom_errorbar(aes(ymin = low.CI, ymax = upp.CI), linetype = 2) +
  geom_hline(y = 0) +
  xlab("Target study day") + ylab("Treatment difference")

print(p, vp = viewport(width = 18, height = 5, default.units = "inches"))
