# -*- coding: utf-8 -*-
"""
Created on Tue May 26 14:40:42 2020

@author: Cliente
"""


import pandas as pd
#import Orange
from sklearn.ensemble import RandomForestClassifier
from sklearn.model_selection import train_test_split
from sklearn.metrics import classification_report, confusion_matrix, accuracy_score
import matplotlib.pyplot as plt
from sklearn.metrics import plot_confusion_matrix

def main():
    file = '../Data_train/minerals_balanced.txt'

    file_test = '../Data_test/anderson_output_csv.csv'
    
    regressor,data,cols = mk_group_regressor(file)
    
    predict_file(file_test,regressor,data,cols)


def test_acc(X,y,n_estimators=50):
    # Function to test the accuracy
    
    
    X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.3, random_state=0)
    
    regressor = RandomForestClassifier(n_estimators=n_estimators, random_state=0)
    regressor.fit(X_train, y_train)
    y_pred = regressor.predict(X_test)
    
    print(confusion_matrix(y_test,y_pred))
    print(classification_report(y_test,y_pred))
    print(accuracy_score(y_test, y_pred))



def mk_group_regressor(file):
    # Function to create the GROUP predictor
    # TODO: change [7:29] for the variables list
    
    data = pd.read_csv(file,sep=",")
    
    cols = data.columns.to_list()[7:29]
    
    X = data[cols].iloc[:,:].values
    y = data.iloc[:,4].values
    
    regressor = RandomForestClassifier(n_estimators=50, random_state=0)
    regressor.fit(X, y)
    test_acc(X,y)
    
    return regressor,data,cols




def predict_file(file_test,regressor,data,cols):
    
    data_test = pd.read_csv(file_test,sep=";")
    
    X_new = data_test[cols].iloc[:,:].values
    y_new = regressor.predict(X_new)
    
    
    # trainning sulphides
    sulfide_data = data[data['GROUP']=='SULFIDE']
    X_sulf = sulfide_data[cols].iloc[:,:].values
    y_sulf = sulfide_data.iloc[:,5].values
    
    test_acc(X_sulf,y_sulf)
    
    sulfide_regressor = RandomForestClassifier(n_estimators=50, random_state=0)
    sulfide_regressor.fit(X_sulf,y_sulf)
    y_new_mineral = sulfide_regressor.predict(X_new)
    
    data_test["Predicted Group"] = y_new
    data_test["Predicted Mineral"] = y_new_mineral
    
    #disp = plot_confusion_matrix(sulfide_regressor, X_new, data_test.iloc[:,3].values,display_labels=data_test.MINERAL.unique(),cmap=plt.cm.Blues, normalize='true')
    #plt.xticks(rotation=90)
    #plt.savefig("Confusion_Matrix.png")
    
    data_test.to_excel('Anderson_prediction.xls')
    
main()

