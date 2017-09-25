FROM ibmcom/icp-inception:2.1.0-beta-2

RUN apt-get update -q && \
    apt-get install -yq python-pip && \
    pip install softlayer
