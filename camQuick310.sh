#!/bin/bash
# CAM 3.1.0 "offline" install steps: icp-cam-x86_64-3.1.0.0.tar.gz should be in same location
# THIS SCRIPT ONLY WORKS FOR UBUNTU LINUX and assumes arch amd64
# Run it on the ICP Master 
# We install Kubectl, cloudctl
# We install NFS server on the master using apt-get
# We configure 4 exports in NFS and create the 4 CAM PVs pointing to the master ip
# either run as root or as a sub-account with sudo configured for NOPASSWORD prompt
# usage: ./camQuick.sh 192.168.27.100 admin admin 

if [ $# -eq 0 ]; then
echo "Usage: $0 masterIp user password";
echo "";
echo "example, ./camQuick310.sh 192.168.27.100 admin admin ";
echo "";
echo ".-=all options are required=-.";
echo "masterIp = IP address of the ICP Master node";
echo "user = admin should do fine";
echo "password = admin user passsord, usually admin";
echo "";
exit 1;
fi

MASTER_IP=$1
user_name=$2
pass=$3

# install NFS packages
sudo apt-get install --yes --quiet nfs-kernel-server nfs-common

# make the directories used for CAM PVs, update /etc/exports with the locations, recycle NFS exports on the fly
sudo mkdir -p /export/CAM_logs && sudo mkdir -p /export/CAM_db && sudo mkdir -p /export/CAM_terraform && sudo mkdir -p /export/CAM_BPD_appdata
echo "/export/CAM_logs   *(rw,sync,insecure,no_root_squash,no_subtree_check,nohide)" | sudo tee --append /etc/exports
echo "/export/CAM_db     *(rw,sync,insecure,no_root_squash,no_subtree_check,nohide)" | sudo tee --append /etc/exports
echo "/export/CAM_terraform     *(rw,sync,insecure,no_root_squash,no_subtree_check,nohide)" | sudo tee --append /etc/exports
echo "/export/CAM_BPD_appdata     *(rw,sync,insecure,no_root_squash,no_subtree_check,nohide)" | sudo tee --append /etc/exports
sudo exportfs -a

# install kubectl from the local ICP 310 image
docker run -e LICENSE=accept --net=host -v /usr/local/bin:/data ibmcom/icp-inception-amd64:3.1.0-ee cp /usr/local/bin/kubectl /data

# download linux 'cloudctl' CLI from ICP and install 
curl -kLo cloudctl-linux-amd64-3.1.0-715 https://$MASTER_IP:8443/api/cli/cloudctl-linux-amd64
chmod 755 cloudctl-linux-amd64-3.1.0-715
sudo mv cloudctl-linux-amd64-3.1.0-715 /usr/local/bin/cloudctl
export PATH=$PATH:/usr/local/bin
echo -e "export PATH=$PATH:/usr/local/bin" >> /root/.bashrc

# login to your cluster and configure 
cloudctl login -u $user_name -p $pass -a https://$MASTER_IP:8443 --skip-ssl-validation -n services -c id-mycluster-account

# log in to the Docker private image registry
docker login -u $user_name -p $pass mycluster.icp:8500

# load the images and helm chart from the PPA CAM 3.1 package
cloudctl catalog load-archive --archive icp-cam-x86_64-3.1.0.0.tar.gz

# Generate a deployment ServiceID API Key
export serviceIDName='service-deploy'
export serviceApiKeyName='service-deploy-api-key'
cloudctl iam service-id-create ${serviceIDName} -d 'Service ID for service-deploy'
cloudctl iam service-policy-create ${serviceIDName} -r Administrator,ClusterAdministrator --service-name 'idmgmt'
cloudctl iam service-policy-create ${serviceIDName} -r Administrator,ClusterAdministrator --service-name 'identity'
#cloudctl iam service-api-key-create ${serviceApiKeyName} ${serviceIDName} -d 'Api key for service-deploy'
  # Create Deploy API Key taken from cam.sh used in CAM dev BVT pipeline
  echo "Creating Deploy API Key..."
  cloudctl iam service-api-key-create ${serviceApiKeyName} ${serviceIDName} -d 'Api key for service-deploy' -f /tmp/service-deploy-apikey > /dev/null 2>&1
  if [ $? -eq 0 ]; then
    deployApiKey=$(cat /tmp/service-deploy-apikey |  sed -n '/"apikey": /{s///; s/[",]//g; p; q}')
    if [ -z $deployApiKey ]; then
      echo "Failed to create Deploy API Key. Exiting..."
      exit 1
    else
      echo "Successfully created Deploy API Key."
    fi
  fi
rm -f /tmp/service-deploy-apikey

# grap the CAM chart from IBM Cloud Private:
wget https://$MASTER_IP:8443/helm-repo/requiredAssets/ibm-cam-3.1.0.tgz --no-check-certificate

# unpack the CAM chart and modify the PV files to include NFS server IP address and paths
tar xzf ibm-cam-3.1.0.tgz && cd ibm-cam/pre-install/
sed -i 's/<your PV ip>/'"$MASTER_IP"'/' *.yaml
sed -i 's-<your PV path>-/export/CAM_logs-' cam-logs-pv.yaml
sed -i 's-<your PV path>-/export/CAM_db-' cam-mongo-pv.yaml
sed -i 's-<your PV path>-/export/CAM_terraform-' cam-terraform-pv.yaml
sed -i 's-<your PV path>-/export/CAM_BPD_appdata-' cam-bpd-appdata-pv.yaml

# use kubectl to create the 4 PVs
kubectl create -f ./cam-mongo-pv.yaml 
kubectl create -f ./cam-logs-pv.yaml 
kubectl create -f ./cam-terraform-pv.yaml 
kubectl create -f ./cam-bpd-appdata-pv.yaml

# run the CAM deploy
cd &&  helm install ibm-cam-3.1.0.tgz --name cam --namespace services --set global.iam.deployApiKey=`echo $deployApiKey` --set global.audit=false --tls

# check the pods status to ensure all are running
watch kubectl get -n services pods -o wide
