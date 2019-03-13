Summary
=======
This Terraform module will perform a simple IBM Cloud Private (ICP) deployment. By default, it will install the Community Edition, but you can also configure it to install the Enterprise Edition as well. It is currently setup to deploy an ICP master node (also serves as the boot, proxy, and management node) and a user-configurable number of ICP worker nodes. This module serves as a simple way to provision an ICP cluster within your infrastructure.


Pre-requisites
------------
* Get access to an OpenStack (or PowerVC) server instance.
* If the default SSH user is not the root user, the default user must have password-less sudo access.
* Install [Terraform](https://www.terraform.io/downloads.html) on your workstation.
* Refer to ICP documentation for installation pre-requisites. https://www.ibm.com/support/knowledgecenter/en/SSBS6K/product_welcome_cloud_private.html

Supported OS versions
------------
This Terraform deployment supports the following OS images on different platforms. Check ICP documentation for supported system configurations.
    * Ubuntu 18.04 LTS and 16.04 LTS
    * Red Hat Enterprise Linux (RHEL) 7.4, 7.5, and 7.6
    * SUSE Linux Enterprise Server (SLES) 12 SP3
    
Additional image considerations
------------
Ensure that the base image used for deployment have necessary repositories configured to install docker and other packages, or have all the below packages pre-installed.
* docker-ce (docker for SLES) -  ICP Enterprise Edition users should use the ICP-provided platform specific docker tar ball and the docker_download_location variable in variables.tf to specify the download url.
* moreutils
* container-selinux
* socat

Instructions
------------
1. Login to your Terraform workstation.
2. Clone this repository. (git clone git@github.com:IBM/deploy-ibm-cloud-private.git)
3. Generate an SSH key pair. This will be referenced in Inputs below. (ssh-keygen -t rsa)
4. Edit the contents of variables.tf to align with your OpenStack (or PowerVC) deployment. (see Inputs below)
5. Run terraform init to initialize and download the terraform modules needed for deployment.
6. Run [terraform apply] to start the ICP deployment to the OpenStack server.
7. Wait for installation to complete.
Within about 30-40 minutes, you should be able to access your ICP cluster at https://<ICP_MASTER_IP_ADDRESS>:8443

Inputs
------------
**Configure the OpenStack Provider**

| Name | Default | Type | Description |
|--------------------|---------------|--------|----------------------------------------|
|openstack_user_name|my_user_name|string|The user name used to connect to OpenStack|
|openstack_password|my_password|string|The password for the user|
|openstack_project_name|ibm-default|string|The name of the project (a.k.a. tenant) used|
|openstack_domain_name|Default|string|The domain to be used|
|openstack_auth_url|https://<HOSTNAME>:5000/v3/|string|The endpoint URL used to connect to OpenStack|

**Configure the Instance details**

| Name | Default | Type | Description |
|--------------------|---------------|--------|----------------------------------------|
|instance_prefix|icp|string|Prefix to use in instance names|
|openstack_image_id|my_image_id|string|The ID of the image to be used for deploy operations|
|openstack_flavor_id_master_node|my_flavor_id|string|The ID of the flavor to be used for ICP master node deploy operations|
|openstack_flavor_id_worker_node|my_flavor_id|string|The ID of the flavor to be used for ICP worker node deploy operations|
|openstack_network_name|my_network_name|string|The name of the network to be used for deploy operations|
|openstack_ssh_key_file|<path to the private SSH key file>|string|The path to the private SSH key file. Appending '.pub' indicates the public key filename|


**Configure ICP details**

| Name | Default | Type | Description |
|--------------------|---------------|--------|----------------------------------------|
|icp_install_user|ubuntu|string|The user with sudo access across nodes (users section of cloud-init)s|
|icp_install_user_password||string|Password for sudo access (leave empty if using passwordless sudo access)|
|icp_num_workers|1|string|The number of ICP worker nodes to provision|
|icp_version|3.1.2|string|ICP version number|
|icp_architecture|ppc64le|string|x86 or ppc64le|
|icp_download_location||string|HTTP wget location for ICP Enterprise Edition - ignored for community edition|
|icp_default_admin_password|S3cure-icp-admin-passw0rd-default|string|Password to use for default admin user|
|icp_management_services|{
        "istio" = "disabled"
        "metering" = "enabled"
    }|map|Map of management services to enable/disable in icp config.yaml|
|docker_download_location||string|HTTP wget location for ICP provided Docker package|
|||string||
|||string||
|||string||

Authors
------------
Yussuf Shaikh yussuf@us.ibm.com
