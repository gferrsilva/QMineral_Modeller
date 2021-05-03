  
#####
# Visualizing instances from SMOTE
# 
# version: 1.0 (2021/05/20)
#
# Last modifications:
#
# -----
# Amphiboles, Apatites, Carbonates, Clay Minerals, Feldspars, Feldspathoides,
# Garnets, Ilmenites, Micas, Olivines, Perovskites, Pyroxenes, Quartz, Sulfides,
# Titanite, Zircon
# -----
# Guilherme Ferreira, (guilherme.ferreira@cprm.gov.br)
# May, 2021
#####

#####
# Setting up the enviroment
#####
setwd('~/GitHub/MinChem_Modeller/data_train')
library(tidyverse)

#####
# Reading
#####

fromSMOTE <- read.csv('SMOTE_Random_Sampler_v2.csv',)

write.csv(x = fromSMOTE %>%
  group_by(GROUP, MINERAL) %>%
  count(),file = '~/GitHub/MinChem_Modeller/references/listofminerals_final.csv')

#####
# Functions
#####

plot_pca_byGroup <- function(grupo = grupo,
                             leg.position = NULL,
                             alpha = 1,...) {
  require(tidyverse)
  
  pca <- prcomp(fromSMOTE[fromSMOTE$GROUP == grupo,1:22],center = TRUE)
  
  df <- fromSMOTE %>%
    filter(GROUP == grupo) %>%
    bind_cols(as_tibble(pca$x))

  pca.list <- as.list(summary(pca))
  xlab <- pca.list$importance[[2,'PC1']]
  ylab <- pca.list$importance[[2,'PC2']]

  print(paste0('Graphic of ',grupo[[1]],' done.'))
  df %>%
    ggplot(aes(x = PC1, y = PC2, col = MINERAL)) +
    geom_point(alpha = alpha) +
    labs(x = paste0('PC1 (',round(100*xlab,1),'% of data variance)'),
         y = paste0('PC2 (',round(100*ylab,1),'%)')) +
    theme(legend.position = leg.position) +
    labs(title = paste0('Samples of ',grupo,' group.'))
  
}

#####
# Applying
#####


lista <- c('FELDSPAR','GARNET','PYROXENE','AMPHIBOLES', 'CARBONATE',
           'OLIVINE','FELDSPATHOID')

lapply(lista, plot_pca_byGroup,
       leg.position = 'none',
       alpha = .5)
