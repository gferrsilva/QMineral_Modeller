#####
# Data wrangling and primary classifier of amphiboles
# Guilherme Ferreira, (guilherme.ferreira@cprm.gov.br)
# April, 2020
#####
# Setting up the enviroment
#####
setwd("C:/Users/GUILHERMEFERREIRA-PC/Desktop/Banco de Dados/GEOROC/Minerals")
set.seed(123)

#####
#Import Packages
#####
library(readr)
library(tidyr)
library(dplyr)
library(Cairo)
library(ggplot2)
library(corrplot)
library(reshape2)
library(ggthemes)
library(dplyr)
library(randomForest)
library(caret)

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

df1 <- as_tibble(read_csv('AMPHIBOLES.csv'),n_max = 38639)
df1 <- df1[1:38639,]

## Verifying the fill rate of columns and rows

col.fillrate(df1, sort = T)

rows <- NULL

for (r in 1:nrow(df1)) {
  rows[r] <- (100 - 100*(sum(is.na(df1[r,])))/ncol(df1))
}

## Subsect dataframe
amph <- df1 %>%
  select(1:89) %>%
  filter(!is.na(`SIO2(WT%)`)) %>%
  filter(!is.na(`FEOT(WT%)`)) %>%
  filter(!is.na(`K2O(WT%)`)) 

# Split label and variables
labels <- amph[1:23]
amph_labels <- labels %>%
  select(`SAMPLE NAME`, `ROCK NAME`, `MINERAL`)

amph_elems <- amph[24:ncol(amph)]

amph_elems <- amph_elems %>%
  select_if(~sum(!is.na(.x)) >= (.5 * nrow(amph_elems)))

###Renaming the columns and fixing class -----
names(amph_elems) <- c('SiO2','TiO2','Al2O3','Cr2O3','FeOT','CaO','MgO','MnO','K2O','Na2O') 

amph_elems$K2O <- as.double(amph_elems$K2O)

###Dataframe amphiboles -----
amphiboles <- bind_cols(amph_labels, amph_elems)

## Principal componente Analysis -----

pca <- prcomp(na.omit(amph_elems),center = T,scale. = T,)

summary(pca)

### Appending PCA results to amphiboles df -----
amphiboles <- bind_cols(na.omit(amphiboles), as_tibble(pca$x))

# Count the number of samples by rock name -----
amphiboles %>%
  group_by(`ROCK NAME`) %>%
  count(sort = T)

# Fixing the class of a column -----
amphiboles$MINERAL <- as.factor(amphiboles$MINERAL)

# Wrting file of selected samples -----
write_csv(amphiboles, path = 'selected_amphiboles.csv')

#####
# Machine Learning
#####

# Train-Test-Blind split

  ## Blind -----
amph_blind <- amphiboles %>%
  filter(MINERAL == 'AMPHIBOLE')

  ## Input -----

amph_input <- amphiboles %>%
  filter(MINERAL != 'AMPHIBOLE')

# Fixing class -----
amph_input$MINERAL <- factor(amph_input$MINERAL)

## Train-test split
index <- createDataPartition(amph_input$MINERAL, p = 0.7, list = FALSE)
train_data <- amph_input[as.vector(index), c(3,14:23)]
test_data  <- amph_input[-index, 14:23]
y_test <- as_tibble(amph_input[-index,3])

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

pred_amph <- as_tibble(predict(model_rf_over, amph_blind))

pred_amph <- bind_cols(amph_blind, pred_amph)

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

(p.trainset <- ggplot(amphiboles %>% filter(MINERAL != 'AMPHIBOLE'),
                      aes(x = PC1, y = PC2, col = MINERAL)) +
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


CairoPDF(file = 'p.trainset.PDF', width = 9, height = 8)
print(p.trainset)
dev.off()


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
  labs(title = 'Amphibole classification - Random Forest', subtitle = paste0('N.Trees = 150, 70-30% split, 10-fold, Accuracy: ', 100*round(accuracy_m1,digits = 2),'%')) +
  theme(axis.text.x = element_text(
    angle = 90, vjust = .5, hjust = 1, size = 7),
    axis.text.y = element_text(size = 7),
    legend.position = 'none')
 )

CairoPDF(file = 'p.confmatrix.PDF', width = 9, height = 8)
print(p.confmatrx)
dev.off()

(p.blind <- ggplot(pred_amph,
       aes(x = PC1, y = PC2, col = value)) +
  geom_point(size = 4, alpha = .4) + #theme(legend.position = 'omit') +
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

CairoPDF(file = 'p.blind.PDF', width = 9, height = 8)
print(p.blind)
dev.off()

#####
# References
#####

## Variance importance/Mean Decrease Gini
# https://stats.stackexchange.com/questions/197827/how-to-interpret-mean-decrease-in-accuracy-and-mean-decrease-gini-in-random-fore
# https://topepo.github.io/caret/variable-importance.html
# https://www.r-bloggers.com/variable-importance-plot-and-variable-selection/
