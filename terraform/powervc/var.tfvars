openstack_user_name = "yussuf"
openstack_password = "passw0rd"
openstack_auth_url = "https://9.114.192.63:5000/v3/"
#Ubuntu
openstack_image_id = "774c6fe1-1b41-4c7f-8730-f34d01577360"
#SLES
#openstack_image_id = "86d459e8-fd91-4479-be05-18901e19d5b5"
#RHEL
#openstack_image_id = "540b16e4-5f51-4b2a-b282-9e7a056d8395"
openstack_flavor_id_master_node = "b00279d5-7314-4ca2-b5cc-1715447dbdce"
openstack_flavor_id_worker_node = "1da60bbe-89f0-4d6d-b3b7-ba03e4333679"
openstack_ssh_key_file = "/root/.ssh/id_rsa"
openstack_network_name = "ICP-2231"

instance_prefix = "yussuf-mcm"
icp_install_user = "root"
icp_edition = "ce"
icp_version = "3.1.2"
icp_num_workers = "1"


#mcm_download_location = "https://na-blue.artifactory.swg-devops.com/artifactory/hyc-mcm-stable-generic-local/mcm/mcm-3.1.1/RC1/2018-10-25/mcm-3.1.1.tgz"
mcm_download_location = "http://9.47.84.27:8880/mcm-3.1.2.tgz"
mcm_download_user = "yussuf@us.ibm.com"
mcm_download_password = "Open@@##"

cam_docker_user="yussuf"
cam_docker_password="camel0nt0p"
cam_version="3.1.0"
cam_download_location = "http://9.47.84.27:8880/icp-cam-ppc-3.1.0.0.tar.gz"
cam_download_user = "yussuf@us.ibm.com"
cam_download_password = "Open@@##"
cam_product_id = "IBMCloudAutomationManager_5737E67_3100_EE_000"
