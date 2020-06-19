import base64
import datetime
import io
import os
import pandas as pd

import dash
from dash.dependencies import Input, Output, State
import dash_core_components as dcc
import dash_html_components as html
import dash_table
from web_app import about,table, plot

def encode_image(image_file):
    encoded = base64.b64encode(open(image_file, 'rb').read())
    return 'data:image/jpg;base64,{}'.format(encoded.decode())


external_stylesheets = ['https://codepen.io/chriddyp/pen/bWLwgP.css']

app = dash.Dash(__name__, external_stylesheets=external_stylesheets)
server = app.server
app.title = 'Qmin'

app.layout = html.Div([
    dcc.Store(id='store_1', storage_type='session'),
    html.Div([
        html.Img(id='Qmin-logo', src=encode_image('../figures/Qmin_logo.jpg'), height=250, width=1450)
    ], style={'paddingTop': 10}),
    dcc.Tabs(id="tabs", value='tab-1', children=[
        dcc.Tab(label='Qmin', value='tab-1',
                children=[
                    html.H4("Upload Files"),
                    html.Div([html.P("Decimal Separator:"),
                    dcc.Input(id='nsep', size='1', placeholder='.'),
                             html.P("  Column Separator:"),
                             dcc.Input(id='columns-separator', size='1', placeholder=','),
                             html.P("  Header Skip:"),
                             dcc.Input(id='header-skip', size='1', placeholder=0),
                             html.P("  Footer Skip:"),
                             dcc.Input(id='footer-skip', size='1', placeholder=0)
                              ], style={'width': '60%',
                                        'display': 'flex',
                                        'flex-flow': 'row wrap',
                                        'align-items': 'center',
                                        'padding': '5px'}),
                    dcc.Upload(
                        id='upload-data',
                        children=html.Div([
                            'Drag and Drop or ',
                            html.A('Select Files')
                        ]),
                        style={
                            'width': '50%',
                            'height': '60px',
                            'lineHeight': '60px',
                            'borderWidth': '1px',
                            'borderStyle': 'dashed',
                            'borderRadius': '5px',
                            'textAlign': 'center',
                            'margin': '10px'
                        },
                        # Allow multiple files to be uploaded
                        multiple=True
                    ),

                    html.Div(
                        id="download-area",
                        className="block",
                        children=[]
                    ),
                    html.Div(id='download-name'),


                    html.Div(id='output-data-upload')
                ]),
        dcc.Tab(label='About', value='tab-2'),
        dcc.Tab(id='tb3',label='Plot', value='tab-3',
                children=[
        html.Div([
        html.Div([dcc.Dropdown(id='dropdown1')],
            style={'width':'24%','display':'inline-block'}),
        html.Div([dcc.Dropdown(id='dropdown2')],
                 style={'width':'24%','display':'inline-block'}),
        html.Div([dcc.Dropdown(id='dropdown3')],
                 style={'width':'24%','display':'inline-block'}),
        html.Div([dcc.Dropdown(
                id='dropdown4',
                 options=[{'label': 'MINERAL PREDICTED', 'value': 'MINERAL PREDICTED'},
                         {'label': 'GROUP PREDICTED', 'value': 'GROUP PREDICTED'}],
                value='MINERAL PREDICTED'
            )], style={'width': '24%', 'display': 'inline-block'}),
        html.Div(id='dd-output-container'),
                ])
                ])]),
    html.Div(id='tabs-content2'),
    html.Div(id='tabs-content'),

])


# Return Tab2 (About text in markdown)
@app.callback(Output('tabs-content', 'children'),
              [Input('tabs', 'value')])
def render_content(tab):
    if tab == 'tab-2':
        return about.layout


@app.callback(Output('tb3', 'children'),
            [Input('tabs', 'value')],
            [State('form-download', 'action'),
            State('upload-data', 'contents')])
def update_dropdown(tab, nameform, content):
    import numpy as np

    if content == None:
        return

    relative_filename = nameform

    df = pd.read_excel(relative_filename)

    features = df.columns.to_list()
    clean_features = []

    for name in features:
        if df[name].dtypes == np.float or df[name].dtypes == np.int64:
            clean_features.append(name)
    if tab == 'tab-3':
        return html.Div([
        html.Div([
            dcc.Dropdown(
                id='dropdown1',
                options=[{'label': i, 'value': i} for i in clean_features],
                value=clean_features[2]
            )], style={'width': '24%', 'display': 'inline-block'}),
        html.Div([
            dcc.Dropdown(
                id='dropdown2',
                options=[{'label': i, 'value': i} for i in clean_features],
                value=clean_features[3]
            )], style={'width': '24%', 'display': 'inline-block'}),
        html.Div([
            dcc.Dropdown(
                id='dropdown3',
                options=[{'label': i, 'value': i} for i in clean_features],
                value=clean_features[4]
            )], style={'width': '24%', 'display': 'inline-block'}),
        html.Div([
            dcc.Dropdown(
                id='dropdown4',
                options=[{'label': 'MINERAL PREDICTED', 'value': 'MINERAL PREDICTED'},
                         {'label': 'GROUP PREDICTED', 'value': 'GROUP PREDICTED'}],
                value='MINERAL PREDICTED'
            )], style={'width': '24%', 'display': 'inline-block'}),
    html.Div(id='dd-output-container'),
    ], style={'passing': 10})

@app.callback(Output('tabs-content2','children'),
               [Input('tabs','value'),
                Input('dropdown1','value'),
                Input('dropdown2', 'value'),
                Input('dropdown3', 'value'),
                Input('dropdown4','value')],
              [State('form-download', 'action'),
               State('upload-data', 'contents')])
def update_graph(tabs, dp1, dp2, dp3, dp4, nameform, contents):
    import plotly.express as px

    if tabs == 'tab-3':

        if contents == None:
            return

        relative_filename = nameform

        df = pd.read_excel(relative_filename)

        if 'Total' in df.columns:
            fig = px.scatter_ternary(df,
                                     a=df[dp1], b=df[dp2],
                                     c=df[dp3], size_max=15,
                                     color=dp4, hover_name=df['MINERAL PREDICTED'],
                                     size=df['Total'])
        else:
            fig = px.scatter_ternary(df,
                                 a=df[dp1], b=df[dp2],
                                 c=df[dp3], size_max=15,
                                 color=dp4,hover_name=df['MINERAL PREDICTED'])
        return dcc.Graph(id='ternary-graph',figure=fig)


def write_excel(df):
    import uuid
    import pandas as pd

    filename = f"{uuid.uuid1()}.xlsx"


    relative_filename = os.path.join(
        'downloads',
        filename
    )
    if os.path.exists(relative_filename):
        os.remove(relative_filename)


    absolute_filename = os.path.join(os.getcwd(), relative_filename)
    writer = pd.ExcelWriter(absolute_filename)
    df.to_excel(writer, 'QMIN')
    writer.save()
    return relative_filename


def parse_contents(contents, filename, date, write=False):
    import qmin

    content_type, content_string = contents.split(',')
    decoded = base64.b64decode(content_string)
    try:
        if 'csv' in filename:
            # Assume that the user uploaded a CSV file is CPRM style (evandro)

            df = qmin.load_data_ms_web(io.StringIO(decoded.decode('ISO-8859-1')), ftype='csv')
            filename_output = write_excel(df)

        elif 'xls' in filename or 'xlsx' in filename:
            # Assume that the user uploaded an excel file
            #This excel is format of Microssonda!!!!
            df = qmin.load_data_ms_web(io.BytesIO(decoded), ftype='xls')
            filename_output = write_excel(df)

        if write:
            filename_output = write_excel(df)
    except Exception as e:
        print(e)
        return html.Div([
            'There was an error processing this file.'
        ])

    return html.Div([
        html.H5(filename),
        html.H6(datetime.datetime.fromtimestamp(date)),

        dash_table.DataTable(
            id='table',
            style_table={
                'maxHeight': '700px',
                'overflowY': 'scroll',
                'overflowX': 'scroll'
            },

            data=df.to_dict('records'),
            columns=[{'name': i, 'id': i} for i in df.columns],

            fixed_rows={'headers': True, 'data': 0},
        style_data_conditional=[
        {
            'if': {'row_index': 'odd'},
            'backgroundColor': 'rgb(248, 248, 248)'
        }],

        style_header=
        {
        'backgroundColor': 'rgb(230, 230, 230)',
        'fontWeight': 'bold'
        },
        style_cell=
        {
            'overflow': 'hidden',
            'textOverflow': 'ellipsis',
            'width': 'auto'
        }
        ),

        html.Hr(),  # horizontal line

    ]), filename_output

# Plot table!
@app.callback(Output('output-data-upload', 'children'),
              [Input('upload-data', 'contents')],
              [State('upload-data', 'filename'),
               State('upload-data', 'last_modified'),
               State('columns-separator', 'placeholder')]
               )
def update_output(list_of_contents, list_of_names, list_of_dates, csep=None):
    print('columns-separator', csep)

    if list_of_contents is not None:
         results = [
             parse_contents(c, n, d) for c, n, d in
             zip(list_of_contents, list_of_names, list_of_dates)]
         children = [results[0][0]]

         return children


def build_download_button(uri):
    """Generates a download button for the resource"""
    button = html.Form(
        action=uri,
        method="get",
        id='form-download',
        children=[
            html.Button(
                className="button",
                type="submit",
                children=[
                    "download"
                ]
            )
        ]
    )
    return button

@app.callback(
    Output("download-area", "children"),
    [Input('upload-data', 'contents')],
    [State('upload-data', 'filename'),
     State('upload-data', 'last_modified')])
def show_download_button(list_of_contents, list_of_names, list_of_dates):

    if list_of_contents is not None:
         results = [
             parse_contents(c, n, d) for c, n, d in
             zip(list_of_contents, list_of_names, list_of_dates)]
         filename = results[0][1]

         return [build_download_button(filename)]


@app.server.route('/downloads/<path:path>')
def serve_static(path):
    import flask
    root_dir = os.getcwd()
    return flask.send_from_directory(
        os.path.join(root_dir, 'downloads'), path
    )

if __name__ == '__main__':
    app.run_server(debug=True)