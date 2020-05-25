#####
# Converting elements to oxides
# 
# version: 1.0 (2020/05/20)
#
# Last modifications:
#
# -----
# Source: Sulfetos do Evandro
# -----
# Guilherme Ferreira, (guilherme.ferreira@cprm.gov.br)
# May, 2020
#####

#####
# Setting up the enviroment
#####

setwd('C:/Users/GUILHERMEFERREIRA-PC/Documents/GitHub/MinChem_Modeller')
set.seed(123)

#####
#Import Packages
#####

library(tidyverse)
library(missRanger)

#####
# PREPRARING DATA 
#####

# Listing files
files <- list.files(path = 'data_raw/OtherSources/evandro',pattern = 'sulfides')

# Reading giles
evandro <- sapply(paste0('data_raw/OtherSources/evandro/',files), read_tsv) %>%
  bind_rows()

# Missing Value Imputation
evandro <- missRanger(evandro, pmm.k = 3, num.trees = 100)

# Converting Element to Oxides
evandro <- evandro %>%
  mutate(WO3 = 1.261034048*W, W = NULL,
         FEO = 1.381978994*Fe, Fe = NULL,
         COO = 1.362026696*Co, Co = NULL,
         NIO = 1.272588445*Ni, Ni = NULL,
         CUO = 1.251877817*Cu, Cu = NULL,
         ZNO = 1.244709983*Zn, Zn = NULL,
         BI2O3 = 1.114827202*Bi, Bi = NULL,
         MOO = 1.500375094*Mo, Mo = NULL,
         PBO = 1.077237962*Pb, Pb = NULL,
         CR2O3 = 1.461560947*Cr, Cr = NULL,
         V2O3 = 1.471237311*V, V = NULL,
         MNO = 1.291155584*Mn, Mn = NULL,
         CDO = 1.142334933*Cd, Cd = NULL,
         HGO = 1.079796998*Hg, Hg = NULL) %>%
  select(1:3, 12:25, 4:11)

# Preparing data to match the model's variables
evandro <- evandro %>%
  mutate(V2O3 = NULL,
         WO3 = NULL,
         BI2O3 = NULL,
         MOO = NULL,
         CDO = NULL,
         HGO = NULL,
         Te = NULL,
         AS = As, As = NULL,
         Sb = NULL,
         Se = NULL,
         NA2O = 0,
         MGO = 0,
         AL2O3 = 0,
         SIO2 = 0,
         CAO = 0,
         CL = 0,
         TIO2 = 0,
         FEOT = FEO, FEO = NULL,
         X1 = NULL,
         P2O5 = 0,
         H20 = 0,
         ZRO2 = 0,
         K2O = 0,
         `F` = 0) 
#####
# SAVING DATA 
#####

# Folder 'data_test'
write.csv(evandro, file = 'data_test/evandro.csv')
