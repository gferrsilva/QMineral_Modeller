ARG BASE_IMAGE=ndscprm/miniforge:latest
FROM ${BASE_IMAGE}

ENV QMIN_USER qmin
ENV QMIN_GROUP ${QMIN_USER}
ENV QMIN_HOME /var/${QMIN_USER}

# Add non-root user
RUN set -xe && \
    groupadd ${QMIN_USER} && \
    useradd -m -g ${QMIN_GROUP} -G www-data -s /bin/bash -d ${QMIN_HOME} -c "QMin default user" ${QMIN_USER}

WORKDIR ${QMIN_HOME}

COPY --chown=${QMIN_USER}:${QMIN_GROUP} . ${QMIN_HOME}

# Instal dependencies
RUN set -xe && \
    pip install --no-cache-dir  -r requirements.txt && \
    ln -s ${QMIN_HOME}/scripts/docker-entrypoint.sh /docker-entrypoint.d/start-qmin.sh

USER ${QMIN_USER}

EXPOSE 8000
