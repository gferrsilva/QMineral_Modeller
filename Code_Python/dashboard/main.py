########################################################
# TODO: Reorganize this, to make QMin as a Module and  #
#       make a template project for flask and dash     #
########################################################

from dash import Dash
from flask_mail import Mail

import config as qmin_settings

external_stylesheets = ['https://codepen.io/chriddyp/pen/bWLwgP.css']

app = Dash(
    __name__,
    external_stylesheets=external_stylesheets,
    prevent_initial_callbacks=True,
    url_base_pathname=qmin_settings.QMIN_BASE_URL
)

app.title = 'Qmin'

# Flask config
server = app.server
server.config.from_object(qmin_settings)

# Flask mail
mail = Mail(server)