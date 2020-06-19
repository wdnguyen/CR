library(tidyverse) # godsend: ggplot2, tibble, tidyr, readr, dplyr, purrr, stringr, forcats
library(gridExtra)
library(grid)
library(ggthemes)
library(reshape)
library(lubridate)
library(reshape2)
library(scales)
library(patchwork) # subplotting
library(ggrepel)
library(ggpmisc)
library(ggpubr)
library(blockTools)
library(ggstatsplot)
library(lattice)
library(viridis)
library(cowplot)
library(purrr)
library(RColorBrewer)

if(!require(pacman))install.packages("pacman")
pacman::p_load('dplyr','tidyr','gapminder','ggplot2','ggalt',
               'forcats','R.utils', 'png', 'grid','ggpubr', 'scales', 'bbplot')

# Utility functions (pretty graphs)
source("MyUtils.R")

df <- read.csv("https://raw.githubusercontent.com/wdnguyen/CR/master/CostaRica_Chemistry_20200518.csv", na.strings = "BDL")
# could also use df[df == "BDL"] <- NA

df$SamplingDate <- as.POSIXct(df$SamplingDate, format = "%m/%d/%Y %H:%M")
df$Chemetrics_Acidified_Date <- as.POSIXct(df$Chemetrics_Acidified_Date, format = "%m/%d/%Y %H:%M")

long <- df %>%
  gather(Species, Concentration, Temp:D) 

x <- long %>%
  filter(Species == "Temp") %>%
  ggplot(aes(x=Source, y=Concentration)) + geom_boxplot()

response  = names(df)[4:5] #[1:5]
exp1 = names(df)[6:60]
response = set_names(response,response)
exp1 = set_names(exp1, exp1)

boxplot_fun = function(x,y) {
  ggplot(df, aes(x = .data[[x]], y= .data[[y]]) ) +
    geom_boxplot(fill = "slateblue", alpha = 0.2) +
    theme_bw() +
    coord_flip() + # for some reason, loop flipped axes
    theme(text = element_text(size=14, family = "Helvetica"),
          axis.title = element_text(face = "bold")) +
    labs(x = x, 
         y = y)
}

all_plots = map(response,
                ~map(exp1, boxplot_fun, y = .x))

iwalk(all_plots, ~{
  pdf(paste0(.y, "_boxplots.pdf") )
  print(.x)
  dev.off()
})

plotnames = imap(all_plots, ~paste0(.y, "_", names(.x), ".png")) %>%
  flatten()

