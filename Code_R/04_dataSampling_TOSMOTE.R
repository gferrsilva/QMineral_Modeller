#####
# Data to SMOTE pos DBScan
# 
# 
# version: 0.1 
#
# Last modifications: * DBscan to remove outliers group by group
#                     * Recode mineral names according to IMA
#                     * Exclude non-minerals and irrelevant data from database
#                     
#
#
# -----
# Amphiboles, Apatites, Carbonates, Clay Minerals, Feldspars, Feldspathoides,
# Garnets, Ilmenites, Micas, Olivines, Perovskites, Pyroxenes, Quartz, Sulfides,
# Titanite, Zircon
# -----
# Guilherme Ferreira, (guilherme.ferreira@cprm.gov.br)
# December, 2020
#####

#####
# Setting up the enviroment
#####

setwd("~/GitHub/MinChem_Modeller") # Ajustando o work direction
url <- 'https://www.dropbox.com/s/tpts55k1imhvt30/minerals_posDBScan.csv?dl=1'
set.seed(123) # Ajustando o 'Random State' da maquina para reproduzir os codigos

#####
#Import Packages
#####

library(tidyverse) # Conjunto de bibliotecas em R que facilitam a manipulação e visualização de dados. Equivalente ao pandas, matplotlib, seaborn, etc
library(dbscan) # outlier detection
library(factoextra) # Cluster viz
library(smotefamily)
library(data.table)

#####
# DATA WRANGLING 
#####

pyroxene <- read_csv('data_input/pyroxene.csv') %>%
  select(-id)

sel <- names(pyroxene)

sel <- sel[c(-1,-2,-5)]

min <- read_csv(url,na = 'NA') %>% # importar o arquivo amphiboles.csv para um arquivo temporÃ¡rio df1
  # mutate(AS_ppm = ifelse(AS_ppm > 100, AS_ppm/10000, # Adjusting values of column
  #                        ifelse(AS_ppm > 50, AS_ppm/10, AS_ppm))) %>%
  # mutate(AS = AS_ppm, AS_ppm = NULL, # Rename columns
  #        ROCK = `ROCK NAME`, `ROCK NAME` = NULL,
  #        SAMPLE = `SAMPLE NAME`, `SAMPLE NAME` = NULL) %>%
  select(all_of(sel))
  

min <- min %>%
  bind_rows(pyroxene) %>%
  select(-ROCK, -SAMPLE,-X1)

remove(pyroxene, sel)

min <- min %>%
  group_by(MINERAL) %>%
  sample_n(50, replace = TRUE) %>%
  ungroup() %>%
  distinct()

table(min$MINERAL)

toSMOTE <- min %>%
  group_by(MINERAL) %>%
  mutate(count = n()) %>%
  filter(count >= 10) %>%
  ungroup() %>%
  select(-count) %>%
  filter(MINERAL != "AMPHIBOLE",
         MINERAL != "GARNET",
         MINERAL != 'SULFIDE',
         MINERAL != 'OLIVINE',
         MINERAL != 'MONOSULFIDE SOLID SOLUTION',
         MINERAL != 'MICA',
         MINERAL != 'CLAY MINERAL') %>%
  data.table()

table(toSMOTE$MINERAL)

toSMOTE[MINERAL == 'STILPNOMELANE', GROUP := 'STILPNOMELANE']

write.csv(x = toSMOTE,file = 'data_input/SMOTE/toSMOTE_posDBscan.csv')
