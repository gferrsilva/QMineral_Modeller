# -*- coding: utf-8 -*-
"""
Created on Mon Jan 11 12:19:01 2021

@author: Cliente
"""


import pandas as pd

df = pd.read_csv("D:\CPRM\Qmin\QMineral_Modeller-master\data_input\minerals_toSMOTE.csv")


group_list = df['GROUP'].unique()

for group in group_list:
    
    
    # Get the desired element
    mask = df['GROUP'] == group
    
    # Write the new file
    df_1 = df[mask] # or directly use: df_1 = df[df['Time'] < 0.1]
    
    i=0
    for files in df_1['MINERAL'].unique():
    
        print('{} instances for {}'.format(len(df[df['MINERAL'] == files]),files))
        i=+1
        
    print('\n{} instances for GROUP {}, with {} minerals\n'.format(len(df[df['GROUP'] == group]),group,len(df_1['MINERAL'].unique())))
    # save it 
    df_1.to_csv("D:\CPRM\Qmin\QMineral_Modeller-master\data_input\Data_split\{}_rf.csv".format(group),index=False)
                
             