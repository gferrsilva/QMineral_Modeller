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
setwd("~/GitHub/MinChem_Modeller") # defining the work direction
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

files <- list.files('data_input/toSMOTE', pattern = '.csv')

minerals <- sapply(paste0('data_input/toSMOTE/',files), read_csv) %>%
  bind_rows()

# Quartz ----

quartz <- read_csv('data_input/minerals_posDBScan.csv') %>% # Read file and associate to an object
  dplyr::select(1,47,19,14,3,25:46) %>% # select and reorder the columns
  mutate(id = X1, X1 = NULL) %>% # Rename Column
  mutate(AS_ppm = ifelse(AS_ppm > 100, AS_ppm/10000, # Adjusting values of column
                         ifelse(AS_ppm > 50, AS_ppm/10, AS_ppm))) %>%
  mutate(AS = AS_ppm, AS_ppm = NULL, # Rename columns
         ROCK = `ROCK NAME`, `ROCK NAME` = NULL,
         SAMPLE = `SAMPLE NAME`, `SAMPLE NAME` = NULL) %>%
  filter(GROUP == 'QUARTZ') %>%
  dplyr::select(24,27, 1:2,26, 3:23,25) %>%# Reorder Columns
  group_by(MINERAL) %>%
  sample_n(50,replace = FALSE) %>%
  distinct(.keep_all = TRUE)

# Ilmenite ----

ilmenite <- read_csv('data_input/minerals_posDBScan.csv') %>% # Read file and associate to an object
  dplyr::select(1,47,19,14,3,25:46) %>% # select and reorder the columns
  mutate(id = X1, X1 = NULL) %>% # Rename Column
  mutate(AS_ppm = ifelse(AS_ppm > 100, AS_ppm/10000, # Adjusting values of column
                         ifelse(AS_ppm > 50, AS_ppm/10, AS_ppm))) %>%
  mutate(AS = AS_ppm, AS_ppm = NULL, # Rename columns
         ROCK = `ROCK NAME`, `ROCK NAME` = NULL,
         SAMPLE = `SAMPLE NAME`, `SAMPLE NAME` = NULL) %>%
  filter(GROUP == 'ILMENITE') %>%
  dplyr::select(24,27, 1:2,26, 3:23,25) %>%# Reorder Columns
  sample_n(50, replace = FALSE) %>%
  distinct(.keep_all = TRUE)

# Apatite ----

apatite <- read_csv('data_input/minerals_posDBScan.csv') %>% # Read file and associate to an object
  dplyr::select(1,47,19,14,3,25:46) %>% # select and reorder the columns
  mutate(id = X1, X1 = NULL) %>% # Rename Column
  mutate(AS_ppm = ifelse(AS_ppm > 100, AS_ppm/10000, # Adjusting values of column
                         ifelse(AS_ppm > 50, AS_ppm/10, AS_ppm))) %>%
  mutate(AS = AS_ppm, AS_ppm = NULL, # Rename columns
         ROCK = `ROCK NAME`, `ROCK NAME` = NULL,
         SAMPLE = `SAMPLE NAME`, `SAMPLE NAME` = NULL) %>%
  filter(GROUP == 'APATITE') %>%
  dplyr::select(24,27, 1:2,26, 3:23,25) %>%# Reorder Columns
  sample_n(50, replace = FALSE) %>%
  distinct(.keep_all = TRUE)

# Titanite ----

titanite <- read_csv('data_input/minerals_posDBScan.csv') %>% # Read file and associate to an object
  dplyr::select(1,47,19,14,3,25:46) %>% # select and reorder the columns
  mutate(id = X1, X1 = NULL) %>% # Rename Column
  mutate(AS_ppm = ifelse(AS_ppm > 100, AS_ppm/10000, # Adjusting values of column
                         ifelse(AS_ppm > 50, AS_ppm/10, AS_ppm))) %>%
  mutate(AS = AS_ppm, AS_ppm = NULL, # Rename columns
         ROCK = `ROCK NAME`, `ROCK NAME` = NULL,
         SAMPLE = `SAMPLE NAME`, `SAMPLE NAME` = NULL) %>%
  filter(GROUP == 'TITANITE') %>%
  dplyr::select(24,27, 1:2,26, 3:23,25) %>%# Reorder Columns
  group_by(MINERAL) %>%
  sample_n(50,replace = FALSE) %>%
  distinct(.keep_all = TRUE)

# Zircon ----

zircon <- read_csv('data_input/minerals_posDBScan.csv') %>% # Read file and associate to an object
  dplyr::select(1,47,19,14,3,25:46) %>% # select and reorder the columns
  mutate(id = X1, X1 = NULL) %>% # Rename Column
  mutate(AS_ppm = ifelse(AS_ppm > 100, AS_ppm/10000, # Adjusting values of column
                         ifelse(AS_ppm > 50, AS_ppm/10, AS_ppm))) %>%
  mutate(AS = AS_ppm, AS_ppm = NULL, # Rename columns
         ROCK = `ROCK NAME`, `ROCK NAME` = NULL,
         SAMPLE = `SAMPLE NAME`, `SAMPLE NAME` = NULL) %>%
  filter(GROUP == 'ZIRCON') %>%
  dplyr::select(24,27, 1:2,26, 3:23,25) %>%# Reorder Columns
  sample_n(50,replace = FALSE) %>%
  distinct(.keep_all = TRUE)

# Perovskite ----

perovskite <- read_csv('data_input/minerals_posDBScan.csv') %>% # Read file and associate to an object
  dplyr::select(1,47,19,14,3,25:46) %>% # select and reorder the columns
  mutate(id = X1, X1 = NULL) %>% # Rename Column
  mutate(AS_ppm = ifelse(AS_ppm > 100, AS_ppm/10000, # Adjusting values of column
                         ifelse(AS_ppm > 50, AS_ppm/10, AS_ppm))) %>%
  mutate(AS = AS_ppm, AS_ppm = NULL, # Rename columns
         ROCK = `ROCK NAME`, `ROCK NAME` = NULL,
         SAMPLE = `SAMPLE NAME`, `SAMPLE NAME` = NULL) %>%
  filter(MINERAL == 'PEROVSKITE') %>%
  dplyr::select(24,27, 1:2,26, 3:23,25) %>%# Reorder Columns
  group_by(MINERAL) %>%
  sample_n(50,replace = FALSE) %>%
  distinct(.keep_all = TRUE)

# Pyroxenes ----
set.seed(42)
pyroxene <- read_csv('data_input/toSMOTE/pyroxene_model.csv') %>%
  select(-X1) %>%
  group_by(MINERAL) %>%
  sample_n(50,replace = TRUE) %>%
  distinct(.keep_all = TRUE)


#####
# JOINING DATA
#####

set.seed(42)
toSMOTE <- minerals %>%
  filter(GROUP != 'PYROXENE') %>%
  bind_rows(pyroxene,
            apatite,
            ilmenite,
            perovskite,
            quartz,
            titanite,
            zircon) %>%
  as_tibble() %>%
  filter(MINERAL != 'COBALTITE',
         MINERAL != 'GERSDORFFITE',
         MINERAL != 'GODLEVSKITE',
         MINERAL != 'GUANGLINITE',
         MINERAL != 'HEXATESTIBIOPANICKELITE',
         MINERAL != 'HOLLINGWORTHITE',
         MINERAL != 'LINNAEITE',
         MINERAL != 'MAUCHERITE',
         MINERAL != 'MARGARITE',
         MINERAL != 'NICKELINE',
         MINERAL != 'NONTRONITE',
         MINERAL != 'PARKERITE',
         MINERAL != 'VISHNEVITE',
         MINERAL != 'HUANGHOITE-(Ce)',
         MINERAL != 'IRARSITE',
         MINERAL != 'KAOLINITE',
         MINERAL != 'KHANNESHITE',
         MINERAL != 'MCKELVEYITE-(Y)',
         MINERAL != 'OLEKMINSKITE',
         MINERAL != 'MOLYBDENITE',
         MINERAL != 'QAQARSSUKITE-(Ce)',
         MINERAL != 'WITHERITE',
         MINERAL != 'PIRSSONITE',
         MINERAL != 'FERRORICHTERITE',
         MINERAL != 'MAGNESIOKATAPHORITE',
         MINERAL != 'GLAUCOPHANE',
         MINERAL != 'NORSETHITE',
         MINERAL != 'WINCHITE',
         MINERAL != 'CORDYLITE (SENSU LATO)',
         MINERAL != 'HORNBLENDE',
         MINERAL != 'CEBAITE-(Ce)',
         MINERAL != 'MAGNESIOARFVEDSONITE',
         MINERAL != 'BARROISITE',
         MINERAL != 'STRONTIANITE',
         MINERAL != 'FERRO-TSCHERMAKITE',
         MINERAL != 'ALSTONITE/BARYTOCALCITE/PARALSTONITE',
         MINERAL != 'JADEITE',
         MINERAL != 'ANTHOPHYLLITE')

write.csv(toSMOTE, 'data_input/minerals_balanced.csv')

contagem <- toSMOTE %>%
  group_by(MINERAL, GROUP) %>%
  count()

write.csv(contagem, 'references/listofminerals.csv')




