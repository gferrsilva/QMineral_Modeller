from os import path, environ

DEBUG=environ.get('DEBUG', False)

# Mail
# https://pythonhosted.org/Flask-Mail/
MAIL_ENABLED=environ.get('MAIL_ENABLED', False)
MAIL_SERVER=environ.get('MAIL_SERVER', 'smtp.gmail.com')
MAIL_PORT=environ.get('MAIL_PORT', 587)
MAIL_USE_TLS=environ.get('MAIL_USE_TLS', True)
MAIL_USE_SSL=environ.get('MAIL_USE_SSL', False)
MAIL_DEBUG=DEBUG
MAIL_USERNAME=environ.get('MAIL_USERNAME', 'qmin.mineral@gmail.com')
MAIL_DEFAULT_SENDER=environ.get('MAIL_DEFAULT_SENDER', 'qmin.mineral@gmail.com')

if MAIL_ENABLED:
    with open(environ.get('MAIL_PASSWORD_FILE'), 'r') as f:
        MAIL_PASSWORD=f.read()

# QMIN Settings
QMIN_MODEL_FILE=environ.get(
    'QMIN_MODEL_FILE',
    path.join(path.dirname(__file__), 'model_py/allmodels6.pkl')
)

QMIN_REGRESSION_MODEL_FILE=environ.get( 
    'QMIN_REGRESSION_MODEL_FILE',
    path.join(path.dirname(__file__), 'model_py/regression_anfibolio.pkl')
)

QMIN_OXIDE_TO_ELEMENT_FILE=environ.get( 
    'QMIN_OXIDE_TO_ELEMENT_FILE',
    path.join(path.dirname(__file__), 'assets/OXIDE_TO_ELEMENT.csv')
)

QMIN_DOWNLOAD_DIR=environ.get( 
    'QMIN_DOWNLOAD_DIR',
    path.join(path.dirname(__file__), 'downloads')
)
