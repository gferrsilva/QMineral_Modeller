Preprint: [![DOI:10.21203/rs.3.rs-629516/v1](https://img.shields.io/badge/DOI-10.21203%2Frs.3.rs--629516%2Fv1-%2300D0AF)](https://doi.org/10.21203/rs.3.rs-629516/v1) Published: [![DOI:10.1016/j.cageo.2021.104949](https://img.shields.io/badge/DOI-10.1016%2Fj.cageo.2021.104949-%23B31B1B)](https://doi.org/10.1016/j.cageo.2021.104949)

![jpeg](figures/QMIN_Logo_new.jpg)

## Introduction

This is the Qmin - Mineral Chemistry Virtual Assistant. The models herein
presented perform mineral classification, missing value imputation by multivariate
regression and mineral formula prediction by several Random Forest classification 
and regression nested models.

The models have been developed by researchers of the [Geological Survey of Brazil](https://www.cprm.gov.br/en/) (SGB/CPRM), with the assistance of
the technical manager of the EPMA laboratory of the [Institute of Geosciences/University of Brasília](http://www.igd.unb.br/) (IG/UnB). 

## Documentation

Additional information about the building process is available on the internet in the [preprint file](https://www.researchsquare.com/article/rs-629516/v1) (original manuscript still not certified by a peer review), or in the [published version of our work](https://www.sciencedirect.com/science/article/pii/S0098300421002351?via%3Dihub), available at the journal Computers and Geosciences.

You can also watch the [presentation (only in Portuguese)](https://www.youtube.com/watch?v=MkC9UHxOzWQ) for the release of the Beta version of the application.

## Important Notes

:warning: This model is in active development and so parameter names and
behaviors, and output file formats will change without notice.

:warning: The model is stochastic. Multiple runs with different seeds ([or random state](https://stackoverflow.com/questions/42191717/python-random-state-in-splitting-dataset))
should be undertaken to see average behavior.

:warning: The quality of the prediction is directly 
dependent on the quality of the entry data. Consider the best practice to input
data with the sum of elements concentration between 98-102%

:warning: At the current state, Qmin is able to predict among 19 groups and 102 different minerals.
Any other mineral not listed below will not perform as desired:

* AMPHIBOLES (13 minerals): ACTINOLITE, ARFVEDSONITE, CUMMINGTONITE, EDENITE,
HASTINGSITE, HORNBLENDE (SENSU LATO), KAERSUTITE, KATOPHORITE, MAGNESIOHASTINGSITE,
PARGASITE, RICHTERITE, RIEBECKITE, TREMOLITE.

* APATITE: APATITE (SENSU LATO)

* CARBONATES (13 minerals): ANCYLITE, ANKERITE, BURBANKITE, CALCITE, CARBOCERNAITE,
DOLOMITE, GREGORYITE, KUKHARENKOITE (SENSU LATO), KUTNAHORITE, MAGNESITE,
NATROFAIRCHILDITE/NYEREREITE/ZEMKORITE, SHORTITE, SIDERITE

* CHLORITE: CHLORITE (SENSU LATO) :warning: STILL UNSTABLE! :warning:

* CLAY-MINERALS (5 minerals): BEIDELLITE, CORRENSITE, ILLITE, MONTMORILLONITE, SAPONITE

* EPIDOTE: EPIDOTE (SENSU LATO) :warning: STILL UNSTABLE! :warning:

* FELDSPARS (8 minerals): ALBITE, ANDESINE, ANORTHITE, ANORTHOCLASE, BYTOWNITE, K-FELDSPAR,
LABRADORITE, OLIGOCLASE

* FELDSPATHOIDS (8 minerals): ANALCIME, CANCRINITE, HAUYNE, LEUCITE, NEPHELINE, NOSEAN, 
TRIKALSILITE/KALSILITE/KALIOPHILITE/PANUNZITE, SODALITE


* GARNETS (5 minerals): ALMANDINE, ANDRADITE, GROSSULAR, PYROPE, SCHORLOMITE

* ILMENITE

* MICAS (6 minerals): BIOTITE (SENSU LATO), CELADONITE, MUSCOVITE, PARAGONITE, YANGZHUMINGITE,
ZINNWALDITE (SENSU LATO)


* OLIVINES (3 minerals): FAYALITE, FORSTERITE, MONTICELLITE

* PEROVSKITE

* PYROXENES (9 minerals): AEGIRINE, AUGITE, DIOPSIDE, ENSTATITE/CLINOENSTATITE,
FERROSILITE/CLINOFERROSILITE, HEDENBERGITE, OMPHACITE, PIGEONITE, TITAN-AUGITE

* QUARTZ

* SPINELS (5 minerals): CHROMITE, HERCYNITE, MAGNETITE, SPINEL, ULVOSPINEL


* SULFIDES (18 minerals): ALABANDITE, ARSENOPYRITE, BORNITE, CHALCOCITE, CHALCOPYRITE,
CHLORBARTONITE, CUBANITE/ISOCUBANITE, GALENA, HEAZLEWOODITE, MACKINAWITE,
PENTLANDITE, POLYDYMITE, PYRITE, PYRRHOTITE, RASVUMITE, SPHALERITE, STROMEYERITE


* TITANITE

* ZIRCON

<p>

## Mineral Formula Calculation

### _Mineral Formula Calculation by Deterministic Approach_
The mineral formulas here implemented for _**Feldspar**_, _**Garnet**_, _**Mica**_, _**Olivine**_, _**Pyroxene**_ and _**Spinel**_ were calculated based on EPMA data and the total content of Fe3+ was obtained, when possible, by the charge balance after the calculation of [atom per formula unit number](https://www.researchgate.net/post/How_can_I_convert_wt_of_oxide_to_apfu_atom_per_formula_unit_like_table_1_in_attached_file_without_content_of_Li2O_and_H2O).
Then, the formula printed out in the output is the product of several calculations concatenated into a string datatype column.

### _Mineral Formula Calculation by Probabilistic Approach_
The calculation formula for **Amphiboles** will be made by a multivariate regression for each one of the Crystallographic Sites, still in development, and will later be made available in this repository.
<p>
:warning: THE MINERAL FORMULA CALCULATION FOR AMPHIBOLES IS UNSTABLE, AND WE TURN IT DOWN. This is because we have reported underestimation of Fe3+ and Fe2+ in the final formula. :warning:
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

The data wrangling, first missing value imputaion, conversion elements to oxides, and balancing
of mineral instances was done in R. The code is available in the [Code_R](./Code_R) folder.

The final models used in this work were developed in the Python3 language, and are available in the [model_py](./Code_Python/dashboard/model_py/) folder.
All python codes are available in the [Code_Python](./Code_Python) folder.

## Contributors

* [Guilherme Ferreira da Silva](http://lattes.cnpq.br/3088062889595212), (E-mail: guilherme.ferreira@cprm.gov.br)
* [Marcos Vinícius Ferreira](http://lattes.cnpq.br/0664633989688055), (E-mail: marcos.ferreira@cprm.gov.br)
* [Iago Sousa Lima Costa](http://lattes.cnpq.br/9427131869731616), (E-mail: iago.costa@cprm.gov.br)
* [Renato Bernardes Borges](http://lattes.cnpq.br/6396868621473599), (E-mail: renato.bernardes@unb.br)
* [Carlos Eduardo Miranda Mota](http://lattes.cnpq.br/9373929014144622), (E-mail: carlos.mota@cprm.gov.br)

## Copyright and License

The source code for Qmin is licensed based on the BSD 3-Clause License, see [LICENSE](LICENSE).
