
import dash_html_components as html
import dash_core_components as dcc
from dash.dependencies import Input, Output, State

#@app.callback(Output('store-1', 'children'),
#              [Input('upload-data', 'contents')],
#              [State('upload-data', 'filename'),
#               State('upload-data', 'last_modified')])
# STORE N-CLICKS in dcc.Store 1

def get_data_df(df):
    if ftype == 'csv':
        #df = pd.read_csv(filename, skipfooter=6, skiprows=3, )
        df = pd.read_csv(filename)
    elif ftype == 'xls' or ftype == 'xlsx':
        try:
            df = pd.read_excel(filename, skipfooter=6, skiprows=3)
        except Exception:
            df = pd.read_excel(filename, skipfooter=6, skiprows=3, engine="openpyxl")
    else:
         raise InputError("Input file not suported!!!")
    return df





import plotly.express as px
df = px.data.election()
fig = px.scatter_ternary(df,
                         a="Joly", b="Coderre",
                         c="Bergeron", hover_name="district",
                         color="winner", size="total", size_max=15,
                         color_discrete_map = {"Joly": "blue",
                                               "Bergeron": "green",
                                               "Coderre":"red"} )
#fig.show()
def ternary(df):
    import numpy as np

    features = df.columns.to_list()
    clean_features = []

    for name in features:
         if df[name].dtypes == np.float or df[name].dtypes == np.int64:
             clean_features.append(name)

    fig = px.scatter_ternary(df,
                             a=clean_features[2], b=clean_features[3],
                             c=clean_features[4], size_max=15,
                             color=df['MINERAL PREDICTED'])


    return html.Div([
        html.Div([
        dcc.Dropdown(
            id='dropdown1',
            options=[{'label':i, 'value': i} for i in clean_features],
        value=clean_features[2]
    )], style={'width':'24%','display':'inline-block'}),
        html.Div([
        dcc.Dropdown(
            id='dropdown2',
            options=[{'label':i, 'value': i} for i in clean_features],
            value=clean_features[3]
        )],style={'width':'24%','display':'inline-block'}),
        html.Div([
        dcc.Dropdown(
            id='dropdown3',
            options=[{'label':i, 'value': i} for i in clean_features],
            value=clean_features[4]
        )],style={'width':'24%','display':'inline-block'}),
        html.Div([
            dcc.Dropdown(
                id='dropdown4',
                options=[{'label': 'MINERAL PREDICTED', 'value': 'MINERAL PREDICTED'},
                         {'label': 'GROUP PREDICTED', 'value': 'GROUP PREDICTED'}],
                value='MINERAL PREDICTED'
            )], style={'width': '24%', 'display': 'inline-block'}),
        html.Div(id='dd-output-container'),
        dcc.Graph(id='ternary-graph',figure=fig)
    ],style={'passing':10})