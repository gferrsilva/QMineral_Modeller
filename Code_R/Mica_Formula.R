<<<<<<< HEAD
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

els <- c('SiO2','TiO2','Al2O3','FeO','MnO', 'MgO','CaO', 'Na2O', 'K2O','F','CL')
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
 
# mica <- read_csv('data_input/minerals.csv') %>% # Read file and associate to an object
#   select(1,47,19,14,3,25:46) %>% # select and reorder the columns
#   mutate(id = X1, X1 = NULL) %>% # Rename Column
#   mutate(AS_ppm = ifelse(AS_ppm > 100, AS_ppm/10000, # Adjusting values of column
#                          ifelse(AS_ppm > 50, AS_ppm/10, AS_ppm))) %>%
#   mutate(AS = AS_ppm, AS_ppm = NULL, # Rename columns
#          ROCK = `ROCK NAME`, `ROCK NAME` = NULL,
#          SAMPLE = `SAMPLE NAME`, `SAMPLE NAME` = NULL) %>%
#   filter(GROUP == 'MICA') %>%
#   select(24,27, 1:2,26, 3:23,25) %>% # Reorder Columns
#   rename(SiO2 = SIO2,
#          TiO2 = TIO2,
#          Al2O3 = AL2O3,
#          FeO = FEOT,
#          MnO = MNO,
#          MgO = MGO,
#          CaO = CAO,
#          Na2O = NA2O,
#          Cl = CL,
#          Cr2O3 = CR2O3,
#          Fluor = `F`)

mica <- read_csv('./data_train/SMOTE_Random_Sampler.csv') %>%
  filter(GROUP == 'MICA') %>%
  rename(Index = X1,
         SiO2 = SIO2,
         TiO2 = TIO2,
         Al2O3 = AL2O3,
         FeO = FEOT,
         MnO = MNO,
         MgO = MGO,
         CaO = CAO,
         Na2O = NA2O,
         Cl = CL,
         Cr2O3 = CR2O3,
         Fluor = `F`)


mica$Li2O <- ifelse(test = (0.287*mica$SiO2 - 9.552) > 0,
                    yes = 0.287*mica$SiO2 - 9.552,
                    no = 0)
formula <- tibble(.rows = nrow(mica))

formula$mineral <- mica$MINERAL

formula$Si_mole <- mica$SiO2/30.045
formula$Ti_mole <- mica$TiO2/39.949
formula$Al_mole <- mica$Al2O3/33.987
formula$Cr_mole <- mica$Cr2O3/50.667
formula$Fe_mole <- mica$FeO/71.846
formula$Mn_mole <- mica$MnO/70.937
formula$Mg_mole <- mica$MgO/40.304
formula$Ca_mole <- mica$CaO/56.079
formula$Na_mole <- mica$Na2O/61.979
formula$K_mole <- mica$K2O/94.196
formula$Cl_mole <- mica$Cl/35.453
formula$F_mole <- mica$Fluor*1/18.998

formula$Li_mole <- mica$Li2O/29.887

mole_cations_total <- formula %>%
  select(ends_with('_mole')) %>%
  mutate(sum = rowSums(.)) %>%
  select('sum') %>%
  rename(mole_cations_total = sum)

formula <- bind_cols(formula, mole_cations_total)
remove(mole_cations_total)

formula$mole_cations_correct <- formula$mole_cations_total - formula$Cl_mole - formula$F_mole

formula$num_oxygen <- 22/formula$mole_cations_correct

formula$Si_norm_cations <- formula$Si_mole*formula$num_oxygen
formula$Ti_norm_cations <- formula$Ti_mole*formula$num_oxygen
formula$Al_norm_cations <- formula$Al_mole*formula$num_oxygen
formula$Cr_norm_cations <- formula$Cr_mole*formula$num_oxygen
formula$Fe_norm_cations <- formula$Fe_mole*formula$num_oxygen
formula$Mn_norm_cations <- formula$Mn_mole*formula$num_oxygen
formula$Mg_norm_cations <- formula$Mg_mole*formula$num_oxygen
formula$Ca_norm_cations <- formula$Ca_mole*formula$num_oxygen
formula$Na_norm_cations <- formula$Na_mole*formula$num_oxygen
formula$K_norm_cations <- formula$K_mole*formula$num_oxygen
formula$Cl_norm_cations <- formula$Cl_mole*formula$num_oxygen
formula$F_norm_cations <- formula$F_mole*formula$num_oxygen
formula$Li_norm_cations <- formula$Li_mole*formula$num_oxygen

formula$OH <- ifelse(test = ((4 - (formula$F_norm_cations + formula$Cl_norm_cations)) > 0),
                     yes = 4 - (formula$F_norm_cations + formula$Cl_norm_cations),
                     no = 0)

formula$Z_Si <- formula$Si_norm_cations/2
formula$Z_Al <- ifelse(test = formula$Z_Si > 8,
                       yes = 0,
                       no = ifelse(test = 2*(formula$Al_norm_cations/3) > (8 - formula$Z_Si),
                                   yes = 8 - formula$Z_Si,
                                   no = 2*(formula$Al_norm_cations/3)))

Z_sum <- formula %>%
  select(starts_with('Z_')) %>%
  mutate(sum = rowSums(.)) %>%
  select('sum') %>%
  rename(Z_sum = sum)

formula <- formula %>%
  bind_cols(Z_sum)
remove(Z_sum)

formula$Y_Al <- ifelse(test = formula$Z_Si + 2*(formula$Al_norm_cations/3) < 8,
                       yes = 0,
                       no = 2*(formula$Al_norm_cations/3) - formula$Z_Al)

formula$Y_Ti <- formula$Ti_norm_cations/2
formula$Y_Cr <- 2*formula$Cr_norm_cations/3
formula$Y_Fe <- formula$Fe_norm_cations
formula$Y_Mn <- formula$Mn_norm_cations
formula$Y_Mg <- formula$Mg_norm_cations
formula$Y_Li <- 2*formula$Li_norm_cations

Y_sum <- formula %>%
  select(starts_with('Y_')) %>%
  mutate(sum = rowSums(.)) %>%
  select('sum') %>%
  rename(Y_sum = sum)

formula <- formula %>%
  bind_cols(Y_sum)
remove(Y_sum)

formula$X_Ca <- formula$Ca_norm_cations
formula$X_Na <- 2*formula$Na_norm_cations
formula$X_K <- 2*formula$K_norm_cations

X_sum <- formula %>%
  select(starts_with('X_')) %>%
  mutate(sum = rowSums(.)) %>%
  select('sum') %>%
  rename(X_sum = sum)

formula <- formula %>%
  bind_cols(X_sum)
remove(X_sum)


formula$H_OH <- formula$OH
formula$H_F <- formula$F_norm_cations
formula$H_Cl <- formula$Cl_norm_cations

H_sum <- formula %>%
  select(starts_with('H_')) %>%
  mutate(sum = rowSums(.)) %>%
  select('sum') %>%
  rename(H_sum = sum)

formula <- formula %>%
  bind_cols(H_sum)
remove(H_sum)
=======
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

els <- c('SiO2','TiO2','Al2O3','FeO','MnO', 'MgO','CaO', 'Na2O', 'K2O','F','CL')
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
 
# mica <- read_csv('data_input/minerals.csv') %>% # Read file and associate to an object
#   select(1,47,19,14,3,25:46) %>% # select and reorder the columns
#   mutate(id = X1, X1 = NULL) %>% # Rename Column
#   mutate(AS_ppm = ifelse(AS_ppm > 100, AS_ppm/10000, # Adjusting values of column
#                          ifelse(AS_ppm > 50, AS_ppm/10, AS_ppm))) %>%
#   mutate(AS = AS_ppm, AS_ppm = NULL, # Rename columns
#          ROCK = `ROCK NAME`, `ROCK NAME` = NULL,
#          SAMPLE = `SAMPLE NAME`, `SAMPLE NAME` = NULL) %>%
#   filter(GROUP == 'MICA') %>%
#   select(24,27, 1:2,26, 3:23,25) %>% # Reorder Columns
#   rename(SiO2 = SIO2,
#          TiO2 = TIO2,
#          Al2O3 = AL2O3,
#          FeO = FEOT,
#          MnO = MNO,
#          MgO = MGO,
#          CaO = CAO,
#          Na2O = NA2O,
#          Cl = CL,
#          Cr2O3 = CR2O3,
#          Fluor = `F`)

mica <- read_csv('./data_train/SMOTE_Random_Sampler.csv') %>%
  filter(GROUP == 'MICA') %>%
  rename(Index = X1,
         SiO2 = SIO2,
         TiO2 = TIO2,
         Al2O3 = AL2O3,
         FeO = FEOT,
         MnO = MNO,
         MgO = MGO,
         CaO = CAO,
         Na2O = NA2O,
         Cl = CL,
         Cr2O3 = CR2O3,
         Fluor = `F`)


mica$Li2O <- ifelse(test = (0.287*mica$SiO2 - 9.552) > 0,
                    yes = 0.287*mica$SiO2 - 9.552,
                    no = 0)
formula <- tibble(.rows = nrow(mica))

formula$mineral <- mica$MINERAL

formula$Si_mole <- mica$SiO2/30.045
formula$Ti_mole <- mica$TiO2/39.949
formula$Al_mole <- mica$Al2O3/33.987
formula$Cr_mole <- mica$Cr2O3/50.667
formula$Fe_mole <- mica$FeO/71.846
formula$Mn_mole <- mica$MnO/70.937
formula$Mg_mole <- mica$MgO/40.304
formula$Ca_mole <- mica$CaO/56.079
formula$Na_mole <- mica$Na2O/61.979
formula$K_mole <- mica$K2O/94.196
formula$Cl_mole <- mica$Cl/35.453
formula$F_mole <- mica$Fluor*1/18.998

formula$Li_mole <- mica$Li2O/29.887

mole_cations_total <- formula %>%
  select(ends_with('_mole')) %>%
  mutate(sum = rowSums(.)) %>%
  select('sum') %>%
  rename(mole_cations_total = sum)

formula <- bind_cols(formula, mole_cations_total)
remove(mole_cations_total)

formula$mole_cations_correct <- formula$mole_cations_total - formula$Cl_mole - formula$F_mole

formula$num_oxygen <- 22/formula$mole_cations_correct

formula$Si_norm_cations <- formula$Si_mole*formula$num_oxygen
formula$Ti_norm_cations <- formula$Ti_mole*formula$num_oxygen
formula$Al_norm_cations <- formula$Al_mole*formula$num_oxygen
formula$Cr_norm_cations <- formula$Cr_mole*formula$num_oxygen
formula$Fe_norm_cations <- formula$Fe_mole*formula$num_oxygen
formula$Mn_norm_cations <- formula$Mn_mole*formula$num_oxygen
formula$Mg_norm_cations <- formula$Mg_mole*formula$num_oxygen
formula$Ca_norm_cations <- formula$Ca_mole*formula$num_oxygen
formula$Na_norm_cations <- formula$Na_mole*formula$num_oxygen
formula$K_norm_cations <- formula$K_mole*formula$num_oxygen
formula$Cl_norm_cations <- formula$Cl_mole*formula$num_oxygen
formula$F_norm_cations <- formula$F_mole*formula$num_oxygen
formula$Li_norm_cations <- formula$Li_mole*formula$num_oxygen

formula$OH <- ifelse(test = ((4 - (formula$F_norm_cations + formula$Cl_norm_cations)) > 0),
                     yes = 4 - (formula$F_norm_cations + formula$Cl_norm_cations),
                     no = 0)

formula$Z_Si <- formula$Si_norm_cations/2
formula$Z_Al <- ifelse(test = formula$Z_Si > 8,
                       yes = 0,
                       no = ifelse(test = 2*(formula$Al_norm_cations/3) > (8 - formula$Z_Si),
                                   yes = 8 - formula$Z_Si,
                                   no = 2*(formula$Al_norm_cations/3)))

Z_sum <- formula %>%
  select(starts_with('Z_')) %>%
  mutate(sum = rowSums(.)) %>%
  select('sum') %>%
  rename(Z_sum = sum)

formula <- formula %>%
  bind_cols(Z_sum)
remove(Z_sum)

formula$Y_Al <- ifelse(test = formula$Z_Si + 2*(formula$Al_norm_cations/3) < 8,
                       yes = 0,
                       no = 2*(formula$Al_norm_cations/3) - formula$Z_Al)

formula$Y_Ti <- formula$Ti_norm_cations/2
formula$Y_Cr <- 2*formula$Cr_norm_cations/3
formula$Y_Fe <- formula$Fe_norm_cations
formula$Y_Mn <- formula$Mn_norm_cations
formula$Y_Mg <- formula$Mg_norm_cations
formula$Y_Li <- 2*formula$Li_norm_cations

Y_sum <- formula %>%
  select(starts_with('Y_')) %>%
  mutate(sum = rowSums(.)) %>%
  select('sum') %>%
  rename(Y_sum = sum)

formula <- formula %>%
  bind_cols(Y_sum)
remove(Y_sum)

formula$X_Ca <- formula$Ca_norm_cations
formula$X_Na <- 2*formula$Na_norm_cations
formula$X_K <- 2*formula$K_norm_cations

X_sum <- formula %>%
  select(starts_with('X_')) %>%
  mutate(sum = rowSums(.)) %>%
  select('sum') %>%
  rename(X_sum = sum)

formula <- formula %>%
  bind_cols(X_sum)
remove(X_sum)


formula$H_OH <- formula$OH
formula$H_F <- formula$F_norm_cations
formula$H_Cl <- formula$Cl_norm_cations

H_sum <- formula %>%
  select(starts_with('H_')) %>%
  mutate(sum = rowSums(.)) %>%
  select('sum') %>%
  rename(H_sum = sum)

formula <- formula %>%
  bind_cols(H_sum)
remove(H_sum)

# t <- formula %>%
#   select(ends_with('_sum'))
>>>>>>> 3acb0c24e66aecf0043dab7d2014997fd24745b8
