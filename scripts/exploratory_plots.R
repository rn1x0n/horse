#' # Exploratory Plots

#+ echo = FALSE
source(file.path("..", "_setup.R"))
opts_chunk$set(warning = FALSE, error = FALSE)

#' ## Algometry
#' ### Value over time
#+ echo = FALSE, fig.width = 15, fig.height = 12

plot.data <- subset(data, TEST.TYPE == "algometry" & grepl("mean$", PARAMETER))
plot.data$PARAMETER <- par.rename(plot.data$PARAMETER, "\\.mean$")

ggplot(plot.data, aes(x = STUDY.DAY.TARGET, y = VALUE)) +
  facet_grid(HORSE ~ PARAMETER) +
  geom_line(aes(linetype = TREAT)) +
  xlab("Target study day") + ylab("Kg") +
  scale_linetype(guide = guide_legend(title = "Treatment"))
  #coord_cartesian(ylim = ylim)


#' ### Within horse differences over time
#' This is the treatment effect for each horse
#+ echo = FALSE, fig.width = 15, fig.height = 12

plot.data <- subset(data, TEST.TYPE == "algometry" & grepl("mean.te$", PARAMETER))
plot.data$PARAMETER <- par.rename(plot.data$PARAMETER, "\\.mean.te$")

ggplot(plot.data, aes(x = STUDY.DAY.TARGET, y = VALUE)) +
  facet_grid(HORSE ~ PARAMETER) +
  geom_line() +
  xlab("Target study day") + ylab("Kg") +
  scale_linetype(guide = guide_legend(title = "Treatment"))
  #coord_cartesian(ylim = ylim)


