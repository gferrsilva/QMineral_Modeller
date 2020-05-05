#####
# Traning a Random Forest Classifier
# -----
# Amphiboles, Feldspars, Micas, Garnets, Pyroxene, Carbonates
# Apatite, Titanite, Feldspathoids, Olivines, Spinel
# -----
# Guilherme Ferreira, (guilherme.ferreira@cprm.gov.br)
# May, 2020
#####
# Setting up the enviroment
#####
setwd("C:/Users/GUILHERMEFERREIRA-PC/Documents/GitHub/MinChem_Modeller/input")
set.seed(123)

#####
#Import Packages
#####
library(Cairo)
library(tidyverse)
library(reshape2)
library(ggthemes)
library(missRanger)
library(caret)
library(randomForest)

#####
# Built-in Functions
#####

#####
# PREPRARING DATA 
#####

files <- list.files(pattern = "*rf.csv")

df <- lapply(files, read_csv) %>%
  bind_rows() %>%
  as_tibble() %>%
  select(39,19,14,3,7,9,25:38)

names(df) <- c("GROUP","MINERAL","ROCK","SAMPLE",
               "LAT", "LONG", "SIO2", "TIO2",
               "AL2O3", "CR2O3", "FEOT", "CAO",
               "MGO", "MNO", "K2O", "NA2O",
               "P2O5", "H20", "F", "CL")

df <- df %>%
  mutate(GROUP = factor(GROUP),
         MINERAL = factor(MINERAL),
         ROCK = factor(ROCK))

df$H20 <- replace_na(df$H20,0)

pca <- prcomp(df[7:20],center = T,scale. = T,)

summary(pca)

df <- bind_cols(df, as_tibble(pca$x))

input <- df %>%
  group_by(GROUP) %>%
  sample_frac(.1)
#####
# Random Forest
#####

# Train-Test-Blind split

## Train-test split
index <- createDataPartition(input$GROUP, p = 0.7, list = FALSE)
train_data <- input[as.vector(index), c(1,21:34)]
test_data  <- input[-index, 21:34]
y_test <- as_tibble(input[-index,1])

## Random Forest Setting up

ctrl <- trainControl(method = "repeatedcv", 
                     number = 3, 
                     repeats = 5, 
                     verboseIter = T,
                     sampling = "up")

## Model Fit

model_rf_over <- caret::train(GROUP ~ .,
                              data = train_data,
                              method = "rf",
                              preProcess = c("scale", "center"),
                              trControl = ctrl, ntree = 150)#, importance = T) # importance = T gera um gráfico de varImp para cada classe

print(model_rf_over)

#### Test

pred_1 <- as_tibble(predict(model_rf_over, test_data))

confusionMatrix(pred_1$value, y_test$GROUP)
(accuracy_m1 = mean(y_test == pred_1))

c <- confusionMatrix(pred_1$value, y_test$GROUP)
t <- confusionMatrix(y_test$MINERAL, y_test$GROUP)

heat <- as_tibble(c$table)
true <- as_tibble(t$table)

plotTable <- heat %>%
  mutate(goodbad = ifelse(heat$Prediction == heat$Reference, "good", "bad")) %>%
  group_by(Reference) %>%
  mutate(prop = n/sum(n))

plotTable$prop[is.nan(plotTable$prop)] <- 0

minerals <- as_tibble(cbind(y_test, test_data, pred_1))

(p.testset <- ggplot(minerals,
                      aes(x = PC1, y = PC2, col = GROUP)) +
    geom_point(alpha = .4) + coord_equal() + 
    theme(legend.text = element_text(size = 7)) +
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
)


(p.confmatrx <- ggplot(data = plotTable, 
                       aes(
                         x = Reference,
                         y = Prediction,
                         fill = goodbad
                       )
) +
    geom_tile(aes(alpha = prop)) +
    geom_text(aes(label = round(prop, 1)), size = 4) +
    scale_fill_manual(values =
                        c(good = "green",
                          bad = "red")
    ) +
    theme_bw() + coord_equal() + guides(fill = F) +
    labs(title = 'Amphibole classification - Random Forest', subtitle = paste0('N.Trees = 150, 70-30% split, 5-fold, Accuracy: ', 100*round(accuracy_m1,digits = 2),'%')) +
    theme(axis.text.x = element_text(
      angle = 90, vjust = .5, hjust = 1, size = 7),
      axis.text.y = element_text(size = 7),
      legend.position = 'none')
)

CairoPDF(file = 'p.minerals.testset', width = 9, height = 8)
print(p.testset)
print(p.confmatrx)
dev.off()
