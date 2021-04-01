import dash_core_components as dcc
import dash_html_components as html

PAGE_SIZE = 50

layout = html.Div(
        dcc.Markdown('''

## Introduction

This is the Qmin - Mineral Chemistry Virtual Assistant. The models herein
presented perform mineral classification, missing value imputation by multivariate
regression and mineral formula prediction by several Random Forest classification 
and regression nested models.

The models have been developed by researchers of the Directory of Geology and Mineral
Resources, of the [Geological Survey of Brazil](https://www.cprm.gov.br/en/) (DGM/CPRM), with the assistance of
the technical manager of the EPMA laboratory of the [Institute of Geosciences/University of Brasília](http://www.igd.unb.br/) (IG/UnB).

## Important Notes

* this model is in active development and so parameter names and
behaviors, and output file formats will change without notice.

* The model is stochastic. Multiple runs with different seeds ([or random state](https://stackoverflow.com/questions/42191717/python-random-state-in-splitting-dataset))
should be undertaken to see average behavior.

* The quality of the prediction is directly 
dependent on the quality of the entry data. Consider the best practice to input
data with the sum of elements concentration between 98-102%

* At the current state, Qmin is able to predict among 17 groups and 188 different minerals.
Any other mineral not listed bellow will not perform as desired:

## Groups

* AMPHIBOLES (13 minerals): ACTINOLITE ARFVEDSONITE CUMMINGTONITE EDENITE HASTINGSITE HORNBLENDE (SENSU LATO) KAERSUTITE KATOPHORITE MAGNESIOHASTINGSITE PARGASITE RICHTERITE RIEBECKITE TREMOLITE.

* APATITE

* CARBONATES (13 minerals): ANCYLITE
ANKERITE
BURBANKITE
CACARBOCERNAITE
DOLOMITE
GREGORYITE
KUKHARENKOITE (SENSU LATO)
KUTNAHORITE
MAGNESITE
NATROFAIRCHILDITE/NYEREREITE/ZEMKORITE
SHORTITE
SIDERITELCITE


* CLAY-MINERALS (5 minerals): BEIDELLITE
CORRENSITE
ILLITE
MONTMORILLONITE
SAPONITE 

* FELDSPARS (8 minerals): ALBITE
ANDESINE
ANORTHITE
ANORTHOCLASE
BYTOWNITE
K-FELDSPAR
LABRADORITE
OLIGOCLASE

* FELDSPATHOIDS (8 minerals): ANALCIME
CANCRINITE
HAUYNE
KALSILITE/KALIOPHILITE/PANUNZITE/TRIKALSILITE
LEUCITE
NEPHELINE
NOSEAN
SODALITE

* GARNETS (5 minerals): ALMANDINE
ANDRADITE
GROSSULAR
PYROPE
SCHORLOMITE 

* ILMENITE

* MICAS (6 minerals): BIOTITE (SENSU LATO)
CELADONITE
MUSCOVITE
PARAGONITE
YANGZHUMINGITE
ZINNWALDITE (SENSU LATO) 

* OLIVINES (3 minerals): FAYALITE
FORSTERITE
MONTICELLITE 

* PEROVSKITE

* PYROXENES (9 minerals):  AEGIRINE
AUGITE
DIOPSIDE
ENSTATITE/CLINOENSTATITE
FERROSILITE/CLINOFERROSILITE
HEDENBERGITE
OMPHACITE
PIGEONITE
TITAN-AUGITE

* QUARTZ

* SPINELS (5 minerals): CHROMITE
HERCYNITE
MAGNETITE
SPINEL
ULVOSPINEL 

* SULFIDES (19 minerals): ALABANDITE
ARSENOPYRITE
BORNITE
CHALCOCITE
CHALCOPYRITE
CHLORBARTONITE
CUBANITE
GALENA
HEAZLEWOODITE
ISOCUBANITE
MACKINAWITE
MERENSKYITE
PENTLANDITE
POLYDYMITE
PYRITE
PYRRHOTITE
RASVUMITE
SPHALERITE
STROMEYERITE 

* TITANITE

* ZIRCON

<p>


## Status

This model is in active development and subject to significant code changes
to:

* Increase the number of groups and minerals covered
* Improve performance
* Increase the size of samples used for training

## Training Data

The directory [data_raw](./data_raw) contains all raw data considered for the models' building. 
The main source of the data used for training is the [GEOROC](http://georoc.mpch-mainz.gwdg.de/georoc/) database.
The repository GEOROC is maintained by the Max Planck Institute for Chemistry in Mainz.

Some other data used in this work are a concession of researchers of the Geological Survey of Brazil 
and was used for the model's test and calibration. Those are available in the folder [OtherSources](./data_raw/OtherSources).

## Building:

Project Developed on R and Python3 languages.<p>

The data wrangling, first missing value imputaion, convertion elements to oxides, and balancing
of mineral instances was done in R. T

The final models used in this work were developed on Python3 language.

## Contributors

* [Guilherme Ferreira da Silva](http://buscatextual.cnpq.br/buscatextual/visualizacv.do?id=K4452179T4&idiomaExibicao=2), (E-mail: guilherme.ferreira@cprm.gov.br)
* [Marcos Vinícius Ferreira](http://buscatextual.cnpq.br/buscatextual/visualizacv.do?id=K4331039T8&idiomaExibicao=2), (E-mail: marcos.ferreira@cprm.gov.br)
* [Iago Sousa Lima Costa](http://buscatextual.cnpq.br/buscatextual/visualizacv.do?id=K4360736A0&idiomaExibicao=2), (E-mail: iago.costa@cprm.gov.br)
* [Renato Bernardes Borges](http://buscatextual.cnpq.br/buscatextual/visualizacv.do?id=K4272197D7&idiomaExibicao=2), (E-mail: renato.bernardes@unb.br)

## Copyright and License

The source code for Qmin is licensed under the MIT License, see [LICENSE](LICENSE).
        '''

        )
                )