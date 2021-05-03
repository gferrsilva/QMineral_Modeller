#####
# Mineral Group Classification by Random Forest
# 
# version: 1.0 (2020/05/20)
#
# Last modifications:
#
# -----
# Amphiboles, Apatites, Carbonates, Clay Minerals, Feldspathoides, Feldspathoides,
# Feldspathoides, Ilmenites, Micas, Olivines, Perovskites, Pyroxenes, Quartz, Sulfides,
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

minerals <- read_csv('data_input/minerals_posDBScan.csv') %>% # Read file and associate to an object
  select(1,47,19,14,3,25:46) %>% # select and reorder the columns
  mutate(id = X1, X1 = NULL) %>% # Rename Column
  mutate(AS_ppm = ifelse(AS_ppm > 100, AS_ppm/10000, # Adjusting values of column
                         ifelse(AS_ppm > 50, AS_ppm/10, AS_ppm))) %>%
  mutate(AS = AS_ppm, AS_ppm = NULL, # Rename columns
         ROCK = `ROCK NAME`, `ROCK NAME` = NULL,
         SAMPLE = `SAMPLE NAME`, `SAMPLE NAME` = NULL) %>%
  filter(GROUP == 'FELDSPATHOID') %>%
  select(24,27, 1:2,26, 3:23,25) # Reorder Columns

minerals$MINERAL <- minerals$MINERAL %>%
  replace_na('FELDSPATHOID')

foid <- minerals %>%
  filter(MINERAL != 'FELDSPATHOID')

blind <- minerals %>%
  filter(MINERAL == 'FELDSPATHOID')


foid <- foid %>%
  mutate(id = factor(id), # Defining the following variables as categorical (factors in R)
         GROUP = factor(GROUP),
         ROCK = factor(ROCK),
         SAMPLE = factor(SAMPLE))

input <- foid %>% # manipulating the minerals database and associate the answer with input object
  group_by(MINERAL) %>% # grouping the instances by the mineral 'GROUP' class
  sample_n(30, replace = T) # sampling 300 instances of each 'GROUP', with replacement

#####
# Random Forest
#####

# Defining the First Model ----

# Train-Test-Blind split

## Train-test split
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

foid_rf_over <- caret::train(MINERAL ~ ., # training the model
                                data = train_data, # data for training
                                method = "rf", # method choosen for traininf
                                preProcess = c("scale", "center"), # Pre-process
                                trControl = ctrl, ntree = 150)#, type = 'prob') # Defines the hyperparameters

print(foid_rf_over) # Print on the console the summary of the model

#### Test

pred <- as_tibble(predict(foid_rf_over, test_data)) # predict the classes of the test set

confusionMatrix(pred$value, factor(y_test$MINERAL)) # confusion matrix printed out on the console
(accuracy_m1 = mean(y_test == pred)) # associate the accuracy to an object


#### Blind

pred1 <- as_tibble(predict(foid_rf_over, blind)) # predict the classes of the test set

blind <- blind %>%
  mutate(MINERAL = pred1$value,
         id = factor(id))
#### Merging Datasets

feldspathoid <- foid %>%
  bind_rows(blind)

export <- feldspathoid %>%
  group_by(MINERAL) %>%
  sample_n(50, replace = T) %>%
  distinct(.keep_all = TRUE)

write.csv(feldspathoid, 'data_input/feldspathoid.csv')

pca <- prcomp(feldspathoid[6:27], center = T)

fviz_pca_var(pca,
             col.var = "contrib", # Color by contributions to the PC
             gradient.cols = c("#00AFBB", "#E7B800", "#FC4E07"),
             repel = TRUE)     # Avoid text overlapping

(biplot <- fviz_pca_biplot(pca, 
                palette = "jco", 
                addEllipses = F, label = "var")
)

feldspathoid <- feldspathoid %>%
  bind_cols(as_tibble(pca$x)) %>%
  mutate(x1 = NULL)

# Defining the Final model ----

input1 <- feldspathoid %>% # manipulating the minerals database and associate the answer with input object
  group_by(MINERAL) %>% # grouping the instances by the mineral 'GROUP' class
  sample_n(240, replace = T) # sampling 300 instances of each 'GROUP', with replacement

# Train-Test-Blind split

## Train-test split
index <- createDataPartition(input1$MINERAL, p = 0.7, list = FALSE) # Train-test split using an index
train_data <- input1[as.vector(index), c(4,6:27)] # Selecting the train_data (GROUP + PCA)
test_data  <- input1[-index, 6:27]  # Selecting the test_data (PCA)
y_test <- as_tibble(input1[-index,4])  # Selecting the test_classes (GROUP)

## Random Forest Setting up

ctrl <- trainControl(method = "repeatedcv",#classProbs = T, # Setting up the RF hyperparameters
                     number = 5,   # Number of folds on cross validation
                     repeats = 5, # Number of repeats on every fold
                     verboseIter = T, # Output the result of every iteration on the console
                     sampling = "up") # upsampling instances with unbalanced classes

## Model Fit

feldspathoid_rf_over <- caret::train(MINERAL ~ ., # training the model
                                data = train_data, # data for training
                                method = "rf", # method choosen for traininf
                                preProcess = c("scale", "center"), # Pre-process
                                trControl = ctrl, ntree = 150)#, type = 'prob') # Defines the hyperparameters

print(feldspathoid_rf_over) # Print on the console the summary of the model

#### Test

pred <- as_tibble(predict(feldspathoid_rf_over, test_data)) # predict the classes of the test set

confusionMatrix(pred$value, factor(y_test$MINERAL)) # confusion matrix printed out on the console
(accuracy_m1 = mean(y_test == pred)) # associate the accuracy to an object

# Saving the final model ----

saveRDS(feldspathoid_rf_over, 'model_r/feldspathoid.RDS')

#####
# Data Visualization
#####

# Spatialization of Test Set ----

(p.testset <- ggplot(input1,                                  # Spatialization of Test set
                     aes(x = PC1, y = PC2, col = MINERAL, shape = MINERAL, fill = MINERAL)) + # Coordinates
   geom_point(alpha = .7) + #coord_equal() +               # Plot data as points
   theme(legend.text = element_text(size = 7)) +          # Defines the size of the font legend
   guides(col = guide_legend(ncol = 1)) +               # Legend shown in one unique column
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
    labs(title = 'Feldspathoides classification - Random Forest (Test Set)', subtitle = paste0('N.Samples = 30 for each mineral, N.Trees = 150, 70-30% split, 5-fold, Accuracy: ', 100*round(accuracy_m1,digits = 2),'%')) +
    theme(axis.text.x = element_text(
      angle = 90, vjust = .5, hjust = 1, size = 7),
      axis.text.y = element_text(size = 7),
      legend.position = 'none')
)

CairoPDF(file = 'figures/R_RF_Feldspathoid_Model', width = 9, height = 8) # Creates a PDF file and addresses a name/path
print(biplot)
print(p.testset) # First Page, Test Set Spatialization
print(p.confmatrx) # Second Page, Confusion Matrix
dev.off() # Figure device Off
