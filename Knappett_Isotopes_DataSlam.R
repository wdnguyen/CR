library(ggplot2)
library(gridExtra)
library(grid)
library(ggthemes)
library(reshape)

grid_arrange_shared_legend <- function(..., ncol = length(list(...)), nrow = 1, position = c("bottom", "right")) {
  
  plots <- list(...)
  position <- match.arg(position)
  g <- ggplotGrob(plots[[1]] + theme(legend.position = position))$grobs
  legend <- g[[which(sapply(g, function(x) x$name) == "guide-box")]]
  lheight <- sum(legend$height)
  lwidth <- sum(legend$width)
  gl <- lapply(plots, function(x) x + theme(legend.position="none"))
  gl <- c(gl, ncol = ncol, nrow = nrow)
  
  combined <- switch(position,
                     "bottom" = arrangeGrob(do.call(arrangeGrob, gl),
                                            legend,
                                            ncol = 1,
                                            heights = unit.c(unit(1, "npc") - lheight, lheight)),
                     "right" = arrangeGrob(do.call(arrangeGrob, gl),
                                           legend,
                                           ncol = 2,
                                           widths = unit.c(unit(1, "npc") - lwidth, lwidth)))
  
  grid.newpage()
  grid.draw(combined)
  
  # return gtable invisibly
  invisible(combined)
  
}

# Multiple plot function
#
# ggplot objects can be passed in ..., or to plotlist (as a list of ggplot objects)
# - cols:   Number of columns in layout
# - layout: A matrix specifying the layout. If present, 'cols' is ignored.
#
# If the layout is something like matrix(c(1,2,3,3), nrow=2, byrow=TRUE),
# then plot 1 will go in the upper left, 2 will go in the upper right, and
# 3 will go all the way across the bottom.
#
multiplot <- function(..., plotlist=NULL, file, cols=1, layout=NULL) {
  library(grid)
  
  # Make a list from the ... arguments and plotlist
  plots <- c(list(...), plotlist)
  
  numPlots = length(plots)
  
  # If layout is NULL, then use 'cols' to determine layout
  if (is.null(layout)) {
    # Make the panel
    # ncol: Number of columns of plots
    # nrow: Number of rows needed, calculated from # of cols
    layout <- matrix(seq(1, cols * ceiling(numPlots/cols)),
                     ncol = cols, nrow = ceiling(numPlots/cols))
  }
  
  if (numPlots==1) {
    print(plots[[1]])
    
  } else {
    # Set up the page
    grid.newpage()
    pushViewport(viewport(layout = grid.layout(nrow(layout), ncol(layout))))
    
    # Make each plot, in the correct location
    for (i in 1:numPlots) {
      # Get the i,j matrix positions of the regions that contain this subplot
      matchidx <- as.data.frame(which(layout == i, arr.ind = TRUE))
      
      print(plots[[i]], vp = viewport(layout.pos.row = matchidx$row,
                                      layout.pos.col = matchidx$col))
    }
  }
}

knappett_isotopes <- read.csv("knappett_isotopes.csv")
knappett_rain <- read.csv("DownstreamMiller.csv")

knappett_dates <- strptime(knappett_isotopes$Date_Time, format = "%m/%d/%y %H:%M")
knappett_rain_dates <- strptime(knappett_rain$Date, format ="%m/%d/%y %H:%M")

knappett_isotopes_fixed <- data.frame(knappett_isotopes, knappett_dates)
knappett_rain_fixed <- data.frame(knappett_rain, knappett_rain_dates)

# Subsetting Data
upstream_data <- subset(knappett_isotopes_fixed, Site == "Upstream")
downstream_data <- subset(knappett_isotopes_fixed, Site == "Downstream")

# Oxygen
oxygen_plot <- ggplot() +
  geom_line(data = upstream_data, aes(x=knappett_dates, y=Oxygen, colour="HMU")) +
  geom_point(data = upstream_data, aes(x=knappett_dates, y=Oxygen, colour="HMU")) +
  geom_line(data = downstream_data, aes(x=knappett_dates, y=Oxygen, colour="HMD")) +
  geom_point(data = downstream_data, aes(x=knappett_dates, y=Oxygen, colour="HMD")) +
  geom_hline(yintercept = -6.49, linetype=2) + 
  # annotate("text", x=as.Date(7/8/18 1:50), -6.49, vjust = -1, label = "Well 200") +
  geom_hline(yintercept = -4.68, linetype=2) + 
  # annotate("text", 0.9*max(upstream_data$knappett_dates), -4.68, vjust = -1, label = "Well 205") +
  geom_hline(yintercept = -3.21, linetype=3) + 
  # annotate("text", 0.9*max(upstream_data$knappett_dates), -3.21, vjust = 1.5, label = "Rain") +
  theme_few() +
  scale_color_manual("",
                     breaks = c("HMU", "HMD"),
                     values = c("HMU"="blue", "HMD"="red")) + 
  # ggtitle("48-Hour Data Slam: Oxygen") +
  theme(plot.title = element_text(hjust = 0.5),
        text=element_text(size=20),
        legend.position="none",
        axis.title.x=element_blank(),
        axis.text.x=element_blank(),
        # axis.ticks.x=element_blank(),
        axis.text.y = element_text(colour="black", size=18)) +
  xlab("Time") +
  ylab(expression(paste(delta^18,"O (‰)"))) +
  scale_y_continuous(limits=c(-7,-3))

# Deuterium
deuterium_plot <- ggplot() +
  geom_line(data = upstream_data, aes(x=knappett_dates, y=Deuterium, colour="HMU")) +
  geom_point(data = upstream_data, aes(x=knappett_dates, y=Deuterium, colour="HMU")) +
  geom_line(data = downstream_data, aes(x=knappett_dates, y=Deuterium, colour="HMD")) +
  geom_point(data = downstream_data, aes(x=knappett_dates, y=Deuterium, colour="HMD")) + 
  geom_hline(yintercept = -27.1, linetype=2) + 
  geom_hline(yintercept = -25.1, linetype=2) + 
  geom_hline(yintercept = -12.2, linetype=3) + 
  theme_few() +
  scale_color_manual("",
                     breaks = c("HMU", "HMD"),
                     values = c("HMU"="blue", "HMD"="red")) + 
  # ggtitle("48-Hour Data Slam: Deuterium") +
  theme(plot.title = element_text(hjust = 0.5),
        text=element_text(size=20),
        legend.position="bottom",
        axis.text.y = element_text(colour="black", size=18),
        axis.text.x = element_text(colour="black"),
        axis.title.x = element_blank()) +
  # xlab("\nTime") +
  scale_x_datetime(date_labels = "%m/%d\n%H:%M") +
  ylab(expression(paste(delta,"D (‰)"))) +
  scale_y_continuous(limits=c(-40,-10))

# Rain
rain_plot <- ggplot(data = knappett_rain_fixed[1:581,], aes(x = knappett_rain_dates, y = Rain)) + 
  geom_bar(stat = "identity", 
           position = 'dodge',
           # fill = "black", #rgb(187, 8, 38, maxColorValue = 255), 
           color = "black") + #rgb(187, 8, 38, maxColorValue = 255)) + 
  theme_bw() + 
  # ggtitle("48-Hour Data Slam") +
  theme(#text=element_text(size=18),
        panel.border = element_blank(), 
        panel.grid.major.x = element_blank(), 
        panel.grid.major.y = element_blank(),# element_line(colour = "black"), 
        panel.grid.minor = element_blank(), 
        axis.line = element_line(colour = "black"), 
        axis.text.x = element_blank(), #(angle = 45, hjust = 1, color="white"),
        axis.line.x = element_blank(), #(color = "white"),
        axis.ticks.x = element_blank(),
        axis.text.y = element_text(colour="black", size=18),
        axis.title.x = element_blank(),
        axis.title.y = element_text(colour="black", size=18)) + 
  labs(y = "Precip\n(mm)") +
  # scale_y_reverse() + 
  scale_y_continuous(trans = "reverse") +
ggsave("precipitation.png", plot=rain_plot, width=7.5, height=3)

# multiplot(oxygen_plot, deuterium_plot, cols=1)




# or


# adding stream data
lia_Q <- read.csv("lia_Q.csv")
Q_dates <- strptime(lia_Q$Date_Time, format ="%m/%d/%y %H:%M")
Q <- data.frame(lia_Q$Q, Q_dates)
Qmelt <- melt(Q, id="Q_dates", value.name="Q")

UpQ <- read.csv("UpQDataSlam.csv")
Q_dates <- strptime(UpQ$Up_Dates, format ="%m/%d/%y %H:%M")
Qup <- data.frame(UpQ$UpQ, Q_dates)
QUpmelt <- melt(Qup, id="Q_dates", value.name="Qup")

Qplot <- ggplot() +
  geom_line(data=Qmelt,
            aes(x=Q_dates, y=value, colour="HMD")) +
  geom_line(data=QUpmelt,
            aes(x=Q_dates, y=value, colour="HMU")) +
  theme_few() +
  scale_color_manual("",
                     breaks = c("HMU", "HMD"),
                     values = c("HMU"="blue", "HMD"="red")) + 
  # ggtitle("48-Hour Data Slam: Oxygen") +
  theme(plot.title = element_text(hjust = 0.5),
        text=element_text(size=18),
        legend.position="none",
        axis.title.x=element_blank(),
        axis.text.x=element_blank(),
        # axis.ticks.x=element_blank(),
        axis.text.y = element_text(colour="black", size=18)) +
  xlab("Time") +
  ylab("Discharge\n(cms)\n") 


library(patchwork)
rain_plot + oxygen_plot + deuterium_plot + plot_layout(ncol=1, heights=c(1,2,2))
rain_plot + Qplot + oxygen_plot + deuterium_plot + plot_layout(ncol=1, heights=c(1,2,2,2))

# ggsave("subplot.png", plotplot)
