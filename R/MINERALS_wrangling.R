#####
# Data wrangling and primary classifier of selected minerals
# -----
# Amphiboles, Feldspars, Micas, Garnets, Pyroxene, Carbonates
# Apatite, Titanite, Feldspathoids, Olivines, Spinel
# -----
# Guilherme Ferreira, (guilherme.ferreira@cprm.gov.br)
# April, 2020
#####
# Setting up the enviroment
#####
setwd("C:/Users/GUILHERMEFERREIRA-PC/Documents/GitHub/MinChem_Modeller")
set.seed(123)

selection <- c('SIO2(WT%)', 'TIO2(WT%)', 'AL2O3(WT%)', 'CR2O3(WT%)',
               'FEOT(WT%)','CAO(WT%)','MGO(WT%)','MNO(WT%)','K2O(WT%)',
               'NA2O(WT%)','P2O5(WT%)','H2O(WT%)','F(WT%)','CL(WT%)')

elems_names <- c('SIO2','TIO2','AL2O3','CR2O3','FEOT','CAO',
                 'MGO','MNO','K2O','NA2O','P2O5','H20','F','CL')

#####
#Import Packages
#####
library(tidyverse)
library(missRanger)

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

# Amphiboles -----

df1 <- as_tibble(read_csv('csv_files/AMPHIBOLES.csv'),n_max = 38639)
df1 <- df1[1:38639,]

amph <- df1 %>%
  select(1:89) %>%
  filter(!is.na(`SIO2(WT%)`))

amph_labels <- amph[1:23]

amph_elems <- amph %>%
  select(all_of(selection))

names(amph_elems) <- elems_names

amph_elems <- sapply(amph_elems,as.numeric)
amph_elems <- as_tibble(amph_elems)

remove(df1,amph)
# Garnets -----

df1 <- as_tibble(read_delim('csv_files/GARNETS.csv',delim = ';'),n_max = 42340)
df1 <- df1[1:42340,]

grt <- df1 %>%
  select(1:89) %>%
  filter(!is.na(`SIO2(WT%)`))

grt_labels <- grt[1:23]

grt_elems <- grt %>%
  select(all_of(selection))

names(grt_elems) <- elems_names

grt_elems <- sapply(grt_elems,as.numeric)
grt_elems <- as_tibble(grt_elems)

remove(df1,grt)
# Feldspars -----

df1 <- as_tibble(read_csv('csv_files/FELDSPARS.csv'),n_max = 174107)
df1 <- df1[1:174107,]

felds <- df1 %>%
  select(1:89) %>%
  filter(!is.na(`SIO2(WT%)`))

felds_labels <- felds[1:23]

felds_elems <- felds %>%
  select(all_of(selection))

names(felds_elems) <- elems_names

felds_elems <- sapply(felds_elems,as.numeric)
felds_elems <- as_tibble(felds_elems)

felds_elems$H20 <- replace_na(felds_elems$H20, 0)

remove(df1,felds)

# Mica -----

df1 <- as_tibble(read_csv('csv_files/MICA.csv'),n_max = 35035)
df1 <- df1[1:35035,]

mica <- df1 %>%
  select(1:89) %>%
  filter(!is.na(`SIO2(WT%)`))

mica_labels <- mica[1:23]

mica_elems <- mica %>%
  select(all_of(selection))

names(mica_elems) <- elems_names

mica_elems <- sapply(mica_elems,as.numeric)
mica_elems <- as_tibble(mica_elems)

remove(df1,mica)

# Pyroxenes -----

df1 <- as_tibble(read_csv('csv_files/PYROXENES.csv'),n_max = 15006)
df1 <- df1[1:15006,]

px <- df1 %>%
  select(1:89) %>%
  filter(!is.na(`SIO2(WT%)`))

px_labels <- px[1:23]

px_elems <- px %>%
  select(all_of(selection))

names(px_elems) <- elems_names

px_elems <- sapply(px_elems,as.numeric)
px_elems <- as_tibble(px_elems)

remove(df1,px)

# Carbonates -----

df1 <- as_tibble(read_csv('csv_files/CARBONATES.csv'),n_max = 9189)
df1 <- df1[1:9189,]

carb <- df1 %>%
  select(1:89) %>%
  filter(!is.na(`CAO(WT%)`))

carb_labels <- carb[1:23]

carb_elems <- carb %>%
  select(all_of(selection))

names(carb_elems) <- elems_names

carb_elems <- sapply(carb_elems,as.numeric)
carb_elems <- as_tibble(carb_elems)

remove(df1,carb)

# Apatites -----

df1 <- as_tibble(read_csv('csv_files/APATITES.csv'),n_max = 12696)
df1 <- df1[1:12696,]

apat <- df1 %>%
  select(1:89) %>%
  filter(!is.na(`P2O5(WT%)`))

apat_labels <- apat[1:23]

apat_elems <- apat %>%
  select(all_of(selection))

names(apat_elems) <- elems_names

apat_elems <- sapply(apat_elems,as.numeric)
apat_elems <- as_tibble(apat_elems)

remove(df1,carb)


# Spinels -----

df1 <- as_tibble(read_csv('csv_files/SPINELS.csv'),n_max = 64421)
df1 <- df1[1:64421,]

spin <- df1 %>%
  select(1:89) %>%
  filter(!is.na(`CR2O3(WT%)`))

spin_labels <- spin[1:23]

spin_elems <- spin %>%
  select(all_of(selection))

names(spin_elems) <- elems_names

spin_elems <- sapply(spin_elems,as.numeric)
spin_elems <- as_tibble(spin_elems)

remove(df1,spin)

# Titanite -----

df1 <- as_tibble(read_csv('csv_files/TITANITES.csv'),n_max = 5469)
df1 <- df1[1:5469,]

titan <- df1 %>%
  select(1:89) %>%
  filter(!is.na(`TIO2(WT%)`))

titan_labels <- titan[1:23]

titan_elems <- titan %>%
  select(all_of(selection))

names(titan_elems) <- elems_names

titan_elems <- sapply(titan_elems,as.numeric)
titan_elems <- as_tibble(titan_elems)

remove(df1,titan)

# Feldspathoid -----

df1 <- as_tibble(read_csv('csv_files/FELDSPATHOIDES.csv'),n_max = 4332)
df1 <- df1[1:4332,]

foid <- df1 %>%
  select(1:89) %>% 
  filter(!is.na(`SIO2(WT%)`))

foid_labels <- foid[1:23]

foid_elems <- foid %>%
  select(all_of(selection))

names(foid_elems) <- elems_names

foid_elems <- sapply(foid_elems,as.numeric)
foid_elems <- as_tibble(foid_elems)

remove(df1,foid)

# OLIVINES -----

df1 <- as_tibble(read_csv('csv_files/OLIVINES.csv'),n_max = 185404)
df1 <- df1[1:185404,]

oliv <- df1 %>%
  select(1:89) %>% 
  filter(!is.na(`SIO2(WT%)`))

oliv_labels <- oliv[1:23]

oliv_elems <- oliv %>%
  select(all_of(selection))

names(oliv_elems) <- elems_names

oliv_elems <- sapply(oliv_elems,as.numeric)
oliv_elems <- as_tibble(oliv_elems)

remove(df1,oliv)


#####
# DATA IMPUTATION 
#####


amph_elems <- missRanger(amph_elems, pmm.k = 3, num.trees = 100)

grt_elems <- missRanger(grt_elems, pmm.k = 3, num.trees = 100)

felds_elems <- missRanger(felds_elems, pmm.k = 3, num.trees = 100)

mica_elems <- missRanger(mica_elems, pmm.k = 3, num.trees = 100)

apat_elems <- missRanger(apat_elems, pmm.k = 3, num.trees = 100)

carb_elems <- missRanger(carb_elems, pmm.k = 3, num.trees = 100)

foid_elems <- missRanger(foid_elems, pmm.k = 3, num.trees = 100)

oliv_elems <- missRanger(oliv_elems, pmm.k = 3, num.trees = 100)

px_elems <- missRanger(px_elems, pmm.k = 3, num.trees = 100)

spin_elems <- missRanger(spin_elems, pmm.k = 3, num.trees = 100)

titan_elems <- missRanger(titan_elems, pmm.k = 3, num.trees = 100)

#####
# SAVING FILES 
#####
# Amphiboles ----
amphiboles <- as_tibble(cbind(amph_labels,amph_elems)) %>%
  mutate(GROUP = 'AMPHIBOLES')
write.csv(amphiboles, 'input/amphiboles_rf.csv')
# Garnet ----
garnet <- as_tibble(cbind(grt_labels,grt_elems)) %>%
  mutate(GROUP = 'GARNET')
write.csv(garnet, 'input/garnet_rf.csv')
# Feldspar ----
felds <- as_tibble(cbind(felds_labels,felds_elems)) %>%
  mutate(GROUP = 'FELDSPAR')
write.csv(feldspar, 'input/feldspar_rf.csv')
# Mica ----
mica <- as_tibble(cbind(mica_labels,mica_elems)) %>%
  mutate(GROUP = 'MICA')
write.csv(mica, 'input/mica_rf.csv')
# Apatite ----
apat <- as_tibble(cbind(apat_labels,apat_elems)) %>%
  mutate(GROUP = 'APATITE')
write.csv(apat, 'input/apatite_rf.csv')
# Carbonate ----
carb <- as_tibble(cbind(carb_labels,carb_elems)) %>%
  mutate(GROUP = 'CARBONATE')
write.csv(carb, 'input/carbonate_rf.csv')
# Feldspathoid ----
foid <- as_tibble(cbind(foid_labels,foid_elems)) %>%
  mutate(GROUP = 'FELDSPATHOID')
write.csv(foid, 'input/feldspathoid_rf.csv')
# Olivine ----
oliv <- as_tibble(cbind(oliv_labels,oliv_elems)) %>%
  mutate(GROUP = 'OLIVE')
write.csv(oliv, 'input/olivine_rf.csv')
# Pyroxene ----
px <- as_tibble(cbind(px_labels,px_elems)) %>%
  mutate(GROUP = 'PYROXENE')
write.csv(px, 'input/pyroxene_rf.csv')
# Spinel ----
spin <- as_tibble(cbind(spin_labels,spin_elems)) %>%
  mutate(GROUP = 'SPINEL')
write.csv(spin, 'input/spinel_rf.csv')
# Titanite ----
titan <- as_tibble(cbind(titan_labels,titan_elems)) %>%
  mutate(GROUP = 'TITANITE')
write.csv(titan, 'input/titanite_rf.csv')
