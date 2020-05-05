#####
# Data wrangling and primary classifier of mica
# Guilherme Ferreira, (guilherme.ferreira@cprm.gov.br)
# April, 2020
#####
# Setting up the enviroment
#####
setwd("C:/Users/GUILHERMEFERREIRA-PC/Documents/GitHub/MinChem_Modeller")
set.seed(123)

#####
#Import Packages
#####
library(Cairo)
library(tidyverse)
library(corrplot)
library(reshape2)
library(ggthemes)
library(randomForest)
library(caret)
# library(ggtern)

#####
# Built-in Functions
#####
col.fillrate <- function(df, sort = F) {
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
# DATA WRANGLING 
#####


# Import data

df1 <- as_tibble(read_csv('csv_files/MICA.csv'),n_max = 35035)
df1 <- df1[1:35035,]

## Verifying the fill rate of columns and rows

col.fillrate(df1, sort = T)

# rows <- NULL
# 
# for (r in 1:nrow(df1)) {
#   rows[r] <- (100 - 100*(sum(is.na(df1[r,])))/ncol(df1))
# }

## Subsect dataframe
mica <- df1 %>%
  select(1:89) %>%
  filter(!is.na(`SIO2(WT%)`))# %>%
#filter(!is.na(`NA2O(WT%)`)) %>%
#filter(!is.na(`K2O(WT%)`)) 

# Split label and variables
labels <- mica[1:23]
mica_labels <- labels %>%
  select(`SAMPLE NAME`, `ROCK NAME`, `MINERAL`)

mica_elems <- mica[24:ncol(mica)]

mica_elems <- mica_elems %>%
  select_if(~sum(!is.na(.x)) >= (.5 * nrow(mica_elems)))

###Renaming the columns and fixing class -----
names(mica_elems) <- c('SiO2','TiO2','Al2O3','Cr2O3','FeOT','CaO','MgO','MnO','K2O','Na2O','F')
mica_elems <- sapply(mica_elems, as.numeric)

###Dataframe df_mica -----
df_mica <- bind_cols(mica_labels, as_tibble(mica_elems))
df_mica <- na.omit(df_mica)

## Principal componente Analysis -----

pca <- prcomp(df_mica[4:14],center = T,scale. = T,)

summary(pca)

### Appending PCA results to df_mica df -----
df_mica <- bind_cols(na.omit(df_mica), as_tibble(pca$x))

# Count the number of samples by rock name -----
df_mica %>%
  group_by(`MINERAL`) %>%
  count(sort = T)

# Fixing the class of a column -----
df_mica$MINERAL <- as.factor(df_mica$MINERAL)

# Wrting file of selected samples -----
write_csv(df_mica, path = 'selected_df_mica.csv')

#####
# Machine Learning
#####


#####
# References
#####
