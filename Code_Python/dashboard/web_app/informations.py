import dash_html_components as html
import dash_core_components as dcc

def about_card():
    """
    :return: A Div containing dashboard title & descriptions.
    """
    return    html.Div([
                  html.H2('About',style={'text-align': 'center'}),
                  html.P('''This is the Qmin - Mineral Chemistry Virtual Assistant. The models herein presented perform mineral
                         classification, missing value imputation by multivariate regression and mineral formula prediction by several
                         Random Forest classification and regression nested models.The models have been developed by researchers of the
                         Directory of Geology and Mineral Resources, of the Geological Survey of Brazil (DGM/CPRM), with the assistance
                         of the technical manager of the EPMA laboratory of the Institute of Geosciences/University of Brasília (IG/UnB).''',
                         
                         style={'text-align': 'center'}),
                
                html.H5('Important Notes',style={'text-align': 'center'}),
                
                dcc.Markdown(''' 
                       * This model is in active development and so parameter names and behaviors, and output file formats
                       will change without notice.                       
                       * The model is stochastic. Multiple runs with different seeds (or random state)
                       should be undertaken to see average behavior.                       
                       * At the current state, Qmin is able to predict among 19 groups and 102 different minerals
                       . Any other mineral not listed bellow will not perform as desired:
                       
                       '''),
                         
                html.Details([                
                    html.Summary('AMPHIBOLES (13 minerals)',style={'font-weight':'bold','letter-spacing':'2.1px','font-size':'16px','padding-left':'12px'}),
                    html.P('''ACTINOLITE, ARFVEDSONITE, CUMMINGTONITE, EDENITE, HASTINGSITE,
                     HORNBLENDE (SENSU LATO), KAERSUTITE, KATOPHORITE, MAGNESIOHASTINGSITE, 
                     PARGASITE, RICHTERITE, RIEBECKITE, TREMOLITE''')
                    ]),
                           
               html.Details([                
                    html.Summary('APATITE ',style={'font-weight':'bold','letter-spacing':'2.1px','font-size':'16px','padding-left':'12px'}),                 
                    html.P('''Apatite''')
                    ]),
               
               html.Details([                
                    html.Summary('CARBONATES (13 minerals)',style={'font-weight':'bold','letter-spacing':'2.1px','font-size':'16px','padding-left':'12px'}),
                    html.P('''ANCYLITE, ANKERITE, BURBANKITE, CACARBOCERNAITE, DOLOMITE, GREGORYITE, 
                    KUKHARENKOITE (SENSU LATO), KUTNAHORITE, MAGNESITE, 
                    NATROFAIRCHILDITE/NYEREREITE/ZEMKORITE, SHORTITE, SIDERITELCITE''')
                    ]),

        html.Details([
            html.Summary('CHLORITE', style={'font-weight': 'bold', 'letter-spacing': '2.1px', 'font-size': '16px',
                                             'padding-left': '12px'}),
            html.P('''CHLORITE (SENSU LATO)''')
        ]),
                           
               html.Details([                
                    html.Summary('CLAY-MINERALS (5 minerals) ',style={'font-weight':'bold','letter-spacing':'2.1px','font-size':'16px','padding-left':'12px'}),
                    html.P('''BEIDELLITE, CORRENSITE, ILLITE, MONTMORILLONITE, SAPONITE''')
                    ]),
        html.Details([
            html.Summary('EPIDOTE', style={'font-weight': 'bold', 'letter-spacing': '2.1px', 'font-size': '16px',
                                            'padding-left': '12px'}),
            html.P('''EPIDOTE (SENSU LATO)''')
        ]),
                                          
               html.Details([                
                    html.Summary('FELDSPARS (8 minerals)',style={'font-weight':'bold','letter-spacing':'2.1px','font-size':'16px','padding-left':'12px'}),
                    html.P('''ALBITE, ANDESINE, ANORTHITE, ANORTHOCLASE, BYTOWNITE, K-FELDSPAR,
                     LABRADORITE, OLIGOCLASE''')
                    ]),
                                                         
               html.Details([                
                    html.Summary('FELDSPATHOIDS (8 minerals) ',style={'font-weight':'bold','letter-spacing':'2.1px','font-size':'16px','padding-left':'12px'}),
                    html.P('''ANALCIME, CANCRINITE, HAUYNE, 
                    KALSILITE/KALIOPHILITE/PANUNZITE/TRIKALSILITE, LEUCITE, NEPHELINE, NOSEAN, 
                    SODALITE''')
                    ]),
                                                                        
               html.Details([                
                    html.Summary('GARNETS (5 minerals)',style={'font-weight':'bold','letter-spacing':'2.1px','font-size':'16px','padding-left':'12px'}),
                    html.P('''ALMANDINE, ANDRADITE, GROSSULAR, PYROPE, SCHORLOMITE ''')
                    ]),
                                                                                       
               html.Details([                
                    html.Summary('ILMENITE ',style={'font-weight':'bold','letter-spacing':'2.1px','font-size':'16px','padding-left':'12px'}),                 
                    html.P('''Ilmenite''')
                    ]),
                                                                                                      
               html.Details([                
                    html.Summary('MICAS (6 minerals) ',style={'font-weight':'bold','letter-spacing':'2.1px','font-size':'16px','padding-left':'12px'}),
                    html.P('''BIOTITE (SENSU LATO), CELADONITE, MUSCOVITE, PARAGONITE, YANGZHUMINGITE,
                     ZINNWALDITE (SENSU LATO)''')
                    ]),
                                                                                                                     
               html.Details([                
                    html.Summary('OLIVINES (3 minerals) ',style={'font-weight':'bold','letter-spacing':'2.1px','font-size':'16px','padding-left':'12px'}),
                    html.P('''FAYALITE, FORSTERITE, MONTICELLITE''')
                    ]),
               
               html.Details([                
                    html.Summary('PEROVSKITE ',style={'font-weight':'bold','letter-spacing':'2.1px','font-size':'16px','padding-left':'12px'}),                 
                    html.P('''Perovskite''')
                    ]),
                              
               html.Details([                
                    html.Summary('PYROXENES (9 minerals) ',style={'font-weight':'bold','letter-spacing':'2.1px','font-size':'16px','padding-left':'12px'}),
                    html.P(''' AEGIRINE, AUGITE, DIOPSIDE, ENSTATITE/CLINOENSTATITE, 
                    FERROSILITE/CLINOFERROSILITE, HEDENBERGITE, OMPHACITE, PIGEONITE, TITAN-AUGITE''')
                    ]),
                                             
               html.Details([                
                    html.Summary('QUARTZ ',style={'font-weight':'bold','letter-spacing':'2.1px','font-size':'16px','padding-left':'12px'}),                 
                    html.P('''Quartz''')
                    ]),
                                                            
               html.Details([                
                    html.Summary('SPINELS (5 minerals) ',style={'font-weight':'bold','letter-spacing':'2.1px','font-size':'16px','padding-left':'12px'}),
                    html.P('''CHROMITE, HERCYNITE, MAGNETITE, SPINEL, ULVOSPINEL ''')
                    ]),
               
               html.Details([                
                    html.Summary('SULFIDES (19 minerals) ',style={'font-weight':'bold','letter-spacing':'2.1px','font-size':'16px','padding-left':'12px'}),
                    html.P('''ALABANDITE, ARSENOPYRITE, BORNITE, CHALCOCITE, CHALCOPYRITE, CHLORBARTONITE, 
                    CUBANITE, GALENA, HEAZLEWOODITE, ISOCUBANITE, MACKINAWITE, MERENSKYITE, PENTLANDITE,
                     POLYDYMITE, PYRITE, PYRRHOTITERASVUMITE, SPHALERITE, STROMEYERITE ''')
                    ]),
                              
               html.Details([                
                    html.Summary('TITANITE ',style={'font-weight':'bold','letter-spacing':'2.1px','font-size':'16px','padding-left':'12px'}),                 
                    html.P('''Titanite''')
                    ]),
                                             
               html.Details([                
                    html.Summary('ZIRCON ',style={'font-weight':'bold','letter-spacing':'2.1px','font-size':'16px','padding-left':'12px'}),                 
                    html.P('''Zircon''')
                    ]),
              ],className = 'item-a')

                           
                           
def status_area():
    """
    :return: A Div containing dashboard title & descriptions.
    """
    return    html.Div([
        
                  html.H2('Status',style={'text-align': 'center'}),
                  html.P('''This model is in active development and subject to significant code changes to:'''),
                  dcc.Markdown('''
                               * Increase the number of groups and minerals covered
                               * Improve performance
                               * Increase the size of samples used for training
                                                              
                               '''),
                               
                 html.H5('Training Data',style={'text-align': 'left'}),
                 dcc.Markdown('''The directory [data_raw](https://github.com/gferrsilva/QMineral_Modeller/tree/master/data_raw)
                              contains all raw data considered for the models' building.
                              The main source of the data used for training is the [GEOROC](http://georoc.mpch-mainz.gwdg.de/georoc/) 
                              database. The repository GEOROC is maintained by the Max Planck Institute for Chemistry in Mainz.'''),
                              
                 dcc.Markdown('''Some other data used in this work are a concession of researchers of the Geological Survey
                              of Brazil and was used for the model's test and calibration. Those are available
                              in the folder [OtherSources](https://github.com/gferrsilva/QMineral_Modeller/tree/master/data_raw/OtherSources).                            
                               '''),
                               
                html.H4('Contributors',style={'text-align': 'center'}),
                
                html.Div([
                    
                    html.Div([
                              
                               html.A([
                                   html.Img(src="assets/contributors/Guilherme.png",style={
                                       'float':'center',
                                       'display': 'block',
                                       'margin-left': 'auto',
                                       'margin-right': 'auto',
                                       'opacity:hoever': '0.3',
                                       'margin-botton': '100px'},
                                        height = '140', width = '140')
                                   
                                       ],href='http://buscatextual.cnpq.br/buscatextual/visualizacv.do?id=K4452179T4&idiomaExibicao=2'),
                               dcc.Markdown('''**Guilherme Ferreira**''',style={'text-align': 'center','font-size':'16px','margin-top': '10px'}),
                               dcc.Markdown('''Geologist''',style={'text-align': 'center'}),
                               dcc.Markdown('''*Geological Survey of Brazil*''',style={'text-align': 'center'}),
                               dcc.Markdown('''
                                            * Conceptualization
                                            * Data curation
                                            * R Programming
                                            ''',style={'text-align': 'center'})
                               
                              ],className='two columns'),
                    
                    html.Div([
                              
                               html.A([
                                   html.Img(src="assets/contributors/Marcos.png",style={
                                       'float':'center',
                                       'display': 'block',
                                       'margin-left': 'auto',
                                       'margin-right': 'auto',
                                       'margin-botton': '100px'},
                                        height = '140', width = '140')
                                   
                                       ],href='http://buscatextual.cnpq.br/buscatextual/visualizacv.do?id=K4331039T8&idiomaExibicao=2'),
                               dcc.Markdown('''**Marcos Ferreira**''',style={'text-align': 'center','font-size':'16px','margin-top': '10px'}),
                               dcc.Markdown('''Geophysicist''',style={'text-align': 'center'}),
                               dcc.Markdown('''*Geological Survey of Brazil*''',style={'text-align': 'center'}),
                               dcc.Markdown('''
                                            * Machine Learning developer
                                            * Python Programming
                                            * Dash design
                                            ''',style={'text-align': 'center'})
                               
                              ],className='two columns'),
              
                                        
                    html.Div([
                              
                               html.A([
                                   html.Img(src="assets/contributors/Iago.png",style={
                                       'float':'center',
                                       'display': 'block',
                                       'margin-left': 'auto',
                                       'margin-right': 'auto',
                                       'margin-botton': '100px'},
                                        height = '140', width = '140')
                                   
                                       ],href='http://buscatextual.cnpq.br/buscatextual/visualizacv.do?id=K4360736A0&idiomaExibicao=2'),
                               dcc.Markdown('''**Iago Costa**''',style={'text-align': 'center','font-size':'16px','margin-top': '10px'}),
                               dcc.Markdown('''Geophysicist''',style={'text-align': 'center'}),
                               dcc.Markdown('''*Geological Survey of Brazil*''',style={'text-align': 'center'}),
                               dcc.Markdown('''
                                            * Machine Learning developer
                                            * Python Programming
                                            * Dash design
                                            ''',style={'text-align': 'center'})
                              ],className='two columns'),



                    html.Div([
                              
                               html.A([
                                   html.Img(src="assets/contributors/Renato.png",style={
                                       'float':'center',
                                       'display': 'block',
                                       'margin-left': 'auto',
                                       'margin-right': 'auto',
                                       'margin-botton': '100px'},
                                        height = '140', width = '140')
                                   
                                       ],href='http://lattes.cnpq.br/6396868621473599'),
                               dcc.Markdown('''**Renato Bernardes**''',style={'text-align': 'center','font-size':'16px','margin-top': '10px'}),
                               dcc.Markdown('''Geologist''',style={'text-align': 'center'}),
                               dcc.Markdown('''*University of Brasilia*''',style={'text-align': 'center'}),
                               dcc.Markdown('''
                                            * Data curation
                                            * QA/QC control
                                            ''',style={'text-align': 'center'})
                               
                              ],className='two columns'),
                    html.Div([

                        html.A([
                            html.Img(src="assets/contributors/Carlos_Mota.png", style={
                                'float': 'center',
                                'display': 'block',
                                'margin-left': 'auto',
                                'margin-right': 'auto',
                                'margin-botton': '100px'},
                                     height='140', width='140')

                        ],
                            href='http://lattes.cnpq.br/9373929014144622'),
                        dcc.Markdown('''**Carlos Mota**''',
                                     style={'text-align': 'center', 'font-size': '16px', 'margin-top': '10px'}),
                        dcc.Markdown('''Geologist''', style={'text-align': 'center'}),
                        dcc.Markdown('''*Geological Survey of Brazil*''', style={'text-align': 'center'}),
                        dcc.Markdown('''
                                  * Python Programming 
                                  * DevOps Engineering
                                  ''', style={'text-align': 'center'})
                    ], className='two columns')
                                             

                        ], className='row',)
                            


              ],className = 'item-a')