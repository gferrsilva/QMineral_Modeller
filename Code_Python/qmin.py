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
                          cmap=plt.cm.Oranges,
                          output='../figures/rf_confusion_matrix.png'):
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

    plt.figure(figsize=(10, 10))
    plt.imshow(cm, interpolation='nearest', cmap=cmap)
    plt.title(title, size=18)
    plt.colorbar(aspect=4)
    tick_marks = np.arange(len(classes))
    plt.xticks(tick_marks, classes, rotation=45, size=10)
    plt.yticks(tick_marks, classes, size=10)

    fmt = '.2f' if normalize else 'd'
    thresh = cm.max() / 2.

    # Labeling the plot
    for i, j in itertools.product(range(cm.shape[0]), range(cm.shape[1])):
        plt.text(j, i, format(cm[i, j], fmt), fontsize=10,
                 horizontalalignment="center",
                 color="blue" if cm[i, j] > thresh else "black")

    plt.grid(None)
    plt.tight_layout()
    plt.ylabel('True label', size=12)
    plt.xlabel('Predicted label', size=12)
    plt.savefig(output)


def oob_curve(nmin, nmax):
    error_rate = []

    for i in range(nmin, nmax + 1):
        print("Fitinng Model %d of %d" % (i, nmax - nmin))
        model = RandomForestClassifier(n_estimators=i,
                                       max_features='sqrt',
                                       n_jobs=-1,
                                       oob_score=True)
        model.fit(train, train_labels)
        oob_error = 1 - model.oob_score_
        error_rate.append((i, oob_error))

        # Plot Figure

        plt.figure(figsize=(10, 10))
        for xs, ys in error_rate:
            plt.plot(xs, ys, 'k*')
        plt.xlim(nmin - 5, nmax + 2)
        plt.xlabel("n_estimators")
        plt.ylabel("OOB error rate")
        plt.title("OOB Random Forest Classifier")
        plt.savefig('../figures/oob.png')

    return error_rate


def saveModel(model_name):
    # Save Model
    path = '../model_py/'
    pickle.dump(model, open(path+model_name, 'wb'))
    print("Model Saved ...\n"+path+model_name)


def load_model():
    modelsaved = '../model_py/allmodels.pkl'
    with open(modelsaved, "rb") as f:
        model = pickle.load(f)

    return model

def test_cprm_datasets(filename, models):
    # Features used in training!
    #model = load_model()
  #  print(model)
    Qmin_RF_features = models['Train Features']
    #Qmin_RF_features = trainFeatures.values.tolist()
    print(Qmin_RF_features)
    df = pd.read_csv(filename, encoding="ISO-8859-1")
    df_w = df

    # Remove Columns not in Qmin_Group_RF (Oxides used in trainnig RF model)
    for i in df.columns:
        if i == 'FEO':
            df = df.rename(columns={'FEO': 'FEOT'})
            continue
        if i not in Qmin_RF_features:
            print('Data not in trained RF Model: ', i)
            df = df.drop(columns=i)

            # Add missing columns
    for i in Qmin_RF_features:
        if i not in df.columns:
            print('Missing... ', i)
            df[i] = 0.0

    df = df.astype('float64')
    df = df.reindex(columns=Qmin_RF_features)

    group_class = models['GROUP'].predict(df)
    mineral_class = models['SULFIDE'].predict(df)
    df_w['GROUP_ClASS'] = group_class
    df_w['MINERAL_CLASS'] = mineral_class
    df_w.to_csv(filename[:-4] + '_rf_python.csv')
    print(classification_report(df_w['MINERAL'], mineral_class))
    print(accuracy_score(df_w['MINERAL'], mineral_class))

