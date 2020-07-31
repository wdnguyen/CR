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
library(svglite)

if(!require(pacman))install.packages("pacman")
pacman::p_load('dplyr','tidyr','gapminder','ggplot2','ggalt',
               'forcats','R.utils', 'png', 'grid','ggpubr', 'scales', 'bbplot')

# Utility functions (pretty graphs)
source("MyUtils.R")

df <- read.csv("https://raw.githubusercontent.com/wdnguyen/CR/master/CostaRica_Chemistry_20200518.csv", na.strings = "BDL", stringsAsFactors = FALSE)
# could also use df[df == "BDL"] <- NA

df$SamplingDate <- as.POSIXct(df$SamplingDate, format = "%m/%d/%y %H:%M")
df$Chemetrics_Acidified_Date <- as.POSIXct(df$Chemetrics_Acidified_Date, format = "%m/%d/%y %H:%M")

# df <- df[format(df$SamplingDate, '%Y') != "2019", ]

df <- dplyr::mutate_if(tibble::as_tibble(df), 
                       is.character, 
                       stringr::str_replace_all, pattern = "Upstream", replacement = "Up")

df <- dplyr::mutate_if(tibble::as_tibble(df), 
                       is.character, 
                       stringr::str_replace_all, pattern = "Downstream", replacement = "Down")

# Setting in certain order
df$Site <- factor(df$Site,
                  levels=c("Rain", "Soil", "Spring", "Up", "Down"))

#unbracketed <- df %>%
#  select(ID, Site, Source, SPCOND, pH, ORP, AlkalinityW, Fl, NO2, NO3, Na_IC, Mo, Si, P, Cr, Ti, B, Sr, Sr2, Ba, K, As, Na, Mg) %>%
#  gather(Species, Concentration, SPCOND:Mg) 


######## Endmember Summaries ########
# Batch: Downstream
# Endmembers: Upstream, Soil, Rain
df_summary <- df %>%
  group_by(Site) %>%
  summarise_all(funs(mean, max, sd), na.rm = TRUE)

