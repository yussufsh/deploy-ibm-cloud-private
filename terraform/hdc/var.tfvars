openstack_user_name = "yussuf@us.ibm.com"
openstack_password = "Open@@##"
openstack_project_name = "BlueRidgeGroup-P"
openstack_domain_name = "ibm"
openstack_auth_url = "https://hdc-prod-cloud.hursley.ibm.com:5000/v3"
#PKVM-Ubt16.04-Srv-ppc64le
openstack_image_id = "bd1aa2a1-188f-45ed-b1ba-17cc9182e714"
#openstack_image_id = "05f4c117-b3c2-4afd-945b-0116006ad975"
openstack_flavor_id_master_node = "7477eac4-55be-42d8-8c4c-19316e608dad"
openstack_flavor_id_worker_node = "5"
openstack_ssh_key_file = "/root/.ssh/id_rsa"
openstack_network_name = "BlueRidgeGroup-P_Network"
openstack_floating_network_name = "HDC_floating_ips"
openstack_security_groups = ["default", "icp-rules"]
openstack_availability_zone = "PowerKVM"
instance_prefix = "yussuf-mcm"
icp_version = "3.1.2"
icp_edition = "ce"
icp_install_user = "cloudusr"
icp_disabled_services = [ "istio", "vulnerability-advisor", "storage-glusterfs", "storage-minio",
        "platform-security-netpolst", "node-problem-detector-draino",
        "multicluster-hub", "multicluster-endpoint", "metering" ]

icp_num_workers = "1"

#mcm_download_location = "https://na-blue.artifactory.swg-devops.com/artifactory/hyc-mcm-stable-generic-local/mcm/mcm-3.1.1/RC1/2018-10-25/mcm-3.1.1.tgz"
mcm_download_location = "http://10.56.0.74/mcm-3.1.2.tgz"
mcm_download_user = "yussuf@us.ibm.com"
mcm_download_password = "Open@@##"

cam_version="3.1.0"

cam_docker_user="yussuf"
cam_docker_password="camel0nt0p"

#cam_download_location = "http://10.56.0.74/icp-cam-ppc-3.1.0.0.tar.gz"
#cam_download_user = "yussuf@us.ibm.com"
cam_download_password = "Open@@##"
cam_product_id = "IBMCloudAutomationManager_5737E67_3100_EE_000"
