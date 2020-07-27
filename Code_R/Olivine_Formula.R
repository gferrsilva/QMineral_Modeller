#####
# Mineral Group Classification by Random Forest
# 
# version: 1.0 (2020/05/20)
#
# Last modifications:
#
# -----
# Amphiboles, Apatites, Carbonates, Clay Minerals, Olivines, Feldspathoides,
# Olivines, Ilmenites, Micas, Olivines, Perovskites, Pyroxenes, Quartz, Sulfides,
# Titanite, Zircon
# -----
# Guilherme Ferreira, (guilherme.ferreira@cprm.gov.br)
# May, 2020
#####

#####
# Setting up the enviroment
#####
setwd("~/GitHub/MinChem_Modeller") # defining the work direction
set.seed(0) # defining the 'random state' of the pseudo-random generator

selection <- c('SIO2(WT%)', 'TIO2(WT%)', 'AL2O3(WT%)', 'CR2O3(WT%)', 
               'FEOT(WT%)','CAO(WT%)','MGO(WT%)','MNO(WT%)','K2O(WT%)',
               'NA2O(WT%)','P2O5(WT%)','H2O(WT%)','F(WT%)','CL(WT%)',
               'NIO(WT%)','CUO(WT%)','COO(WT%)','ZNO(WT%)','AS(PPM)',
               'PBO(WT%)','S(WT%)','ZRO2(WT%)')

# Simplifcação dos elementos electionados acima
elems_names <- c('SiO2','TiO2','Al2O3','Cr2O3','FeO','CaO',
                 'MgO','MnO','K2O','Na2O','P2O5','H20','F','Cl',
                 'NiO','CuO','CoO','ZnO','As_ppm','PbO','S','ZrO2')

els <- c('SiO2','TiO2','Al2O3','Cr2O3','FeO','MnO', 'MgO','CaO', 'Na2O', 'K2O')

#####
#Import Packages
#####

library(tidyverse) # Collection of libraries: dplyr, ggplot2, purrr, tidyr. Data wrangling and visualizing

#####
# PREPRARING DATA 
#####

oliv <- read_csv('data_input/minerals.csv') %>% # Read file and associate to an object
  select(1,47,19,14,3,25:46) %>% # select and reorder the columns
  mutate(id = X1, X1 = NULL) %>% # Rename Column
  mutate(AS_ppm = ifelse(AS_ppm > 100, AS_ppm/10000, # Adjusting values of column
                         ifelse(AS_ppm > 50, AS_ppm/10, AS_ppm))) %>%
  mutate(AS = AS_ppm, AS_ppm = NULL, # Rename columns
         ROCK = `ROCK NAME`, `ROCK NAME` = NULL,
         SAMPLE = `SAMPLE NAME`, `SAMPLE NAME` = NULL) %>%
  filter(GROUP == 'OLIVINE') %>%
  select(24,27, 1:2,26, 3:23,25) %>% # Reorder Columns
  rename(SiO2 = SIO2,
         FeO = FEOT,
         TiO2 = TIO2,
         Al2O3 = AL2O3,
         Cr2O3 = CR2O3,
         CaO = CAO,
         MgO = MGO,
         MnO = MNO,
         Na2O = NA2O,
         NiO = NIO,
         CuO = CUO,
         CoO = COO,
         ZnO = ZNO,
         PbO = PBO,
         As = AS,
         ZrO2 = ZRO2,
         Cl = CL)

oliv$MINERAL <- oliv$MINERAL %>%
  replace_na('OLIVINE')
 
oliv <- oliv %>%
  select(id, all_of(els), MINERAL)

formula <- tibble(.rows = nrow(oliv))

formula$mineral <- oliv$MINERAL

formula$Si_mole <- oliv$SiO2*1/60.0843
formula$Si_oxygen <- oliv$SiO2*2/60.0843

formula$Ti_mole <- oliv$TiO2*1/79.8988
formula$Ti_oxygen <- oliv$TiO2*2/79.8988

formula$Al_mole <- oliv$Al2O3*2/101.9613
formula$Al_oxygen <- oliv$Al2O3*3/101.9613

formula$Cr_mole <- oliv$Cr2O3*2/159.6922
formula$Cr_oxygen <- oliv$Cr2O3*3/159.6922

formula$Fe_mole <- oliv$FeO*1/71.8464
formula$Fe_oxygen <- oliv$FeO*1/71.8464

formula$Mn_mole <- oliv$MnO*1/70.9374
formula$Mn_oxygen <- oliv$MnO*1/70.9374

formula$Mg_mole <- oliv$MgO*1/40.3044
formula$Mg_oxygen <- oliv$MgO*1/40.3044

formula$Ca_mole <- oliv$CaO*1/56.0794
formula$Ca_oxygen <- oliv$CaO*1/56.0794


formula$mole_cations_total <- formula %>%
  select(ends_with('_mole')) %>%
  mutate(sum = rowSums(.)) %>%
  select('sum')

formula$mole_oxygen_total <- formula %>%
  select(ends_with('_oxygen')) %>%
  mutate(sum = rowSums(.)) %>%
  select('sum')

formula$Si_norm_cations <- 3*formula$Si_mole/formula$mole_cations_total
formula$Ti_norm_cations <- 3*formula$Ti_mole/formula$mole_cations_total
formula$Al_norm_cations <- 3*formula$Al_mole/formula$mole_cations_total
formula$Cr_norm_cations <- 3*formula$Cr_mole/formula$mole_cations_total
formula$Fe_norm_cations <- 3*formula$Fe_mole/formula$mole_cations_total
formula$Mn_norm_cations <- 3*formula$Mn_mole/formula$mole_cations_total
formula$Mg_norm_cations <- 3*formula$Mg_mole/formula$mole_cations_total
formula$Ca_norm_cations <- 3*formula$Ca_mole/formula$mole_cations_total


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

formula$norm_oxygen_total <- formula %>%
  select(ends_with('_norm_oxygen')) %>%
  mutate(sum = rowSums(.)) %>%
  select('sum')

formula <- as_tibble(as.matrix(formula))

formula <- formula %>%
  mutate_at(2:ncol(formula), as.numeric)

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
formula$Fe3_atom <- ifelse(test = 8.0 - formula$calculated_charge > 0,
                           yes = 8.0 - formula$calculated_charge,
                           no =  0)
formula$Fe2_atom <- ifelse(formula$Fe_norm_cations - formula$Fe3_atom > 0, 
                           yes = formula$Fe_norm_cations - formula$Fe3_atom, 0)

formula <- formula %>%
  mutate(Forsterite = Mg_atom/(Mn_atom + Fe2_atom + Fe3_atom + Mg_atom + Ca_atom),
         Fayalite = (Fe2_atom + Fe3_atom)/(Mn_atom + Fe2_atom + Fe3_atom + Mg_atom + Ca_atom),
         Tephroite = Mn_atom/(Mn_atom + Fe2_atom + Fe3_atom + Mg_atom + Ca_atom),
         `Ca-Olivine` = Ca_atom/(Mn_atom + Fe2_atom + Fe3_atom + Mg_atom + Ca_atom))

oliv <- bind_cols(oliv, formula[48:51])

pca <- prcomp(oliv[2:11],center = T)

df <- bind_cols(oliv, as_tibble(pca$x))         
# 
# df %>%
#   sample_frac(.1) %>%
#   gather(key = element, value = `WT(%)`, 2:11) %>%
#   filter(element != 'SiO2',
#          element != 'Al2O3',
#          element != 'TiO2') %>%
#   ggplot(aes(x = PC1,
#              y = PC2,
#              col = `WT(%)`)) +
#   geom_point(alpha = .4) +
#   scale_color_viridis_c(option = 'B',) +
#   # scale_color_gradient2(low = 'blue',
#   #                       mid = 'yellow',
#   #                       high = 'red',
#   #                       midpoint = 10) +
#   # scale_color_binned(type = 'viridis') +
#   facet_wrap(~element,
#              nrow = 2,
#              scales = 'free',) +
#   theme(legend.position = c(.85, .2))
# 
df %>%
  sample_frac(.1) %>%
  gather(key = Olivine, value = Mol, 13:16) %>%
  ggplot(aes(x = PC1,
             y = PC2,
             col = Mol)) +
  geom_point(alpha = .4) +
  # ylim(c(-5,5)) +
  facet_wrap(~Olivine,
             nrow = 2,
             scales = 'free',) +
  scale_color_viridis_c(option = 'C',) #+
  # theme(legend.position = c(.7, .2),
  #       legend.direction = 'horizontal')
