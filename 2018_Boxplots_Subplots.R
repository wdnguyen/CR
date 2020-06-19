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

df$SamplingDate <- as.POSIXct(df$SamplingDate, format = "%m/%d/%Y %H:%M")
df$Chemetrics_Acidified_Date <- as.POSIXct(df$Chemetrics_Acidified_Date, format = "%m/%d/%Y %H:%M")

df <- df[format(df$SamplingDate, '%Y') != "2019", ]

# df <- head(df,-2) # for some reason, two rows of NaN were appended to bottom of data frame

df <- dplyr::mutate_if(tibble::as_tibble(df), 
                       is.character, 
                       stringr::str_replace_all, pattern = "Upstream", replacement = "Up")

df <- dplyr::mutate_if(tibble::as_tibble(df), 
                       is.character, 
                       stringr::str_replace_all, pattern = "Downstream", replacement = "Down")

# Setting in certain order
df$Site <- factor(df$Site,
                  levels=c("Rain", "Soil", "Spring", "Up", "Down"))

unbracketed <- df %>%
  select(ID, Site, Source, SPCOND, pH, ORP, AlkalinityW, Fl, NO2, NO3, Na_IC, Mo, Si, P, Cr, Ti, B, Sr, Sr2, Ba, K, As, Na, Mg) %>%
  gather(Species, Concentration, SPCOND:Mg) 

u_production <- df %>%
  select(ID, Site, Source, pH, Fl, Cr, Ti, B, Na) %>%
  gather(Species, Concentration, pH:Na) 

u_removal <- df %>%
  select(ID, Site, Source, ORP, NO2, NO3, Mo, Si, P, As) %>%
  gather(Species, Concentration, ORP:As)

norprorem <- df %>%
  select(ID, Site, Source, SPCOND, AlkalinityW, Na_IC, Ca_IC, Sr, Sr2, Ba, K, Mg) %>%
  gather(Species, Concentration, SPCOND:Mg)

bracketed <- df %>%
  select(ID, Site, Source, NH3_f, H2S_f, NO3_f, O2, Cl, SO4, K_IC, Mg_IC, Mn, Fe, Ni, Zn, O18, D) %>%
  gather(Species, Concentration, NH3_f:D) 

neutral <- df %>%
  select(ID, Site, Source, DOC, TDN, TotalNField, Li, Ca_IC, Cd, Sb, Pb, U, Al, S, Ca, Co, Cu) %>%
  gather(Species, Concentration, DOC:Cu) 

################

theme_ex = labs(y=expression(Concentration~(mg~L^{-1}))) +
  theme(axis.title.x = element_blank()) +
  theme_bw()

unbracketed_plot <- ggplot(unbracketed, aes(x=Site, y=Concentration, fill=Site)) + 
  geom_boxplot() +
  facet_wrap(~Species, scale = "free") +
  labs(y=expression(Concentration~(mg~L^{-1}))) +
  theme(axis.title.x = element_blank()) +
  theme_bw() +
  scale_fill_manual(values = c("magenta", "green", "yellow", "blue", "red"))

bracketed_plot <- ggplot(bracketed, aes(x=Site, y=Concentration, fill=Site)) + 
  geom_boxplot() +
  facet_wrap(~Species, scale = "free") +
  labs(y=expression(Concentration~(mg~L^{-1}))) +
  theme(axis.title.x = element_blank()) +
  theme_bw() +
  scale_fill_manual(values = c("magenta", "green", "yellow", "blue", "red"))

u_production_plot <- ggplot(u_production, aes(x=Site, y=Concentration, fill=Site)) + 
  geom_boxplot() +
  facet_wrap(~Species, scale = "free") +
  labs(y=expression(Concentration~(mg~L^{-1}))) +
  theme(axis.title.x = element_blank()) +
  theme_bw() +
  scale_fill_manual(values = c("magenta", "green", "yellow", "blue", "red"))

norprorem_plot <- ggplot(norprorem, aes(x=Site, y=Concentration, fill=Site)) + 
  geom_boxplot() +
  facet_wrap(~Species, scale = "free") +
  labs(y=expression(Concentration~(mg~L^{-1}))) +
  theme(axis.title.x = element_blank()) +
  theme_bw() +
  scale_fill_manual(values = c("magenta", "green", "yellow", "blue", "red"))

u_removal_plot <- ggplot(u_removal, aes(x=Site, y=Concentration, fill=Site)) + 
  geom_boxplot() +
  facet_wrap(~Species, scale = "free") +
  labs(y=expression(Concentration~(mg~L^{-1}))) +
  theme(axis.title.x = element_blank()) +
  theme_bw() +
  scale_fill_manual(values = c("magenta", "green", "yellow", "blue", "red"))

neutral_plot <- ggplot(neutral, aes(x=Site, y=Concentration, fill=Site)) + 
  geom_boxplot() +
  facet_wrap(~Species, scale = "free") +
  labs(y=expression(Concentration~(mg~L^{-1}))) +
  theme(axis.title.x = element_blank()) +
  theme_bw() +
  scale_fill_manual(values = c("magenta", "green", "yellow", "blue", "red"))

ggsave(file = "2018_unbracketed.png", plot = unbracketed_plot, width = 12, height = 8, dpi = 300)
ggsave(file = "2018_bracketed.png", plot = bracketed_plot, width = 12, height = 8, dpi = 300)
ggsave(file = "2018_u_production_plot.png", plot = u_production_plot, width = 12, height = 8, dpi = 300)
ggsave(file = "2018_u_removal_plot.png", plot = u_removal_plot, width = 12, height = 8, dpi = 300)
ggsave(file = "2018_neutral_plot.png", plot = neutral_plot, width = 12, height = 8, dpi = 300)

