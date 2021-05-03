library(tidyverse) # ggplot2, tidyr, dplyr
library(readxl) # open XLSX data
# library(geoquimica) # Data wrangling
# library(DMwR) # SMOTE
# library(caret) # Machine Learning
# library(randomForest) # RF
# library(randomForestExplainer) # RF
# library(pROC) # ROC and AUC
library(ElemStatLearn)
library(smotefamily)

setwd('C:/Users/GUILHERMEFERREIRA-PC/Documents/GitHub/MinChem_Modeller')


# CHLORITE ----

chl1 <- read_excel('data_raw/OtherSources/Chlorite.xlsx') #%>%
  # mutate(min = 'Chlorite') %>%
  # select(17, 2:15)

chl2 <- read_excel('data_raw/OtherSources/Chlorite_Malta2020.xlsx')

chl3 <- read_excel('data_raw/OtherSources/Chlorite_Zhang_et_al2020.xlsx')

df <- chl1 %>%
  bind_rows(chl2, chl3)


splitIndex <- caret::createDataPartition(df$MINERAL, 
                                         p =.3125,
                                         list = FALSE,
                                         times = 1)

train <- df[splitIndex,]
test <- df[-splitIndex,]

write.csv(train, 'chlorite_train.csv')

write.csv(test,'chlorite_test.csv')


# 
# toSmote <- chl 
# 
# 
# fromSmote <- SMOTE(X = as.data.frame(toSmote[,-1]),
#                    K = 8,dup_size = 5,
#                    target = as.data.frame(toSmote[,'min']))

df <- as_tibble(fromSmote$syn_data)

pca <- prcomp(df[,-15],center = TRUE,scale. = TRUE)

df1 <- as_tibble(pca$x) %>%
  bind_cols(df)

df1 %>%
  ggplot(aes(x = PC1, y = PC2, col = MGO)) +
  geom_point() +
  scale_color_viridis_c()

write.csv(df, 'chlorite_train.csv')
write.csv(chl, 'chlorite_test.csv')
                                         
# EPIDOTE ----

epidote <- read_excel('data_raw/OtherSources/Epidote.xlsx')

epidote1 <- read_excel('data_raw/OtherSources/Epidote_Santos2019.xlsx')

df <- epidote %>%
  bind_rows(epidote1) %>%
  select(1:11) %>%
  replace_na(data = `F`, replace = 0)


splitIndex <- caret::createDataPartition(df$MINERAL, 
                                         p =.3759,
                                         list = FALSE,
                                         times = 1)

train <- df[splitIndex,]
test <- df[-splitIndex,]


toSmote <- train #%>%
  # mutate(min = 'Chlorite') %>%
  # select(17, 2:15)

set.seed(0)
fromSmote <- SMOTE(X = as.data.frame(toSmote[,-1]),
                   K = 20,dup_size = 2,
                   target = as.data.frame(toSmote[,'MINERAL']))

df <- as_tibble(fromSmote$syn_data)

pca <- prcomp(df[,-12],center = TRUE,scale. = TRUE)

df1 <- as_tibble(pca$x) %>%
  bind_cols(df)

df1 %>%
  ggplot(aes(x = PC1, y = PC2, col = CAO)) +
  geom_point() +
  scale_color_viridis_c()

df <- df %>%
  sample_n(size = 50,replace = FALSE)

write.csv(train, 'epidote_train.csv')

write.csv(test,'epidote_test.csv')
