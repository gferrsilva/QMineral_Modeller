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
                       * At the current state, Qmin is able to predict among 17 groups and 188 different minerals
                       . Any other mineral not listed bellow will not perform as desired:
                       
                       '''),
                         
                html.Details([                
                    html.Summary('AMPHIBOLES (29 minerals)',style={'font-weight':'bold','letter-spacing':'2.1px','font-size':'16px','padding-left':'12px'}),                 
                    html.P('''Actinolite, Antophyllite, Arfvedsonite, Barroisite,
                    Cummingtonie, Eckermannite, Edenite, Fe-Ti-Tschermakite,
                    Fe-Tschermakite, Fe-Trschermakitic Hornblende, Ferrincnybite,
                    Gedrite, Glaucophane, Hastingsite, Kataphorite, Magnesio-Hastingsite,
                    Magnesio-Hornblende, Magnesio-Arfvedsonite, Magnesio-Kataphorite, Oxykaersutite,
                    Pargasite, Richterite, Riebeckite, Ti-Mg-Hastingsite, Tremolite, Tschermakite, Winchite''')
                    ]),
                           
               html.Details([                
                    html.Summary('APATITE ',style={'font-weight':'bold','letter-spacing':'2.1px','font-size':'16px','padding-left':'12px'}),                 
                    html.P('''Apatite''')
                    ]),
               
               html.Details([                
                    html.Summary('CARBONATES (31 minerals)',style={'font-weight':'bold','letter-spacing':'2.1px','font-size':'16px','padding-left':'12px'}),                 
                    html.P('''Alstonite, Ancylite, Ankerite, Barytocalcite, Breunnerite,
                           Burbankite, Calcite, Carbocernaite, Cebaite, Cordylite, Dolomite,
                           Fluoro-Carbonate, Gregoryite, Huanghoite, Khanneshite, Kukharenkoite,
                           Kutnahorite, Magnesiosiderite, Magnesite, Mckelveyite, Norsethite,
                           Nyerereite, Olekminskite, Pirssonite, Qaqarssukite, Rhodochrosite, 
                           Shortite, Siderite, Spurrite, Strontianite, Witherite''')
                    ]),
                           
               html.Details([                
                    html.Summary('CLAY-MINERALS (9 minerals) ',style={'font-weight':'bold','letter-spacing':'2.1px','font-size':'16px','padding-left':'12px'}),                 
                    html.P('''Beidellite, Corrensite, Illite, Kaolinite, Montmorillonite, Nontronite, Palagonite, Saponite, Smectite''')
                    ]),
                                          
               html.Details([                
                    html.Summary('FELDSPARS (10 minerals)',style={'font-weight':'bold','letter-spacing':'2.1px','font-size':'16px','padding-left':'12px'}),                 
                    html.P('''Albite, Andesine, Anorthite, Anorthoclase, Bytownite, Labradorite, Microcline, Oligoclase, Orthoclase, Sanidine''')
                    ]),
                                                         
               html.Details([                
                    html.Summary('FELDSPATHOIDS (11 minerals) ',style={'font-weight':'bold','letter-spacing':'2.1px','font-size':'16px','padding-left':'12px'}),                 
                    html.P('''Analcime, Cancrinite, Hauyne, Kaliophilite, Kalsilite, Leucite, Nepheline, Nosean, Pseudoleucite, Sodalite, Vishnevite''')
                    ]),
                                                                        
               html.Details([                
                    html.Summary('GARNETS (8 minerals)',style={'font-weight':'bold','letter-spacing':'2.1px','font-size':'16px','padding-left':'12px'}),                 
                    html.P('''Almandine, Andradite, Grossular, Hibschite, Hydrogarnet, Melanite, Pyrope, Schorlomite''')
                    ]),
                                                                                       
               html.Details([                
                    html.Summary('ILMENITE ',style={'font-weight':'bold','letter-spacing':'2.1px','font-size':'16px','padding-left':'12px'}),                 
                    html.P('''Ilmenite''')
                    ]),
                                                                                                      
               html.Details([                
                    html.Summary('MICAS (17 minerals) ',style={'font-weight':'bold','letter-spacing':'2.1px','font-size':'16px','padding-left':'12px'}),                 
                    html.P('''Annite, Biotite, Celadonite, Glauconite, Hydromica, Hydromuscovite, Lepidolite, Margarite, Muscovite, Paragonite, Phengite, Phengite-muscovite, Phlogopite, Sericite, Siderophyllite, Yangzhumingite, Zinnwaldite''')
                    ]),
                                                                                                                     
               html.Details([                
                    html.Summary('OLIVINES (5 minerals) ',style={'font-weight':'bold','letter-spacing':'2.1px','font-size':'16px','padding-left':'12px'}),                 
                    html.P('''Fayalite, Forsterite, Iddingsite, Monticellite, Ringwoodite''')
                    ]),
               
               html.Details([                
                    html.Summary('PEROVSKITE ',style={'font-weight':'bold','letter-spacing':'2.1px','font-size':'16px','padding-left':'12px'}),                 
                    html.P('''Perovskite''')
                    ]),
                              
               html.Details([                
                    html.Summary('PYROXENES (20 minerals) ',style={'font-weight':'bold','letter-spacing':'2.1px','font-size':'16px','padding-left':'12px'}),                 
                    html.P('''Acmite, Aegirine, Augite, Clinoenstatite Cr-diopside, Diopside, Enstatite, Fassaite, Fe-diopside, Ferroaugite Ferrohedenbergite, Ferropigeonite, Ferrosilite, Hedenbergite, Hypersthene Jadeite, Omphacite, Pigeonite, Salite, Titan-augite''')
                    ]),
                                             
               html.Details([                
                    html.Summary('QUARTZ ',style={'font-weight':'bold','letter-spacing':'2.1px','font-size':'16px','padding-left':'12px'}),                 
                    html.P('''Quartz''')
                    ]),
                                                            
               html.Details([                
                    html.Summary('SPINELS (11 minerals) ',style={'font-weight':'bold','letter-spacing':'2.1px','font-size':'16px','padding-left':'12px'}),                 
                    html.P('''Al-spinel, Chrome-spinel, Chromite, Fe-chromite, Gahnite, Hercynite, Magnesioferrite, Magnetite, Pleonaste, Titano-magnetite, Ulvospinel''')
                    ]),
               
               html.Details([                
                    html.Summary('SULFIDES (31 minerals) ',style={'font-weight':'bold','letter-spacing':'2.1px','font-size':'16px','padding-left':'12px'}),                 
                    html.P('''Alabandite, Arsenopyrite, Bornite, Chalcocite, Chalcopyrite Chlorbartonite, Cobaltite, Cubanite, Galena, Gersdorffite, Godlevskite, Guanglinite, Heazlewoodite, Hexatestibiopanickelite, Hollingworthite, Irarsite, Isocubanite, Linnaeite, Mackinawite, Maucherite, Merenskyite, Molybdenite, Nickeline, Parkerite, Pentlandite, Polydymite, Pyrite, Pyrrhotite, Rasvumite, Sphalerite, Stromeyerite.''')
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
                                            * R Programing
                                            ''',style={'text-align': 'center'})
                               
                              ],className='three columns'),
                    
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
                                            * Python Programing
                                            * Dash design
                                            ''',style={'text-align': 'center'})
                               
                              ],className='three columns'),
              
                                        
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
                                            * Python Programing
                                            * Dash design
                                            ''',style={'text-align': 'center'})
                              ],className='three columns'),
                    
                    
                    
                    
                   html.Div([
                              
                               html.A([
                                   html.Img(src="assets/contributors/Renato.png",style={
                                       'float':'center',
                                       'display': 'block',
                                       'margin-left': 'auto',
                                       'margin-right': 'auto',
                                       'margin-botton': '100px'},
                                        height = '140', width = '140')
                                   
                                       ],href='http://buscatextual.cnpq.br/buscatextual/visualizacv.do?id=K4360736A0&idiomaExibicao=2'),
                               dcc.Markdown('''**Renato Bernardes**''',style={'text-align': 'center','font-size':'16px','margin-top': '10px'}),
                               dcc.Markdown('''Geologist''',style={'text-align': 'center'}),
                               dcc.Markdown('''*University of Brasilia*''',style={'text-align': 'center'}),
                               dcc.Markdown('''
                                            * Data curation
                                            * QA/QC control
                                            ''',style={'text-align': 'center'})
                               
                              ],className='three columns'),
                                             
                    
                    
                    
                    
                    
                    
                    
                    
                        ],className='row',)
                            


              ],className = 'item-a')