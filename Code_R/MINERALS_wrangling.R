#####
# Data wrangling and primary classifier of selected minerals
# 
# version: 2.1 (2020/05/19)
#
# Last modifications: * Addition of Clay Minerals, Perovskite, Quartz, Sulfides and Zircon;
#                     * Addition of 'FE(WT%)','NI(WT%)','CU(WT%)','CO(WT%)','ZN(WT%)','AS(WT%)',
#                     'PB(WT%)','S(WT%)' to the selected elements;
#                     * Join data frames into 'minerals', writing 
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

setwd("~/GitHub/MinChem_Modeller") # Ajustando o work direction

set.seed(123) # Ajustando o 'Random State' da máquina para reproduzir os códigos

# Lista de elementos a ser selecionados do banco de dados original
selection <- c('SIO2(WT%)', 'TIO2(WT%)', 'AL2O3(WT%)', 'CR2O3(WT%)', 
               'FEOT(WT%)','CAO(WT%)','MGO(WT%)','MNO(WT%)','K2O(WT%)',
               'NA2O(WT%)','P2O5(WT%)','H2O(WT%)','F(WT%)','CL(WT%)',
               'NIO(WT%)','CUO(WT%)','COO(WT%)','ZNO(WT%)','AS(PPM)',
               'PBO(WT%)','S(WT%)','ZRO2(WT%)')
selsulf <- c('FE(WT%)','NI(WT%)','CU(WT%)','CO(WT%)','ZN(WT%)','AS(WT%)','PB(WT%)')

# Simplifcação dos elementos electionados acima
elems_names <- c('SIO2','TIO2','AL2O3','CR2O3','FEOT','CAO',
                 'MGO','MNO','K2O','NA2O','P2O5','H20','F','CL',
                 'NIO','CUO','COO','ZNO','AS_ppm','PBO','S','ZRO2')


#####
#Import Packages
#####
library(tidyverse) # Conjunto de bibliotecas em R que facilitam a manipulação e visualização de dados. Equivalente ao pandas, matplotlib, seaborn, etc
library(missRanger) # Biblioteca de Missing Values Imputation by Randon Forest Regression

#####
# Built-in Functions
#####
col.fillrate <- function(df, sort = F) { # Apresenta a proporção de dados preenchidos, por coluna
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

df1 <- read_csv('data_raw/AMPHIBOLES.csv',n_max = 38639,na = 'NA') # importar o arquivo amphiboles.csv para um arquivo temporário df1

amph <- df1 %>%
  filter(!is.na(`SIO2(WT%)`)) # filtra todos os dados que não tenham valores na columa de SiO2

amph_labels <- amph[1:23] # seleciona os metadados

amph_elems <- amph %>% # seleciona as colunas de elementos
  select(all_of(selection)) %>%
  mutate(`CUO(WT%)` = 0,
         `S(WT%)` = 0)

names(amph_elems) <- elems_names # renomeia as colunas de elementos

amph_elems <- sapply(amph_elems,as.numeric) # define as variáveis como numéricas
amph_elems <- as_tibble(amph_elems) # converte o df para formato 'tibble', do Tidyverse

remove(df1,amph) # descarta variáveis

# Apatites -----

df1 <- read_csv('data_raw/APATITES.csv',n_max = 12696)

apat <- df1 %>%
  # select(1:89) %>%
  filter(!is.na(`P2O5(WT%)`))

apat_labels <- apat[1:23]

apat_elems <- apat %>%
  mutate(`COO(WT%)` = 0,
         `AS(PPM)` = 0,
         `CUO(WT%)` = 0) %>%
  #        `CO(WT%)` = 0,
  #        `ZN(WT%)` = 0,
  #        `AS(WT%)` = 0,
  #        `PB(WT%)` = 0) %>%
  select(all_of(selection))

names(apat_elems) <- elems_names

apat_elems <- sapply(apat_elems,as.numeric)
apat_elems <- as_tibble(apat_elems)

remove(df1,apat)

# Carbonates -----

df1 <- read_csv('data_raw/CARBONATES.csv',n_max = 9189)

carb <- df1 %>%
  # select(1:89) %>%
  filter(!is.na(`CAO(WT%)`))

carb_labels <- carb[1:23]

carb_elems <- carb %>%
  mutate(`COO(WT%)` = 0,
         `H2O(WT%)` = 0,
         `CUO(WT%)` = 0,
         `AS(PPM)` = 0) %>%
  # `CU(WT%)` = NA,
  # `CO(WT%)` = NA,
  # `ZN(WT%)` = NA,
  #        `AS(WT%)` = NA,
  #        `PB(WT%)` = NA) %>%
  select(all_of(selection))

names(carb_elems) <- elems_names

carb_elems <- sapply(carb_elems,as.numeric)
carb_elems <- as_tibble(carb_elems)

remove(df1,carb)

# Clay Minerals -----

df1 <- read_csv('data_raw/CLAY_MINERALS.csv',n_max = 753)

clay <- df1 %>%
  # select(1:89) %>%
  filter(!is.na(`SIO2(WT%)`))

clay_labels <- clay[1:23]

clay_elems <- clay %>%
  mutate(`CUO(WT%)` = 0,
         `COO(WT%)` = 0,
         `ZNO(WT%)` = 0,
         `AS(PPM)` = 0,
         `PBO(WT%)` = 0,
         `ZRO2(WT%)` = 0,
         `S(WT%)` = 0,
         `F(WT%)` = 0) %>%
  select(all_of(selection))

names(clay_elems) <- elems_names

clay_elems <- sapply(clay_elems,as.numeric)
clay_elems <- as_tibble(clay_elems)

remove(df1, clay)

# Feldspars -----

df1 <- read_csv('data_raw/FELDSPARS.csv',n_max = 174107)

felds <- df1 %>%
  # select(1:89) %>%
  filter(!is.na(`SIO2(WT%)`))

felds_labels <- felds[1:23]

felds_elems <- felds %>%
  mutate(`CUO(WT%)` = 0,
         `COO(WT%)` = 0,
         `H2O(WT%)` = 0,
         `S(WT%)` = 0,
         `PBO(WT%)` = 0) %>%
  select(all_of(selection))

names(felds_elems) <- elems_names

felds_elems <- sapply(felds_elems,as.numeric)
felds_elems <- as_tibble(felds_elems)

felds_elems$H20 <- replace_na(felds_elems$H20, 0)

remove(df1,felds)

# Feldspathoid -----

df1 <- read_csv('data_raw/FELDSPATHOIDES.csv',n_max = 4332)

foid <- df1 %>%
  # select(1:89) %>% 
  filter(!is.na(`SIO2(WT%)`))

foid_labels <- foid[1:23]

foid_elems <- foid %>%
  mutate(`CUO(WT%)` = 0,
         `AS(PPM)` = 0,
         `ZRO2(WT%)` = 0,
         `PBO(WT%)` = 0) %>%
  select(all_of(selection))

names(foid_elems) <- elems_names

foid_elems <- sapply(foid_elems,as.numeric)
foid_elems <- as_tibble(foid_elems)

remove(df1,foid)

# Garnets -----

df1 <- read_csv('data_raw/GARNETS.csv',n_max = 42340)

grt <- df1 %>%
  # select(1:89) %>%
  filter(!is.na(`SIO2(WT%)`))

grt_labels <- grt[1:23]

grt_elems <- grt %>%
  mutate(`CUO(WT%)` = 0,
         `COO(WT%)` = 0,
         `PBO(WT%)` = 0,
         `AS(PPM)` = 0) %>%
  #        `ZN(WT%)` = NA,
  #        `AS(WT%)` = NA,
  #        `PB(WT%)` = NA) %>%
  select(all_of(selection))

names(grt_elems) <- elems_names

grt_elems <- sapply(grt_elems,as.numeric)
grt_elems <- as_tibble(grt_elems)

remove(df1,grt)

# Ilmenite -----

df1 <- read_csv('data_raw/ILMENITES.csv',n_max = 14894)

ilm <- df1 %>%
  # select(1:89) %>%
  filter(!is.na(`TIO2(WT%)`))

ilm_labels <- ilm[1:23]

ilm_elems <- ilm %>%
  select(all_of(selection)) %>%
  mutate(`AS(PPM)` = 0,
         `S(WT%)` = 0,
         `PBO(WT%)` = 0,
         `CUO(WT%)` = 0)

names(ilm_elems) <- elems_names

ilm_elems <- sapply(ilm_elems,as.numeric)
ilm_elems <- as_tibble(ilm_elems)

remove(df1,ilm)

# Mica -----

df1 <- read_csv('data_raw/MICA.csv',n_max = 35035)

mica <- df1 %>%
  # select(1:89) %>%
  filter(!is.na(`SIO2(WT%)`))

mica_labels <- mica[1:23]

mica_elems <- mica %>%
  mutate(`CUO(WT%)` = 0,
         `COO(WT%)` = 0,
         `ZNO(WT%)` = 0,
         `AS(PPM)` = 0,
         `PBO(WT%)` = 0,
         `S(WT%)` = 0,
         `ZRO2(WT%)` = 0,) %>%
  select(all_of(selection))

names(mica_elems) <- elems_names

mica_elems <- sapply(mica_elems,as.numeric)
mica_elems <- as_tibble(mica_elems)

remove(df1,mica)

# OLIVINES -----

df1 <- read_csv('data_raw/OLIVINES.csv',n_max = 185404)

oliv <- df1 %>%
  # select(1:89) %>% 
  filter(!is.na(`SIO2(WT%)`))

oliv_labels <- oliv[1:23]

oliv_elems <- oliv %>%
  mutate(`PBO(WT%)` = 0) %>%
  select(all_of(selection))

names(oliv_elems) <- elems_names

oliv_elems <- sapply(oliv_elems,as.numeric)
oliv_elems <- as_tibble(oliv_elems)

remove(df1,oliv)

# PEROVSKITE -----

df1 <- read_csv('data_raw/PEROVSKITES.csv',n_max = 11022)

perov <- df1 %>%
  # select(1:89) %>% 
  filter(!is.na(`CAO(WT%)`))

perov_labels <- perov[1:23]

perov_elems <- perov %>%
  mutate(`AS(PPM)` = 0,
         `CUO(WT%)` = 0,
         `COO(WT%)` = 0,
         `S(WT%)` = 0,) %>%
  select(all_of(selection))

names(perov_elems) <- elems_names

perov_elems <- sapply(perov_elems,as.numeric)
perov_elems <- as_tibble(perov_elems)

remove(df1,perov)

# Pyroxenes -----

df1 <- read_csv('data_raw/PYROXENES.csv',n_max = 15006)

px <- df1 %>%
  # select(1:89) %>%
  filter(!is.na(`SIO2(WT%)`))

px_labels <- px[1:23]

px_elems <- px %>%
  mutate(`PBO(WT%)` = 0,
         `CUO(WT%)` = 0,
         `COO(WT%)` = 0,
         `AS(PPM)` = 0) %>%
  #        `ZN(WT%)` = NA,
  #        `AS(WT%)` = NA,
  #        `PB(WT%)` = NA) %>%
  select(all_of(selection))

names(px_elems) <- elems_names

px_elems <- sapply(px_elems,as.numeric)
px_elems <- as_tibble(px_elems)

remove(df1,px)

# Quartz -----

df1 <- read_csv('data_raw/QUARTZ.csv',n_max = 5304)

qtz <- df1 %>%
  # select(1:89) %>%
  filter(!is.na(`SIO2(WT%)`))

qtz_labels <- qtz[1:23]

qtz_elems <- qtz %>%
  mutate(`S(WT%)` = 0,
         `CUO(WT%)` = 0,
         `COO(WT%)` = 0,
         `AS(PPM)` = 0,
         `ZRO2(WT%)` = 0,
         `H2O(WT%)` = 0,
         `PBO(WT%)` = 0) %>%
  select(all_of(selection))

names(qtz_elems) <- elems_names

qtz_elems <- sapply(qtz_elems,as.numeric)
qtz_elems <- as_tibble(qtz_elems)

remove(df1,qtz)

# Spinels -----

df1 <- read_csv('data_raw/SPINELS.csv',n_max = 64421)

spin <- df1 %>%
  # select(1:89) %>%
  filter(!is.na(`CR2O3(WT%)`))

spin_labels <- spin[1:23]

spin_elems <- spin %>%
  mutate(`S(WT%)` = 0,
         `AS(PPM)` = 0) %>%
  select(all_of(selection))

names(spin_elems) <- elems_names

spin_elems <- sapply(spin_elems,as.numeric)
spin_elems <- as_tibble(spin_elems)

remove(df1,spin)

# Sulfides -----

df1 <- read_csv('data_raw/SULFIDES.csv',n_max = 7004)

sulf <- df1 %>%
  # select(1:89) #%>%
  filter(!is.na(`S(WT%)`))

# sulf <- sulf %>%
#   mutate(`AS(PPM)` =  10000*coalesce(`AS(WT%)`))


sulf_labels <- sulf[1:23]
sulf$`H2O(WT%)` <- 0

sulf_elems <- sulf %>%
  mutate(`H2O(WT%)` = 0,
         `ZRO2(WT%)` = 0,
         `CL(WT%)` = 0,
         `SIO2(WT%)` = 0,
         `AL2O3(WT%)` = 0,
         `TIO2(WT%)` = 0,
         `MGO(WT%)` = 0,
         `MNO(WT%)` = 0) %>%
  mutate(`AS(PPM)` =  10000*coalesce(`AS(WT%)`)) %>%
  select(all_of(c(selection,selsulf))) %>%
  mutate(`NIO(WT%)` =  (1.272588*`NI(WT%)`)) %>%
  mutate(`CUO(WT%)` =  (1.251878*`CU(WT%)`)) %>%
  mutate(`COO(WT%)` =  (1.271455*`CO(WT%)`)) %>%
  mutate(`FEOT(WT%)` = (1.381978*`FE(WT%)`)) %>%
  mutate(`ZNO(WT%)` =  (1.244709*`ZN(WT%)`)) %>%
  mutate(`PBO(WT%)` =  (1.077237*`PB(WT%)`)) %>%
  mutate(`F(WT%)` =  0,
         `P2O5(WT%)` =  0,
         `CR2O3(WT%)` =  0) %>%
  select(-selsulf)

names(sulf_elems) <- elems_names

sulf_elems <- sapply(sulf_elems,as.numeric)
sulf_elems <- as_tibble(sulf_elems)

remove(df1,sulf)

# Titanite -----

df1 <- read_csv('data_raw/TITANITES.csv',n_max = 5469)

titan <- df1 %>%
  # select(1:89) %>%
  filter(!is.na(`TIO2(WT%)`))

titan_labels <- titan[1:23]

titan_elems <- titan %>%
  mutate(`S(WT%)` = 0,
         `CUO(WT%)` = 0,
         `COO(WT%)` = 0,
         `AS(PPM)` = 0) %>%
  #        `ZN(WT%)` = NA,
  #        `AS(WT%)` = NA,
  #        `S(WT%)` = NA,
  #        `PB(WT%)` = NA) %>%
  select(all_of(selection))

names(titan_elems) <- elems_names

titan_elems <- sapply(titan_elems,as.numeric)
titan_elems <- as_tibble(titan_elems)

remove(df1,titan)

# Zircon -----

df1 <- read_csv('data_raw/ZIRCONS.csv',n_max = 265824)

zirc <- df1 %>%
  # select(1:89) %>%
  filter(!is.na(`ZRO2(WT%)`))

zirc_labels <- zirc[1:23]

zirc_elems <- zirc %>%
  mutate(`S(WT%)` = 0,
         `CUO(WT%)` = 0,
         `COO(WT%)` = 0,
         `ZNO(WT%)` = 0,
         `AS(PPM)` = 0,
         `H2O(WT%)` = 0) %>%
  select(all_of(selection))

names(zirc_elems) <- elems_names

zirc_elems <- sapply(zirc_elems,as.numeric)
zirc_elems <- as_tibble(zirc_elems)

remove(df1,zirc)




#####
# DATA IMPUTATION 
#####

# Missing Value imputation by random forest regression. pmm.k = 3, 3 elementos para média móvel
# num.tress = 100, verbose = 2 (output os OOB de cada regressão)
# Repetido uma vez para cada elemento (poderia ter feito um for, mas fiquei com preguiça. Conserto isso depois)

amph_elems1 <- missRanger(amph_elems, pmm.k = 3, num.trees = 100, verbose = 2)
apat_elems1 <- missRanger(apat_elems, pmm.k = 3, num.trees = 100, verbose = 2)
carb_elems1 <- missRanger(carb_elems, pmm.k = 3, num.trees = 100, verbose = 2)
clay_elems1 <- missRanger(clay_elems, pmm.k = 3, num.trees = 100, verbose = 2)
felds_elems1 <- missRanger(felds_elems, pmm.k = 3, num.trees = 100, verbose = 2)
foid_elems1 <- missRanger(foid_elems, pmm.k = 3, num.trees = 100, verbose = 2)
grt_elems1 <- missRanger(grt_elems, pmm.k = 3, num.trees = 100, verbose = 2)
ilm_elems1 <- missRanger(ilm_elems, pmm.k = 3, num.trees = 100, verbose = 2)
mica_elems1 <- missRanger(mica_elems, pmm.k = 3, num.trees = 100, verbose = 2)
oliv_elems1 <- missRanger(oliv_elems, pmm.k = 3, num.trees = 100, verbose = 2)
perov_elems1 <- missRanger(perov_elems, pmm.k = 3, num.trees = 100, verbose = 2)
px_elems1 <- missRanger(px_elems, pmm.k = 3, num.trees = 100, verbose = 2)
qtz_elems1 <- missRanger(qtz_elems, pmm.k = 3, num.trees = 100, verbose = 2)
spin_elems1 <- missRanger(spin_elems, pmm.k = 3, num.trees = 100, verbose = 2)
sulf_elems1 <- missRanger(sulf_elems, pmm.k = 3, num.trees = 100, verbose = 2)
titan_elems1 <- missRanger(titan_elems, pmm.k = 3, num.trees = 100, verbose = 2)
zirc_elems1 <- missRanger(zirc_elems, pmm.k = 3, num.trees = 100, verbose = 2)


#####
# WRITING INDIVIDUAL FILES 
#####

# Amphiboles ----
amphiboles <- as_tibble(cbind(amph_labels,amph_elems1)) %>%
  mutate(GROUP = 'AMPHIBOLES') %>%
  mutate(SPOT = as.character(SPOT))
write.csv(amphiboles, 'data_input/amphiboles_rf.csv')
# Apatite ----
apat <- as_tibble(cbind(apat_labels,apat_elems1)) %>%
  mutate(GROUP = 'APATITE') %>%
  mutate(SPOT = as.character(SPOT))
write.csv(apat, 'data_input/apatite_rf.csv')
# Carbonate ----
carb <- as_tibble(cbind(carb_labels,carb_elems1)) %>%
  mutate(GROUP = 'CARBONATE') %>%
  mutate(SPOT = as.character(SPOT))
write.csv(carb, 'data_input/carbonate_rf.csv')
# Clay Minerals ----
clay <- as_tibble(cbind(clay_labels,clay_elems1)) %>%
  mutate(GROUP = 'CLAY') %>%
  mutate(SPOT = as.character(SPOT))
write.csv(clay, 'data_input/clayminerals_rf.csv')
# Feldspar ----
felds <- as_tibble(cbind(felds_labels,felds_elems1)) %>%
  mutate(GROUP = 'FELDSPAR') %>%
  mutate(SPOT = as.character(SPOT))
write.csv(felds, 'data_input/feldspar_rf.csv')
# Feldspathoid ----
foid <- as_tibble(cbind(foid_labels,foid_elems1)) %>%
  mutate(GROUP = 'FELDSPATHOID') %>%
  mutate(SPOT = as.character(SPOT))
write.csv(foid, 'data_input/feldspathoid_rf.csv')
# Garnet ----
garnet <- as_tibble(cbind(grt_labels,grt_elems1)) %>%
  mutate(GROUP = 'GARNET') %>%
  mutate(SPOT = as.character(SPOT))
write.csv(garnet, 'data_input/garnet_rf.csv')
# Ilmenites ----
ilmenite <- as_tibble(cbind(ilm_labels,ilm_elems1)) %>%
  mutate(GROUP = 'ILMENITE') %>%
  mutate(SPOT = as.character(SPOT))
write.csv(ilmenite, 'data_input/ilmenite_rf.csv')
# Mica ----
mica <- as_tibble(cbind(mica_labels,mica_elems1)) %>%
  mutate(GROUP = 'MICA') %>%
  mutate(SPOT = as.character(SPOT))
write.csv(mica, 'data_input/mica_rf.csv')
# Olivine ----
oliv <- as_tibble(cbind(oliv_labels,oliv_elems1)) %>%
  mutate(GROUP = 'OLIVINE') %>%
  mutate(SPOT = as.character(SPOT))
write.csv(oliv, 'data_input/olivine_rf.csv')
# Perovskite ----
perov <- as_tibble(cbind(perov_labels,perov_elems1)) %>%
  mutate(GROUP = 'PEROVSKITE') %>%
  mutate(SPOT = as.character(SPOT))
write.csv(perov, 'data_input/perovskite_rf.csv')
# Pyroxene ----
px <- as_tibble(cbind(px_labels,px_elems1)) %>%
  mutate(GROUP = 'PYROXENE') %>%
  mutate(SPOT = as.character(SPOT))
write.csv(px, 'data_input/pyroxene_rf.csv')
# Quartz ----
qtz <- as_tibble(cbind(qtz_labels,qtz_elems1)) %>%
  mutate(GROUP = 'QUARTZ') %>%
  mutate(SPOT = as.character(SPOT))
write.csv(qtz, 'data_input/quartz_rf.csv')
# Spinel ----
spin <- as_tibble(cbind(spin_labels,spin_elems1)) %>%
  mutate(GROUP = 'SPINEL') %>%
  mutate(SPOT = as.character(SPOT))
write.csv(spin, 'data_input/spinel_rf.csv')
# Sulfide ----
sulf <- as_tibble(cbind(sulf_labels,sulf_elems1)) %>%
  mutate(GROUP = 'SULFIDE')
write.csv(sulf, 'data_input/sulfide_rf.csv')
# Titanite ----
titan <- as_tibble(cbind(titan_labels,titan_elems1)) %>%
  mutate(GROUP = 'TITANITE') %>%
  mutate(SPOT = as.character(SPOT))
write.csv(titan, 'data_input/titanite_rf.csv')
# Zircon ----
zirc <- as_tibble(cbind(zirc_labels,zirc_elems1)) %>%
  mutate(GROUP = 'ZIRCON') %>%
  mutate(SPOT = as.character(SPOT))
write.csv(zirc, 'data_input/zirc_rf.csv')




#####
# JOINING DATA 
#####

# CLEANING UP THE ENVIROMENT ----
remove(amph_labels,amph_elems, apat_labels, apat_elems,carb_labels,carb_elems,
       clay_labels,clay_elems,felds_labels,felds_elems,foid_labels,foid_elems,
       grt_labels,grt_elems,ilm_labels,ilm_elems,mica_labels,mica_elems,
       oliv_labels,oliv_elems,perov_labels,perov_elems,px_labels,px_elems,
       qtz_labels,qtz_elems,spin_labels,spin_elems,sulf_labels,sulf_elems,
       titan_labels,titan_elems,zirc_labels,zirc_elems)

# MERGING DATA FRAMES ----

minerals <- amphiboles %>%
  bind_rows(apat, carb, clay, felds, foid, garnet, ilmenite, mica,
            oliv, perov, px, qtz, spin, sulf, titan, zirc)

# WRITING JOINED DATA FRAMES ----
write.csv(minerals, 'data_input/minerals.csv')

