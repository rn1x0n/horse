#' # Exploratory Plots
#' - Report generated `r date()`

#+ echo = FALSE
source(file.path("..", "_setup.R"))
data <- dget(file.path(gv$data, 'data.dput'))
opts_chunk$set(warning = FALSE, error = FALSE, message = FALSE, echo = FALSE)


#####################################################################
#' ## Algometry
#+
#####################################################################
#' ### Value over time
#+ echo = FALSE, fig.width = 15, fig.height = 12

plot.data <- subset(data, TEST.TYPE == "algometry" & grepl("mean$", PARAMETER))
plot.data$PARAMETER <- par.rename(plot.data$PARAMETER, "\\.mean$")
plot.data$TREAT <- as.factor(plot.data$TREAT)

ggplot(plot.data, aes(x = STUDY.DAY.TARGET, y = VALUE)) +
  facet_grid(HORSE ~ PARAMETER) +
  geom_line(aes(linetype = TREAT)) +
  xlab("Target study day") + ylab("Kg") +
  scale_linetype(guide = guide_legend(title = "Treatment"))

#' ### Change from baseline, for each treatment
#+ echo = FALSE, fig.width = 15, fig.height = 12

plot.data <- subset(data, TEST.TYPE == "algometry" & grepl("mean.deltabl$", PARAMETER))
plot.data$PARAMETER <- par.rename(plot.data$PARAMETER, "\\.mean.deltabl$")
plot.data$TREAT <- as.factor(plot.data$TREAT)

ggplot(plot.data, aes(x = STUDY.DAY.TARGET, y = VALUE)) +
  facet_grid(HORSE ~ PARAMETER) +
  geom_line(aes(linetype = TREAT)) +
  xlab("Target study day") + ylab("Kg") +
  scale_linetype(guide = guide_legend(title = "Treatment"))

#' ### Change from baseline, for each treatment, averaged over horses, smoothed plot
#+ echo = FALSE, fig.width = 18, fig.height = 8

  p <- ggplot(plot.data, aes(x = STUDY.DAY.TARGET, y = VALUE, linetype = TREAT)) +
  facet_wrap(~ PARAMETER, nrow = 2) +
  stat_smooth()+
  xlab("Target study day") + ylab("Kg") +
  scale_linetype(guide = guide_legend(title = "Treatment"))

  suppressMessages(print(p))

#' ### Change from baseline, for each treatment, averaged over horses, boxplot
#+ echo = FALSE, fig.width = 18, fig.height = 8

p <- ggplot(plot.data, aes(x = as.factor(STUDY.DAY.TARGET), y = VALUE, linetype = TREAT)) +
  facet_wrap(~ PARAMETER, nrow = 2) +
  geom_boxplot(position = "dodge") +
  xlab("Target study day") + ylab("Kg") +
  scale_linetype(guide = guide_legend(title = "Treatment"))

suppressMessages(print(p, vp = viewport(width = 18, height = 8, default.units = "inches")))

#' ### Within horse differences
#' This is the treatment effect for each horse
#' Positive value = treated leg has higher value
#+ echo = FALSE, fig.width = 15, fig.height = 12

plot.data <- subset(data, TEST.TYPE == "algometry" & grepl("mean.te$", PARAMETER))
plot.data$PARAMETER <- par.rename(plot.data$PARAMETER, "\\.mean.te$")
plot.data$TREAT <- as.factor(plot.data$TREAT)

ggplot(plot.data, aes(x = STUDY.DAY.TARGET, y = VALUE)) +
  facet_grid(HORSE ~ PARAMETER) +
  geom_line() +
  xlab("Target study day") + ylab("Kg") +
  scale_linetype(guide = guide_legend(title = "Treatment"))
  #coord_cartesian(ylim = ylim)

#' ### Within horse differences, change from baseline
#' This is the treatment effect for each horse
#' Positive value = treated leg has higher value
#+ echo = FALSE, fig.width = 15, fig.height = 12

plot.data <- subset(data, TEST.TYPE == "algometry" & grepl("mean.deltabl.te$", PARAMETER))
plot.data$PARAMETER <- par.rename(plot.data$PARAMETER, "\\.mean.deltabl.te$")
plot.data$TREAT <- as.factor(plot.data$TREAT)

ggplot(plot.data, aes(x = STUDY.DAY.TARGET, y = VALUE)) +
  facet_grid(HORSE ~ PARAMETER) +
  geom_line() +
  xlab("Target study day") + ylab("Kg") +
  scale_linetype(guide = guide_legend(title = "Treatment"))

#' ### Within horse differences, change from baseline, averaged over horses
#' Positive value = treated leg has higher value
#' Loess smoother

#+ fig.width = 18, fig.height = 8

  p <- ggplot(plot.data, aes(x = STUDY.DAY.TARGET, y = VALUE)) +
  facet_wrap(~ PARAMETER, nrow = 2) +
  stat_smooth()+
  xlab("Target study day") + ylab("Kg") 

suppressMessages(print(p))

#' Box plot
#+ echo = FALSE, fig.width = 18, fig.height = 8

p <- ggplot(plot.data, aes(x = as.factor(STUDY.DAY.TARGET), y = VALUE)) +
  facet_wrap(~ PARAMETER, nrow = 2) +
  geom_boxplot(position = "dodge") +
  xlab("Target study day") + ylab("Kg") 

suppressMessages(print(p, vp = viewport(width = 18, height = 8, default.units = "inches")))

#####################################################################

#' ## Other measures
#+
type.names <- c(             "thermography",      
                             "goniometry", 
                             "circumference", 
                             "IL-1_",
                             "TNF-_",
                             "Substance P",
                             "Aggrecan"
)
#####################################################################
#' ### Value over time
#+ fig.width = 4, fig.height = 12

for(type in type.names){
  
  plot.data <- subset(data, TEST.TYPE == type  & grepl("mean$", PARAMETER))
  plot.data$TREAT <- as.factor(plot.data$TREAT)
  
  plot.data$PARAMETER <- par.rename(plot.data$PARAMETER, "")
  plot.data$PARAMETER <- par.rename(plot.data$PARAMETER, c("_", "-","ELISA", " 1", "\\mean$"))
  
  p <- ggplot(plot.data, aes(x = STUDY.DAY.TARGET, y = VALUE)) +
    facet_grid(HORSE ~ PARAMETER) +
    geom_line(aes(linetype = TREAT)) +
    xlab("Target study day") + ylab(unique(plot.data$UNIT)) +
    scale_linetype(guide = guide_legend(title = "Treatment"))
  
  print(p)
}

#####################################################################
#' ### Change from baseline, for each treatment
#+ echo = FALSE, fig.width = 4, fig.height = 12

for(type in type.names){
  
  plot.data <- subset(data, TEST.TYPE == type  & grepl("mean.deltabl$", PARAMETER))
  plot.data$TREAT <- as.factor(plot.data$TREAT)
  plot.data$PARAMETER <- par.rename(plot.data$PARAMETER, "")
  plot.data$PARAMETER <- par.rename(plot.data$PARAMETER, c("_", "-","ELISA", " 1", "\\mean deltabl"))
  
p <- ggplot(plot.data, aes(x = STUDY.DAY.TARGET, y = VALUE)) +
  facet_grid(HORSE ~ PARAMETER) +
  geom_line(aes(linetype = TREAT)) +
  xlab("Target study day") + ylab(unique(plot.data$UNIT)) +
  scale_linetype(guide = guide_legend(title = "Treatment"))

  print(p)
}

#' Loess smoother

#+ fig.width = 4, fig.height = 4

  for(type in type.names){
    
    plot.data <- subset(data, TEST.TYPE == type  & grepl("mean.deltabl$", PARAMETER))
    plot.data$TREAT <- as.factor(plot.data$TREAT)
    plot.data$PARAMETER <- par.rename(plot.data$PARAMETER, "")
    plot.data$PARAMETER <- par.rename(plot.data$PARAMETER, c("_", "-","ELISA", " 1", "\\mean deltabl"))
    
p <- ggplot(plot.data, aes(x = STUDY.DAY.TARGET, y = VALUE, linetype = TREAT)) +
  facet_wrap(~ PARAMETER) +
  stat_smooth()+
  xlab("Target study day") + ylab(unique(plot.data$UNIT)) +
  scale_linetype(guide = guide_legend(title = "Treatment"))

    suppressMessages(print(p))
    
}

#' Box plots
#+ echo = FALSE, fig.width = 4, fig.height = 4

for(type in type.names){
  
  plot.data <- subset(data, TEST.TYPE == type  & grepl("mean.deltabl$", PARAMETER))
  plot.data$TREAT <- as.factor(plot.data$TREAT)
  plot.data$PARAMETER <- par.rename(plot.data$PARAMETER, "")
  plot.data$PARAMETER <- par.rename(plot.data$PARAMETER, c("_", "-","ELISA", " 1", "\\mean deltabl"))
  
p <- ggplot(plot.data, aes(x = as.factor(STUDY.DAY.TARGET), y = VALUE, linetype = TREAT)) +
  facet_wrap(~ PARAMETER) +
  geom_boxplot(position = "dodge") + 
  xlab("Target study day") + ylab(unique(plot.data$UNIT)) +
  scale_linetype(guide = guide_legend(title = "Treatment"))
suppressMessages(print(p))
}
#####################################################################
#' ### Within horse differences
#' This is the treatment effect for each horse
#' Positive value = treated leg has higher value
#+ echo = FALSE, fig.width = 4, fig.height = 12


for(type in type.names){
  
  plot.data <- subset(data, TEST.TYPE == type  & grepl("mean.te$", PARAMETER))
  plot.data$TREAT <- as.factor(plot.data$TREAT)
  
  plot.data$PARAMETER <- par.rename(plot.data$PARAMETER, "")
  plot.data$PARAMETER <- par.rename(plot.data$PARAMETER, c(" ELISA", " 1", "\\mean te$"))
 
  ribbon.data <- data.frame(STUDY.DAY.TARGET = unique(plot.data$STUDY.DAY.TARGET))
  
p <- ggplot(plot.data, aes(x = STUDY.DAY.TARGET)) +
  facet_grid(HORSE ~ PARAMETER) 
 
  if(type == "thermography"){
    p <- p + geom_ribbon(aes(ymin = -1.2, ymax = 1.2),  data = ribbon.data, fill = "grey")
  }
  
  p <- p + 
    geom_line(aes(y = VALUE)) +
    xlab("Target study day") + ylab(unique(plot.data$UNIT)) +
    scale_linetype(guide = guide_legend(title = "Treatment"))
  
  print(p)
}  

#####################################################################

#' ### Within horse differences, change from baseline
#' This is the treatment effect for each horse
#' Positive value = treated leg has higher value
#+ echo = FALSE, fig.width = 4, fig.height = 12

for(type in type.names){
  
  plot.data <- subset(data, TEST.TYPE == type  & grepl("mean.deltabl.te$", PARAMETER))
  plot.data$PARAMETER <- par.rename(plot.data$PARAMETER, "")
  plot.data$PARAMETER <- par.rename(plot.data$PARAMETER, c(" ELISA", " 1", "\\mean deltabl te$"))
  
  p <- ggplot(plot.data, aes(x = STUDY.DAY.TARGET, y = VALUE)) +
  facet_grid(HORSE ~ PARAMETER) +
  geom_line() +
  xlab("Target study day") + ylab(unique(plot.data$UNIT)) +
  scale_linetype(guide = guide_legend(title = "Treatment"))
  print(p)
 
}

#####################################################################
#' Loess smoother
#+ fig.width = 4, fig.height = 4

  for(type in type.names){
    
    plot.data <- subset(data, TEST.TYPE == type  & grepl("mean.deltabl.te$", PARAMETER))
    plot.data$PARAMETER <- par.rename(plot.data$PARAMETER, "")
    plot.data$PARAMETER <- par.rename(plot.data$PARAMETER, c("_", " ELISA", " 1", "\\mean deltabl te$"))
    
    
p <- ggplot(plot.data, aes(x = STUDY.DAY.TARGET, y = VALUE)) +
  facet_wrap(~ PARAMETER, nrow = 2) +
      stat_smooth()+
  xlab("Target study day") + ylab(unique(plot.data$UNIT)) #+ ggtitle(unique(plot.data$PARAMETER))
  scale_linetype(guide = guide_legend(title = "Treatment"))

    suppressMessages(print(p))
  }

#' Box plot
#+ fig.width = 3, fig.height = 4

for(type in type.names){
  
  plot.data <- subset(data, TEST.TYPE == type  & grepl("mean.deltabl.te$", PARAMETER))
  plot.data$PARAMETER <- par.rename(plot.data$PARAMETER, "")
  plot.data$PARAMETER <- par.rename(plot.data$PARAMETER, c("_", " ELISA", " 1", "\\mean deltabl te$"))
    
    p <- ggplot(plot.data, aes(x = as.factor(STUDY.DAY.TARGET), y = VALUE)) +
      facet_wrap(~ PARAMETER, nrow = 2) +
      geom_boxplot(position = "dodge") +
      xlab("Target study day") + ylab(unique(plot.data$UNIT)) 
      
    suppressMessages(print(p))
    
}

#####################################################################
#' ## Lameness Flex
#+ fig.width = 8, fig.height = 12

plot.data <- subset(data, PARAMETER == "lameness.flex")
plot.data$PARAMETER <- par.rename(plot.data$PARAMETER, "")

#plot.data$VALUE <- as.factor(plot.data$VALUE)
#plot.data$VALUE[plot.data$VALUE == 0] <- "Negative"
#plot.data$VALUE[plot.data$VALUE == 1] <- "Positive"

plot.data$TREAT[plot.data$TREAT == 0] <- "Not treated"
plot.data$TREAT[plot.data$TREAT == 1] <- "Treated"

p <- ggplot(plot.data, aes(x = STUDY.DAY.TARGET, y = VALUE)) +
  facet_grid(HORSE ~ TREAT) +
  geom_step()+
  geom_point() +
  xlab("Target study day") + ylab("") +
  scale_linetype(guide = guide_legend(title = "Treatment")) +
  scale_y_continuous(breaks = c(0, 1), labels = c("Negative", "Positive"))

print(p)

#####################################################################
#' ## Lameness subjective
#+ fig.width = 8, fig.height = 12

plot.data <- subset(data, PARAMETER == "lameness.sub")
plot.data$PARAMETER <- par.rename(plot.data$PARAMETER, "")

plot.data$TREAT[plot.data$TREAT == 0] <- "Not treated"
plot.data$TREAT[plot.data$TREAT == 1] <- "Treated"

p <- ggplot(plot.data, aes(x = STUDY.DAY.TARGET, y = VALUE)) +
  facet_grid(HORSE ~ TREAT) +
  geom_step()+
  geom_point() +
  xlab("Target study day") + ylab("") +
  scale_linetype(guide = guide_legend(title = "Treatment")) +
  scale_y_continuous(breaks = c(0, 1, 2, 3), labels = c("Not lame", "Lame 1/5", "Lame 2/5", "Lame 3/5"))

print(p)

#####################################################################
#' ## Palpatation
#+ fig.width = 8, fig.height = 12

plot.data <- subset(data, PARAMETER == "palpation.1")
plot.data$PARAMETER <- par.rename(plot.data$PARAMETER, "")
plot.data$PARAMETER <- par.rename(plot.data$PARAMETER, " 1")

plot.data$TREAT[plot.data$TREAT == 0] <- "Not treated"
plot.data$TREAT[plot.data$TREAT == 1] <- "Treated"

p <- ggplot(plot.data, aes(x = STUDY.DAY.TARGET, y = VALUE)) +
  facet_grid(HORSE ~ TREAT) +
  geom_step()+
  geom_point() +
  xlab("Target study day") + ylab("") +
  scale_linetype(guide = guide_legend(title = "Treatment")) +
  scale_y_continuous(breaks = c(0, 1, 2, 3), labels = c("Not painful", "Mildly painful", "Painful", "Severely painful"))

print(p)

#####################################################################
#' ## Swelling subjective
#+ fig.width = 8, fig.height = 12

plot.data <- subset(data, PARAMETER == "swelling.sub")
plot.data$PARAMETER <- par.rename(plot.data$PARAMETER, "")
plot.data$PARAMETER <- par.rename(plot.data$PARAMETER, " 1")

plot.data$TREAT[plot.data$TREAT == 0] <- "Not treated"
plot.data$TREAT[plot.data$TREAT == 1] <- "Treated"

p <- ggplot(plot.data, aes(x = STUDY.DAY.TARGET, y = VALUE)) +
  facet_grid(HORSE ~ TREAT) +
  geom_step()+
  geom_point() +
  xlab("Target study day") + ylab("") +
  scale_linetype(guide = guide_legend(title = "Treatment")) +
  scale_y_continuous(breaks = c(0, 1, 2, 3), labels = c("No swelling", "Mild swelling", "Swelling", "Severe swelling"))

print(p)

#####################################################################
#' ## Lameness Sym
#' ### Value over time
#+ fig.width = 5, fig.height = 12

plot.data <- subset(data, grepl("lameness.sym", PARAMETER) & grepl("mean$", PARAMETER))
plot.data$PARAMETER <- par.rename(plot.data$PARAMETER, "\\.mean$")

ribbon.data <- data.frame(STUDY.DAY.TARGET = unique(plot.data$STUDY.DAY.TARGET))

ggplot(plot.data, aes(x = STUDY.DAY.TARGET, y = VALUE)) +
  facet_grid(HORSE ~ PARAMETER) +
  geom_ribbon(aes(y = NULL, ymin = 0.82, ymax = 1.18),  data = ribbon.data, fill = "grey") +
  geom_line() +
  geom_point() +
  xlab("Target study day") + ylab("") 
  #scale_linetype(guide = guide_legend(title = "Treatment"))


