# -*- coding: utf-8 -*-
"""
Created on Fri May 29 18:41:43 2020

@author: Cliente
"""

import pandas as pd
import statistics
from imblearn.pipeline import make_pipeline
from imblearn.over_sampling import SMOTE
from imblearn.under_sampling import NearMiss,RandomUnderSampler
import glob
from sklearn.model_selection import train_test_split
from sklearn.ensemble import RandomForestClassifier
from sklearn.metrics import confusion_matrix, classification_report 
from timeit import default_timer as timer

start = timer()


path_files = '../data_input/Data_split'

cutoff = 10

number_of_samples = 50   # Number of SMOTE samples

def smote_data(mineral_file,cutoff,log_file,number_of_samples=15):
    
    mineral = pd.read_csv(mineral_file,index_col='MINERAL')
    
    # Verify cutoff condition
    min_list = mineral.index.unique()
    
    pass_minerals = []
    cut_minerals = []
    for var in min_list:
        #print(len(mineral[mineral.index == var]))
        if len(mineral[mineral.index == var]) >= cutoff:
            #pass_minerals.append(len(mineral[mineral['MINERAL'] == var]))
            pass_minerals.append(var)
        else:
            #cut_minerals.append(len(mineral[mineral['MINERAL'] == var]))
            cut_minerals.append(var)
            
   
    # remove minerals bellow cutoff
    mineral.drop(cut_minerals, inplace=True)
    
    count_min = []
    for var in pass_minerals:
        count_min.append(mineral.loc[var,:].shape[0])
           
    
    
    #### RUN SMOTE TO BALANCE THE CLASSES ####
    
    # test if the data has a minimum of 2 classes to balance
    if mineral.index.unique().shape[0] > 1:
        ############ oversampling and downsampling base on the median (or a value)
        #median_value = int(statistics.median(count_min))
        median_value = number_of_samples
                
        #cols = mineral.columns.to_list()[5:]
        cols = ['SIO2', 'TIO2', 'AL2O3', 'CR2O3', 'FEOT', 'CAO', 'MGO', 'MNO', 'K2O', 'NA2O', 'P2O5', 'H20',
                'F', 'CL', 'NIO', 'CUO', 'COO', 'ZNO', 'PBO', 'S', 'ZRO2', 'AS']
        
        X = mineral[cols].iloc[:,:].values
        y = mineral.index.values
        
       
        down_keys = []
        up_keys = []
        
        for var in pass_minerals:
            if mineral.loc[var,:].shape[0] > median_value:
                down_keys.append(var)
                #downsample = {var : median_value}
            if mineral.loc[var,:].shape[0] < median_value:
                up_keys.append(var)
                #upsample= {var : median_value}
            else:
                None
        
        downsample_dict={}
        upsample_dict = {}
        
        for i in down_keys:
            downsample_dict[i] = median_value
            
        for i in up_keys:
            upsample_dict[i] = median_value 
        
        
        #pipe = make_pipeline(SMOTE(sampling_strategy=upsample_dict),NearMiss(sampling_strategy=downsample_dict,version=1)) ## Near Miss
        pipe = make_pipeline(SMOTE(sampling_strategy=upsample_dict,k_neighbors=3),RandomUnderSampler(sampling_strategy=downsample_dict))
        X_smt, y_smt = pipe.fit_resample(X, y)
        
        X_new = pd.DataFrame(X_smt, columns=cols)
        X_new['MINERAL'] = y_smt
        X_new['GROUP'] = mineral.GROUP.unique()[0]
        
        #for var in pass_minerals:
            #print(len(X_new[X_new['MINERAL'] == var]))
        print("\n\nprocessing group: %s" % mineral.GROUP.unique()[0])
        print("%i of %i minerals removed: " % (len(cut_minerals),len(min_list)))
        print("accepted: %s" % pass_minerals)
        print('rejected: %s' % cut_minerals)
        print("median value: %i" % median_value)
        print('sample size: %i\n\n' % len(X_new[X_new['MINERAL'] == pass_minerals[0]] ))
        
        log_file.write("processing group: %s\n" % mineral.GROUP.unique()[0])
        log_file.write("%i of %i minerals removed: \n" % (len(cut_minerals),len(min_list)))
        log_file.write("accepted: %s\n" % pass_minerals)
        log_file.write('rejected: %s\n' % cut_minerals)
        log_file.write("median value: %i\n" % median_value)
        log_file.write('sample size: %i\n\n' % len(X_new[X_new['MINERAL'] == pass_minerals[0]] ))
        
        
        ## Test accuracy after SMOTE
        test_acc(X,y,log_file)
        
        
        ## Test accuracy before SMOTE
        X_final = X_new[cols].iloc[:,:].values
        y_final = X_new['MINERAL'].iloc[:].values
        test_acc(X_final,y_final,log_file)
        
        
        
        
        return X_new


def test_acc(X,y,log_file):
    X_train, X_test, y_train, y_test = train_test_split(X, y, test_size = 0.3, random_state = 0)

    model = RandomForestClassifier(n_estimators=50,max_features='sqrt',n_jobs=-1, oob_score=True)
    model.fit(X_train, y_train.ravel())
    predictions = model.predict(X_test) 
  
    # print classification report 
    print(classification_report(y_test, predictions))
    log_file.write(classification_report(y_test, predictions))


log_file = open("SMOTE_log_Random_Sampler.txt", "w")


mineral_file = "../data_input/Data_split/AMPHIBOLES_rf.csv"
df_main = smote_data(mineral_file,cutoff,log_file,number_of_samples)

input_files = glob.glob(path_files+'\*')

for files in input_files[1:]:
    df = smote_data(files,cutoff,log_file,number_of_samples)
    df_main = pd.concat([df_main, df])

df_main.round(2).to_csv('Data_imput_SMOTE_Random_Sampler.csv',index=False)

log_file.close()

end = timer()
print('Elapsed time is %.2f seconds.' % (end-start))



# Write the new file
 # or directly use: df_1 = df[df['Time'] < 0.1]
    
for group in df_main['GROUP'].unique():
    
    mask = df_main['GROUP'] == group
    df_1 = df_main[mask]

    i=0
    for files in df_1['MINERAL'].unique():
        
        print('{} instances for {}'.format(len(df_1[df_1['MINERAL'] == files]),files))
        i=+1
            
    print('\n{} instances for GROUP {}, with {} minerals\n'.format(len(df_main[df_main['GROUP'] == group]),group,len(df_1['MINERAL'].unique())))
    



  




