#####
# Data wrangling and primary classifier of amphiboles
# Guilherme Ferreira, (guilherme.ferreira@cprm.gov.br)
# April, 2020
#####
# Setting up the enviroment
#####
setwd("C:/Users/GUILHERMEFERREIRA-PC/Desktop/Banco de Dados/GEOROC/Minerals")
set.seed(123)

#####
#Import Packages
#####
library(readr)
library(tidyr)
library(dplyr)
library(Cairo)
library(ggplot2)
# library(corrplot)
# library(reshape2)
# library(ggthemes)
# library(randomForest)
# library(caret)
library(mclust)
library(factoextra)

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


# Import data

df1 <- as_tibble(read_delim('GARNETS.csv',delim = ';'),n_max = 42340)
df1 <- df1[1:42340,]

## Verifying the fill rate of columns and rows

col.fillrate(df1, sort = T)

## Subsect dataframe
grt <- df1 %>%
  select(1:89) %>%
  filter(!is.na(`SIO2(WT%)`)) %>%
  filter(!is.na(`FEOT(WT%)`)) %>%
  filter(!is.na(`CAO(WT%)`)) 

# Split label and variables
labels <- grt[1:23]
grt_labels <- labels %>%
  select(`SAMPLE NAME`, `ROCK NAME`, `MINERAL`)

grt_elems <- grt[24:ncol(grt)]

grt_elems <- grt_elems %>%
  select_if(~sum(!is.na(.x)) >= (.5 * nrow(grt_elems)))

###Renaming the columns and fixing class
names(grt_elems) <- c('SiO2','TiO2','Al2O3','Cr2O3','FeOT','CaO','MgO','MnO','Na2O') 

###Dataframe garnet
garnet <- bind_cols(as_tibble(grt_labels), as_tibble(grt_elems))

#####
## Principal componente Analysis
#####

pca <- prcomp(na.omit(grt_elems),center = T,scale. = T,)

summary(pca)

# Visualizando os Autovalores

fviz_eig(pca, addlabels = T) +
  theme(text = element_text(family = 'Arial')) +
  ylim(0,60)


# Gráfico de indivíduos: aqueles de perfil similar serão agrupados conjuntamente

fviz_pca_ind(pca,
             col.ind = "cos2", # Color by the quality of representation
             gradient.cols = c("#00AFBB", "#E7B800", "#FC4E07"),
             repel = F,      # Avoid text overlapping
             axes = c(1,2), #controla quais eixos devem ser mostrados na figura
             geom = c("point")
)

# Gráfico de variáveis: variáveis correlacionáveis apontam para a mesma direção

fviz_pca_var(pca,
             col.var = "contrib", # Color by contributions to the PC
             gradient.cols = c("#00AFBB", "#E7B800", "#FC4E07"),
             repel = TRUE     # Avoid text overlapping
)

# Gráfico de indivíduos e variáveis

fviz_pca_biplot(pca, 
                palette = "jco", 
                addEllipses = TRUE, label = "var")

### Appending PCA results to garnet df
garnet <- bind_cols(na.omit(garnet), as_tibble(pca$x))

#####
# Saving filte
#####

# Count the number of samples by rock name
garnet %>%
  group_by(`ROCK NAME`) %>%
  count(sort = T)

# Fixing the class of a column
garnet$MINERAL <- as.factor(garnet$MINERAL)

# Wrting file of selected samples
write_csv(garnet, path = 'selected_garnet.csv')

# Simplifying the Rock Name Classification

rock_names <- read_tsv('garnet_rocks.txt')

garnet <- garnet %>%
  left_join(rock_names, by = c('ROCK NAME' = 'ROCK_COMPLETE')) %>%
  select(1:3, 22:24, 4:21)

names(garnet) <- c('SAMPLE NAME', 'ROCK NAME', 'MINERAL', 'ROCK', 'COMPOSITION', 'CLASS',
                   'SiO2', 'TiO2', 'Al2O3', 'Cr2O3', 'FeOT', 'CaO', 'MgO', 'MnO', 'Na2O',
                   'PC1', 'PC2', 'PC3', 'PC4', 'PC5', 'PC6', 'PC7', 'PC8', 'PC9')

#####
# Machine Learning
#####

#####
# Data Vis
#####


CairoPDF(file = 'p.garnet.PDF', width = 10, height = 8)

ggplot(garnet,
       aes(x = PC1,
           y = PC2,
           fill = ROCK)) +
  geom_point(shape = 21, col = 'black', alpha = .4, aes(size = CaO)) +  
  theme(legend.text = element_text(size = 7)) + coord_equal() + ylim(c(-6, 18.5)) + xlim(c(-17.5, 10)) +
  labs(title = 'Garnet Classification by Rock type',
       subtitle = 'PCA plot for selected rocks') + #, 
  # legend.position = 'omit') +
  guides(col = guide_legend(ncol = 1)) +
  # scale_color_gradient2(low = 'blue',
  #                       mid = 'green',
  #                       high = 'red',
  #                       midpoint = .4)
  #legend.position = 'omit') +
  scale_fill_manual(values = c(
    "dodgerblue2", "#E31A1C", # red
    "green4",
    "#6A3D9A", # purple
    "#FF7F00", # orange
    "black", "gold1",
    "skyblue2", "#FB9A99", # lt pink
    "palegreen2",
    "#CAB2D6", # lt purple
    "#FDBF6F", # lt orange
    "gray70", "khaki2",
    "maroon", "orchid1", "deeppink1", "blue1", "steelblue4",
    "darkturquoise", "green1", "yellow4", "yellow3",
    "darkorange4", "brown", 'orange3', 'green3', 'gold3', 'brown2',
    'skyblue3','gray30','khaki1', 'orchid2', 'deeppink2','steelblue3'
  )
  )

ggplot(garnet %>%
          filter(`ROCK NAME` == 'GRANITE' |
                   `ROCK NAME` == 'PERIDOTITE' |
                   `ROCK NAME` == 'SCHIST' |
                   `ROCK NAME` == 'LHERZOLITE' |
                   `ROCK NAME` == 'GRANULITE' |
                   `ROCK NAME` == 'PEGMATOID' |
                   `ROCK NAME` == 'BASALT' |
                   `ROCK NAME` == 'CLINOPYROXENITE' |
                   `ROCK NAME` == 'LAMPROPHYRE'),
        aes(x = PC1,
            y = PC2,
            fill = `ROCK NAME`)) +
    geom_point(shape = 21, col = 'black', alpha = .4, aes(size = CaO)) +  
    theme(legend.text = element_text(size = 7)) + coord_equal() + ylim(c(-6, 18.5)) + xlim(c(-17.5, 10)) +
          labs(title = 'Garnet Classification by Rock type',
               subtitle = 'PCA plot for selected rocks') + #, 
    # legend.position = 'omit') +
    guides(col = guide_legend(ncol = 1)) +
    # scale_color_gradient2(low = 'blue',
    #                       mid = 'green',
    #                       high = 'red',
    #                       midpoint = .4)
    #legend.position = 'omit') +
    scale_fill_manual(values = c(
      "dodgerblue2", "#E31A1C", # red
      "darkorange4",
      "#6A3D9A", # purple
      "gray70", "gold1",
      # "skyblue2", # lt pink
      "palegreen2",
      "#CAB2D6", # lt purple
      "#FDBF6F", # lt orange
      "black", "khaki2",
      "maroon", "orchid1", "deeppink1", "blue1", "steelblue4",
      "darkturquoise", "green1", "yellow4", "yellow3",
      "green4", "brown"
    )
)

ggplot(garnet %>%
          filter(`ROCK NAME` == 'GRANITE' |
                   `ROCK NAME` == 'PERIDOTITE' |
                   `ROCK NAME` == 'SCHIST' |
                   `ROCK NAME` == 'LHERZOLITE' |
                   `ROCK NAME` == 'GRANULITE' |
                   `ROCK NAME` == 'PEGMATOID' |
                   `ROCK NAME` == 'BASALT' |
                   `ROCK NAME` == 'CLINOPYROXENITE' |
                   `ROCK NAME` == 'LAMPROPHYRE'),
        aes(x = PC1,
            y = PC2,
            fill = `ROCK NAME`)) +
    coord_equal() + ylim(c(-6, 18.5)) + xlim(c(-17.5, 10)) +
    geom_smooth(inherit.aes = T, aes(col = `ROCK NAME`)) +
    theme(legend.text = element_text(size = 7)) + 
    labs(title = 'Garnet Classification by Rock type',
         subtitle = 'PCA trend line for selected rocks') + #, 
    # legend.position = 'omit') +
    guides(col = guide_legend(ncol = 1)) +
    # scale_color_gradient2(low = 'blue',
    #                       mid = 'green',
    #                       high = 'red',
    #                       midpoint = .4)
    #legend.position = 'omit') +
    scale_fill_manual(values = c(
      "dodgerblue2", "#E31A1C", # red
      "darkorange4",
      "#6A3D9A", # purple
      "gray70", "gold1",
      # "skyblue2", # lt pink
      "palegreen2",
      "#CAB2D6", # lt purple
      "#FDBF6F", # lt orange
      "black", "khaki2",
      "maroon", "orchid1", "deeppink1", "blue1", "steelblue4",
      "darkturquoise", "green1", "yellow4", "yellow3",
      "green4", "brown"
    )) +
    scale_color_manual(values = c(
      "dodgerblue2", "#E31A1C", # red
      "darkorange4",
      "#6A3D9A", # purple
      "gray70", "gold1",
      # "skyblue2", # lt pink
      "palegreen2",
      "#CAB2D6", # lt purple
      "#FDBF6F", # lt orange
      "black", "khaki2",
      "maroon", "orchid1", "deeppink1", "blue1", "steelblue4",
      "darkturquoise", "green1", "yellow4", "yellow3",
      "green4", "brown"
    )
)

ggplot(na.omit(garnet),
       aes(x = PC1,
           y = PC2,
           col = COMPOSITION)) +
  coord_equal() + ylim(c(-6, 18.5)) + xlim(c(-17.5, 10)) +
  geom_smooth(method = 'loess') +
  theme(legend.text = element_text(size = 7)) + 
  labs(title = 'Garnet Classification by Rock type',
       subtitle = 'PCA trend line for selected rocks') + #, 
  guides(col = guide_legend(ncol = 1)) +
   scale_color_manual(values = c(
    "dodgerblue2", "#E31A1C", # red
    "green4",
    "#6A3D9A", # purple
    "#FF7F00", # orange
    "black", "gold1",
    "skyblue2", "#FB9A99", # lt pink
    "palegreen2",
    "#CAB2D6", # lt purple
    "#FDBF6F", # lt orange
    "gray70", "khaki2",
    "maroon", "orchid1", "deeppink1", "blue1", "steelblue4",
    "darkturquoise", "green1", "yellow4", "yellow3",
    "darkorange4", "brown", 'orange3', 'green3', 'gold3', 'brown2',
    'skyblue3','gray30','khaki1', 'orchid2', 'deeppink2','steelblue3'
  )
  )

ggplot(garnet %>%
         filter(`ROCK NAME` == 'KIMBERLITE'),
       aes(x = PC1,
           y = PC2)) +
  geom_point(shape = 21, col = 'black', alpha = .4,
             aes(fill = (CaO/(CaO + MgO + FeOT)),
                 size = Al2O3)) + coord_equal() +
  geom_smooth(inherit.aes = F, se = F, data = na.omit(garnet),
              mapping = aes(x = PC1,
                            y = PC2,
                            col = COMPOSITION),
              method = 'loess') +
  ylim(c(-6, 18.5)) + xlim(c(-17.5, 10)) +
  theme(legend.text = element_text(size = 7)) + 
  labs(title = 'Garnet found in Kimberlites',
       subtitle = 'Crustal Inheritance or Mantelic Source?') + #, 
  # legend.position = 'omit') +
  guides(col = guide_legend(ncol = 1)) +
  scale_fill_gradient2(low = 'blue',
                       mid = 'green',
                       high = 'red',
                       midpoint = .35) +
  scale_color_manual(values = c(
    "dodgerblue2", "#E31A1C", # red
    "darkorange4",
    "#6A3D9A", # purple
    "gray70", "gold1",
    # "skyblue2", # lt pink
    "palegreen2",
    "#CAB2D6", # lt purple
    "#FDBF6F", # lt orange
    "black", "khaki2",
    "maroon", "orchid1", "deeppink1", "blue1", "steelblue4",
    "darkturquoise", "green1", "yellow4", "yellow3",
    "green4", "brown"
  )
  )


ggplot(garnet %>%
          filter(`ROCK NAME` == 'KIMBERLITE'),
        aes(x = PC1,
            y = PC2,
            fill = (CaO/(CaO + MgO + FeOT)),
            size = CaO)) +
    geom_point(shape = 21, col = 'black', alpha = .4) + coord_equal() +
    geom_smooth(inherit.aes = F, data = garnet %>%
                  filter(`ROCK NAME` == 'GRANITE' |
                           `ROCK NAME` == 'PERIDOTITE' |
                           `ROCK NAME` == 'SCHIST' |
                           `ROCK NAME` == 'LHERZOLITE' |
                           `ROCK NAME` == 'GRANULITE' |
                           `ROCK NAME` == 'PEGMATOID' |
                           `ROCK NAME` == 'BASALT' |
                           `ROCK NAME` == 'CLINOPYROXENITE' |
                           `ROCK NAME` == 'LAMPROPHYRE'),
                mapping = aes(x = PC1,
                              y = PC2,
                              # fill = `ROCK NAME`),
                              col = `ROCK NAME`),
                method = 'loess') +
    ylim(c(-6, 18.5)) + xlim(c(-17.5, 10)) +
    theme(legend.text = element_text(size = 7)) + 
    labs(title = 'Garnet found in Kimberlites',
         subtitle = 'Crustal Inheritance or Mantelic Source?') + #, 
    # legend.position = 'omit') +
    guides(col = guide_legend(ncol = 1)) +
    scale_fill_gradient2(low = 'blue',
                          mid = 'green',
                          high = 'red',
                          midpoint = .35) +
  scale_color_manual(values = c(
    "dodgerblue2", "#E31A1C", # red
    "darkorange4",
    "#6A3D9A", # purple
    "gray70", "gold1",
    # "skyblue2", # lt pink
    "palegreen2",
    "#CAB2D6", # lt purple
    "#FDBF6F", # lt orange
    "black", "khaki2",
    "maroon", "orchid1", "deeppink1", "blue1", "steelblue4",
    "darkturquoise", "green1", "yellow4", "yellow3",
    "green4", "brown"
  )
  )

ggplot(garnet %>%
         filter(`ROCK NAME` != 'KIMBERLITE'),
       aes(x = PC1,
           y = PC2,
           fill = (CaO/(CaO + MgO + FeOT)),
           size = CaO)) +
  geom_point(shape = 21, col = 'black', alpha = .4) + coord_equal() +
  geom_smooth(inherit.aes = F, data = garnet %>%
                filter(`ROCK NAME` == 'GRANITE' |
                         `ROCK NAME` == 'PERIDOTITE' |
                         `ROCK NAME` == 'SCHIST' |
                         `ROCK NAME` == 'LHERZOLITE' |
                         `ROCK NAME` == 'GRANULITE' |
                         `ROCK NAME` == 'PEGMATOID' |
                         `ROCK NAME` == 'BASALT' |
                         `ROCK NAME` == 'CLINOPYROXENITE' |
                         `ROCK NAME` == 'LAMPROPHYRE'),
              mapping = aes(x = PC1,
                            y = PC2,
                            # fill = `ROCK NAME`),
                            col = `ROCK NAME`),
              method = 'loess') +
  ylim(c(-6, 18.5)) + xlim(c(-17.5, 10)) +
  theme(legend.text = element_text(size = 7)) + 
  labs(title = 'Garnet found in non-Kimberlites',
       subtitle = 'PCA trend line for selected rocks') + #, 
  # legend.position = 'omit') +
  guides(col = guide_legend(ncol = 1)) +
  scale_fill_gradient2(low = 'blue',
                       mid = 'green',
                       high = 'red',
                       midpoint = .35) +
  scale_color_manual(values = c(
    "dodgerblue2", "#E31A1C", # red
    "darkorange4",
    "#6A3D9A", # purple
    "gray70", "gold1",
    # "skyblue2", # lt pink
    "palegreen2",
    "#CAB2D6", # lt purple
    "#FDBF6F", # lt orange
    "black", "khaki2",
    "maroon", "orchid1", "deeppink1", "blue1", "steelblue4",
    "darkturquoise", "green1", "yellow4", "yellow3",
    "green4", "brown"
  )
  )

ggplot(garnet %>%
         filter(`ROCK NAME` != 'KIMBERLITE'),
       aes(x = PC1,
           y = PC2,
           fill = `ROCK NAME`,
           size = CaO)) +
  geom_point(shape = 21, col = 'black', alpha = .4) + coord_equal() +
  geom_smooth(inherit.aes = F, data = garnet %>%
                filter(`ROCK NAME` == 'GRANITE' |
                         `ROCK NAME` == 'PERIDOTITE' |
                         `ROCK NAME` == 'SCHIST' |
                         `ROCK NAME` == 'LHERZOLITE' |
                         `ROCK NAME` == 'GRANULITE' |
                         `ROCK NAME` == 'PEGMATOID' |
                         `ROCK NAME` == 'BASALT' |
                         `ROCK NAME` == 'CLINOPYROXENITE' |
                         `ROCK NAME` == 'LAMPROPHYRE'),
              mapping = aes(x = PC1,
                            y = PC2,
                            # fill = `ROCK NAME`),
                            col = `ROCK NAME`),
              method = 'loess') +
  ylim(c(-6, 18.5)) + xlim(c(-17.5, 10)) +
  theme(legend.text = element_text(size = 7),
        legend.position = 'omit') + 
  labs(title = 'Garnet found in non-Kimberlites',
       subtitle = 'PCA trend line for selected rocks. Circles colored by rock type') + 
  guides(col = guide_legend(ncol = 1)) +
  scale_color_manual(values = c(
    "dodgerblue2", "#E31A1C", # red
    "darkorange4",
    "#6A3D9A", # purple
    "gray70", "gold1",
    # "skyblue2", # lt pink
    "palegreen2",
    "#CAB2D6", # lt purple
    "#FDBF6F", # lt orange
    "black", "khaki2",
    "maroon", "orchid1", "deeppink1", "blue1", "steelblue4",
    "darkturquoise", "green1", "yellow4", "yellow3",
    "green4", "brown"
  )
  )

dev.off()

#####
# Plotting Garnets by chemichal composition
#####

CairoPDF(file = 'p.garnet1.PDF', width = 10, height = 8)

ggplot(na.omit(garnet), aes(x = PC1,
                   y = PC2,
                   fill = MgO,
                   size = Al2O3
                   )) +
  geom_point(shape = 21, alpha = .4, col = 'black') +
  ylim(c(-6, 18.5)) + xlim(c(-17.5, 10)) +
  theme(legend.text = element_text(size = 7)) +
  labs(title = 'Garnet classification based on MgO and Al2O3 content',
       subtitle = 'PCA plot') + 
  guides(col = guide_legend(ncol = 1)) +
  scale_fill_gradient2(low = 'darkblue',
                       mid = 'green',
                       high = 'red',
                       midpoint = 20)

ggplot(na.omit(garnet), aes(x = PC1,
                            y = PC2,
                            fill = CaO,
                            size = Al2O3
                            )) +
  geom_point(shape = 21, alpha = .4, col = 'black') +
  ylim(c(-6, 18.5)) + xlim(c(-17.5, 10)) +
  theme(legend.text = element_text(size = 7)) +
  labs(title = 'Garnet classification based on CaO and Al2O3 content',
       subtitle = 'PCA plot') + 
  guides(col = guide_legend(ncol = 1)) +
  scale_fill_gradient2(low = 'darkblue',
                       mid = 'green',
                       high = 'red',
                       midpoint = 20)

ggplot(na.omit(garnet), aes(x = PC1,
                            y = PC2,
                            fill = FeOT,
                            size = Al2O3
)) +
  geom_point(shape = 21, alpha = .4, col = 'black') +
  ylim(c(-6, 18.5)) + xlim(c(-17.5, 10)) +
  theme(legend.text = element_text(size = 7)) +
  labs(title = 'Garnet classification based on FeOT and Al2O3 content',
       subtitle = 'PCA plot') + 
  guides(col = guide_legend(ncol = 1)) +
  scale_fill_gradient2(low = 'darkblue',
                       mid = 'green',
                       high = 'red',
                       midpoint = 20)

ggplot(na.omit(garnet), aes(x = PC1,
                            y = PC2,
                            fill = Cr2O3,
                            size = Al2O3
                            )) +
  geom_point(shape = 21, alpha = .4, col = 'black') +
  ylim(c(-6, 18.5)) + xlim(c(-17.5, 10)) +
  theme(legend.text = element_text(size = 7)) +
  labs(title = 'Garnet classification based on Cr2O3 and Al2O3 content',
       subtitle = 'PCA plot') + 
  guides(col = guide_legend(ncol = 1)) +
  scale_fill_gradient2(low = 'darkblue',
                       mid = 'green',
                       high = 'red',
                       midpoint = 10)

ggplot(na.omit(garnet), aes(x = PC1,
                            y = PC2,
                            fill = MnO,
                            size = Al2O3
                            )) +
  geom_point(shape = 21, alpha = .4, col = 'black') +
  ylim(c(-6, 18.5)) + xlim(c(-17.5, 10)) +
  theme(legend.text = element_text(size = 7)) +
  labs(title = 'Garnet classification based on MnO and Al2O3 content',
       subtitle = 'PCA plot') + 
  guides(col = guide_legend(ncol = 1)) +
  scale_fill_gradient2(low = 'darkblue',
                       mid = 'green',
                       high = 'red',
                       midpoint = 10)

ggplot(na.omit(garnet), aes(x = PC1,
                            y = PC2,
                            fill = TiO2,
                            size = Al2O3
                            )) +
  geom_point(shape = 21, alpha = .4, col = 'black') +
  ylim(c(-6, 18.5)) + xlim(c(-17.5, 10)) +
  theme(legend.text = element_text(size = 7)) +
  labs(title = 'Garnet classification based on TiO2 and Al2O3 content',
       subtitle = 'PCA plot') + 
  guides(col = guide_legend(ncol = 1)) +
  scale_fill_gradient2(low = 'darkblue',
                       mid = 'green',
                       high = 'red',
                       midpoint = 10)

ggplot(na.omit(garnet), aes(x = PC1,
                            y = PC2,
                            fill = SiO2,
                            size = SiO2
                            )) +
  geom_point(shape = 21, alpha = .4, col = 'black') +
  ylim(c(-6, 18.5)) + xlim(c(-17.5, 10)) +
  theme(legend.text = element_text(size = 7)) +
  labs(title = 'Garnet classification based on SiO2 content',
       subtitle = 'PCA plot') + 
  guides(col = guide_legend(ncol = 1)) +
  scale_fill_gradient2(low = 'darkblue',
                       mid = 'green',
                       high = 'red',
                       midpoint = 35)

ggplot(na.omit(garnet),
       aes(x = PC1,
           y = PC2)) +
  geom_point(shape = 21,
             alpha = .4,
             col = 'black',
             fill = 'gray30',
             size = 2.5) +
  ylim(c(-6, 18.5)) + xlim(c(-17.5, 10)) +
  theme(legend.text = element_text(size = 7)) +
  labs(title = 'Garnet classification',
       subtitle = 'PCA plot') 

dev.off()
#####
# References
#####

## Variance importance/Mean Decrease Gini
# https://stats.stackexchange.com/questions/197827/how-to-interpret-mean-decrease-in-accuracy-and-mean-decrease-gini-in-random-fore
# https://topepo.github.io/caret/variable-importance.html
# https://www.r-bloggers.com/variable-importance-plot-and-variable-selection/
