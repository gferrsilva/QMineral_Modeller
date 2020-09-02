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

# Lista de elementos a ser selecionados do banco de dados original
selection <- c('SIO2(WT%)', 'TIO2(WT%)', 'AL2O3(WT%)', 'CR2O3(WT%)', 
               'FEOT(WT%)','CAO(WT%)','MGO(WT%)','MNO(WT%)','K2O(WT%)',
               'NA2O(WT%)','P2O5(WT%)','H2O(WT%)','F(WT%)','CL(WT%)',
               'NIO(WT%)','CUO(WT%)','COO(WT%)','ZNO(WT%)','AS(PPM)',
               'PBO(WT%)','S(WT%)','ZRO2(WT%)')

# Simplifcação dos elementos electionados acima
elems_names <- c('SIO2','TIO2','AL2O3','CR2O3','FEOT','CAO',
                 'MGO','MNO','K2O','NA2O','P2O5','H20','F','CL',
                 'NIO','CUO','COO','ZNO','AS_ppm','PBO','S','ZRO2')
#####
# Import Packages
#####
library(Cairo) # Export figures
library(tidyverse) # Collection of libraries: dplyr, ggplot2, purrr, tidyr. Data wrangling and visualizing
library(ggthemes) # Predefined themes
library(caret) # Machine Learning Toolkit
library(randomForest) # Random Forest library
library(factoextra) # Deal with PCA and PCA datavis
library(missRanger)

cpx <- read_csv('data_RAW/GEOROC/CLINOPYROXENES.csv', n_max = 40906,progress = T,skip_empty_rows = T) # Read file and associate to an object
opx <- read_csv('data_RAW/GEOROC/ORTHOPYROXENES.csv', n_max = 44841) # Read file and associate to an object
px_blind <- read_csv('data_RAW/GEOROC/PYROXENES.csv', n_max = 15056) # Read file and associate to an object

#####
# OPX Wrangling
#####

opx <- opx %>%
  # select(1:89) %>%
  filter(!is.na(`SIO2(WT%)`))

opx_labels <- opx[1:23]

opx_elems <- opx %>%
  mutate(`PBO(WT%)` = 0,
         `CUO(WT%)` = 0,
         `S(WT%)` = 0) %>%
         #`AS(PPM)` = 0) %>%
  #        `ZN(WT%)` = NA,
  #        `AS(WT%)` = NA,
  #        `PB(WT%)` = NA) %>%
  select(all_of(selection))

names(opx_elems) <- elems_names

opx_elems <- sapply(opx_elems,as.numeric)
opx_elems <- as_tibble(opx_elems)

opx_elems1 <- missRanger(opx_elems, pmm.k = 3, num.trees = 100, verbose = 2)

opx <- as_tibble(cbind(opx_labels,opx_elems1)) %>%
  mutate(GROUP = 'PYROXENE') %>%
  mutate(id = row_number()) %>%
  mutate(SPOT = as.character(SPOT)) %>%
  select(47,1:46) %>%
  select(1,47,19,14,3,25:46) %>% # select and reorder the columns
  mutate(AS_ppm = ifelse(AS_ppm > 100, AS_ppm/10000, # Adjusting values of column
                         ifelse(AS_ppm > 50, AS_ppm/10, AS_ppm))) %>%
  mutate(AS = AS_ppm, AS_ppm = NULL, # Rename columns
         ROCK = `ROCK NAME`, `ROCK NAME` = NULL,
         SAMPLE = `SAMPLE NAME`, `SAMPLE NAME` = NULL) %>%
  select(1,27,2,3,26,4:25) # Reorder Columns

remove(opx_elems,opx_elems1,opx_labels)

opx1 <- opx %>%
  filter(MINERAL != 'ORTHOPYROXENE',
         MINERAL != 'BRONZITE',
         MINERAL != 'FERROHYPERSTHENE') %>%
         filter(!is.na(MINERAL))
         
opx_blind <- opx %>%
  filter(MINERAL == 'ORTHOPYROXENE')

#####
# CPX Wrangling
#####

cpx <- cpx %>%
  # select(1:89) %>%
  filter(!is.na(`SIO2(WT%)`))

cpx_labels <- cpx[1:23]

cpx_elems <- cpx %>%
  mutate(`PBO(WT%)` = 0,
         `CUO(WT%)` = 0,
         `S(WT%)` = 0) %>%
  #`AS(PPM)` = 0) %>%
  #        `ZN(WT%)` = NA,
  #        `AS(WT%)` = NA,
  #        `PB(WT%)` = NA) %>%
  select(all_of(selection))

names(cpx_elems) <- elems_names

cpx_elems <- sapply(cpx_elems,as.numeric)
cpx_elems <- as_tibble(cpx_elems)

cpx_elems1 <- missRanger(cpx_elems, pmm.k = 3, num.trees = 100, verbose = 2)

cpx <- as_tibble(cbind(cpx_labels,cpx_elems1)) %>%
  mutate(GROUP = 'PYROXENE') %>%
  mutate(SPOT = as.character(SPOT))

cpx <- as_tibble(cbind(cpx_labels,cpx_elems1)) %>%
  mutate(GROUP = 'PYROXENE') %>%
  mutate(id = row_number()) %>%
  mutate(SPOT = as.character(SPOT)) %>%
  select(47,1:46) %>%
  select(1,47,19,14,3,25:46) %>% # select and reorder the columns
  mutate(AS_ppm = ifelse(AS_ppm > 100, AS_ppm/10000, # Adjusting values of column
                         ifelse(AS_ppm > 50, AS_ppm/10, AS_ppm))) %>%
  mutate(AS = AS_ppm, AS_ppm = NULL, # Rename columns
         ROCK = `ROCK NAME`, `ROCK NAME` = NULL,
         SAMPLE = `SAMPLE NAME`, `SAMPLE NAME` = NULL) %>%
  select(1,27,2,3,26,4:25) # Reorder Columns

remove(cpx_elems,cpx_elems1,cpx_labels)

cpx1 <- cpx %>%
  filter(MINERAL != 'CLINOPYROXENE') %>%
  filter(!is.na(MINERAL)) %>%
  mutate(AS = 0)

cpx_blind <- cpx %>%
  filter(MINERAL == 'CLINOPYROXENE') %>%
  mutate(AS = 0)


#####
# PX_Blind Wrangling
#####

px_blind <- px_blind %>%
  # select(1:89) %>%
  filter(!is.na(`SIO2(WT%)`))

px_blind_labels <- px_blind[1:23]

px_blind_elems <- px_blind %>%
  mutate(`PBO(WT%)` = 0,
         `CUO(WT%)` = 0,
         `S(WT%)` = 0,
         `COO(WT%)` = 0) %>%
  select(all_of(selection))

names(px_blind_elems) <- elems_names

px_blind_elems <- sapply(px_blind_elems,as.numeric)
px_blind_elems <- as_tibble(px_blind_elems)

px_blind_elems1 <- missRanger(px_blind_elems, pmm.k = 3, num.trees = 100, verbose = 2)

px_blind <- as_tibble(cbind(px_blind_labels,px_blind_elems1)) %>%
  mutate(GROUP = 'PYROXENE') %>%
  mutate(SPOT = as.character(SPOT))

px_blind <- as_tibble(cbind(px_blind_labels,px_blind_elems1)) %>%
  mutate(GROUP = 'PYROXENE') %>%
  mutate(id = row_number()) %>%
  mutate(SPOT = as.character(SPOT)) %>%
  select(47,1:46) %>%
  select(1,47,19,14,3,25:46) %>% # select and reorder the columns
  mutate(AS_ppm = ifelse(AS_ppm > 100, AS_ppm/10000, # Adjusting values of column
                         ifelse(AS_ppm > 50, AS_ppm/10, AS_ppm))) %>%
  mutate(AS = AS_ppm, AS_ppm = NULL, # Rename columns
         ROCK = `ROCK NAME`, `ROCK NAME` = NULL,
         SAMPLE = `SAMPLE NAME`, `SAMPLE NAME` = NULL) %>%
  select(1,27,2,3,26,4:25) # Reorder Columns

px_blind <- px_blind %>%
  mutate(AS = 0)

remove(px_blind_elems,px_blind_elems1,px_blind_labels)



#####
# OPX Random Forest
#####

input <- opx1 %>% # manipulating the minerals database and associate the answer with input object
  group_by(MINERAL) %>% # grouping the instances by the mineral 'GROUP' class
  sample_n(30, replace = T) # sampling 300 instances of each 'GROUP', with replacement

index <- createDataPartition(input$MINERAL, p = 0.7, list = FALSE) # Train-test split using an index
train_data <- input[as.vector(index), c(4,6:27)] # Selecting the train_data (GROUP + PCA)
test_data  <- input[-index, 6:27]  # Selecting the test_data (PCA)
y_test <- as_tibble(input[-index,4])  # Selecting the test_classes (GROUP)

## Random Forest Setting up

ctrl <- trainControl(method = "repeatedcv",#classProbs = T, # Setting up the RF hyperparameters
                     number = 5,   # Number of folds on cross validation
                     repeats = 5, # Number of repeats on every fold
                     verboseIter = T, # Output the result of every iteration on the console
                     sampling = "up") # upsampling instances with unbalanced classes

## Model Fit

opx_rf_over <- caret::train(MINERAL ~ ., # training the model
                                data = train_data, # data for training
                                method = "rf", # method choosen for traininf
                                preProcess = c("scale", "center"), # Pre-process
                                trControl = ctrl, ntree = 150)#, type = 'prob') # Defines the hyperparameters

print(opx_rf_over) # Print on the console the summary of the model

#### Test

pred <- as_tibble(predict(opx_rf_over, test_data)) # predict the classes of the test set

confusionMatrix(pred$value, factor(y_test$MINERAL)) # confusion matrix printed out on the console
(accuracy_m1 = mean(y_test == pred)) # associate the accuracy to an object

#### Blind

pred1 <- as_tibble(predict(opx_rf_over, opx_blind)) # predict the classes of the test set

opx_blind <- opx_blind %>%
  mutate(MINERAL = pred1$value,
         id = factor(id))

opx_rf <- opx1 %>%
  mutate(id = factor(id)) %>%
  bind_rows(opx_blind)


#####
# CPX Random Forest
#####

input <- cpx1 %>% # manipulating the minerals database and associate the answer with input object
  group_by(MINERAL) %>% # grouping the instances by the mineral 'GROUP' class
  sample_n(30, replace = T) # sampling 300 instances of each 'GROUP', with replacement

index <- createDataPartition(input$MINERAL, p = 0.7, list = FALSE) # Train-test split using an index
train_data <- input[as.vector(index), c(4,6:27)] # Selecting the train_data (GROUP + PCA)
test_data  <- input[-index, 6:27]  # Selecting the test_data (PCA)
y_test <- as_tibble(input[-index,4])  # Selecting the test_classes (GROUP)

## Random Forest Setting up

ctrl <- trainControl(method = "repeatedcv",#classProbs = T, # Setting up the RF hyperparameters
                     number = 5,   # Number of folds on cross validation
                     repeats = 5, # Number of repeats on every fold
                     verboseIter = T, # Output the result of every iteration on the console
                     sampling = "up") # upsampling instances with unbalanced classes

## Model Fit

cpx_rf_over <- caret::train(MINERAL ~ ., # training the model
                            data = train_data, # data for training
                            method = "rf", # method choosen for traininf
                            preProcess = c("scale", "center"), # Pre-process
                            trControl = ctrl, ntree = 150)#, type = 'prob') # Defines the hyperparameters

print(cpx_rf_over) # Print on the console the summary of the model

#### Test

pred <- as_tibble(predict(cpx_rf_over, test_data)) # predict the classes of the test set

confusionMatrix(pred$value, factor(y_test$MINERAL)) # confusion matrix printed out on the console
(accuracy_m1 = mean(y_test == pred)) # associate the accuracy to an object

#### Blind

pred1 <- as_tibble(predict(cpx_rf_over, cpx_blind)) # predict the classes of the test set

cpx_blind <- cpx_blind %>%
  mutate(MINERAL = pred1$value,
         id = factor(id))

cpx_rf <- cpx1 %>%
  mutate(id = factor(id)) %>%
  bind_rows(cpx_blind)


#####
# Predicting PX_Blind
#####

pyroxene <- opx_rf %>%
  bind_rows(cpx_rf)

write.csv(pyroxene, 'data_input/pyroxene.csv')

# input <- pyroxene %>% # manipulating the minerals database and associate the answer with input object
#   group_by(MINERAL) %>% # grouping the instances by the mineral 'GROUP' class
#   sample_n(30, replace = T) # sampling 300 instances of each 'GROUP', with replacement

index <- createDataPartition(input$MINERAL, p = 0.7, list = FALSE) # Train-test split using an index
train_data <- input[as.vector(index), c(4,6:27)] # Selecting the train_data (GROUP + PCA)
test_data  <- input[-index, 6:27]  # Selecting the test_data (PCA)
y_test <- as_tibble(input[-index,4])  # Selecting the test_classes (GROUP)

## Random Forest Setting up

ctrl <- trainControl(method = "repeatedcv",#classProbs = T, # Setting up the RF hyperparameters
                     number = 5,   # Number of folds on cross validation
                     repeats = 5, # Number of repeats on every fold
                     verboseIter = T, # Output the result of every iteration on the console
                     sampling = "up") # upsampling instances with unbalanced classes

## Model Fit

pyroxene_rf_over <- caret::train(MINERAL ~ ., # training the model
                            data = train_data, # data for training
                            method = "rf", # method choosen for traininf
                            preProcess = c("scale", "center"), # Pre-process
                            trControl = ctrl, ntree = 150)#, type = 'prob') # Defines the hyperparameters

print(pyroxene_rf_over) # Print on the console the summary of the model

#### Test

pred <- as_tibble(predict(pyroxene_rf_over, test_data)) # predict the classes of the test set

confusionMatrix(pred$value, factor(y_test$MINERAL)) # confusion matrix printed out on the console
(accuracy_m1 = mean(y_test == pred)) # associate the accuracy to an object

#### Blind

pred1 <- as_tibble(predict(pyroxene_rf_over, px_blind)) # predict the classes of the test set

px_blind <- px_blind %>%
  mutate(MINERAL = pred1$value,
         id = factor(id))

pyroxene_rf <- pyroxene %>%
  mutate(id = factor(id)) %>%
  bind_rows(px_blind)

# Saving the final model ----

export <- pyroxene %>%
  group_by(MINERAL) %>%
  sample_n(30, replace = T)

write.csv(export, 'data_input/pyroxene_model.csv')

saveRDS(pyroxene_rf_over, 'model_r/pyroxene.RDS')

#### Merging Datasets

pca <- prcomp(pyroxene[6:27], center = T)

fviz_pca_var(pca,
             col.var = "contrib", # Color by contributions to the PC
             gradient.cols = c("#00AFBB", "#E7B800", "#FC4E07"),
             repel = TRUE)     # Avoid text overlapping

(biplot <- fviz_pca_biplot(pca, 
                palette = "jco", 
                addEllipses = F, label = "var")
)

pyroxene <- pyroxene %>%
  bind_cols(as_tibble(pca$x)) %>%
  mutate(x1 = NULL)

#####
# Data Visualization
#####

# Spatialization of Test Set ----

(p.testset <- ggplot(pyroxene %>%
                       group_by(MINERAL) %>%
                       sample_frac(.1),                                  # Spatialization of Test set
                     aes(x = PC1, y = PC2, col = MINERAL, shape = MINERAL, fill = MINERAL)) + # Coordinates
   geom_point(alpha = .7) + coord_equal() +               # Plot data as points
   theme(legend.text = element_text(size = 7)) +          # Defines the size of the font legend
   guides(col = guide_legend(ncol = 1)) +                 # Legend shown in one unique column
   scale_shape_manual(values = c(17, 17, 18, 19,
                                 16, 17, 18, 19,
                                 16, 17, 18, 19,
                                 16, 17, 18, 19,
                                 16, 17, 18, 19,
                                 16, 17, 18, 19,
                                 16, 17, 18, 19,
                                 16, 17, 18, 19,
                                 16, 17, 18, 19)) +
   scale_color_manual(values = c(                         # Defines the colors of each class, by order
     "dodgerblue2", "#E31A1C", # red
     "green4",
     "#6A3D9A", # purple
     "#FF7F00", # orange
     "black", "gold1",
     "skyblue2", "#FB9A99", # lt pink
     "palegreen2",
     "#CAB2D6", # lt purple
     "#FDBF6F", # lt orange
     "gray70", "khaki2",
     "maroon", "orchid1", "deeppink1", "blue1", "steelblue4",
     "darkturquoise", "green1", "yellow4", "yellow3",
     "#CAB2D6", # lt purple
     "#FDBF6F", # lt orange
     "gray70", "khaki2",
     "maroon", "orchid1", "deeppink1", "blue1", "steelblue4",
     "darkturquoise", "green1", "yellow4", "yellow3",
     "darkorange4", "brown"
   )))


# Confusion Matrix ----

c <- confusionMatrix(pred$value, factor(y_test$MINERAL)) # building the y axis of the confusion matrix
t <- confusionMatrix(factor(y_test$MINERAL), factor(y_test$MINERAL)) # building the x axis of the confusion matrix

heat <- as_tibble(c$table) # access the values of c
true <- as_tibble(t$table) # access the values of t

plotTable <- heat %>%
  mutate(goodbad = ifelse(heat$Prediction == heat$Reference, "good", "bad")) %>% # defines if a prediction was 'good' or 'bad'
  group_by(Reference) %>% # groups the values by 'Reference' (aka Actual Values)
  mutate(prop = n/sum(n)) # calculates the proportion of good/bad predictions on every cell of the matrix

plotTable$prop[is.nan(plotTable$prop)] <- 0 # if there is any NaN value on any cell of the matrix, defines it as zero

min <- as_tibble(cbind(y_test, test_data, pred)) # creates a database with true_values of the test, test data and prediction for the test

(p.confmatrx <- ggplot(data = plotTable, 
                       aes(
                         x = Reference,
                         y = Prediction,
                         fill = goodbad
                       )
) +
    geom_tile(aes(alpha = prop)) +
    geom_text(aes(label = round(prop, 1)), size = 3) +
    scale_fill_manual(values =
                        c(good = "green",
                          bad = "red")
    ) +
    theme_bw() + coord_equal() + guides(fill = F) +
    labs(title = 'Pyroxenes classification - Random Forest (Test Set)', subtitle = paste0('N.Samples = 30 for each mineral, N.Trees = 150, 70-30% split, 5-fold, Accuracy: ', 100*round(accuracy_m1,digits = 2),'%')) +
    theme(axis.text.x = element_text(
      angle = 90, vjust = .5, hjust = 1, size = 7),
      axis.text.y = element_text(size = 7),
      legend.position = 'none')
)

CairoPDF(file = 'figures/R_RF_Pyroxene_Model', width = 9, height = 8) # Creates a PDF file and addresses a name/path
print(biplot)
print(p.testset) # First Page, Test Set Spatialization
print(p.confmatrx) # Second Page, Confusion Matrix
dev.off() # Figure device Off
