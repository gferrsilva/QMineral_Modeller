# Qmin - MINERAL CHEMISTRY VIRTUAL ASSISTANT

This is the Qmin - Mineral Chemistry Virtual Assistant. The models herein
presented performes mineral classification, missing value imputation by multivariate
regression and mineral formula prediction by several Random Forest classification
and regression nested  models.

The models have been developed by researchers of the Diretory of Geology and Mineral
Resources, of the Geological Survey of Brazil (DGM/CPRM), with assistance of the techical 
manager of the EPMA laboratory of the Institute of Geosciences/University of Brasília (IG/UnB).

## Important Notes

* At the current state, Qmin is able to predict among 17 groups and 188 different minerals.
Any other mineral/grup not listed bellow will not perform as desired:

* Amphibole (29 minerals)
* Apatite
* Carbonate (31 minerals)
* Clay Mineral (9 minerals)
* Feldspar (10 minerals)
* Feldspathoid (11 minerals)
* Garnet (8 minerals
* Ilmenite
* Mica (17 minerals)
* Olivine (5 minerals)
* Perovskite
* Pyroxene (20 minerals)
* Quartz
* Spinel (11 minerals)
* Sulfide (31 minerals)
* Titanite
* Zircon
<p>
:warning: This model is in active development and so parameter name and
behaviours, and output file formats will change without notice.

:warning: The model is stochastic. Multiple runs with different seeds should be
undertaken to see average behaviour.

:warning: The quality of the prediction is directly
dependent on the quality of the entry data. Consider as the best practice to input
data with the sum of elements concentration between 98-102%.

## Status

This model is in active development and subject to significant code changes
to:

- Increase the number of groups and minerals covered

- Improve performance

## Training Data

The directory [data_raw](./data_raw) contains all raw data considered for the models' building.
<p>
The main source of the data used for training is the GEOROC database <http://georoc.mpch-mainz.gwdg.de/georoc/>.
The repository GEOROC is maintained by the Max Planck Institute for Chemistry in Mainz.
<p>
Some other data used in this work are a concession of researchers of the Geological Survey of Brazil,
and was used for model's test callibration. Those are disposed in the folder [OtherSources](./data_raw/OtherSources).

## Building:

Project Developed on R and Python3 languages.<p>

The data wrangling, first missing value imputaion, convertion elements to oxides, and balancing of mineral instances was done in R.
The code is available in the [Code_R](./Code_R) folder. Some Random Forest classification models are also available in the [model_r](./model_r) folder.

The final models used in this work were developed on Python3 language, and are available in the [model_py](./model_py) folder.

## Contributors

* [Guilherme Ferreira da Silva](http://buscatextual.cnpq.br/buscatextual/visualizacv.do?id=K4452179T4&idiomaExibicao=2), guilherme.ferreira@cprm.gov.br
* [Marcos Vinícius Ferreira](http://buscatextual.cnpq.br/buscatextual/visualizacv.do?id=K4331039T8&idiomaExibicao=2), marcos.ferreira@cprm.gov.br
* [Iago Sousa Lima Costa](http://buscatextual.cnpq.br/buscatextual/visualizacv.do?id=K4360736A0&idiomaExibicao=2), iago.costa@cprm.gov.br.
* [Renato Bernardes Borges](http://buscatextual.cnpq.br/buscatextual/visualizacv.do?id=K4272197D7&idiomaExibicao=2), renato.bernardes@unb.br.

## Copyright and License

The source code for Qmin is licensed under the MTI License, see [LICENSE](LICENSE).
