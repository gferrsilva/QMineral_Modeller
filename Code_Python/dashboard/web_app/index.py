import dash
import dash_bootstrap_components as dbc
import dash_core_components as dcc
import dash_html_components as html
from dash.dependencies import Input, Output
import dash_table
import pandas as pd
import sqlite3

import plotly.graph_objs as go

app = dash.Dash(__name__, external_stylesheets=[dbc.themes.BOOTSTRAP])
server = app.server
app.config.suppress_callback_exceptions = True

#set the app.layout
app.layout = html.Div([
    dcc.Tabs(id="tabs", value='tab-1', children=[
        dcc.Tab(label='Tab one', value='tab-1'),
        dcc.Tab(label='Tab two', value='tab-2'),
    ]),
    html.Div(id='tabs-content')
])


#callback to control the tab content
@app.callback(Output('tabs-content', 'children'),
              [Input('tabs', 'value')])
def render_content(tab):
    if tab == 'tab-1':
        return html.H1('Tab 1')
    elif tab == 'tab-2':
        return html.H1('Tab 2')

if __name__ == '__main__':
    app.run_server(debug=True)

import dash

import dash_html_components as html
import dash_core_components as dcc
from dash.dependencies import Output, Input, State
from dash.exceptions import PreventUpdate


external_stylesheets = ['https://codepen.io/chriddyp/pen/bWLwgP.css']

app = dash.Dash(__name__, external_stylesheets=external_stylesheets)

app.config['suppress_callback_exceptions'] = True

app.layout = html.Div([

    dcc.Store(id='store_1', storage_type='session'),

    html.Div([
        dcc.Tabs(id="tabs", value=0, children=[
            dcc.Tab(label='app1', value='app1'),
            dcc.Tab(label='app2', value='app2'),
        ]),

    ]),

    html.Br(),

    html.Div(id='page-content'),

])


app1_layout = html.Div([

     html.Div(

        dcc.Checklist(
             id='erase_stored_data',
             options=[
                 {'label': 'n-clicks', 'value': 0},
            ],
            values=[],
            labelStyle={'display': 'inline-block'}
        ),
        id='erase_checklist_container',

    ),

    html.Button('Hey yo !', id='button_1'),

    html.Div(id='display_clicks')

])

app2_layout = html.Div([

    html.Div(id='display_state_app2')

])


# DISPATCH LAYOUT
@app.callback(Output('page-content', 'children'), [Input('tabs', 'value')])
def display_page(tab_value):
    if tab_value == 'app1':
        return app1_layout
    elif tab_value == 'app2':
        return app2_layout
    else:
        return html.Div('oOOouups ; I ; did it again...')


# STORE N-CLICKS in dcc.Store 1
@app.callback(Output('store_1', 'data'),
              [Input('button_1', 'n_clicks')],
              [State('store_1', 'data')])
def upload_data(n_clicks, data):
    if n_clicks is None:
        raise PreventUpdate

    data = data or {'clicks': 0}

    data['clicks'] = data['clicks'] + 1

    return data


# DISPLAY N-CLICKS and dcc.Store TIMESTAMPS
@app.callback(Output('display_clicks', 'children'),
              [Input('store_1', 'modified_timestamp')],
              [State('store_1', 'data')])
def display_clicks(ts, state_data):
    if ts is None:
        raise PreventUpdate

    state_data = state_data or {}

    return html.Div([
        html.Div('timestamp : {}'.format(ts)),
        html.Div(state_data.get('clicks'))
    ])


# ERASE DATA FROM dcc.Store
@app.callback(Output('store_1', 'clear_data'),
              [Input('erase_stored_data', 'values')])
def delete_counter_data(values):
    if 0 in values:
        return True


# DISPLAY DATA ON APP2 (sencond tab)
@app.callback(Output('display_state_app2', 'children'),
              [Input('tabs', 'value')],
              [State('store_1', 'data')])
def display_stuff_in_app2(value, store_1_data):

    if value == 'app2':

        data1 = store_1_data or {'clicks': 0}