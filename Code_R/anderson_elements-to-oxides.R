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
files <- list.files(path = 'data_raw/OtherSources/anderson',pattern = '*.txt')

# Reading giles
anderson <- read_tsv(paste0('data_raw/OtherSources/anderson/',files)) %>%
  select(1:16) #%>%
  # mutate(`S(WT%)` = `S(WT%)`/100)

anderson[5:16] <- as_tibble(lapply(anderson[5:16], as.numeric))

anderson[is.na(anderson)] <- 0

# Converting Element to Oxides
anderson <- anderson %>%
  mutate(FEOT = 1.381978994*`FE(WT%)`, `FE(WT%)` = NULL,
         COO = 1.362026696*`CO(WT%)`, `CO(WT%)` = NULL,
         NIO = 1.272588445*`NI(WT%)`, `NI(WT%)` = NULL,
         CUO = 1.251877817*`CU(WT%)`, `CU(WT%)` = NULL,
         ZNO = 1.244709983*`ZN(WT%)`, `ZN(WT%)` = NULL,
         PBO = 1.077237962*`PB(WT%)`, `PB(WT%)` = NULL,
         MNO = 1.291155584*`MN(WT%)`, `MN(WT%)` = NULL,
         AS = `AS(WT%)`, `AS(WT%)` = NULL,
         S = `S(WT%)`, `S(WT%)` = NULL,
         `AG(WT%)` = NULL,
         `SB(WT%)` = NULL,
         `AU(WT%)` = NULL,
         SIO2 = 0,
         TIO2 = 0,
         AL2O3 = 0,
         CAO = 0,
         MGO = 0,
         K2O = 0,
         NA2O = 0,
         P2O5 = 0,
         H2O = 0,
         `F` = 0,
         CL = 0,
         ZRO2 = 0,
         CR2O3 = 0,
         H20 = 0)

#####
# SAVING DATA 
#####

# Folder 'data_test'
write.csv(anderson, file = 'data_test/anderson.csv')

#####
# PREDICT 
#####

sulfides_rf <- readRDS('model_r/sulfide.RDS')

pred <- predict(sulfides_rf, anderson[5:27])

tbl <- anderson %>%
  bind_cols(as_tibble(pred)) %>%
  select(1:3,28,4:27)

(mean(tbl$MINERAL == tbl$value))

write.csv(tbl, file = 'data_test/anderson_output.csv')
