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

# grt <- read_csv('./data_train/SMOTE_Random_Sampler.csv') %>%
#   filter(GROUP == 'GARNET') %>%
#   select(1:9,24:25) %>%
#   rename(Index = X1,
#          SiO2 = SIO2,
#          TiO2 = TIO2,
#          Al2O3 = AL2O3,
#          Cr2O3 = CR2O3,
#          FeO = FEOT,
#          MnO = MNO,
#          MgO = MGO,
#          CaO = CAO)

# Real minerals to SMOTE

# grt <- read_csv('./data_input/SMOTE/Other/minerals_toSMOTE.csv') %>%
#   filter(GROUP == 'GARNET') %>%
#   group_by(MINERAL) %>%
#   sample_n(15, replace = T) %>%
#   select(2:5,7:14) %>%
#   rename(SiO2 = SIO2,
#          TiO2 = TIO2,
#          Al2O3 = AL2O3,
#          Cr2O3 = CR2O3,
#          FeO = FEOT,
#          MnO = MNO,
#          MgO = MGO,
#          CaO = CAO)
 
# Blind garnet

grt <- read_csv('data_input/minerals.csv') %>% # Read file and associate to an object
  select(1,47,19,14,3,25:46) %>% # select and reorder the columns
  mutate(id = X1, X1 = NULL) %>% # Rename Column
  mutate(AS_ppm = ifelse(AS_ppm > 100, AS_ppm/10000, # Adjusting values of column
                         ifelse(AS_ppm > 50, AS_ppm/10, AS_ppm))) %>%
  mutate(AS = AS_ppm, AS_ppm = NULL, # Rename columns
         ROCK = `ROCK NAME`, `ROCK NAME` = NULL,
         SAMPLE = `SAMPLE NAME`, `SAMPLE NAME` = NULL) %>%
  filter(GROUP == 'GARNET') %>%
  select(24,27, 1:2,26, 3:23,25) %>% # Reorder Columns
  rename(SiO2 = SIO2,
         TiO2 = TIO2,
         Al2O3 = AL2O3,
         Cr2O3 = CR2O3,
         FeO = FEOT,
         MnO = MNO,
         MgO = MGO,
         CaO = CAO)



# tabper <- read_delim('references/periodictable.txt',
#                      delim = '\t')
els <- c('SiO2','TiO2','Al2O3','Cr2O3','FeO','MnO', 'MgO','CaO')
gr <- grt %>% select(all_of(els)) #%>%
#  mutate(Total = rowSums(.))


formula <- tibble(.rows = nrow(gr))

formula$mineral <- gr$MINERAL
formula$Si_mole <- gr$SiO2*1/60.0843
formula$Si_oxygen <- gr$SiO2*2/60.0843
  
formula$Ti_mole <- gr$TiO2*1/79.8988
formula$Ti_oxygen <- gr$TiO2*2/79.8988
  
formula$Al_mole <- gr$Al2O3*2/101.9613
formula$Al_oxygen <- gr$Al2O3*3/101.9613

formula$Cr_mole <- gr$Cr2O3*2/159.6922
formula$Cr_oxygen <- gr$Cr2O3*3/159.6922

formula$Fe_mole <- gr$FeO*1/71.8464
formula$Fe_oxygen <- gr$FeO*1/71.8464

formula$Mn_mole <- gr$MnO*1/70.9374
formula$Mn_oxygen <- gr$MnO*1/70.9374

formula$Mg_mole <- gr$MgO*1/40.3044
formula$Mg_oxygen <- gr$MgO*1/40.3044

formula$Ca_mole <- gr$CaO*1/56.0794
formula$Ca_oxygen <- gr$CaO*1/56.0794

formula$mole_cations_total <- formula %>%
  select(ends_with('_mole')) %>%
  mutate(sum = rowSums(.)) %>%
  select(9)

formula$mole_oxygen_total <- formula %>%
  select(ends_with('_oxygen')) %>%
  mutate(sum = rowSums(.)) %>%
  select(9)
         

formula$Si_norm_cations <- 8*formula$Si_mole/formula$mole_cations_total
formula$Ti_norm_cations <- 8*formula$Ti_mole/formula$mole_cations_total
formula$Al_norm_cations <- 8*formula$Al_mole/formula$mole_cations_total
formula$Cr_norm_cations <- 8*formula$Cr_mole/formula$mole_cations_total
formula$Fe_norm_cations <- 8*formula$Fe_mole/formula$mole_cations_total
formula$Mn_norm_cations <- 8*formula$Mn_mole/formula$mole_cations_total
formula$Mg_norm_cations <- 8*formula$Mg_mole/formula$mole_cations_total
formula$Ca_norm_cations <- 8*formula$Ca_mole/formula$mole_cations_total

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
formula$Ca_norm_oxygen <- formula$Ca_norm_cations*1/1

formula$norm_oxygen_total <- formula %>%
  select(ends_with('_norm_oxygen')) %>%
  mutate(sum = rowSums(.)) %>%
  select(9)

formula <- as_tibble(as.matrix(formula))

formula <- as_tibble(sapply(formula[2:ncol(formula)], as.numeric))

formula <- formula %>%
  mutate(calculated_charge = 4*(Si_norm_cations + Ti_norm_cations) +
           3*(Al_norm_cations + Cr_norm_cations) +
           2*(Fe_norm_cations + Ca_norm_cations + Mn_norm_cations + Mg_norm_cations))

formula$Si_atom <- formula$Si_norm_cations
formula$Ti_atom <- formula$Ti_norm_cations
formula$Al_atom <- formula$Al_norm_cations
formula$Cr_atom <- formula$Cr_norm_cations
formula$Mn_atom <- formula$Mn_norm_cations
formula$Mg_atom <- formula$Mg_norm_cations
formula$Ca_atom <- formula$Ca_norm_cations
formula$Fe3_atom <- ifelse(test = 24.0 - formula$calculated_charge > 0,
                           yes = 24.0 - formula$calculated_charge,
                           no =  0)
formula$Fe2_atom <- ifelse(formula$Fe_norm_cations - formula$Fe3_atom > 0, 
                           yes = formula$Fe_norm_cations - formula$Fe3_atom, 0)

formula <- formula %>%
  mutate(almandine = round(100*Fe2_atom/(Fe2_atom + Mn_atom + Mg_atom + Ca_atom),2),
         pyrope = round(100*Mg_atom/(Fe2_atom + Mn_atom + Mg_atom + Ca_atom),2),
         grossular = round(100*(Ca_atom/(Fe2_atom + Mn_atom + Mg_atom + Ca_atom))*
           (Al_atom/(Ti_atom + Al_atom + Cr_atom + Fe3_atom)),2),
         spessartine = round(100*Mn_atom/(Fe2_atom + Mn_atom + Mg_atom + Ca_atom),2),
         uvarovite = round(100*(Cr_atom/(Fe2_atom + Mn_atom + Mg_atom + Ca_atom))*
           (Ca_atom/(Ti_atom + Al_atom + Cr_atom + Fe3_atom)),2),
         andradite = round(100*(Fe3_atom/(Fe2_atom + Mn_atom + Mg_atom + Ca_atom))*
           (Ca_atom/(Ti_atom + Al_atom + Cr_atom + Fe3_atom)),2),
         CaTi_Grt = round(100*(Ti_atom/(Fe2_atom + Mn_atom + Mg_atom + Ca_atom))*
           (Ca_atom/(Ti_atom + Al_atom + Cr_atom + Fe3_atom)),2),
         Mol_Total = (almandine + pyrope + grossular + spessartine + uvarovite + andradite + CaTi_Grt))

grt1 <- bind_cols(gr, formula[46:53], grt[c('MINERAL')])

grt1 <- grt1 %>%
  mutate(Classification = ifelse(test = (almandine > pyrope &
                                           almandine > grossular &
                                           almandine > spessartine &
                                           almandine > uvarovite &
                                           almandine > andradite &
                                           almandine > CaTi_Grt),
                                 yes = 'Almandine',
                                 no = ifelse(test = (pyrope > almandine &
                                                       pyrope > grossular &
                                                       pyrope > spessartine &
                                                       pyrope > uvarovite &
                                                       pyrope > andradite &
                                                       pyrope > CaTi_Grt),
                                yes = 'Pyrope',
                                no = ifelse(test = (grossular > pyrope &
                                                      grossular > almandine &
                                                      grossular > spessartine &
                                                      grossular > uvarovite &
                                                      grossular > andradite &
                                                      grossular > CaTi_Grt),
                                yes = 'Grossular', 
                                no = ifelse(test = (spessartine > pyrope &
                                                      spessartine > grossular &
                                                      spessartine > almandine &
                                                      spessartine > uvarovite &
                                                      spessartine > andradite &
                                                      spessartine > CaTi_Grt),
                                yes = 'Spessartine',
                                no = ifelse(test = (uvarovite > pyrope &
                                                      uvarovite > grossular &
                                                      uvarovite > spessartine &
                                                      uvarovite > almandine &
                                                      uvarovite > andradite &
                                                      uvarovite > CaTi_Grt),
                                yes = 'Uvarovite',
                                no = ifelse(test = (andradite > pyrope &
                                                      andradite > grossular &
                                                      andradite > spessartine &
                                                      andradite > uvarovite &
                                                      andradite > almandine &
                                                      andradite > CaTi_Grt),
                                yes = 'Andradite',
                                no = ifelse(test = (CaTi_Grt > pyrope &
                                                      CaTi_Grt > grossular &
                                                      CaTi_Grt > spessartine &
                                                      CaTi_Grt > uvarovite &
                                                      CaTi_Grt > andradite &
                                                      CaTi_Grt > almandine),
                                yes = 'Ca-Ti Garnet',
                                no = NA))))))),
         Total = (CaO + SiO2 + Al2O3 + TiO2 + MnO + FeO + Cr2O3 + MgO))

grt1 %>%
  filter(Total > 95 &
           Total < 105) %>%
  group_by(Classification) %>%
  count()

df <- grt1  #%>%
  # filter(Total > 95 &
  #          Total < 105)

pca <- prcomp(df[1:8])

df <- df %>%
  bind_cols(as_tibble(pca$x))

# df %>%
#   filter(!is.na(Classification)) %>%
#   sample_frac(.01) %>%
#   gather(key = element, value = measure, 1:8) %>%
#   ggplot(aes(x = PC1,
#              y = PC2,
#              col = measure)) +
#   geom_point(alpha = .4) +
#   scale_color_viridis_d() +
#   # scale_color_binned(type = 'viridis') +
#   facet_wrap(~element,nrow = 2,scales = 'free',)
# 
# df %>%
#   filter(!is.na(Classification)) %>%
#   # sample_frac(.01) %>%
#   gather(key = element, value = measure, 1:8) %>%
#   ggplot(aes(x = PC1,
#              y = PC2,
#              col = Classification)) +
#   geom_point(alpha = .4)

df %>%
  group_by(Classification) %>%
  count()
