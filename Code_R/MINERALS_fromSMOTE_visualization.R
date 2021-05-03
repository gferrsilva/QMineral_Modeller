library(tidyverse)

setwd('~/GitHub/MinChem_Modeller/data_train')

fromSMOTE <- read.csv('SMOTE_Random_Sampler_v2.csv',)

t <- fromSMOTE %>%
  group_by(GROUP, MINERAL) %>%
  count()

write.csv(x = t,file = '~/GitHub/MinChem_Modeller/references/listofminerals_final.csv')


grupo <- 'FELDSPAR'

pca <- prcomp(fromSMOTE[fromSMOTE$GROUP == grupo,1:22],center = TRUE)

pca.list <- as.list(summary(pca))

summary(pca)

df <- fromSMOTE %>%
  filter(GROUP == grupo) %>%
  bind_cols(as_tibble(pca$x)) 

xlab <- pca.list$importance[[2,'PC1']]
ylab <- pca.list$importance[[2,'PC2']]

df %>%
  ggplot(aes(x = PC1, y = PC2, col = MINERAL)) +
  geom_point() +
  labs(x = paste0('PC1 (',round(100*xlab,1),'% of data variance)'),
       y = paste0('PC2 (',round(100*ylab,1),'%)')) +
  coord_equal()


df %>%
  filter(GROUP == 'CARBONATE') %>%
  ggplot(aes(x = PC1, y = PC2, col = MINERAL)) +
  geom_point()




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


plot_pca_byGroup(grupo = 'FELDSPAR')


lista <- c('FELDSPAR','GARNET','PYROXENE','AMPHIBOLES', 'CARBONATE',
           'OLIVINE','FELDSPATHOID')

Cairo::CairoPDF(file = '~/GitHub/MinChem_Modeller/figures/SMOTE_leg.pdf',
                width = 6,height = 6)
lapply(lista, plot_pca_byGroup,
       # leg.position = 'none',
       alpha = .5)
dev.off()
