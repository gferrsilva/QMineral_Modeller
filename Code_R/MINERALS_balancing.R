#####
# Mineral Group Classification by Random Forest
# 
# version: 1.0 (2020/05/20)
#
# Last modifications:
#
# -----
# Amphiboles, Apatites, Carbonates, Clay Minerals, Spinels, Feldspathoides,
# Spinels, Ilmenites, Micas, Olivines, Perovskites, Pyroxenes, Quartz, Sulfides,
# Titanite, Zircon
# -----
# Guilherme Ferreira, (guilherme.ferreira@cprm.gov.br)
# May, 2020
#####

#####
# Setting up the enviroment
#####
setwd("C:/Users/GUILHERMEFERREIRA-PC/Documents/GitHub/MinChem_Modeller") # defining the work direction
set.seed(0) # defining the 'random state' of the pseudo-random generator

#####
#Import Packages
#####
library(Cairo) # Export figures
library(tidyverse) # Collection of libraries: dplyr, ggplot2, purrr, tidyr. Data wrangling and visualizing
library(ggthemes) # Predefined themes
library(caret) # Machine Learning Toolkit
library(randomForest) # Random Forest library
library(factoextra) # Deal with PCA and PCA datavis


#####
# Built-in Functions
#####

#####
# PREPRARING DATA 
#####

files <- list.files('data_input', pattern = '_model')

minerals <- sapply(paste0('data_input/',files), read_csv) %>%
  bind_rows()

# Quartz ----

quartz <- read_csv('data_input/minerals.csv') %>% # Read file and associate to an object
  select(1,47,19,14,3,25:46) %>% # select and reorder the columns
  mutate(id = X1, X1 = NULL) %>% # Rename Column
  mutate(AS_ppm = ifelse(AS_ppm > 100, AS_ppm/10000, # Adjusting values of column
                         ifelse(AS_ppm > 50, AS_ppm/10, AS_ppm))) %>%
  mutate(AS = AS_ppm, AS_ppm = NULL, # Rename columns
         ROCK = `ROCK NAME`, `ROCK NAME` = NULL,
         SAMPLE = `SAMPLE NAME`, `SAMPLE NAME` = NULL) %>%
  filter(GROUP == 'QUARTZ') %>%
  select(24,27, 1:2,26, 3:23,25) %>%# Reorder Columns
  group_by(MINERAL) %>%
  sample_n(30)

# Ilmenite ----

ilmenite <- read_csv('data_input/minerals.csv') %>% # Read file and associate to an object
  select(1,47,19,14,3,25:46) %>% # select and reorder the columns
  mutate(id = X1, X1 = NULL) %>% # Rename Column
  mutate(AS_ppm = ifelse(AS_ppm > 100, AS_ppm/10000, # Adjusting values of column
                         ifelse(AS_ppm > 50, AS_ppm/10, AS_ppm))) %>%
  mutate(AS = AS_ppm, AS_ppm = NULL, # Rename columns
         ROCK = `ROCK NAME`, `ROCK NAME` = NULL,
         SAMPLE = `SAMPLE NAME`, `SAMPLE NAME` = NULL) %>%
  filter(GROUP == 'ILMENITE') %>%
  select(24,27, 1:2,26, 3:23,25) %>%# Reorder Columns
  sample_n(30, replace = T)

# Apatite ----

apatite <- read_csv('data_input/minerals.csv') %>% # Read file and associate to an object
  select(1,47,19,14,3,25:46) %>% # select and reorder the columns
  mutate(id = X1, X1 = NULL) %>% # Rename Column
  mutate(AS_ppm = ifelse(AS_ppm > 100, AS_ppm/10000, # Adjusting values of column
                         ifelse(AS_ppm > 50, AS_ppm/10, AS_ppm))) %>%
  mutate(AS = AS_ppm, AS_ppm = NULL, # Rename columns
         ROCK = `ROCK NAME`, `ROCK NAME` = NULL,
         SAMPLE = `SAMPLE NAME`, `SAMPLE NAME` = NULL) %>%
  filter(GROUP == 'APATITE') %>%
  select(24,27, 1:2,26, 3:23,25) %>%# Reorder Columns
  sample_n(30)

# Titanite ----

titanite <- read_csv('data_input/minerals.csv') %>% # Read file and associate to an object
  select(1,47,19,14,3,25:46) %>% # select and reorder the columns
  mutate(id = X1, X1 = NULL) %>% # Rename Column
  mutate(AS_ppm = ifelse(AS_ppm > 100, AS_ppm/10000, # Adjusting values of column
                         ifelse(AS_ppm > 50, AS_ppm/10, AS_ppm))) %>%
  mutate(AS = AS_ppm, AS_ppm = NULL, # Rename columns
         ROCK = `ROCK NAME`, `ROCK NAME` = NULL,
         SAMPLE = `SAMPLE NAME`, `SAMPLE NAME` = NULL) %>%
  filter(GROUP == 'TITANITE') %>%
  select(24,27, 1:2,26, 3:23,25) %>%# Reorder Columns
  #group_by(MINERAL) %>%
  sample_n(30)

# Zircon ----

zircon <- read_csv('data_input/minerals.csv') %>% # Read file and associate to an object
  select(1,47,19,14,3,25:46) %>% # select and reorder the columns
  mutate(id = X1, X1 = NULL) %>% # Rename Column
  mutate(AS_ppm = ifelse(AS_ppm > 100, AS_ppm/10000, # Adjusting values of column
                         ifelse(AS_ppm > 50, AS_ppm/10, AS_ppm))) %>%
  mutate(AS = AS_ppm, AS_ppm = NULL, # Rename columns
         ROCK = `ROCK NAME`, `ROCK NAME` = NULL,
         SAMPLE = `SAMPLE NAME`, `SAMPLE NAME` = NULL) %>%
  filter(GROUP == 'ZIRCON') %>%
  select(24,27, 1:2,26, 3:23,25) %>%# Reorder Columns
  sample_n(30)

# Perovskite ----

perovskite <- read_csv('data_input/minerals.csv') %>% # Read file and associate to an object
  select(1,47,19,14,3,25:46) %>% # select and reorder the columns
  mutate(id = X1, X1 = NULL) %>% # Rename Column
  mutate(AS_ppm = ifelse(AS_ppm > 100, AS_ppm/10000, # Adjusting values of column
                         ifelse(AS_ppm > 50, AS_ppm/10, AS_ppm))) %>%
  mutate(AS = AS_ppm, AS_ppm = NULL, # Rename columns
         ROCK = `ROCK NAME`, `ROCK NAME` = NULL,
         SAMPLE = `SAMPLE NAME`, `SAMPLE NAME` = NULL) %>%
  filter(MINERAL == 'PEROVSKITE') %>%
  select(24,27, 1:2,26, 3:23,25) %>%# Reorder Columns
  #group_by(MINERAL) %>%
  sample_n(30)


#####
# JOINING DATA
#####

minerals <- minerals %>%
  bind_rows(apatite,
            ilmenite,
            perovskite,
            quartz,
            titanite,
            zircon) %>%
  as_tibble()

write.csv(minerals, 'data_input/minerals_balanced.csv')

contagem <- minerals %>%
  group_by(MINERAL, GROUP) %>%
  count()

write.csv(contagem, 'references/listofminerals.csv')