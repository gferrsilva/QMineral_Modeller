library(tidyverse)

setwd('C:/Users/GUILHERMEFERREIRA-PC/Documents/GitHub/MinChem_Modeller/data_input/RF')

files <- list.files(pattern = '*rf.csv')

df <- lapply(files, read.csv) 


t1 <- df[[1]] %>%
  select(47, 19, 25:46 )

nome <- names(t1)


t2 <- df[[2]] %>%
  select(47, 19, 25:46 )
t3 <- df[[3]] %>%
  select(47, 19, 25:46 )
t4 <- df[[4]] %>%
  select(47, 19, 25:46 )
t5 <- df[[5]] %>%
  select(47, 19, 25:46 )
t6 <- df[[6]] %>%
  select(47, 19, 25:46 )
# t7 <- df[[7]] %>%
#   select(47, 19, 25:46 )
t7 <- data.table::fread('garnet_rf.csv') %>%
  select(47, 19, 25:46)
names(t7) <- nome

t8 <- df[[8]] %>%
  select(47, 19, 25:46 )
t9 <- df[[9]] %>%
  select(47, 19, 25:46 )
t10 <- df[[10]] %>%
  select(47, 19, 25:46 )
t11 <- df[[11]] %>%
  select(47, 19, 25:46 )
t12 <- df[[12]] %>%
  select(47, 19, 25:46 )
t13 <- df[[13]] %>%
  select(47, 19, 25:46 )
t14 <- df[[14]] %>%
  select(47, 19, 25:46 )
t15 <- df[[15]] %>%
  select(47, 19, 25:46 )
t16 <- df[[16]] %>%
  select(47, 19, 25:46 )
t17 <- df[[17]] %>%
  select(47, 19, 25:46 )

min <- t1 %>%
  bind_rows(t2,t3,t4,t5,t6,t7,t8,t9,t10,t11,t12,t13,t14,t15,t16,t17)

write.csv(min,'~/GitHub/MinChem_Modeller/data_input/minerals.csv')
