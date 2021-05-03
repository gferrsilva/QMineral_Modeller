#####
# Data wrangling and primary classifier of selected minerals
# Outlier removing, Mineral names recoding and Non-Mineral removing
# 
# version: 1.0 (2020/12/17)
#
# Last modifications: * DBscan to remove outliers group by group
#                     * Recode mineral names according to IMA
#                     * Exclude non-minerals and irrelevant data from database
#                     
#
#
# -----
# Amphiboles, Apatites, Carbonates, Clay Minerals, Feldspars, Feldspathoides,
# Garnets, Ilmenites, Micas, Olivines, Perovskites, Pyroxenes, Quartz, Sulfides,
# Titanite, Zircon
# -----
# Guilherme Ferreira, (guilherme.ferreira@cprm.gov.br)
# December, 2020
#####

#####
# Setting up the enviroment
#####

setwd("~/GitHub/MinChem_Modeller") # Ajustando o work direction

set.seed(123) # Ajustando o 'Random State' da máquina para reproduzir os códigos

tic <- Sys.time()
#####
#Import Packages
#####

library(tidyverse) # Conjunto de bibliotecas em R que facilitam a manipulação e visualização de dados. Equivalente ao pandas, matplotlib, seaborn, etc
library(dbscan) # outlier detection
library(factoextra) # Cluster viz

#####
# DATA WRANGLING 
#####

min <- read_csv('data_input/minerals.csv',na = 'NA') # importar o arquivo amphiboles.csv para um arquivo temporário df1

# Fixing the mineral names acoording to IMA's recomendation

min$MINERAL <- recode(.x = min$MINERAL,
         ACMITE = 'AEGIRINE',
         ALABANDITE = 'ALABANDITE/BROWNEITE/RAMBERGITE',
         ALSTONITE = 'ALSTONITE/BARYTOCALCITE/PARALSTONITE',
         ANALCYLITE = 'ANALCYLITE (SENSU LATO)',
         ANNITE = 'BIOTITE (SENSU LATO)',
         APATITE = 'APATITE (SENSU LATO)',
         BARYTOCALCITE = 'ALSTONITE/BARYTOCALCITE/PARALSTONITE',
         BIOTITE = 'BIOTITE (SENSU LATO)',
         BREUNNERITE = 'MAGNESITE',
         CEBAITE = 'CEBAITE-(Ce)',
         CLINOENSTATITE = 'ENSTATITE/CLINOENSTATITE',
         CORDYLITE = 'CORDYLITE (SENSU LATO)',
         `CR-DIOPSIDE` = 'DIOPSIDE',
         CUBANITE = 'CUBANITE/ISOCUBANITE',
         ENSTATITE = 'ENSTATITE/CLINOENSTATITE',
         FASSAITE = 'AUGITE',
         `FE-CHROMITE` = 'CHROMITE',
         `FE-DIOPSIDE` = 'DIOPSIDE',
         FERROAUGITE = 'AUGITE',
         FERROHEDENBERGITE = 'HEDENBERGITE',
         FERROPIGEONITE = 'PIGEONITE',
         FERROSILITE = 'FERROSILITE/CLINOFERROSILITE',
         `FE-TI-TSCHERMAKITE` = 'FERRO-TSCHERMAKITE',
         `FE-TSCHERMAKITE` = 'FERRO-TSCHERMAKITE',
         GUANGLINITE = 'ISOMERTIEITE/MERTIEITE-I',
         HASTINGSITE = 'HASTINGSITE',
         HUANGHOITE = 'HUANGHOITE-(Ce)',
         ISOCUBANITE = 'CUBANITE/ISOCUBANITE',
         KALIOPHILITE = 'KALSILITE/KALIOPHILITE/PANUNZITE/TRIKALSILITE',
         KALSILITE = 'KALSILITE/KALIOPHILITE/PANUNZITE/TRIKALSILITE',
         KATOPHORITE = 'KATOPHORITE',
         KUKHARENKOITE = 'KUKHARENKOITE (SENSU LATO)',
         LEPIDOLITE = 'LEPIDOLITE (SENSU LATO)',
         MAGNESIOKATOPHORITE = 'MAGNESIOKATAPHORITE',
         MAGNESIOSIDERITE = 'SIDERITE',
         MCKELVEYITE = 'MCKELVEYITE-(Y)',
         MELANITE = 'ANDRADITE',
         MICROCLINE = 'K-FELDSPAR',
         NYEREREITE = 'NATROFAIRCHILDITE/NYEREREITE/ZEMKORITE',
         ORTHOCLASE = 'K-FELDSPAR',
         OXYKAERSUTITE = 'KAERSUTITE',
         `PHENGITE-MUSCOVITE` = 'MUSCOVITE',
         PHLOGOPITE = 'BIOTITE (SENSU LATO)',
         PLEONASTE = 'SPINEL',
         QAQARSSUKITE = 'QAQARSSUKITE-(Ce)',
         SALITE = 'DIOPSIDE',
         SANIDINE = 'K-FELDSPAR',
         SIDEROPHYLLITE = 'BIOTITE (SENSU LATO)',
         `TITAN-MAGNESIO-HASTINGSITE` = 'MAGNESIOHASTINGSITE',
         `TITANO-MAGNETITE` = 'MAGNETITE',
         ZINNWALDITE = 'ZINNWALDITE (SENSU LATO)',
         `(AL)KALIFELDSPAR` = 'K-FELDSPAR',
         HORNBLENDE = 'HORNBLENDE (SENSU LATO)',
         `FERRI-TSCHERMAKITE` = 'HORNBLENDE (SENSU LATO)',
         `FERRI-TSCHERMAKITIC HORNBLENDE` = 'HORNBLENDE',
         `MAGNESIO-HORNBLENDE` = 'HORNBLENDE (SENSU LATO)',
         `MAGNESIO-HASTINGSITE` = 'MAGNESIOHASTINGSITE',
         TSCHERMAKITE = 'HORNBLENDE (SENSU LATO)') 

# Filtering non-minerals of the database

min <- min %>%
  filter(MINERAL != 'FLUORO-CARBONATE',
         MINERAL != 'GLAUCONITE',
         MINERAL != 'HEXATESTIBIOPANICKELITE',
         MINERAL != 'HYDROGARNET',
         MINERAL != 'HYDROMICA',
         MINERAL != 'HYDROMUSCOVITE',
         MINERAL != 'HYPERSTHENE',
         MINERAL != 'IDDINGSITE',
         MINERAL != 'PALAGONITE',
         MINERAL != 'PHENGITE',
         MINERAL != 'PSEUDOLEUCITE',
         MINERAL != 'SERICITE',
         MINERAL != 'SMECTITE',
         MINERAL != 'SPURRITE',
         MINERAL != 'NATRIUMFELDSPAR',
         MINERAL != 'PERTHITE',
         MINERAL != 'HYDROGARNET',
         MINERAL != 'ILMENITE-HEMATITE',
         MINERAL != 'HEMOILMENITE',
         MINERAL != 'MAGNETITE/CHROMITE',
         MINERAL != 'THORITE',
         MINERAL != 'MERENSKYITE',
         MINERAL != 'MAUCHERITE',
         MINERAL != 'AL-SPINEL',
         MINERAL != 'CHROME-SPINEL',
         MINERAL != 'FERRICNYB<d6>ITE')

# Remove outlier from Amphiboles ----

amph <- min %>%
  filter(GROUP == 'AMPHIBOLES')


dbscan::kNNdistplot(amph %>%
                      select(25:38), k = 5)
# abline(h = 5, lty = 2)
# 
# amph.db <- dbscan::dbscan(amph %>%
#                             select(25:38),eps = 5,minPts = 5)

# vizualização
# fviz_cluster(object = amph.db,
#              data =  amph %>%
#                select(25:38),
#              geom = 'point',
#              stand = TRUE,
#              show.clust.cent = FALSE,)

amph <- amph %>%
  bind_cols(amph.db$cluster) %>%
  rename(outlier_db = '...48') %>%
  mutate(outlier_db = ifelse(outlier_db == 0,'outlier','regular data'))

# table(amph$MINERAL, amph$outlier_db)

amph <- amph %>%
  filter(outlier_db != 'outlier')

remove(amph.db)

# Remove outlier from Apatite ----

apat <- min %>%
  filter(GROUP == 'APATITE')


# dbscan::kNNdistplot(apat %>%
#                       select(25:39), k = 5)
# abline(h = 5, lty = 2)

apat.db <- dbscan::dbscan(apat %>%
                            select(25:39),eps = 5,minPts = 5)

# vizualização
# fviz_cluster(object = apat.db,
#              data =  apat %>%
#                select(25:39),
#              geom = 'point',
#              stand = TRUE,
#              show.clust.cent = FALSE,)

apat <- apat %>%
  bind_cols(apat.db$cluster) %>%
  rename(outlier_db = '...48') %>%
  mutate(outlier_db = ifelse(outlier_db == 0,'outlier','regular data'))

# table(apat$MINERAL, apat$outlier_db)

apat <- apat %>%
  filter(outlier_db != 'outlier')

remove(apat.db)

# Remove outlier from Carbonate ----

carb <- min %>%
  filter(GROUP == 'CARBONATE')


# dbscan::kNNdistplot(carb %>%
#                       select(25:35,37:39), k = 5)
# abline(h = 10, lty = 2)

carb.db <- dbscan::dbscan(carb %>%
                            select(25:35,37:39),eps = 10,minPts = 5)

# vizualização
# fviz_cluster(object = carb.db,
#              data =  carb %>%
#                select(25:35,37:39),
#              geom = 'point',
#              stand = TRUE,
#              show.clust.cent = FALSE,)

carb <- carb %>%
  bind_cols(carb.db$cluster) %>%
  rename(outlier_db = '...48') %>%
  mutate(outlier_db = ifelse(outlier_db == 0,'outlier','regular data'))

# table(carb$MINERAL, carb$outlier_db)

carb <- carb %>%
  filter(outlier_db != 'outlier')

remove(carb.db)

# Remove outlier from Clay ----

clay <- min %>%
  filter(GROUP == 'CLAY')


# dbscan::kNNdistplot(clay %>%
#                       select(25:36), k = 5)
# abline(h = 15, lty = 2)

clay.db <- dbscan::dbscan(clay %>%
                            select(25:36),eps = 10,minPts = 5)

# vizualização
# fviz_cluster(object = clay.db,
#              data =  clay %>%
#                select(25:36),
#              geom = 'point',
#              stand = TRUE,
#              show.clust.cent = FALSE,)

clay <- clay %>%
  bind_cols(clay.db$cluster) %>%
  rename(outlier_db = '...48') %>%
  mutate(outlier_db = ifelse(outlier_db == 0,'outlier','regular data'))

# table(clay$MINERAL, clay$outlier_db)

clay <- clay %>%
  filter(outlier_db != 'outlier')

remove(clay.db)

# Remove outlier from Feldspar ----

feld <- min %>%
  filter(GROUP == 'FELDSPAR')


# dbscan::kNNdistplot(feld %>%
#                       select(25:35), k = 10)
# abline(h = 3, lty = 2)

feld.db <- dbscan::dbscan(feld %>%
                            select(25:35),eps = 3,minPts = 10)

# vizualização
# fviz_cluster(object = feld.db,
#              data =  feld %>%
#                select(25:35),
#              geom = 'point',
#              stand = TRUE,
#              show.clust.cent = FALSE,)

feld <- feld %>%
  bind_cols(feld.db$cluster) %>%
  rename(outlier_db = '...48') %>%
  mutate(outlier_db = ifelse(outlier_db == 0,'outlier','regular data'))

# table(feld$MINERAL, feld$outlier_db)

feld <- feld %>%
  filter(outlier_db != 'outlier')

remove(feld.db)



# Remove outlier from Feldspathoid ----

foid <- min %>%
  filter(GROUP == 'FELDSPATHOID')


# dbscan::kNNdistplot(foid %>%
#                       select(25:36), k = 5)
# abline(h = 5, lty = 2)

foid.db <- dbscan::dbscan(foid %>%
                            select(25:36),eps = 5,minPts = 5)

# vizualização
# fviz_cluster(object = foid.db,
#              data =  foid %>%
#                select(25:36),
#              geom = 'point',
#              stand = TRUE,
#              show.clust.cent = FALSE,)

foid <- foid %>%
  bind_cols(foid.db$cluster) %>%
  rename(outlier_db = '...48') %>%
  mutate(outlier_db = ifelse(outlier_db == 0,'outlier','regular data'))

# table(foid$MINERAL, foid$outlier_db)

foid <- foid %>%
  filter(outlier_db != 'outlier')

remove(foid.db)

# Remove outlier from Garnet ----

gart <- min %>%
  filter(GROUP == 'GARNET')

# dbscan::kNNdistplot(gart %>%
#                       select(25:37), k = 5)
# abline(h = 3, lty = 2)

gart.db <- dbscan::dbscan(gart %>%
                            select(25:37),eps = 3,minPts = 5)

# vizualização
# fviz_cluster(object = gart.db,
#              data =  gart %>%
#                select(25:37),
#              geom = 'point',
#              stand = TRUE,
#              show.clust.cent = FALSE,)

gart <- gart %>%
  bind_cols(gart.db$cluster) %>%
  rename(outlier_db = '...48') %>%
  mutate(outlier_db = ifelse(outlier_db == 0,'outlier','regular data'))

# table(gart$MINERAL, gart$outlier_db)

gart <- gart %>%
  filter(outlier_db != 'outlier')

remove(gart.db)


# Remove outlier from Ilmenite ----

ilm <- min %>%
  filter(GROUP == 'ILMENITE')


# dbscan::kNNdistplot(ilm %>%
#                       select(25:34), k = 5)
# abline(h = 4, lty = 2)

ilm.db <- dbscan::dbscan(ilm %>%
                            select(25:34),eps = 4,minPts = 5)

# vizualização
# fviz_cluster(object = ilm.db,
#              data =  ilm %>%
#                select(25:34),
#              geom = 'point',
#              stand = TRUE,
#              show.clust.cent = FALSE,)

ilm <- ilm %>%
  bind_cols(ilm.db$cluster) %>%
  rename(outlier_db = '...48') %>%
  mutate(outlier_db = ifelse(outlier_db == 0,'outlier','regular data'))

# table(ilm$MINERAL, ilm$outlier_db)

ilm <- ilm %>%
  filter(outlier_db != 'outlier')

remove(ilm.db)

# Remove outlier from Mica ----

mica <- min %>%
  filter(GROUP == 'MICA')


# dbscan::kNNdistplot(mica %>%
#                       select(25:39), k = 5)
# abline(h = 5, lty = 2)

mica.db <- dbscan::dbscan(mica %>%
                           select(25:39),eps = 5,minPts = 5)

# vizualização
# fviz_cluster(object = mica.db,
#              data =  mica %>%
#                select(25:39),
#              geom = 'point',
#              stand = TRUE,
#              show.clust.cent = FALSE,)

mica <- mica %>%
  bind_cols(mica.db$cluster) %>%
  rename(outlier_db = '...48') %>%
  mutate(outlier_db = ifelse(outlier_db == 0,'outlier','regular data'))

# table(mica$MINERAL, mica$outlier_db)

mica <- mica %>%
  filter(outlier_db != 'outlier')

remove(mica.db)

# Remove outlier from Olivine ----

oliv <- min %>%
  filter(GROUP == 'OLIVINE')


# dbscan::kNNdistplot(oliv %>%
#                       select(25:36), k = 5)
# abline(h = 2, lty = 2)

oliv.db <- dbscan::dbscan(oliv %>%
                            select(25:36),eps = 2,minPts = 5)

# vizualização
# fviz_cluster(object = oliv.db,
#              data =  oliv %>%
#                select(25:36),
#              geom = 'point',
#              stand = TRUE,
#              show.clust.cent = FALSE,)

oliv <- oliv %>%
  bind_cols(oliv.db$cluster) %>%
  rename(outlier_db = '...48') %>%
  mutate(outlier_db = ifelse(outlier_db == 0,'outlier','regular data'))

# table(oliv$MINERAL, oliv$outlier_db)

oliv <- oliv %>%
  filter(outlier_db != 'outlier')

remove(oliv.db)
# Remove outlier from Perovskite ----

pero <- min %>%
  filter(GROUP == 'PEROVSKITE')


# dbscan::kNNdistplot(pero %>%
#                       select(25:35), k = 5)
# abline(h = 3, lty = 2)

pero.db <- dbscan::dbscan(pero %>%
                            select(25:35),eps = 3,minPts = 5)

# vizualização
# fviz_cluster(object = pero.db,
#              data =  pero %>%
#                select(25:35),
#              geom = 'point',
#              stand = TRUE,
#              show.clust.cent = FALSE,)

pero <- pero %>%
  bind_cols(pero.db$cluster) %>%
  rename(outlier_db = '...48') %>%
  mutate(outlier_db = ifelse(outlier_db == 0,'outlier','regular data'))

# table(pero$MINERAL, pero$outlier_db)

pero <- pero %>%
  filter(outlier_db != 'outlier')

remove(pero.db)
# Remove outlier from Pyroxene ----

px <- min %>%
  filter(GROUP == 'PYROXENE')


# dbscan::kNNdistplot(px %>%
#                       select(25:35), k = 5)
# abline(h = 3, lty = 2)

px.db <- dbscan::dbscan(px %>%
                            select(25:35),eps = 3,minPts = 5)

# vizualização
# fviz_cluster(object = px.db,
#              data =  px %>%
#                select(25:35),
#              geom = 'point',
#              stand = TRUE,
#              show.clust.cent = FALSE,)

px <- px %>%
  bind_cols(px.db$cluster) %>%
  rename(outlier_db = '...48') %>%
  mutate(outlier_db = ifelse(outlier_db == 0,'outlier','regular data'))

# table(px$MINERAL, px$outlier_db)

px <- px %>%
  filter(outlier_db != 'outlier')

remove(px.db)

# Remove outlier from Quartz ----

qtz <- min %>%
  filter(GROUP == 'QUARTZ')


# dbscan::kNNdistplot(qtz %>%
#                       select(25:34), k = 5)
# abline(h = 2, lty = 2)

qtz.db <- dbscan::dbscan(qtz %>%
                          select(25:34),eps = 2,minPts = 5)

# vizualização
# fviz_cluster(object = qtz.db,
#              data =  qtz %>%
#                select(25:34),
#              geom = 'point',
#              stand = TRUE,
#              show.clust.cent = FALSE,)

qtz <- qtz %>%
  bind_cols(qtz.db$cluster) %>%
  rename(outlier_db = '...48') %>%
  mutate(outlier_db = ifelse(outlier_db == 0,'outlier','regular data'))

# table(qtz$MINERAL, qtz$outlier_db)

qtz <- qtz %>%
  filter(outlier_db != 'outlier')

remove(qtz.db)

# Remove outlier from Spinel ----

spn <- min %>%
  filter(GROUP == 'SPINEL')


# dbscan::kNNdistplot(spn %>%
#                       select(25:34), k = 5)
# abline(h = 5, lty = 2)

spn.db <- dbscan::dbscan(spn %>%
                           select(25:34),eps = 5,minPts = 5)

# vizualização
# fviz_cluster(object = spn.db,
#              data =  spn %>%
#                select(25:34),
#              geom = 'point',
#              stand = TRUE,
#              show.clust.cent = FALSE,)

spn <- spn %>%
  bind_cols(spn.db$cluster) %>%
  rename(outlier_db = '...48') %>%
  mutate(outlier_db = ifelse(outlier_db == 0,'outlier','regular data'))

# table(spn$MINERAL, spn$outlier_db)

spn <- spn %>%
  filter(outlier_db != 'outlier')

remove(spn.db)

# Remove outlier from Sulfide ----

sulf <- min %>%
  filter(GROUP == 'SULFIDE')


# dbscan::kNNdistplot(sulf %>%
#                       select(29,30,39:45), k = 5)
# 
# abline(h = 3000, lty = 2)

sulf.db <- dbscan::dbscan(sulf %>%
                           select(29,30,39:45),eps = 3000,minPts = 5)

# vizualização
# fviz_cluster(object = sulf.db,
#              data =  sulf %>%
#                select(29,30,39:45),
#              geom = 'point',
#              stand = TRUE,
#              show.clust.cent = FALSE,)

sulf <- sulf %>%
  bind_cols(sulf.db$cluster) %>%
  rename(outlier_db = '...48') %>%
  mutate(outlier_db = ifelse(outlier_db == 0,'outlier','regular data'))

# table(sulf$MINERAL, sulf$outlier_db)

sulf <- sulf %>%
  filter(outlier_db != 'outlier')

remove(sulf.db)

# Remove outlier from Titanite ----

titn <- min %>%
  filter(GROUP == 'TITANITE')


# dbscan::kNNdistplot(titn %>%
#                       select(25:42), k = 5)
# 
# abline(h = 8, lty = 2)

titn.db <- dbscan::dbscan(titn %>%
                            select(25:39),eps = 8,minPts = 5)

# vizualização
# fviz_cluster(object = titn.db,
#              data =  titn %>%
#                select(25:39),
#              geom = 'point',
#              stand = TRUE,
#              show.clust.cent = FALSE,)

titn <- titn %>%
  bind_cols(titn.db$cluster) %>%
  rename(outlier_db = '...48') %>%
  mutate(outlier_db = ifelse(outlier_db == 0,'outlier','regular data'))

# table(titn$MINERAL, titn$outlier_db)

titn <- titn %>%
  filter(outlier_db != 'outlier')

remove(titn.db)

# Remove outlier from Zircon ----

zirc <- min %>%
  filter(GROUP == 'ZIRCON')


# dbscan::kNNdistplot(zirc %>%
#                       select(25:26,46), k = 5)
# 
# abline(h = 1, lty = 2)

zirc.db <- dbscan::dbscan(zirc %>%
                            select(25:26,46),eps = 1,minPts = 5)

# vizualização
# fviz_cluster(object = zirc.db,
#              data =  zirc %>%
#                select(25:26,46),
#              geom = 'point',
#              stand = TRUE,
#              show.clust.cent = FALSE,)

zirc <- zirc %>%
  bind_cols(zirc.db$cluster) %>%
  rename(outlier_db = '...48') %>%
  mutate(outlier_db = ifelse(outlier_db == 0,'outlier','regular data'))

# table(zirc$MINERAL, zirc$outlier_db)

zirc <- zirc %>%
  filter(outlier_db != 'outlier')

remove(zirc.db)



# Joining data ----

min1 <- amph %>%
  bind_rows(apat, carb, clay, feld, foid,
            gart,ilm,mica, oliv, pero, px,
            qtz, spn, sulf, titn, zirc)

# Writing data ----

write.csv(file = 'data_input/minerals_posDBScan.csv',x = min1[,-1])



# End of benchmarking script

tac <- Sys.time() # Closing time

print(paste((nrow(min) - nrow(min1)),'outliers removed from',nrow(min),'samples:',(round(nrow(min1)/nrow(min),2)),'%'))
print(paste('Running time:', # Printing running time
            round(difftime(time1 = tac,
                     time2 = tic,
                     units = 'mins'),digits = 2),
            'minutes'))
