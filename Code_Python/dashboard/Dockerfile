ARG PYTHON_VERSION=3.8
ARG DEBIAN_VERSION=bullseye
ARG QMIN_UID=2000
ARG QMIN_GID=2000
ARG QMIN_HOME_DIR=/var/qmin

# Build virtualenv
FROM python:${PYTHON_VERSION}-${DEBIAN_VERSION} AS BUILD_VENV

ARG QMIN_UID
ARG QMIN_GID
ARG QMIN_HOME_DIR

# Add non-root user
RUN set -xe && \
    groupadd -g ${QMIN_GID} qmin && \
    useradd -m -u ${QMIN_UID} -g qmin -G www-data -d ${QMIN_HOME_DIR} -c "Qmin default user" qmin

USER ${QMIN_UID}

WORKDIR ${QMIN_HOME_DIR}

# Build dependencies
COPY requirements.txt .

RUN set -xe && \
    python -m venv --symlinks ./venv && \
    ./venv/bin/pip install --upgrade pip setuptools wheel && \
    ./venv/bin/python -m pip install --no-cache-dir -r requirements.txt

# Take entrypoint scripts
FROM ndscprm/docker-entrypoint:latest AS DOCKER-ENTRYPOINT-SCRIPT

# Create release image
ARG PYTHON_VERSION
ARG DEBIAN_VERSION
FROM python:${PYTHON_VERSION}-slim-${DEBIAN_VERSION} AS RELEASE

ARG QMIN_UID
ARG QMIN_GID
ARG QMIN_HOME_DIR

USER root

# Add non-root user
RUN set -xe && \
    groupadd -g ${QMIN_GID} qmin && \
    useradd -m -u ${QMIN_UID} -g qmin -G www-data -d ${QMIN_HOME_DIR} -c "Qmin default user" qmin

# Copy statements
COPY --chown=root:root --from=BUILD_VENV ${QMIN_HOME_DIR}/venv ${QMIN_HOME_DIR}/venv
COPY --chown=root:root --from=DOCKER-ENTRYPOINT-SCRIPT /docker-entrypoint.sh /
COPY --chown=${QMIN_UID}:${QMIN_GID} . ${QMIN_HOME_DIR}

WORKDIR ${QMIN_HOME_DIR}

RUN chmod +x ./scripts/start-qmin.sh

ENV PATH=${QMIN_HOME_DIR}/venv/bin:${PATH}

USER ${QMIN_UID}

ENTRYPOINT [ "/docker-entrypoint.sh" ]

CMD [ "./scripts/start-qmin.sh" ]

EXPOSE 8000
