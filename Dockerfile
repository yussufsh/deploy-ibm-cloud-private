FROM ibmcom/cfc-installer:1.1.0

RUN apt-get update && \
    apt-get install -y python-pip && \
    pip install softlayer
