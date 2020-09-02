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
setwd("C:/Users/GUILHERMEFERREIRA-PC/Documents/GitHub/MinChem_Modeller") # defining the work direction
set.seed(123) # defining the 'random state' of the pseudo-random generator

#####
# Import Packages
#####
library(Cairo) # Export figures
library(tidyverse) # Collection of libraries: dplyr, ggplot2, purrr, tidyr. Data wrangling and visualizing
library(ggthemes) # Predefined themes
library(readxl)
library(writexl)
library(missRanger)

px <- read_csv('data_input/pyroxene_rf.csv',skip_empty_rows = T) %>% # Read file and associate to an object
  select(3,14,47, 19, 25:46)

names(px) <- c('Sample', 'Rock', 'Group', 'Mineral', 'SiO2', 'TiO2', 'Al2O3', 'Cr2O3', 'FeOt', 'CaO', 'MgO', 'MnO', 'K2O', 'Na2O', 'P2O5', 'H2O', 'F', 'Cl', 'NiO', 'CuO', 'CoO', 'ZnO', 'As', 'PbO', 'S', 'ZrO2')


raissa <- read_excel(path = 'data_raw/OtherSources/raissa/raissa.xlsx',sheet = 2) %>%
  select(-44)

names(raissa) <- c('Sample', 'Mineral',"SiO2",
                   "TiO2","Al2O3","FeOt","MgO",
                   "MnO","CaO","Na2O","K2O",
                   "Total","TSi","TAl","M1Al",
                   "M1Ti","M1Fe2","M1Mg","M2Fe2",
                   "M2Mn","M2Ca","M2Na","M2K",
                   "Cations","XMg")

# raissa <- raissa %>%
#   filter(Mineral == 'Hedenbergite')
#   filter(Mineral == 'Diopside')

index <- sample(1:nrow(raissa),replace = F,size = 15)

train <- raissa[-index,]
test <- raissa[index,]

test[,12:25] <- NA

df <- train %>%
  bind_rows(test)
raissa1 <- missRanger(df,pmm.k = 5)

raissa1[34:48,]
residuo <- (raissa1[34:48,12:25] - raissa[index,12:25])

(residuo)

erro <- as_tibble(NULL)

for(c in seq_along(residuo)) {
erro[c,1] <- names(residuo[c])
erro[c,2] <- sqrt(sum(residuo[c]^2)/nrow(residuo[c]))
}


