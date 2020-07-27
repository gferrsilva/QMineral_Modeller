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

setwd("~/GitHub/MinChem_Modeller") # defining the work direction
set.seed(123) # defining the 'random state' of the pseudo-random generator

selection <- c('SIO2(WT%)', 'TIO2(WT%)', 'AL2O3(WT%)', 'CR2O3(WT%)', 
               'FEOT(WT%)','CAO(WT%)','MGO(WT%)','MNO(WT%)','K2O(WT%)',
               'NA2O(WT%)','P2O5(WT%)','H2O(WT%)','F(WT%)','CL(WT%)',
               'NIO(WT%)','CUO(WT%)','COO(WT%)','ZNO(WT%)','AS(PPM)',
               'PBO(WT%)','S(WT%)','ZRO2(WT%)')

# Simplifcação dos elementos electionados acima
elems_names <- c('SiO2','TiO2','Al2O3','Cr2O3','FeO','CaO',
                 'MgO','MnO','K2O','Na2O','P2O5','H20','F','Cl',
                 'NiO','CuO','CoO','ZnO','As_ppm','PbO','S','ZrO2')

#####
#Import Packages
#####

library(tidyverse) # Collection of libraries: dplyr, ggplot2, purrr, tidyr. Data wrangling and visualizing
library(missRanger)
#####
# Built-in Functions
#####

#####
# PREPRARING DATA 
#####

# SMOTE calculated minerals


# Blind Pyroxene

# pyroxene <- read_csv('data_input/minerals.csv') %>% # Read file and associate to an object
#   select(1,47,19,14,3,25:46) %>% # select and reorder the columns
#   mutate(id = X1, X1 = NULL) %>% # Rename Column
#   mutate(AS_ppm = ifelse(AS_ppm > 100, AS_ppm/10000, # Adjusting values of column
#                          ifelse(AS_ppm > 50, AS_ppm/10, AS_ppm))) %>%
#   mutate(AS = AS_ppm, AS_ppm = NULL, # Rename columns
#          ROCK = `ROCK NAME`, `ROCK NAME` = NULL,
#          SAMPLE = `SAMPLE NAME`, `SAMPLE NAME` = NULL) %>%
#   filter(GROUP == 'PYROXENE') %>%
#   select(24,27, 1:2,26, 3:23,25) %>% # Reorder Columns
#   rename(SiO2 = SIO2,
#          TiO2 = TIO2,
#          Al2O3 = AL2O3,
#          Cr2O3 = CR2O3,
#          FeO = FEOT,
#          MnO = MNO,
#          MgO = MGO,
#          CaO = CAO,
#          Na2O = NA2O)

# 
# 
# cpx <- read_csv('data_RAW/GEOROC/CLINOPYROXENES.csv', n_max = 40906,progress = T,skip_empty_rows = T) # Read file and associate to an object
# 
# cpx <- cpx %>%
#   # select(1:89) %>%
#   filter(!is.na(`SIO2(WT%)`))
# 
# cpx_labels <- cpx[1:23]
# 
# cpx_elems <- cpx %>%
#   mutate(`PbO(WT%)` = 0,
#          `CuO(WT%)` = 0,
#          `S(WT%)` = 0) %>%
#   #`AS(PPM)` = 0) %>%
#   #        `ZN(WT%)` = NA,
#   #        `AS(WT%)` = NA,
#   #        `PB(WT%)` = NA) %>%
#   select(all_of(selection))
# 
# names(cpx_elems) <- elems_names
# 
# cpx_elems <- sapply(cpx_elems,as.numeric)
# cpx_elems <- as_tibble(cpx_elems)
# 
# cpx_elems1 <- as_tibble(sapply(cpx_elems, replace_na, 0))
#   
# cpx <- as_tibble(cbind(cpx_labels,cpx_elems1)) %>%
#   mutate(GROUP = 'PYROXENE') %>%
#   mutate(SPOT = as.character(SPOT))
# 
# cpx <- as_tibble(cbind(cpx_labels,cpx_elems1)) %>%
#   mutate(GROUP = 'PYROXENE') %>%
#   mutate(id = row_number()) %>%
#   mutate(SPOT = as.character(SPOT)) %>%
#   select(47,1:46) %>%
#   select(1,47,19,14,3,25:46) %>% # select and reorder the columns
#   mutate(As_ppm = ifelse(As_ppm > 100, As_ppm/10000, # Adjusting values of column
#                          ifelse(As_ppm > 50, As_ppm/10, As_ppm))) %>%
#   mutate(As = As_ppm, As_ppm = NULL, # Rename columns
#          ROCK = `ROCK NAME`, `ROCK NAME` = NULL,
#          SAMPLE = `SAMPLE NAME`, `SAMPLE NAME` = NULL) %>%
#   select(1,27,2,3,26,4:25) # Reorder Columns
# 
# remove(cpx_elems,cpx_elems1,cpx_labels)
# ###
# 
# opx <- read_csv('data_RAW/GEOROC/ORTHOPYROXENES.csv', n_max = 44841) # Read file and associate to an object
# 
# opx <- opx %>%
#   # select(1:89) %>%
#   filter(!is.na(`SIO2(WT%)`))
# 
# opx_labels <- opx[1:23]
# 
# opx_elems <- opx %>%
#   mutate(`PBO(WT%)` = 0,
#          `CUO(WT%)` = 0,
#          `S(WT%)` = 0) %>%
#   #`AS(PPM)` = 0) %>%
#   #        `ZN(WT%)` = NA,
#   #        `AS(WT%)` = NA,
#   #        `PB(WT%)` = NA) %>%
#   select(all_of(selection))
# 
# names(opx_elems) <- elems_names
# 
# opx_elems <- sapply(opx_elems,as.numeric)
# opx_elems <- as_tibble(opx_elems)
# 
# opx_elems1 <- as_tibble(sapply(opx_elems, replace_na, 0))
# 
# opx <- as_tibble(cbind(opx_labels,opx_elems1)) %>%
#   mutate(GROUP = 'PYROXENE') %>%
#   mutate(id = row_number()) %>%
#   mutate(SPOT = as.character(SPOT)) %>%
#   select(47,1:46) %>%
#   select(1,47,19,14,3,25:46) %>% # select and reorder the columns
#   mutate(As_ppm = ifelse(As_ppm > 100, AS_ppm/10000, # Adjusting values of column
#                          ifelse(As_ppm > 50, As_ppm/10, As_ppm))) %>%
#   mutate(As = As_ppm, As_ppm = NULL, # Rename columns
#          ROCK = `ROCK NAME`, `ROCK NAME` = NULL,
#          SAMPLE = `SAMPLE NAME`, `SAMPLE NAME` = NULL) %>%
#   select(1,27,2,3,26,4:25) # Reorder Columns
# 
# remove(opx_elems,opx_elems1,opx_labels)
# 
# 
# ## 
# 
# px_blind <- read_csv('data_RAW/GEOROC/PYROXENES.csv', n_max = 15056) # Read file and associate to an object
# 
# px_blind <- px_blind %>%
#   # select(1:89) %>%
#   filter(!is.na(`SIO2(WT%)`))
# 
# px_blind_labels <- px_blind[1:23]
# 
# px_blind_elems <- px_blind %>%
#   mutate(`PBO(WT%)` = 0,
#          `CUO(WT%)` = 0,
#          `S(WT%)` = 0,
#          `COO(WT%)` = 0) %>%
#   select(all_of(selection))
# 
# names(px_blind_elems) <- elems_names
# 
# px_blind_elems <- sapply(px_blind_elems,as.numeric)
# px_blind_elems <- as_tibble(px_blind_elems)
# 
# px_blind_elems1 <- as_tibble(sapply(px_blind_elems, replace_na, 0))
# 
# px_blind <- as_tibble(cbind(px_blind_labels,px_blind_elems1)) %>%
#   mutate(GROUP = 'PYROXENE') %>%
#   mutate(SPOT = as.character(SPOT))
# 
# px_blind <- as_tibble(cbind(px_blind_labels,px_blind_elems1)) %>%
#   mutate(GROUP = 'PYROXENE') %>%
#   mutate(id = row_number()) %>%
#   mutate(SPOT = as.character(SPOT)) %>%
#   select(47,1:46) %>%
#   select(1,47,19,14,3,25:46) %>% # select and reorder the columns
#   mutate(As_ppm = ifelse(As_ppm > 100, As_ppm/10000, # Adjusting values of column
#                          ifelse(As_ppm > 50, As_ppm/10, As_ppm))) %>%
#   mutate(As = As_ppm, As_ppm = NULL, # Rename columns
#          ROCK = `ROCK NAME`, `ROCK NAME` = NULL,
#          SAMPLE = `SAMPLE NAME`, `SAMPLE NAME` = NULL) %>%
#   select(1,27,2,3,26,4:25) # Reorder Columns
# 
# px_blind <- px_blind %>%
#   mutate(As = 0)
# 
# remove(px_blind_elems,px_blind_elems1,px_blind_labels)
# 
# #####
# 
# pyroxene <- bind_rows(opx, cpx, px_blind)

els <- c('SiO2','TiO2','Al2O3','Cr2O3','FeO','MnO', 'MgO','CaO', 'Na2O')
px <- pyroxene %>% select(all_of(els), MINERAL) #%>%

formula <- tibble(.rows = nrow(px))

formula$mineral <- px$MINERAL
formula$Si_mole <- px$SiO2*1/60.0843
formula$Si_oxygen <- px$SiO2*2/60.0843

formula$Ti_mole <- px$TiO2*1/79.8988
formula$Ti_oxygen <- px$TiO2*2/79.8988

formula$Al_mole <- px$Al2O3*2/101.9613
formula$Al_oxygen <- px$Al2O3*3/101.9613

formula$Cr_mole <- px$Cr2O3*2/159.6922
formula$Cr_oxygen <- px$Cr2O3*3/159.6922

formula$Fe_mole <- px$FeO*1/71.8464
formula$Fe_oxygen <- px$FeO*1/71.8464

formula$Mn_mole <- px$MnO*1/70.9374
formula$Mn_oxygen <- px$MnO*1/70.9374

formula$Mg_mole <- px$MgO*1/40.3044
formula$Mg_oxygen <- px$MgO*1/40.3044

formula$Ca_mole <- px$CaO*1/56.0794
formula$Ca_oxygen <- px$CaO*1/56.0794

formula$Na_mole <- px$Na2O*2/61.979
formula$Na_oxygen <- px$Na2O*1/61.9794


formula$mole_cations_total <- formula %>%
  select(ends_with('_mole')) %>%
  mutate(sum = rowSums(.)) %>%
  select('sum')

formula$mole_oxygen_total <- formula %>%
  select(ends_with('_oxygen')) %>%
  mutate(sum = rowSums(.)) %>%
  select('sum')


formula$Si_norm_cations <- 4*formula$Si_mole/formula$mole_cations_total
formula$Ti_norm_cations <- 4*formula$Ti_mole/formula$mole_cations_total
formula$Al_norm_cations <- 4*formula$Al_mole/formula$mole_cations_total
formula$Cr_norm_cations <- 4*formula$Cr_mole/formula$mole_cations_total
formula$Fe_norm_cations <- 4*formula$Fe_mole/formula$mole_cations_total
formula$Mn_norm_cations <- 4*formula$Mn_mole/formula$mole_cations_total
formula$Mg_norm_cations <- 4*formula$Mg_mole/formula$mole_cations_total
formula$Ca_norm_cations <- 4*formula$Ca_mole/formula$mole_cations_total
formula$Na_norm_cations <- 4*formula$Na_mole/formula$mole_cations_total

formula$norm_cations_total <- formula %>%
  select(ends_with('_norm_cations')) %>%
  mutate(sum = rowSums(.)) %>%
  select('sum')

formula$Si_norm_oxygen <- formula$Si_norm_cations*2/1
formula$Ti_norm_oxygen <- formula$Ti_norm_cations*2/1
formula$Al_norm_oxygen <- formula$Al_norm_cations*3/2
formula$Cr_norm_oxygen <- formula$Cr_norm_cations*3/2
formula$Fe_norm_oxygen <- formula$Fe_norm_cations*1/1
formula$Mn_norm_oxygen <- formula$Mn_norm_cations*1/1
formula$Mg_norm_oxygen <- formula$Mg_norm_cations*1/1
formula$Ca_norm_oxygen <- formula$Ca_norm_cations*1/1
formula$Na_norm_oxygen <- formula$Na_norm_cations*1/2

formula$norm_oxygen_total <- formula %>%
  select(ends_with('_norm_oxygen')) %>%
  mutate(sum = rowSums(.)) %>%
  select('sum')

formula <- as_tibble(as.matrix(formula))

formula <- formula %>%
  mutate_at(2:41, as.numeric)

formula$Si_atom <- formula$Si_norm_cations
formula$Ti_atom <- formula$Ti_norm_cations
formula$Al_atom <- formula$Al_norm_cations
formula$Cr_atom <- formula$Cr_norm_cations
formula$Mn_atom <- formula$Mn_norm_cations
formula$Mg_atom <- formula$Mg_norm_cations
formula$Ca_atom <- formula$Ca_norm_cations
formula$Na_atom <- formula$Na_norm_cations
formula$Fe3_atom <- ifelse(test = 6 - formula$norm_oxygen_total > 0,
                           yes = ifelse(test = formula$Fe_norm_oxygen > 2*(6 - formula$norm_oxygen_total),
                                  yes = 2*(6 - formula$norm_oxygen_total),no = formula$Fe_norm_oxygen),
                           no = 0)
  
formula$Fe2_atom <- formula$Fe_norm_cations - formula$Fe3_atom

formula <- formula %>%
  mutate(Wollastonite = round(100*Ca_atom/(Fe2_atom + Ca_atom + Mg_atom),2),
         Enstatite = round(100*Mg_atom/(Fe2_atom + Ca_atom + Mg_atom),2),
         Ferrosilite = round(100*Fe2_atom/(Fe2_atom + Ca_atom + Mg_atom),2),
         Aegerine = round(100*Fe3_atom/(Fe3_atom + Na_atom + Ca_atom),2),
         Jadeite = round(100*Na_atom/(Fe3_atom + Na_atom + Ca_atom),2),
         Diopside = round(100*Ca_atom/(Fe3_atom + Na_atom + Ca_atom),2),
         Ortho_Calcic_total = Wollastonite + Enstatite + Ferrosilite,
         Sodic_Calcic_total = Aegerine + Jadeite + Diopside)
         

formula <- formula %>%
  mutate(Classification = ifelse(test = Na_atom > Fe3_atom,
         yes = ifelse(test = Aegerine > Jadeite & Aegerine > Diopside, yes = 'Aegerine',
                      no = ifelse(test = Jadeite > Aegerine & Jadeite > Diopside, yes = 'Jadeite',
                      no = 'Diopside')),
         no = ifelse(test = Wollastonite > Enstatite & Wollastonite > Ferrosilite, yes = 'Wollastonite',
                     no = ifelse(test = Enstatite > Wollastonite & Enstatite > Ferrosilite, yes = 'Enstatite',
                      no = 'Ferrosilite'))))
formula %>%
  group_by(Classification) %>%
  count()
         
px <- bind_cols(px, formula[52:60])

pca <- prcomp(px[1:9],center = T)

df <- bind_cols(px, as_tibble(pca$x))         

df %>%
  gather(key = element, value = `WT(%)`, 1:9) %>%
  ggplot(aes(x = PC1,
             y = PC2,
             col = `WT(%)`)) +
  geom_point(alpha = .4) +
  scale_color_viridis_c(option = 'A') +
  # scale_color_binned(type = 'viridis') +
  facet_wrap(~element,
             nrow = 2,
             scales = 'free',)

df %>%
  filter(!is.na(Classification)) %>%
  gather(key = element, value = measure, 1:8) %>%
  ggplot(aes(x = PC1,
             y = PC2,
             col = Classification)) +
  geom_point(alpha = .4)
