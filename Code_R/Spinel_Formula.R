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

#####
#Import Packages
#####

library(tidyverse) # Collection of libraries: dplyr, ggplot2, purrr, tidyr. Data wrangling and visualizing

#####
# Built-in Functions
#####

#####
# PREPRARING DATA 
#####

# SMOTE calculated minerals

# spn <- read_csv('./data_train/SMOTE_Random_Sampler.csv') %>%
#   filter(GROUP == 'SPINEL') %>%
#   rename(Index = X1,
#          SiO2 = SIO2,
#          TiO2 = TIO2,
#          Al2O3 = AL2O3,
#          Cr2O3 = CR2O3,
#          FeO = FEOT,
#          MnO = MNO,
#          MgO = MGO,
#          ZnO = ZNO)

spn <- read_csv('./data_input/SMOTE/Other/minerals_toSMOTE.csv') %>%
  filter(GROUP == 'SPINEL') %>%
  group_by(MINERAL) %>%
  sample_n(15, replace = T) %>%
  select(2:5,7:28) %>%
  rename(SiO2 = SIO2,
         TiO2 = TIO2,
         Al2O3 = AL2O3,
         Cr2O3 = CR2O3,
         FeO = FEOT,
         MnO = MNO,
         MgO = MGO,
         ZnO = ZNO) %>%
  ungroup()

els <- c('SiO2','TiO2','Al2O3','Cr2O3','FeO','MnO', 'MgO','ZnO')

formula <- tibble(.rows = nrow(spn))

total <- spn %>%
  select(all_of(els)) %>%
  select_if(is.numeric) %>%
  mutate(Total = rowSums(.)) %>%
  select('Total')

formula <- bind_cols(formula, spn$MINERAL, total)

formula$Si_mole <- spn$SiO2*1/60.0843
formula$Si_oxygen <- spn$SiO2*2/60.0843

formula$Ti_mole <- spn$TiO2*1/79.8988
formula$Ti_oxygen <- spn$TiO2*2/79.8988

formula$Al_mole <- spn$Al2O3*2/101.9613
formula$Al_oxygen <- spn$Al2O3*3/101.9613

formula$Cr_mole <- spn$Cr2O3*2/159.6922
formula$Cr_oxygen <- spn$Cr2O3*3/159.6922

formula$Fe_mole <- spn$FeO*1/71.8464
formula$Fe_oxygen <- spn$FeO*1/71.8464

formula$Mn_mole <- spn$MnO*1/70.9374
formula$Mn_oxygen <- spn$MnO*1/70.9374

formula$Mg_mole <- spn$MgO*1/40.3044
formula$Mg_oxygen <- spn$MgO*1/40.3044

formula$Zn_mole <- spn$ZnO*1/81.38
formula$Zn_oxygen <- spn$ZnO*1/81.38

formula$mole_cations_total <- formula %>%
  select(ends_with('_mole')) %>%
  mutate(sum = rowSums(.)) %>%
  select(9)

formula$mole_oxygen_total <- formula %>%
  select(ends_with('_oxygen')) %>%
  mutate(sum = rowSums(.)) %>%
  select(9)


formula$Si_norm_cations <- 3*formula$Si_mole/formula$mole_cations_total
formula$Ti_norm_cations <- 3*formula$Ti_mole/formula$mole_cations_total
formula$Al_norm_cations <- 3*formula$Al_mole/formula$mole_cations_total
formula$Cr_norm_cations <- 3*formula$Cr_mole/formula$mole_cations_total
formula$Fe_norm_cations <- 3*formula$Fe_mole/formula$mole_cations_total
formula$Mn_norm_cations <- 3*formula$Mn_mole/formula$mole_cations_total
formula$Mg_norm_cations <- 3*formula$Mg_mole/formula$mole_cations_total
formula$Zn_norm_cations <- 3*formula$Zn_mole/formula$mole_cations_total

formula$norm_cations_total <- formula %>%
  select(ends_with('_norm_cations')) %>%
  mutate(sum = rowSums(.)) %>%
  select(9)

formula$Si_norm_oxygen <- formula$Si_norm_cations*2/1
formula$Ti_norm_oxygen <- formula$Ti_norm_cations*2/1
formula$Al_norm_oxygen <- formula$Al_norm_cations*3/2
formula$Cr_norm_oxygen <- formula$Cr_norm_cations*3/2
formula$Fe_norm_oxygen <- formula$Fe_norm_cations*1/1
formula$Mn_norm_oxygen <- formula$Mn_norm_cations*1/1
formula$Mg_norm_oxygen <- formula$Mg_norm_cations*1/1
formula$Zn_norm_oxygen <- formula$Zn_norm_cations*1/1

formula$norm_oxygen_total <- formula %>%
  select(ends_with('_norm_oxygen')) %>%
  mutate(sum = rowSums(.)) %>%
  select(9)

formula <- as_tibble(as.matrix(formula))

formula <- as_tibble(sapply(formula[2:ncol(formula)], as.numeric))

formula <- formula %>%
  mutate(calculated_charge = 4*(Si_norm_cations + Ti_norm_cations) +
           3*(Al_norm_cations + Cr_norm_cations) +
           2*(Fe_norm_cations + Zn_norm_cations + Mn_norm_cations + Mg_norm_cations))

formula$Si_atom <- formula$Si_norm_cations
formula$Ti_atom <- formula$Ti_norm_cations
formula$Al_atom <- formula$Al_norm_cations
formula$Cr_atom <- formula$Cr_norm_cations
formula$Mn_atom <- formula$Mn_norm_cations
formula$Mg_atom <- formula$Mg_norm_cations
formula$Zn_atom <- formula$Zn_norm_cations
formula$Fe3_atom <- ifelse(test = 8 - formula$calculated_charge > 0,
                           yes = 8 - formula$calculated_charge,
                           no =  0)
formula$Fe2_atom <- ifelse(formula$Fe_norm_cations - formula$Fe3_atom > 0, 
                           yes = formula$Fe_norm_cations - formula$Fe3_atom, 0)


formula$X_Mg <- formula$Mg_atom
formula$X_Fe <- formula$Fe2_atom
formula$X_Zn <- formula$Zn_atom
formula$X_Ti <- formula$Ti_atom

X_total <- formula %>%
  select(starts_with('X_')) %>%
  mutate(sum = rowSums(.)) %>%
  select('sum') %>%
  rename(X_total = sum)
formula <- bind_cols(formula, X_total)
remove(X_total)

formula$Y_Al <- formula$Al_atom
formula$Y_Fe <- formula$Fe3_atom
formula$Y_Cr <- formula$Cr_atom

Y_total <- formula %>%
  select(starts_with('Y_')) %>%
  mutate(sum = rowSums(.)) %>%
  select('sum') %>%
  rename(Y_total = sum)
formula <- bind_cols(formula, Y_total)
remove(Y_total)

# Graph ----

# formula %>%
#   ggplot(aes(X_total, Y_total, col = Total)) +
#   geom_jitter(width = .1,height = .1) +
#   scale_color_viridis_c()
# 
# formula %>%
#   ggplot(aes(X_total, Y_total, col = Total)) +
#   geom_hex() +
#   scale_fill_viridis_c()
