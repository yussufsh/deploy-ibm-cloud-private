#!/bin/bash

################################################################
# Module to deploy IBM Cloud Private
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Licensed Materials - Property of IBM
#
# Copyright IBM Corp. 2017.
#
################################################################

METHOD=$1
IP=$2
docker_user=""
docker_password=""
location=""
user=""
password=""
if [ $METHOD == "online" ]; then
    docker_user=$3
    docker_password=$4
else
    location=$3
    user=$4
    password=$5
fi


/bin/echo "Installing CAM.."
export HOME=~
cd $HOME
export HUB_CLUSTER_IP=$IP
export HELM_HOME=~/.helm
machine=`uname -m`
ARCH="amd64"
if [ "$machine" == "ppc64le" ]
then
    ARCH="ppc64le"
fi

helm init --client-only
cloudctl login -a https://${HUB_CLUSTER_IP}:8443 \
    --skip-ssl-validation -u admin -p admin -n services


# Create Docker Store secret
export dockersecretname="dockercamsecret"
kubectl create secret docker-registry ${dockersecretname} \
    --docker-username=${docker_user} \
    --docker-password=${docker_password} \
    -n services
kubectl patch serviceaccount default -p \
    '{"imagePullSecrets": [{"name": "${dockersecretname}"}]}' -n services


# Add Helm Repos
helm repo add ibm-stable \
    https://raw.githubusercontent.com/IBM/charts/master/repo/stable/
helm repo add local-charts \
    https://${HUB_CLUSTER_IP}:8443/helm-repo/charts \
    --ca-file ~/.helm/ca.pem --cert-file ~/.helm/cert.pem \
    --key-file ~/.helm/key.pem
helm repo update
helm fetch ibm-stable/ibm-cam


# Install and configure exportfs; Create Persistent Volumes
apt install -y nfs-kernel-server

pvs=( cam-mongo cam-logs cam-terraform cam-bpd-appdata )
sizes=( 15 10 15 20 )
dir_names=( db logs terraform BPD_appdata )

for ((i = 0; i < ${#pvs[@]}; ++i)); do
item=${pvs[${i}]}
cat > /tmp/${item}-pv.yaml <<EOL
kind: PersistentVolume
apiVersion: v1
metadata:
  name: ${item}-pv
  labels:
    type: ${item}
spec:
  capacity:
    storage: ${sizes[${i}]}Gi
  accessModes:
    - ReadWriteMany
  nfs:
    server: mycluster.icp
    path: /export/CAM_${dir_names[${i}]}
EOL
kubectl create -f /tmp/${item}-pv.yaml
mkdir -p /export/CAM_${dir_names[${i}]}
done
chmod -R 755 /export
cat >> /etc/exports <<EOL
/export *(rw,insecure,no_subtree_check,async,no_root_squash)
/export/CAM_logs *(rw,nohide,insecure,no_subtree_check,async,no_root_squash)
/export/CAM_db *(rw,nohide,insecure,no_subtree_check,async,no_root_squash)
/export/CAM_terraform *(rw,nohide,insecure,no_subtree_check,async,no_root_squash)
/export/CAM_BPD_appdata *(rw,nohide,insecure,no_subtree_check,async,no_root_squash)
EOL
exportfs -a


# Generate a deployment ServiceID API Key
export serviceIDName='service-deploy'
export serviceApiKeyName='service-deploy-api-key'
cloudctl iam service-id-create ${serviceIDName} \
    -d 'Service ID for service-deploy'
cloudctl iam service-policy-create ${serviceIDName} \
    -r Administrator,ClusterAdministrator --service-name 'idmgmt'
cloudctl iam service-policy-create ${serviceIDName} \
    -r Administrator,ClusterAdministrator --service-name 'identity'
export deployApiKey=`cloudctl iam service-api-key-create \
    ${serviceApiKeyName} ${serviceIDName} \
    -d 'Api key for service-deploy' | tail -1 | awk '{print $NF}'`


# Install Cloud Automation Manager
helm install ibm-stable/ibm-cam --name cam --namespace services \
    --set global.image.secretName=${dockersecretname} --set arch=${ARCH} \
    --set global.iam.deployApiKey=${deployApiKey} --tls

/bin/echo "CAM installation completed"
