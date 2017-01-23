# Dockerizing base image for eXo Platform hosting offer with:
#
# - Libre Office
# - MongoDB
# - eXo Platform Trial edition

# Build:    docker build -t exoplatform/exo .
#
# Run:      docker run -ti --rm --name=exo -p 80:8080 exoplatform/exo
#           docker run -d --name=exo -p 80:8080 exoplatform/exo

FROM       exoplatform/base-jdk:jdk8
MAINTAINER eXo Platform <docker@exoplatform.com>

# Install the needed packages
RUN apt-get -qq update && \
  apt-get -qq -y upgrade ${_APT_OPTIONS} && \
  apt-get -qq -y install ${_APT_OPTIONS} libreoffice-calc libreoffice-draw libreoffice-impress libreoffice-math libreoffice-writer && \
  apt-get -qq -y autoremove && \
  apt-get -qq -y clean && \
  rm -rf /var/lib/apt/lists/*

# Environment variables
ARG EXO_VERSION_FULL=4.3.1-CP01
ARG EXO_VERSION_MINOR=4.3
ARG EXO_DOWNLOAD=http://storage.exoplatform.org/downloads/Releases/Platform/${EXO_VERSION_MINOR}/${EXO_VERSION_FULL}/platform-${EXO_VERSION_FULL}.zip
ARG DOWNLOAD_USER

ENV EXO_APP_DIR     /opt/exo
ENV EXO_CONF_DIR    /etc/exo
ENV EXO_DATA_DIR    /srv/exo
ENV EXO_LOG_DIR     /var/log/exo
ENV EXO_TMP_DIR     /tmp/exo-tmp

ENV EXO_USER exo
ENV EXO_GROUP ${EXO_USER}

# add our user and group first to make sure their IDs get assigned consistently, regardless of whatever dependencies get added
# (we use 999 as uid like in official Docker images)
RUN useradd --create-home -u 999 --user-group --shell /bin/bash ${EXO_USER}
# giving all rights to eXo user
RUN echo "exo   ALL = NOPASSWD: ALL" > /etc/sudoers.d/exo && chmod 440 /etc/sudoers.d/exo

# Create needed directories
# RUN mkdir -p ${EXO_APP_DIR}
RUN mkdir -p ${EXO_DATA_DIR}    && chown ${EXO_USER}:${EXO_GROUP} ${EXO_DATA_DIR}
# && \
#   mkdir ${EXO_DATA_DIR}/.eXo/   && chown ${EXO_USER}:${EXO_GROUP} ${EXO_DATA_DIR}/.eXo && \
#   ln -s ${EXO_DATA_DIR}/.eXo    /home/${EXO_USER}/.eXo
RUN mkdir -p ${EXO_TMP_DIR}     && chown ${EXO_USER}:${EXO_GROUP} ${EXO_TMP_DIR}
RUN mkdir -p ${EXO_LOG_DIR}     && chown ${EXO_USER}:${EXO_GROUP} ${EXO_LOG_DIR}

# Install eXo Platform
RUN set -x && if [ -n "${DOWNLOAD_USER}" ]; then PARAMS="-u ${DOWNLOAD_USER}"; fi && \
    curl ${PARAMS} -L -o /srv/downloads/eXo-Platform-${EXO_VERSION_FULL}.zip "${EXO_DOWNLOAD}" && \
    unzip -q /srv/downloads/eXo-Platform-${EXO_VERSION_FULL}.zip -d /srv/downloads/ && \
    rm -f /srv/downloads/eXo-Platform-${EXO_VERSION_FULL}.zip && \
    mv /srv/downloads/platform-${EXO_VERSION_FULL}* ${EXO_APP_DIR} && \
    # ln -s ${EXO_APP_DIR}/platform-${EXO_VERSION}-${EXO_EDITION} ${EXO_APP_DIR} && \
    chown -R ${EXO_USER}:${EXO_GROUP} ${EXO_APP_DIR}
RUN ln -s ${EXO_APP_DIR}/gatein/conf /etc/exo
RUN rm -rf ${EXO_APP_DIR}/logs && ln -s ${EXO_LOG_DIR} ${EXO_APP_DIR}/logs


# Install Docker customization file
ADD bin/setenv-docker-customize.sh ${EXO_APP_DIR}/bin/setenv-docker-customize.sh
RUN chmod 755 ${EXO_APP_DIR}/bin/setenv-docker-customize.sh & chown ${EXO_USER}:${EXO_GROUP} ${EXO_APP_DIR}/bin/setenv-docker-customize.sh
# RUN chmod 755 ${EXO_APP_DIR}/bin/setenv-docker-customize.sh
RUN sed -i '/# Load custom settings/i \
\# Load custom settings for docker environment\n\
[ -r "$CATALINA_BASE/bin/setenv-docker-customize.sh" ] \
&& . "$CATALINA_BASE/bin/setenv-docker-customize.sh" \
|| echo "No Docker eXo Platform customization file : $CATALINA_BASE/bin/setenv-docker-customize.sh"\n\
' ${EXO_APP_DIR}/bin/setenv.sh && \
  grep 'setenv-docker-customize.sh' ${EXO_APP_DIR}/bin/setenv.sh

# Install and Configure the chat
ADD conf/chat.properties      /etc/exo/chat.properties
RUN chown ${EXO_USER}:${EXO_GROUP} /etc/exo/chat.properties

USER ${EXO_USER}
RUN /opt/exo/addon install exo-jdbc-driver-mysql:1.0.0

ARG ADDONS

RUN for a in ${ADDONS}; do echo "Installing addon $a"; /opt/exo/addon install --no-compat $a; done
#RUN /opt/exo/addon install --no-compat exo-chat:1.4.0
#RUN /opt/exo/addon install --no-compat exo-tasks:1.2.0
#RUN /opt/exo/addon install --no-compat exo-remote-edit:1.2.0

CMD [ "/opt/exo/start_eXo.sh" ]
