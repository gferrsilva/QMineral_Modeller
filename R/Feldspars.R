#####
# Data wrangling and primary classifier of Feldspars
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
# library(corrplot)
library(reshape2)
library(ggthemes)
library(missRanger)
# library(caret)
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

df1 <- as_tibble(read_csv('csv_files/FELDSPARS.csv'),n_max = 174107)
df1 <- df1[1:174107,]

## Verifying the fill rate of columns and rows

col.fillrate(df1, sort = T)

# rows <- NULL
# 
# for (r in 1:nrow(df1)) {
#   rows[r] <- (100 - 100*(sum(is.na(df1[r,])))/ncol(df1))
# }
# 
## Subsect dataframe
felds <- df1 %>%
  select(1:89) %>%
  filter(!is.na(`SIO2(WT%)`)) %>%
  filter(!is.na(`NA2O(WT%)`)) %>%
  filter(!is.na(`K2O(WT%)`)) 

# Split label and variables
labels <- felds[1:23]
felds_labels <- labels %>%
  select(`SAMPLE NAME`, `ROCK NAME`, `MINERAL`)

felds_elems <- felds[24:ncol(felds)]

felds_elems <- as_tibble(felds_elems) %>%
  select_if(~sum(!is.na(.x)) >= (.5 * nrow(felds_elems))) %>%
  sapply(as.numeric)

felds_elems <- as_tibble(felds_elems)

###Renaming the columns and fixing class -----
names(felds_elems) <- c('SiO2','TiO2','Al2O3','FeOT','CaO','MgO','K2O','Na2O')

felds_elems1 <- missRanger(felds_elems, pmm.k = 3, num.trees = 100)




felds_elems$K2O <- as.double(felds_elems$K2O)

###Dataframe feldspar -----
feldspar <- bind_cols(felds_labels, felds_elems)

## Principal componente Analysis -----

pca <- prcomp(na.omit(felds_elems),center = T,scale. = T,)

summary(pca)

### Appending PCA results to feldspar df -----
feldspar <- bind_cols(na.omit(feldspar), as_tibble(pca$x))

# Count the number of samples by rock name -----
feldspar %>%
  group_by(`MINERAL`) %>%
  count(sort = T)

# Fixing the class of a column -----
feldspar$MINERAL <- as.factor(feldspar$MINERAL)

# Wrting file of selected samples -----
write_csv(feldspar, path = 'selected_feldspar.csv')

#####
# Machine Learning
#####

# Train-Test-Blind split

## Blind -----
felds_blind <- feldspar %>%
  filter(MINERAL == 'FELDSPAR')

## Input -----

felds_input <- feldspar %>%
  filter(MINERAL != 'FELDSPAR')

# Fixing class -----
felds_input$MINERAL <- factor(felds_input$MINERAL)

## Train-test split
index <- createDataPartition(felds_input$MINERAL, p = 0.7, list = FALSE)
train_data <- felds_input[as.vector(index), c(3,12:19)]
test_data  <- felds_input[-index, 12:19]
y_test <- as_tibble(felds_input[-index,3])

## Random Forest Setting up

ctrl <- trainControl(method = "repeatedcv", 
                     number = 10, 
                     repeats = 10, 
                     verboseIter = T,
                     sampling = "up")

## Model Fit

model_rf_over <- caret::train(MINERAL ~ .,
                              data = train_data,
                              method = "rf",
                              preProcess = c("scale", "center"),
                              trControl = ctrl, ntree = 150)#, importance = T) # importance = T gera um gráfico de varImp para cada classe
plot(varImp(model_rf_over))

importance(model_rf_over)

print(model_rf_over)
#### Train

pred_train <- as_tibble(predict(model_rf_over, train_data[2:11]))

train <- as_tibble(confusionMatrix(factor(pred_train$value),train_data$MINERAL)['table'])


#### Test

pred_1 <- as_tibble(predict(model_rf_over, test_data))

confusionMatrix(pred_1$value, y_test$MINERAL)
(accuracy_m1 = mean(y_test == pred_1))

c <- confusionMatrix(pred_1$value, y_test$MINERAL)
t <- confusionMatrix(y_test$MINERAL, y_test$MINERAL)

pred_felds <- as_tibble(predict(model_rf_over, felds_blind))

pred_felds <- bind_cols(felds_blind, pred_felds)

heat <- as_tibble(c$table)
true <- as_tibble(t$table)

plotTable <- heat %>%
  mutate(goodbad = ifelse(heat$Prediction == heat$Reference, "good", "bad")) %>%
  group_by(Reference) %>%
  mutate(prop = n/sum(n))

plotTable$prop[is.nan(plotTable$prop)] <- 0

#####
# Data Vis
#####

ggtern(data=feldspar %>%
         filter(MINERAL == 'ANORTHOCLASE'), aes(x=Na2O,y=K2O, z=CaO, col = MINERAL)) +
  geom_point()

ggplot(feldspar,
                             aes(x = PC3, y = PC2, col = MINERAL)) +
          geom_point(alpha = .4) + #coord_equal() +
          # theme(legend.text = element_text(size = 7)) +
          guides(col = guide_legend(ncol = 1)) +
          #legend.position = 'omit') +
          scale_color_manual(values = c(
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
            "darkorange4", "brown"
          ))



#####
# References
#####

# missRanger Package. Replace NA values based on Random Forest Regression
#https://cran.r-project.org/web/packages/missRanger/vignettes/vignette_missRanger.html

