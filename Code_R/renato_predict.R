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
# Built-in Functions
#####
col.fillrate <- function(df, sort = F) { # Apresenta a proporção de dados preenchidos, por coluna
  require(dplyr)
  cols <- NULL
  clist <- data.frame(`Column.Name`= character(),
                      `Fill.Rate` = double(),
                      stringsAsFactors = F)
  
  for (c in 1:ncol(df)) {
    cols[c] <- (100*sum(!is.na(df[c]))/nrow(df[c]))
  }
  for (c in 1:ncol(df)) {
    clist[[c,1]]  <- paste0(names(df[c]))
    clist[[c,2]] <- round(cols[[c]],digits = 2)
  } 
  if (sort == F) {
    print(clist)
  } else {
    print(clist %>% arrange(desc(Fill.Rate)))
  }
}
#####
#Import Packages
#####

library(tidyverse)
library(missRanger)

#####
# PREPRARING DATA 
#####

# Listing files
files <- list.files(path = 'data_raw/OtherSources/renato',pattern = '*ANALYSIS.csv')

# Reading giles

r1 <- read_csv(paste0('data_raw/OtherSources/renato/',files[[1]]), skip_empty_rows = T, skip = 3) %>%
  slice(1) %>%
  mutate(MINERAL = 'ALBITE',
         GROUP = 'FELDSPAR',
         Comment = NULL) %>%
  select(1,19, 18, 2:17) 

r2 <- read_csv(paste0('data_raw/OtherSources/renato/',files[[2]]), skip_empty_rows = T, skip = 3) %>%
  slice(1) %>%
  mutate(MINERAL = 'ALBITE',
         GROUP = 'FELDSPAR',
         Comment = NULL) %>%
  select(1,19, 18, 2:17) 

renato <- r1 %>%
  bind_rows(r2)

renato[1:3] <- as_tibble(lapply(renato[1:3], as.factor))

renato <- renato %>%
  mutate(SIO2 = SiO2, SiO2 = NULL,
         NA2O = Na2O, Na2O = NULL,
         MGO = MgO, MgO = NULL,
         AL2O3 = Al2O3, Al2O3 = NULL,
         CL = Cl, Cl = NULL,
         CAO = CaO, CaO = NULL,
         TIO2 = TiO2, TiO2 = NULL,
         CR2O3 = Cr2O3, Cr2O3 = NULL,
         MNO = MnO, MnO = NULL,
         FEOT = FeO, FeO = NULL,
         NIO = NiO, NiO = NULL,
         H20 = 0,
         CUO = 0,
         COO = 0,
         ZNO = 0,
         PBO = 0,
         S = 0,
         ZRO2 = 0,
         AS = 0)

#####
# PREDICT 
#####

feldspar_rf <- readRDS('model_r/feldspar.RDS')

pred <- predict(feldspar_rf, renato[4:ncol(renato)])

tbl <- renato %>%
  bind_cols(as_tibble(pred)) %>%
  mutate(PREDICT = value, value = NULL) %>%
  select(1:3,28,4:27)

(mean(factor(tbl$MINERAL) == factor(tbl$PREDICT)))

write.csv(tbl, file = 'data_test/anderson_output.csv')
