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
library(readxl)
library(caret) # Machine Learning Toolkit
library(randomForest) # Random Forest library

#####
# PREPRARING DATA 
#####

# Listing files
plag_list <- list.files(path = 'data_raw/OtherSources/rafael', pattern = 'PLAG')
grt_list <- list.files(path = 'data_raw/OtherSources/rafael', pattern = 'GRANAD')
mica_list <- list.files(path = 'data_raw/OtherSources/rafael', pattern = 'MICA')

# Reading files
plag <- sapply(paste0('data_raw/OtherSources/rafael/',plag_list), read_excel, sheet = 1, skip = 3) %>%
  bind_rows() %>%
  select(1:15) %>%
  filter(No. != 'Maximum',
         No. != 'Minimum',
         No. != 'Average',
         No. != 'Sigma',
         No. != 'No. of data   110',
         No. != 'No. of data   108',
         No. != 'No. of data   139',
         !is.na(No.),
         Al2O3 > 1) %>%
  select(1,15,14,2:13) %>%
  mutate(GROUP = 'PLAGIOCLASE',
         FEOT = FeO, FeO = NULL)

grt <- sapply(paste0('data_raw/OtherSources/rafael/',grt_list), read_excel, sheet = 1, skip = 3) %>%
  bind_rows() %>%
  select(1, 14, 13, 2:12,15) %>%
  filter(No. != 'Maximum',
         No. != 'Minimum',
         No. != 'Average',
         No. != 'Sigma',
         No. != 'No. of data   110',
         No. != 'No. of data   108',
         No. != 'No. of data   139',
         !is.na(No.),
         Al2O3 > 1) %>%
  mutate(GROUP = 'GARNET')

mica <- sapply(paste0('data_raw/OtherSources/rafael/',mica_list), read_excel, sheet = 1, skip = 3) %>%
  bind_rows() %>%
  select(1, 17, 16, 2:15) %>%
  filter(No. != 'Maximum',
         No. != 'Minimum',
         No. != 'Average',
         No. != 'Sigma',
         No. != 'No. of data   110',
         No. != 'No. of data   108',
         No. != 'No. of data   139',
         !is.na(No.),
         Al2O3 > 1) %>%
  mutate(FEOT = FeO, FeO = NULL,
         OH = `(OH)`, `(OH)` = NULL,
         GROUP = 'MICA')

# Missing Value Imputation
grt[4:15] <- missRanger(grt[4:15], pmm.k = 3, num.trees = 100, verbose = T, returnOOB = T)

# Preparing data to match the model's variables
grt <- grt %>%
  mutate(SIO2 = SiO2, SiO2 = NULL,
         NA2O = Na2O, Na2O = NULL,
         MGO = MgO, MgO = NULL,
         AL2O3 = Al2O3, Al2O3 = NULL,
         CAO = CaO, CaO = NULL,
         CL = 0,
         TIO2 = TiO2, TiO2 = NULL,
         FEOT = FeO, FeO = NULL,
         P2O5 = 0,
         H20 = 0,
         ZRO2 = 0,
         K2O = 0,
         `F` = 0,
         CR2O3 = Cr2O3, Cr2O3 = NULL,
         NIO = NiO, NiO = NULL,
         MNO = MnO, MnO = NULL,
         CUO = 0,
         COO = 0,
         ZNO = 0,
         H20 = 0,
         PBO = 0,
         S = 0,
         AS = 0)


names(plag) <- toupper(names(plag))
names(grt) <- toupper(names(grt))
names(mica) <- toupper(names(mica))

minerals <- grt %>%
  bind_rows(plag, mica)

#####
# PREDICT 
#####

garnet_rf <- readRDS('model_r/garnet.RDS')

pred <- predict(garnet_rf, grt[4:ncol(grt)])

grt <- grt %>%
  bind_cols(as_tibble(pred)) %>%
  select(1:3, 6, 4:5, 7:31)




train <- read_csv('data_input/minerals_balanced.csv') %>% # Read file and associate to an object
  mutate(X1 = NULL, X1_1 = NULL, X1_2 = NULL, H20 = NULL)

train_data <- train %>% # Selecting the train_data (GROUP + PCA)
  select(3, 6:26)

## Random Forest Setting up

ctrl <- trainControl(method = "repeatedcv",classProbs = T, # Setting up the RF hyperparameters
                     number = 2,   # Number of folds on cross validation
                     repeats = 2, # Number of repeats on every fold
                     verboseIter = T, # Output the result of every iteration on the console
                     sampling = "up") # upsampling instances with unbalanced classes

## Model Fit

model_rf_over <- caret::train(GROUP ~ ., # training the model
                              data = train_data, # data for training
                              method = "rf", # method choosen for traininf
                              preProcess = c("scale", "center"), # Pre-process
                              trControl = ctrl, ntree = 150, type = 'prob') # Defines the hyperparameters

print(model_rf_over) # Print on the console the summary of the model

minerals <- minerals %>%
  mutate_if(is.numeric, replace_na, 0) %>%
  select(1:3, 6, 4:5, 7:30)

pred <- as_tibble(predict(model_rf_over, minerals)) # predict the classes of the test set

minerals <- minerals %>%
  bind_cols(as_tibble(pred)) %>%
  select(1:4, 31, 5:30)

mica_rf <- readRDS('./model_r/mica.RDS')
garnet_rf <- readRDS('./model_r/garnet.RDS')
feldspar_rf <- readRDS('./model_r/feldspar.RDS')


mica <- minerals %>%
  filter(GROUP == 'MICA')

garnet <- minerals %>%
  filter(GROUP == 'GARNET')

feldspar <- minerals %>%
  filter(GROUP == 'PLAGIOCLASE')

mica_prob <- as_tibble(predict(mica_rf, mica,type = 'prob')) # predict the classes of the test set
mica_pred <- as_tibble(predict(mica_rf, mica)) # predict the classes of the test set
garnet_pred <- as_tibble(predict(garnet_rf, garnet)) # predict the classes of the test set
felds_pred <- as_tibble(predict(feldspar_rf, feldspar)) # predict the classes of the test set


mica_prob_l <- mica_prob %>%
  mutate(id = row_number()) %>%
  group_by(id) %>%
  gather(key = 'MINERALS', value = 'PROB', 1:17)

mica_prob_l <- mica_prob_l %>%
  order_by(desc(id, PROB))
mica <- bind_cols(mica, as_tibble(mica_pred))
garnet <- bind_cols(garnet, as_tibble(garnet_pred))
feldspar <- bind_cols(feldspar, as_tibble(felds_pred))

minerals <- mica %>%
  bind_rows(garnet, feldspar) %>%
  mutate(GROUP_PRED = value, value = NULL,
         MINERAL_PRED = value1, value1 = NULL) %>%
  select(1:4, 31:32, 5:30)

write_csv(minerals, 'data_test/rafael.csv')
