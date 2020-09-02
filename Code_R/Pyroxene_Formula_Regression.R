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

#####
# Import Packages
#####
library(Cairo) # Export figures
library(tidyverse) # Collection of libraries: dplyr, ggplot2, purrr, tidyr. Data wrangling and visualizing
library(ggthemes) # Predefined themes
library(readxl)
library(writexl)
library(missRanger)


raissa <- read_excel(path = 'data_raw/OtherSources/raissa/raissa.xlsx',sheet = 1) %>%
  mutate(M1Fe2 = `M1Fe2+`, `M1Fe2+` = NULL,
         M2Fe2 = `M2Fe2+`, `M2Fe2+` = NULL,
         XMg = `*XMg`, `*XMg` = NULL)


raissa <- raissa %>%
  # filter(Mineral == 'Hedenbergite')
 filter(Mineral == 'Diopside')

n <- round(0.3*nrow(raissa),digits = 0)
m <- 12:25

set.seed(0)
index <- sample(1:nrow(raissa),
                replace = F, 
                size = n) %>%
          sort()

train <- raissa[-index,]
test <- raissa[index,]
test[,m] <- NA
y_test <- raissa[index, m]

df <- train %>%
  bind_rows(test)


raissa1 <- missRanger(df,pmm.k = 5,
                      num.trees = 300,
                      seed = 123,
                      verbose = 2,
                      maxiter = 10)

raissa1[(1+nrow(train)):nrow(df),m]
y_test

(residuo <- (raissa1[(1+nrow(train)):nrow(df),m] - y_test))

p <- y_test %>%
  cbind(raissa1[(1+nrow(train)):nrow(df),m])

names(p) <- c("Total.actual", "TSi.actual", "TAl.actual",
              "M1Al.actual", "M1Ti.actual", "M1Mg.actual",
              "M2Mn.actual", "M2Ca.actual", "M2Na.actual",
              "M2K.actual", "Cations.actual", "M1Fe2.actual",
              "M2Fe2.actual", "XMg.actual", "Total.pred",
              "TSi.pred", "TAl.pred", "M1Al.pred", "M1Ti.pred",
              "M1Mg.pred", "M2Mn.pred", "M2Ca.pred", "M2Na.pred", "M2K.pred", 
              "Cations.pred", "M1Fe2.pred", "M2Fe2.pred",
              "XMg.pred")

p_tidy <- p %>%
  gather(key = 'Actual',value = value.actual, ends_with('.actual')) %>%
  gather(key = 'Predict',value = value.pred, ends_with('.pred'))

p_summary <- p_tidy %>%
  group_by(Predict) %>%
  summarise(mean = mean(value.pred),
            sd = sd(value.pred))

ggplot(p, aes(x = M2K.pred, y = M2K.actual)) +
  geom_jitter() +
  # geom_smooth(method = 'lm',se = F, col = 'red') +
  coord_equal() +
  # xlim(c(0,.08)) + ylim(c(0,.08)) +
  geom_abline(slope = 1, intercept = 0)

erro <- as_tibble()

for(c in seq_along(residuo)) {
  erro[c,1] <- names(residuo[c])
  erro[c,2] <- sqrt(sum(residuo[c]^2)/nrow(residuo[c]))
}

write.csv(train, 'data_train/train.csv')


res_tidy <- residuo %>%
  gather(key = 'variavel', value = 'value')

res_tidy %>%
  filter(variavel != 'Total' &
           variavel != 'Cations' &
           variavel != 'XMg') %>%
  ggplot(aes(x = value, fill = variavel)) +
  geom_histogram(binwidth = .005) +
  facet_grid(variavel ~ .)
