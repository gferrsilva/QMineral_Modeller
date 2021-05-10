import numpy as np
import pandas as pd
from sklearn.metrics import confusion_matrix, classification_report
from sklearn.ensemble import RandomForestClassifier
from sklearn.metrics import accuracy_score
import itertools
import pickle
import matplotlib.pyplot as plt


class Error(Exception):
    """Base class for exceptions in this module."""
    pass


class InputError(Error):
    """Exception raised for errors in the input.

    Attributes:
        expression -- input expression in which the error occurred
        message -- explanation of the error
    """

    def __init__(self, message):
        self.message = message


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
    path = './model_py/'
    pickle.dump(model, open(path + model_name, 'wb'))
    print("Model Saved ...\n" + path + model_name)


def load_model():
    modelsaved = './model_py/allmodels6.pkl'
    with open(modelsaved, "rb") as f:
        model = pickle.load(f)

    return model

def load_regression_model():
    modelsaved = './model_py/regression_anfibolio.pkl'
    with open(modelsaved, "rb") as f:
        model = pickle.load(f)

    return model

def test_cprm_datasets(filename):
    # Features used in training!
    models = load_model()
    # print(models)
    Qmin_RF_features = models['Train Features']
    # Qmin_RF_features = trainFeatures.values.tolist()
    # print(Qmin_RF_features)
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
    df_c = df.copy()
    df_qc = quality_entropy(models['GROUP'], df, 'group')
    mineral_class = models['SULFIDE'].predict(df_c)
    df_qc2 = quality_entropy(models["SULFIDE"], df_c, 'mineral')
    df_w['GROUP_CLASS'] = group_class
    df_w['GROUP QC'] = df_qc['GROUP QC']
    # df_w['CERTAINTY GROUP'] = df_qc['CERTAINTY GROUP']
    df_w['MINERAL_CLASS'] = mineral_class
    # df_w['CERTAINTY MINERAL'] = df_qc2['CERTAINTY MINERAL']
    df_w['MINERAL QC'] = df_qc2['MINERAL QC']
    df_w['2nd PREDICT MINERAL'] = df_qc2['2nd PREDICT MINERAL']

    df_w.to_excel(filename[:-4] + '_classify.xls')
    cols = df_w.columns.tolist()
    cols = cols[-5:] + cols[:-5]
    df_w = df_w[cols]
    # print(df_w)
    print(classification_report(df_w['MINERAL'], mineral_class))
    print(accuracy_score(df_w['MINERAL'], mineral_class))
    return df_w.round(4)


def test_cprm_datasets_web(filename):
    # Features used in training!
    models = load_model()
    # print(models)
    Qmin_RF_features = models['Train Features']
    # Qmin_RF_features = trainFeatures.values.tolist()
    # print(Qmin_RF_features)
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
    df_c = df.copy()
    df_qc = quality_entropy(models['GROUP'], df, 'group')
    mineral_class = models['SULFIDE'].predict(df_c)
    df_qc2 = quality_entropy(models["SULFIDE"], df_c, 'mineral')
    df_w['GROUP_ClASS'] = group_class
    df_w['GROUP QC'] = df_qc['GROUP QC']
    df_w['CERTAINTY GROUP'] = df_qc['CERTAINTY GROUP']
    df_w['MINERAL_CLASS'] = mineral_class
    df_w['CERTAINTY MINERAL'] = df_qc2['CERTAINTY MINERAL']
    df_w['MINERAL QC'] = df_qc2['MINERAL QC']
    df_w['2nd PREDICT MINERAL'] = df_qc2['2nd PREDICT MINERAL']

    # df_w.to_excel(filename[:-4] + '_classify.xls')
    return df_w.round(4)


def organize(df):
    model = load_model()
    table_reference = './assets/OXIDE_TO_ELEMENT.csv'
    df_references = pd.read_csv(table_reference, sep=';')

    dic = {}
    el = []
    for i in range(len(df_references['Element'])):
        dic[i] = str(df_references['Element'][i]).strip().upper()
        el.append(str(df_references['Element'][i]).strip().upper())
    df_references.replace(dic)
    df_references['Element_Upper'] = el

    # Loop to convert Element to oxide if needed
    # TODO: Check for + in ion exp Ca2+
    for i in df.columns:
        c = i.strip().upper()

        a = df_references[df_references['Element_Upper'] == c]

        if len(a) != 0:
            df[i] = df[i].astype('float')
            if c == 'S' or c == 'AG' or c == 'AS' or i == 'F' or c == 'CL':
                continue
            else:
                if len(a[a['Valency'] == 1]['Factor']) == 1:
                    if c == 'CU':
                        factor = float(a[a['Valency'] == 2]['Factor'])

                        df[c + 'O'] = df[i] * factor
                    else:
                        factor = float(a[a['Valency'] == 1]['Factor'])

                        df[c + 'O'] = df[i] * factor

                elif len(a[a['Valency'] == 2]['Factor']) == 1:
                    factor = float(a[a['Valency'] == 2]['Factor'])
                    df[c + 'O'] = df[i] * factor

                elif len(a[a['Valency'] == 3]['Factor']) == 1:
                    factor = float(a[a['Valency'] == 3]['Factor'])

                    if c == 'CO':
                        df[c + 'O'] = df[i] * factor
                    else:
                        df[c + '2O3'] = df[i] * factor

                elif len(a[a['Valency'] == 5]['Factor']) == 1:
                    factor = float(a[a['Valency'] == 5]['Factor'])
                    df[c + '2O5'] = df[i] * factor

    dic = {}
    for i in range(len(df.columns)):
        dic[df.columns[i]] = str(df.columns[i]).strip().upper()
    df = df.rename(columns=dic)

    # Remove Columns not in Qmin_Group_RF (Oxides used in trainnig RF model)
    for i in df.columns:
        if i == 'FEO':
            df = df.rename(columns={'FEO': 'FEOT'})
            continue
        if i not in model['Train Features']:
            df = df.drop(columns=i)

    # Add missing columns
    for i in model['Train Features']:
        if i not in df.columns:
            df[i] = 0

    df = df.reindex(columns=model['Train Features'])

    return df


def quality_entropy(model, df, gtype):
    # Determine Quality of esimativy based on entropy of probs
    from scipy.stats import entropy

    probs = model.predict_proba(df)

    if gtype == 'group':
        df['CERTAINTY GROUP'] = 0.0
        df['GROUP QC'] = 'qc'
    elif gtype == 'mineral':
        df['CERTAINTY MINERAL'] = 0.0
        df['MINERAL QC'] = 'qc'
        df['2nd PREDICT MINERAL'] = 'mineral'

    j = 0
    for i in probs:
        ent = entropy(i, base=len(i))

        if gtype == 'group':
            df.iloc[j, df.columns.get_loc('CERTAINTY GROUP')] = 1 - ent
            if 1 - ent > 0.7:
                df.iloc[j, df.columns.get_loc('GROUP QC')] = 'HIGH QUALITY'
            elif 1 - ent > 0.5:
                df.iloc[j, df.columns.get_loc('GROUP QC')] = 'MEDIUM QUALITY'
            else:
                df.iloc[j, df.columns.get_loc('GROUP QC')] = "LOW QUALITY"
        elif gtype == 'mineral':
            index_2nd = np.argsort(i)[-2]
            df.iloc[j, df.columns.get_loc('2nd PREDICT MINERAL')] = model.classes_[index_2nd]
            df.iloc[j, df.columns.get_loc('CERTAINTY MINERAL')] = 1 - ent
            if 1 - ent > 0.5:
                df.iloc[j, df.columns.get_loc('MINERAL QC')] = 'HIGH QUALITY'
            if 1 - ent > 0.4:
                df.iloc[j, df.columns.get_loc('MINERAL QC')] = 'MEDIUM QUALITY'
            else:
                df.iloc[j, df.columns.get_loc('MINERAL QC')] = "LOW QUALITY"
        j += 1

    return df


def load_data_ms_web(filename, separator_diferent=',', ftype='csv',
                     skipfooter=6, skiprow=3):
    from formula import get_formula, append_df_to_excel

    model = load_model()

    if ftype == 'csv':
        # df = pd.read_csv(filename, skipfooter=6, skiprows=3, )
        df = pd.read_csv(filename, sep=',')
    elif ftype == 'xls' or ftype == 'xlsx':
       # df = pd.read_excel(filename, skipfooter=skipfooter, skiprows=skiprow)
        df = pd.read_excel(filename)
        #df = pd.read_excel(filename,  skiprows=3, skipfooter=6)
        df = df.dropna()
        #print(df)
    else:
        print('Error in read input')
        raise InputError("Input file not supported!!!")

    df_w = df

    # Check if values is separated with , instead of .
    # if separator_diferent:
    #     df = df.stack().str.replace(',', '.').unstack()
    df = organize(df)

    # Predict Group
    df_w['PREDICTED GROUP'] = model['GROUP'].predict(df)

    df_qc = quality_entropy(model['GROUP'], df, 'group')

    # df_w['CERTAINTY GROUP'] = df_qc['CERTAINTY GROUP']
    df_w['GROUP QC'] = df_qc['GROUP QC']
    groups = df_w['PREDICTED GROUP'].unique()
    #print(groups)
    print(df_w)

    # Predict Mineral
    df_partial = []

    for group in groups:
        print('Predicting Mineral for group:', group)
        print(groups)
        df = df_w[df_w['PREDICTED GROUP'] == group]

        df = organize(df)

        one_mineral = ["APATITE", "ILMENITE", "PEROVSKITE",
                       "QUARTZ", "TITANITE", "ZIRCON","CHLORITE"]

        if group in one_mineral:
           # predictions = model[group].predict(df)
           # print(predictions)
            df = df_w[df_w['PREDICTED GROUP'] == group]
            df['PREDICTED MINERAL'] = group
            df['MINERAL QC'] = "ONLY MINERAL"
            df['2nd PREDICT MINERAL'] = "NONE"
          #  print(df)
        else:
            predictions = model[group].predict(df)

            df_qc = quality_entropy(model[group], df, 'mineral')
         #   print(df_qc)
            # predictions = model[group].predict(df)
            df = df_w[df_w['PREDICTED GROUP'] == group]
            # df['PREDICTED GROUP'] = group
            # print(df)
            df['PREDICTED MINERAL'] = predictions

            #print(df['PREDICTED MINERAL'])
            # df['CERTAINTY MINERAL'] = df_qc['CERTAINTY MINERAL']
            df['MINERAL QC'] = df_qc['MINERAL QC']
            df['2nd PREDICT MINERAL'] = df_qc['2nd PREDICT MINERAL']

       # df = df.astype('float64')
       #  try:
       #      predictions = model[group].predict(df)
       #
       #      df_qc = quality_entropy(model[group], df, 'mineral')
       #      print(df_qc)
       #      # predictions = model[group].predict(df)
       #      df = df_w[df_w['PREDICTED GROUP'] == group]
       #      # df['PREDICTED GROUP'] = group
       #      # print(df)
       #      df['PREDICTED MINERAL'] = predictions
       #
       #      #print(df['PREDICTED MINERAL'])
       #      # df['CERTAINTY MINERAL'] = df_qc['CERTAINTY MINERAL']
       #      df['MINERAL QC'] = df_qc['MINERAL QC']
       #      df['2nd PREDICT MINERAL'] = df_qc['2nd PREDICT MINERAL']
       #  # except ZeroDivisionError:
       #  #     pass
       #  except:
       #      continue


        # print(group+'\n\n')
        df_partial.append(df)
    # print(df_partial)
    df_all = pd.concat(df_partial, axis=0, ignore_index=True)
    print(df_all)
    cols = df_all.columns.tolist()
    cols = cols[-5:] + cols[:-5]
    df_all = df_all[cols]
    formulas, dic_formulas = get_formula(df_all)
    df_all.insert(5, 'FORMULA', formulas['Formula'])

    # groups_df = formulas['PREDICTED GROUP'].unique()
    # for group in groups_df:
    #     df_partial = formulas[formulas['PREDICTED GROUP'] == group]
    #     append_df_to_excel('formula_calculator_output.xlsx', df_partial, sheet_name=group + '_formula')

    return df_all.round(4), dic_formulas


def load_data_ms(filename, separator_diferent=False):
    model = load_model()

    if filename[-3:] == 'csv':
        df = pd.read_csv(filename)
    elif filename[-3:] == 'xls' or filename[-4:] == 'xlsx':
        df = pd.read_excel(filename,  skiprows=3, )
    else:
        raise InputError("Input file not suported!!!")
    df_w = df

    # Check if values is separated with , instead of .
    if separator_diferent:
        df = df.stack().str.replace(',', '.').unstack()
    df = organize(df)

    # Predict Group
    df_w['PREDICTED GROUP'] = model['GROUP'].predict(df)
    df_qc = quality_entropy(model['GROUP'], df, 'group')
    # df_w['CERTAINTY GROUP'] = df_qc['CERTAINTY GROUP']
    df_w['GROUP QC'] = df_qc['GROUP QC']

    groups = df_w['PREDICTED GROUP'].unique()

    # Predict Mineral
    df_partial = []

    for group in groups:
        df = df_w[df_w['PREDICTED GROUP'] == group]
        # Check if values is separated with , instead of .
        if separator_diferent:
            df = df.stack().str.replace(',', '.').unstack()
        df = organize(df)
        predictions = model[group].predict(df)
        # print(group+'\n\n')
        df_qc = quality_entropy(model[group], df, 'mineral')

        # predictions = model[group].predict(df)
        df = df_w[df_w['PREDICTED GROUP'] == group]
        # df['PREDICTED GROUP'] = group
        df['PREDICTED MINERAL'] = predictions
        # df['CERTAINTY MINERAL'] = df_qc['CERTAINTY MINERAL']
        df['MINERAL QC'] = df_qc['MINERAL QC']
        df['2nd PREDICT MINERAL'] = df_qc['2nd PREDICT MINERAL']

        df_partial.append(df)

    df_all = pd.concat(df_partial, axis=0, ignore_index=True)
    # print(df_all)
    cols = df_all.columns.tolist()
    cols = cols[-5:] + cols[:-5]
    df_all = df_all[cols]

    outfilename = filename[:-4] + '_classify.xls'
    # print(outfilename)
    df_all.to_excel(outfilename)

   # print(df)
    return df_all


def _odf2df(odf):
    # convert Orange Data table to Pandas DataFrame

    # TODO Deal with Categorical Variable where Orange convert to ints with indices of text
    col = []
    for i in odf.domain:
        col.append(i.name)

    df = pd.DataFrame(odf, columns=col)

    return df


def predict_mineral_orange(odf):
    # Input Orange Data Table

    model = load_model()

    # Convert from Orange Data table to Pandas
    df = _odf2df(odf)

    # Making a copy of df
    df_w = df
    # Adjust Dataframe for predict, removing columns, sorting, etc
    df = organize(df)

    # Predict Group
    df_w['PREDICTED GROUP'] = model['GROUP'].predict(df)
    df_qc = quality_entropy(model['GROUP'], df, 'group')
    df_w['CERTAINTY GROUP'] = df_qc['CERTAINTY GROUP']
    df_w['GROUP QC'] = df_qc['GROUP QC']

    groups = df_w['PREDICTED GROUP'].unique()

    # Predict Mineral
    df_partial = []

    for group in groups:
        df = df_w[df_w['PREDICTED GROUP'] == group]
        df = organize(df)
        predictions = model[group].predict(df)
        df_qc = quality_entropy(model[group], df, 'mineral')

        # predictions = model[group].predict(df)
        df = df_w[df_w['PREDICTED GROUP'] == group]
        df['PREDICTED MINERAL'] = predictions
        df['CERTAINTY MINERAL'] = df_qc['CERTAINTY MINERAL']
        df['MINERAL QC'] = df_qc['MINERAL QC']
        df['2nd PREDICT MINERAL'] = df_qc['2nd PREDICT MINERAL']

        df_partial.append(df)

    df_all = pd.concat(df_partial, axis=0, ignore_index=True)
    return df_all
