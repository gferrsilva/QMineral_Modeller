# -*- coding: utf-8 -*-
"""
Created on Wed Jun 10 14:04:12 2020

@author: GUILHERMEFERREIRA-PC
"""

import numpy as np
import os
import pandas as pd
from sklearn.ensemble import RandomForestRegressor
from sklearn.datasets import make_regression

os.chdir('C:/Users/GUILHERMEFERREIRA-PC/Documents/GitHub/MinChem_Modeller')

df = pd.read_csv('data_train/train.csv')

df