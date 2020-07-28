import base64
import datetime
import io
import os
import pandas as pd
import plotly.graph_objects as go
import dash
from dash.dependencies import Input, Output, State
import dash_core_components as dcc
import dash_html_components as html
import dash_table
from web_app import about, table, plot, informations
import plotly.express as px
import numpy as np



def encode_image(image_file):
    encoded = base64.b64encode(open(image_file, 'rb').read())
    return 'data:image/jpg;base64,{}'.format(encoded.decode())


external_stylesheets = ['https://codepen.io/chriddyp/pen/bWLwgP.css']

app = dash.Dash(__name__, external_stylesheets=external_stylesheets)
server = app.server
app.title = 'Qmin'

def upload_card():
    """
    :return: A Div for upload data.
    """
    return html.Div([
                html.Div([
                    html.H4("Upload Files",
                            style={'text-align': 'center'}),
                    html.Div(className='row',
                             children=[
                              html.P("Decimal Separator:",
                                     className='four columns'),
                              dcc.Input(id='nsep',
                                        size='1',
                                        placeholder='.',
                                        className='two columns')]),
                    html.B(),
                    html.Div(className='row',
                             children=[html.P("  Column Separator:",
                                              className='four columns'),
                             dcc.Input(id='columns-separator',
                                       size='1', placeholder=',',
                                       className='two columns')]),
                    html.Div(className='row',
                             children=[html.P("  Header Skip:",
                                              className='four columns'),
                             dcc.Input(id='header-skip',
                                       size='1',
                                       placeholder=0,
                                       className='two columns')]),
                    html.Div(className='row',
                             children=[html.P("  Footer Skip:",
                                              className='four columns'),
                             dcc.Input(id='footer-skip',
                                       size='1',
                                       placeholder=0,
                                       className='two columns')])
                            ]),
                    dcc.Upload(
                        id='upload-data',
                        children=html.Div([
                            'Drag and Drop or ',
                            html.A('Select Files')
                        ], style={'text-align': 'center',
                                  'right': '30%'}),
                        style={
                            'width': '50%',
                            'height': '60px',
                            'lineHeight': '60px',
                            'borderWidth': '1px',
                            'borderStyle': 'dashed',
                            'borderRadius': '5px',
                            'textAlign': 'center',
                            'display': 'block',
                            'margin-left': 'auto',
                            'margin-right': 'auto',
                            'margin-top': '20px',
                            'margin-bottom': '20px'},
                         # Allow multiple files to be uploaded
                        multiple=True
                    ),
                    dcc.Checklist(
                            options=[
                                {'label': 'I accept to agreggate my data in the training database of Qmin', 'value': 'true'},
                            ],
                            value=['true'],
                            labelStyle={'display': 'inline-block'},
                            style={'textAlign': 'center',
                                   'display': 'block',
                                   'margin-left': 'auto',
                                   'margin-right': 'auto'}
                        ),
                    html.Div(
                        id="remove_2",
                        className="block",
                        children=[]
                    ),
                    html.Div(id='download-name'),
                    html.Div(id='remove')
                ], className='item-a')

app.layout = html.Div(
    html.Div([
        html.Div(id='banner',
                 style={'width': '100%',
                        'background': "#262B3D",
                        'color': "#E2EFFA"},
                     children=[
                           html.A(id="dashbio-logo",
                                  className='one columns',
                                  children=[html.Img(src='assets/Qmin_logo.png',
                                                     height='60',
                                                     width='70',
                                              style={'top': '10',
                                                     'margin': '10px'})]),
                           html.H2('Mineral Chemistry Virtual Assistant',
                                   className='five columns',
                                   style={'font-size': '45px',
                                          'float': 'left'}),
                           html.A([
                               html.Img(src="assets/GitHub-Mark-Light-64px.png",
                                        style={'float': 'right'})
                               ],
                               href='https://github.com/gferrsilva/QMineral_Modeller')
                          
                           ],
                 className='row'),

         html.Div(children=[
                      html.Div(className='row',  # Define the row element
                               children=[
                        # Define the right element
                          html.Div(className='four columns div-user-controls',
                              children=[upload_card(),
                                          informations.about_card()]),
                                          # Define the left element
                          html.Div(id='right_container',
                                   className='eight columns div-for-charts bg-grey',
                              children=[html.Div([

                dcc.Tabs(
                id="tabs-with-classes",
                value='tab-table',
                parent_className='custom-tabs',
                className='custom-tabs-container',
                children=[
                    dcc.Tab(id='General_tab',
                       label='Dataset',
                        value='tab-table',
                        className='custom-tab',
                        children=[
                         html.Div(id='output-data-upload',
                                  children=[
                                      html.H2('Upload dataset',
                                              style={'text-align': 'center'})
                                      ]),
                         html.Div(
                         id="download-area",
                         className="block",
                         children=[html.Form(
                             action='',
                             method="get",
                             id='form-download',
                             children=[
                                 html.Button(
                                     className="button",
                                     type="submit",
                                     children=["download"]
                                 )
                             ])
                         ])
                           ]),

                     dcc.Tab(id='graphic_tab',
                       label='Graphics',
                        value='graphic-table',
                        className='custom-tab',
                        children=[
                          html.Div(id='General_graphic',children=[
                              html.H3('Upload your dataset',style={'text-align': 'center','padding':'320px'}),   
                              ]),
                          html.Div(id='biplot_graphic'),
                          html.Div(id='triplot_graphic')
                           ]),
                     
                     
                     
                     
                     
                     
                     
                             ])],
                                  className='item-a'),
                                          informations.status_area()
                                          ])
                                           ])  # Define the right element
              ])
                ]))

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
    df = None
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
        html.H5('File loaded: '+filename),
        #html.H4('Last modification in file: '+str(datetime.datetime.fromtimestamp(date))),

        dash_table.DataTable(
            id='table',
            style_table={
                'maxHeight': '500px',
                'overflowY': 'auto',
                'overflowX': 'scroll',
                'minWidth': '100%'
            },

            data=df.to_dict('records'),
            columns=[{'name': i, 'id': i} for i in df.columns],
            fixed_columns={'headers': True, 'data': 2},
            filter_action="native",
            sort_action="native",
            sort_mode='multi',
            style_data_conditional=[
            {
                'if': {'row_index': 'odd'},
                'backgroundColor': 'rgb(248, 248, 248)'
            },
            {
                'if': {'column_id': 'GROUP PREDICTED'},
                'backgroundColor': '#4C5EA1',
                'color': 'white'
            },
            {
                'if': {'column_id': 'QC GROUP'},
                'backgroundColor': '#4C5EA1',
                'color': 'white'
            }

            
            ],
    
            style_header=
            {
            'backgroundColor': '#262B3D',
            'fontWeight': 'bold',
            'color':'white'
            },
            style_cell=
            {
                'overflow': 'hidden',
                'textAlign': 'center',
                'textOverflow': 'ellipsis',
                'width': 'auto'
            }
            ),
        
        #dcc.Graph(figure=fig),

        html.Hr(),  # horizontal line

    ]), filename_output

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

def select_axis(df,feature,axis):
  
    return dict(
        args=[ {axis:[df[feature]], 
                'name':feature}],
        label=feature,
        method="update")


def makeAxis(title, tickangle):
    return {
      'title': title,
      'titlefont': { 'size': 20 },
      'tickangle': tickangle,
      'tickfont': { 'size': 12 },
      'tickcolor': 'rgba(0,0,0,0)',
      'ticklen': 5,
      'showline': True,
      'showgrid': True
    }




@app.callback(Output('output-data-upload', 'children'),
              [Input('upload-data', 'contents')],
              [State('upload-data', 'filename'),
               State('upload-data', 'last_modified'),
               State('columns-separator', 'placeholder')]
               )
def update_output(list_of_contents, list_of_names, list_of_dates, csep=None):
    # print('columns-separator', csep)

    if list_of_contents is not None:
         results = [
             parse_contents(c, n, d) for c, n, d in
             zip(list_of_contents, list_of_names, list_of_dates)]
         children = [results[0][0]]

         return children

    else:
        return html.Div([html.H3('Upload your dataset',style={'text-align': 'center','padding':'320px'})])




@app.callback(
    Output("form-download", "action"),
    [Input('upload-data', 'contents')],
    [State('upload-data', 'filename'),
     State('upload-data', 'last_modified')])
def show_download_button(list_of_contents, list_of_names, list_of_dates):

    if list_of_contents is not None:
         results = [
             parse_contents(c, n, d) for c, n, d in
             zip(list_of_contents, list_of_names, list_of_dates)]
         filename = results[0][1]

         #return [build_download_button(filename)]
         # print("Show Button ", filename)
         return filename



@app.callback(Output('General_graphic', 'children'),
               [Input('graphic_tab', 'value'),
                Input('form-download', 'action')],
                [State('upload-data', 'contents')])

def update_graphic(tab,  nameform, contents):
    #### Callback for the first donut graphic in the graphic table

    if tab == 'graphic-table':
        
        if contents is not None:
  
            relative_filename = nameform
            df = pd.read_excel(relative_filename)
            fig = px.sunburst(df, path=['GROUP PREDICTED', 'MINERAL PREDICTED'])

            return html.Div([
                        dcc.Graph(figure=fig)
                            ])
        
        
        
 ####################################       
        
@app.callback(Output('biplot_graphic', 'children'),
               [Input('graphic_tab', 'value'),
                Input('form-download', 'action')],
                [State('upload-data', 'contents')])

def update_biplot(tab,  nameform, contents):
    #### Callback for the biplot graphic in the graphic table

    if tab == 'graphic-table':
        
        if contents is not None:
       
            relative_filename = nameform
        
            df = pd.read_excel(relative_filename)
            df = df.loc[:, ~df.columns.str.contains('^Unnamed')]  # remove unnamed columns
        
            features = df.columns.to_list()
            clean_features = []
        
            for name in features:
                if df[name].dtypes == np.float or df[name].dtypes == np.int64:
                    clean_features.append(name)

            fig = go.Figure()
            
            # Add traces
            fig.add_trace(
                go.Scatter(
                    x=df[clean_features[0]],
                    y=df[clean_features[0]],
                    mode="markers",
                    marker=dict(color='rgba(152, 0, 0, .8)')
                )
            )
            
            ###### if want to add axis labels ######
            #fig.update_layout(
            #    xaxis_title=clean_features[0],
            #    yaxis_title=clean_features[0],
            #                  )
            
            # Add dropdown
            
            fig.update_traces(mode='markers', marker_line_width=2, marker_size=10)
            
            ###### if want to add title ######
            #fig.update_layout(
            #    title={
            #        'text': "Biplot",
            #        'y':0.9,
            #        'x':0.5,
            #        'xanchor': 'center',
            #        'yanchor': 'top'})
            
            fig.update_layout(
                updatemenus=[
                    dict(
                        buttons=list(
                                [select_axis(df,feature,'y') for feature in clean_features],
                        ),
                
                        direction="down",
                        pad={"r": 10, "t": 10},
                        showactive=True,
                        x=-0.05,
                        xanchor="left",
                        y=1.20,
                        yanchor="top"
                    ),
                    
                    dict(
                        buttons=list(
                                [select_axis(df,feature,'x') for feature in clean_features],
                        ),
                        
                 
                        direction="up",
                        pad={"r": 30, "t": 50},
                        showactive=True,
                        x=1.05,
                        xanchor="right",
                        y=-0.05,
                        yanchor="middle"
                    )]        
                         )



            return html.Div([
                        dcc.Graph(figure=fig)
                            ])
        
        

@app.callback(Output('triplot_graphic', 'children'),
               [Input('graphic_tab', 'value'),
                Input('form-download', 'action')],
                [State('upload-data', 'contents')])

def update_triplot(tab,  nameform, contents):
    #### Callback for the triplot graphic in the graphic table
    
    ########## TODO ###########
    # Color by attribute Group and Minerals
    # Change the hoever style

    if tab == 'graphic-table':
        
        if contents is not None:
       
            relative_filename = nameform
        
            df = pd.read_excel(relative_filename)
            df = df.loc[:, ~df.columns.str.contains('^Unnamed')]  # remove unnamed columns
        
            features = df.columns.to_list()
            clean_features = []
        
            for name in features:
                if df[name].dtypes == np.float or df[name].dtypes == np.int64:
                    clean_features.append(name)

            fig = go.Figure(go.Scatterternary({
                'mode': 'markers',
                'a': df[clean_features[0]],
                'b': df[clean_features[0]],
                'c': df[clean_features[0]],
                'text': df.index,
                'marker': {
                    'symbol': "circle",
                    'color': '#DB7365',        
                    'size': 8,
                    'line': { 'width': 2 }
                }
            }))
            
            fig.update_layout({
                'ternary': {
                    'sum': 100,
                    'aaxis': makeAxis('', 0),
                    'baxis': makeAxis('', 45),
                    'caxis': makeAxis('', -45)
                }
            })
            
            fig.update_layout(
                updatemenus=[
                    dict(
                        buttons=list(
                                [select_axis(df,feature,'a') for feature in clean_features],
                        ),
                
                        direction="down",
                        pad={"r": 10, "t": 10},
                        showactive=True,
                        x=0.45,
                        xanchor="left",
                        y=1.20,
                        yanchor="top"
                    ),
                    
                    dict(
                        buttons=list(
                                [select_axis(df,feature,'b') for feature in clean_features],
                        ),
                        
                 
                        direction="up",
                        pad={"r": 30, "t": 50},
                        showactive=True,
                        x=0.32,
                        xanchor="right",
                        y=-0.07,
                        yanchor="middle"
                    ),
            
                    dict(
                        buttons=list(
                                [select_axis(df,feature,'c') for feature in clean_features],
                        ),
                        
                 
                        direction="up",
                        pad={"r": 30, "t": 50},
                        showactive=True,
                        x=0.85,
                        xanchor="right",
                        y=-0.07,
                        yanchor="middle"
                    ),
                    
                   dict(
                        buttons=list([
                            dict(
                                args=["reversescale", False],
                                label="Group",
                                method="update"
                            ),
                            dict(
                                args=["reversescale", True],
                                label="Mineral",
                                method="update"
                            )
                        ]),
                        type = "buttons",
                        direction="right",
                        pad={"r": 10, "t": 10},
                        showactive=True,
                        x=0.75,
                        xanchor="left",
                        y=1.065,
                        yanchor="top"
                    )
                ])
            
            fig.update_layout(
                annotations=[
                    dict(text="Group by", x=0.86, xref="paper", y=1.125, yref="paper",
                                         showarrow=False)
                ])



            return html.Div([
                        dcc.Graph(figure=fig)
                            ])

#####################################

@app.server.route('/downloads/<path:path>')
def serve_static(path):
    import flask
    root_dir = os.getcwd()
    return flask.send_from_directory(
        os.path.join(root_dir, 'downloads'), path
    )



if __name__ == '__main__':
    app.run_server(debug=True)
