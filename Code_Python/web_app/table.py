import dash_html_components as html
import base64
import datetime
import io
import dash_table
import dash_core_components as dcc

def parse_contents(contents, filename, date):
    import qmin

    content_type, content_string = contents.split(',')
    decoded = base64.b64decode(content_string)
    try:
        if 'csv' in filename:
            # Assume that the user uploaded a CSV file is CPRM style (evandro)
            df = qmin.test_cprm_datasets_web(io.StringIO(decoded.decode('ISO-8859-1')))

        elif 'xls' in filename:
            # Assume that the user uploaded an excel file
            #This excel is format of Microssonda!!!!
            df = qmin.load_data_ms_web(io.BytesIO(decoded))
           # csv_string = df.to_csv(index=False, encoding='utf-8')
            #csv_string = "data:text/csv;charset=utf-8," + urllib.quote(csv_string)
            #update_download_link(df)
    except Exception as e:
        print(e)
        return html.Div([
            'There was an error processing this file.'
        ])

    return html.Div([
        html.H5(filename),
        html.H6(datetime.datetime.fromtimestamp(date)),

        dash_table.DataTable(
            data=df.to_dict('records'),
            columns=[{'name': i, 'id': i} for i in df.columns]
        ),

        html.Hr(),  # horizontal line

        # For debugging, display the raw contents provided by the web browser
        html.Div('Raw Content'),
        html.Pre(contents[0:200] + '...', style={
            'whiteSpace': 'pre-wrap',
            'wordBreak': 'break-all'
        })
    ])

def parse_contents_df(contents, filename, date):
    import qmin

    content_type, content_string = contents.split(',')
    decoded = base64.b64decode(content_string)
    try:
        if 'csv' in filename:
            # Assume that the user uploaded a CSV file is CPRM style (evandro)
            df = qmin.test_cprm_datasets_web(io.StringIO(decoded.decode('ISO-8859-1')))

        elif 'xls' in filename:
            # Assume that the user uploaded an excel file
            #This excel is format of Microssonda!!!!
            df = qmin.load_data_ms_web(io.BytesIO(decoded))
           # csv_string = df.to_csv(index=False, encoding='utf-8')
            #csv_string = "data:text/csv;charset=utf-8," + urllib.quote(csv_string)
            #update_download_link(df)
    except Exception as e:
        print(e)
        return html.Div([
            'There was an error processing this file.'
        ])

    return
layout =  html.Div([
    html.H4("Upload Files"),
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
    html.Div(id='output-data-upload')
    ])
