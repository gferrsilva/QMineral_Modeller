# coding: utf-8

import numpy as np
import pandas as pd
from sklearn.metrics import confusion_matrix
from sklearn.model_selection import train_test_split
from sklearn.ensemble import RandomForestClassifier
from sklearn.metrics import accuracy_score
import itertools
import glob
import pickle
import matplotlib.pyplot as plt

def plot_confusion_matrix(cm, classes,
                          normalize=False,
                          title='Confusion matrix',
                          cmap=plt.cm.Oranges):
    """
    This function prints and plots the confusion matrix.
    Normalization can be applied by setting `normalize=True`.
    Source: http://scikit-learn.org/stable/auto_examples/model_selection/plot_confusion_matrix.html
    """
    
    if normalize:
        cm = cm.astype('float') / cm.sum(axis=1)[:, np.newaxis]
        print("Normalized confusion matrix")
    else:
        print('Confusion matrix, without normalization')

    plt.figure(figsize = (10, 10))
    plt.imshow(cm, interpolation='nearest', cmap=cmap)
    plt.title(title, size = 18)
    plt.colorbar(aspect=4)
    tick_marks = np.arange(len(classes))
    plt.xticks(tick_marks, classes, rotation=45, size = 10)
    plt.yticks(tick_marks, classes, size = 10)

    fmt = '.2f' if normalize else 'd'
    thresh = cm.max() / 2.
    
    # Labeling the plot
    for i, j in itertools.product(range(cm.shape[0]), range(cm.shape[1])):
        plt.text(j, i, format(cm[i, j], fmt), fontsize = 10,
                 horizontalalignment="center",
                 color="blue" if cm[i, j] > thresh else "black")
        
    plt.grid(None)
    plt.tight_layout()
    plt.ylabel('True label', size = 12)
    plt.xlabel('Predicted label', size = 12)
    plt.savefig('../figures/confusion_matrix.png')


def oob_curve(nmin, nmax):
    error_rate = []
    
    for i in range(nmin,nmax+1):
        print("Fitinng Model %d of %d"%(i,nmax-nmin))
        model = RandomForestClassifier(n_estimators=i, 
                               max_features = 'sqrt',
                               n_jobs=-1,
                               oob_score=True)
        model.fit(train, train_labels)
        oob_error = 1 - model.oob_score_
        error_rate.append((i, oob_error))
        
        #Plot Figure
        
        plt.figure(figsize=(10,10))
        for xs, ys in error_rate:
            plt.plot(xs, ys,'k*')
        plt.xlim(nmin-5, nmax+2)
        plt.xlabel("n_estimators")
        plt.ylabel("OOB error rate")
        plt.title("OOB Random Forest Classifier")
        plt.savefig('../figures/oob.png')

    return error_rate
    


path_files = '../data_input/'
input_files = glob.glob(path_files + "*.csv")

min_in = []

for filename in input_files:
    df = pd.read_csv(filename, index_col=None, header=0, encoding = "ISO-8859-1")
    min_in.append(df)

df_all = pd.concat(min_in, axis=0, ignore_index=True)

df = df_all.drop(columns = ['Unnamed: 0', 'CITATION', 'SAMPLE NAME', 'TECTONIC SETTING', 'LOCATION',                        'LOCATION COMMENT', 'LATITUDE (MIN.)', 'LATITUDE (MAX.)',                        'LONGITUDE (MIN.)', 'LONGITUDE (MAX.)', 'LAND/SEA (SAMPLING)',                        'ELEVATION (MIN.)', 'ELEVATION (MAX.)', 'ROCK NAME', 'ROCK TEXTURE',                        'DRILLING DEPTH (MIN.)', 'DRILLING DEPTH (MAX.)', 'ALTERATION',                        'MINERAL', 'SPOT', 'CRYSTAL', 'RIM/CORE (MINERAL GRAINS)', 'GRAIN SIZE',                        'PRIMARY/SECONDARY'])

df = df.drop(columns=['H20'])

# Extract the labels
labels = np.array(df.pop('GROUP'))

# 30% examples in test data
train, test, train_labels, test_labels = train_test_split(df, labels, 
                                                          stratify = labels,
                                                          test_size = 0.3)

print('Training Features Shape:', train.shape)
print('Training Labels Shape:', train_labels.shape)
print('Testing Features Shape:', test.shape)
print('Testing Labels Shape:', test_labels.shape)


# Create the model with 150 trees
model = RandomForestClassifier(n_estimators=50, 
                               max_features = 'sqrt',
                               n_jobs=-1, verbose = 1,
                               oob_score=True)

# Fit on training data
model.fit(train, train_labels)

n_nodes = []
max_depths = []

for ind_tree in model.estimators_:
    n_nodes.append(ind_tree.tree_.node_count)
    max_depths.append(ind_tree.tree_.max_depth)
    
print(f'Average number of nodes {int(np.mean(n_nodes))}')
print(f'Average maximum depth {int(np.mean(max_depths))}')

train_rf_predictions = model.predict(train)
train_rf_probs = model.predict_proba(train)[:, 1]

rf_predictions = model.predict(test)
rf_probs = model.predict_proba(test)[:, 1]

acc = accuracy_score(rf_predictions,test_labels)

print("ACC Treino", accuracy_score(train_rf_predictions,train_labels))
print("ACC Teste",acc)

feature_list = list(df.columns)

# Get numerical feature importances
importances = list(model.feature_importances_)
# List of tuples with variable and importance
feature_importances = [(feature, round(importance, 2)) for feature, importance in zip(feature_list, importances)]
# Sort the feature importances by most important first
feature_importances = sorted(feature_importances, key = lambda x: x[1], reverse = True)
# Print out the feature and importances 
[print('Variable: {:20} Importance: {}'.format(*pair)) for pair in feature_importances];


cm = confusion_matrix(test_labels, rf_predictions)
plot_confusion_matrix(cm, classes = df.columns,
                      title = 'Confusion Matrix')

# Save Model

filename = '../model/model_rf.sav'
pickle.dump(model, open(filename, 'wb'))
