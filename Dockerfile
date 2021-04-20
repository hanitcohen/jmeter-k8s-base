FROM openjdk:14-slim
		
ARG JMETER_VERSION=5.4.1
ARG JMETER_INSTALLATION_PATH="/opt/jmeter/apache-jmeter-${JMETER_VERSION}" 
ARG CURL_OPTS="--connect-timeout 10     --retry 5     --retry-delay 1     --retry-max-time 60" 
ARG JMETER_CMD_RUNNER_PATH="${JMETER_INSTALLATION_PATH}/lib/cmdrunner-2.2.jar" 
ARG JMETER_CMD_RUNNER_URL="http://search.maven.org/remotecontent?filepath=kg/apc/cmdrunner/2.2/cmdrunner-2.2.jar" 
ARG JMETER_PLUGIN_URL="https://jmeter-plugins.org/get/" 
ARG JMETER_PLUGIN_PATH="${JMETER_INSTALLATION_PATH}/lib/ext/jmeter-plugin-manager.jar" 

## Installing dependencies
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y wget coreutils unzip bash curl

# Installing jmeter clean and link
RUN   mkdir /opt/jmeter && \
      cd /opt/jmeter && \
      wget https://archive.apache.org/dist/jmeter/binaries/apache-jmeter-$JMETER_VERSION.tgz && \
      tar --extract --gzip --file apache-jmeter-$JMETER_VERSION.tgz && \
      rm apache-jmeter-$JMETER_VERSION.tgz && \
      rm --recursive --force /var/cache/apk/* && \
      rm --recursive --force  ${JMETER_INSTALLATION_PATH}/docs && \
      ln --symbolic ${JMETER_INSTALLATION_PATH} /opt/jmeter/apache-jmeter

# Install Plugin cmd runner and jmeter plugin
RUN curl ${CURL_OPTS} --location --output "${JMETER_PLUGIN_PATH}" "${JMETER_PLUGIN_URL}"  && \
    curl ${CURL_OPTS} --location --output "${JMETER_CMD_RUNNER_PATH}" "${JMETER_CMD_RUNNER_URL}" && \
    java -classpath "${JMETER_PLUGIN_PATH}" org.jmeterplugins.repository.PluginManagerCMDInstaller 

## Setting users &&  directory and right
RUN mkdir /report &&  \
    addgroup jmeter && \
    adduser --disabled-password --gecos '' --home /jmeter --ingroup jmeter jmeter && \
    chown --recursive jmeter:jmeter /opt/jmeter && \
    chown --recursive jmeter:jmeter /report

ENV JMETER_HOME ${JMETER_INSTALLATION_PATH}

ENV PATH $JMETER_HOME/bin:$PATH

USER jmeter