#####
# Mineral Group Classification by Random Forest
# 
# version: 1.0 (2020/05/20)
#
# Last modifications:
#
# -----
# Amphiboles, Apatites, Carbonates, Clay Minerals, Feldspars, Feldspathoides,
# Garnets, Ilmenites, Micas, Olivines, Perovskites, Pyroxenes, Quartz, Sulfides,
# Titanite, Zircon
# -----
# Guilherme Ferreira, (guilherme.ferreira@cprm.gov.br)
# May, 2020
#####

#####
# Setting up the enviroment
#####

setwd("~/GitHub/MinChem_Modeller") # defining the work direction
set.seed(123) # defining the 'random state' of the pseudo-random generator

#####
#Import Packages
#####

library(tidyverse) # Collection of libraries: dplyr, ggplot2, purrr, tidyr. Data wrangling and visualizing

#####
# Built-in Functions
#####

#####
# PREPRARING DATA 
#####

mica <- read_csv('data_input/minerals.csv') %>% # Read file and associate to an object
  select(1,47,19,14,3,25:46) %>% # select and reorder the columns
  mutate(id = X1, X1 = NULL) %>% # Rename Column
  mutate(AS_ppm = ifelse(AS_ppm > 100, AS_ppm/10000, # Adjusting values of column
                         ifelse(AS_ppm > 50, AS_ppm/10, AS_ppm))) %>%
  mutate(AS = AS_ppm, AS_ppm = NULL, # Rename columns
         ROCK = `ROCK NAME`, `ROCK NAME` = NULL,
         SAMPLE = `SAMPLE NAME`, `SAMPLE NAME` = NULL) %>%
  filter(GROUP == 'MICA') %>%
  select(24,27, 1:2,26, 3:23,25) %>% # Reorder Columns
  rename(SiO2 = SIO2,
         TiO2 = TIO2,
         Al2O3 = AL2O3,
         Cr2O3 = CR2O3,
         FeO = FEOT,
         MnO = MNO,
         MgO = MGO,
         CaO = CAO)
