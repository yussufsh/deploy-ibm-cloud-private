################################################################
# Module to deploy IBM Cloud Private
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an “AS IS” BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# Licensed Materials - Property of IBM
#
# Copyright (C) 2019 IBM Corporation
#
# Yussuf Shaikh <yussuf@us.ibm.com> - Initial implementation.
#
################################################################

################################################################
# Configure the OpenStack Provider
################################################################
variable "openstack_user_name" {
    description = "The user name used to connect to OpenStack"
    default = "my_user_name"
}

variable "openstack_password" {
    description = "The password for the user"
    default = "my_password"
}

variable "openstack_project_name" {
    description = "The name of the project (a.k.a. tenant) used"
    default = "ibm-default"
}

variable "openstack_domain_name" {
    description = "The domain to be used"
    default = "Default"
}

variable "openstack_auth_url" {
    description = "The endpoint URL used to connect to OpenStack"
    default = "https://<HOSTNAME>:5000/v3/"
}


################################################################
# Configure the Instance details
################################################################
variable "instance_prefix" {
    description = "Prefix to use in instance names"
    default = "icp"
}

variable "openstack_image_id" {
    description = "The ID of the image to be used for deploy operations"
    default = "my_image_id"
}

variable "openstack_flavor_id_master_node" {
    description = "The ID of the flavor to be used for ICP master node deploy operations"
    default = "my_flavor_id"
}

variable "openstack_flavor_id_worker_node" {
    description = "The ID of the flavor to be used for ICP worker node deploy operations"
    default = "my_flavor_id"
}

variable "openstack_network_name" {
    description = "The name of the network to be used for deploy operations"
    default = "my_network_name"
}

variable "openstack_ssh_key_file" {
    description = "The path to the private SSH key file. Appending '.pub' indicates the public key filename"
    default = "<path to the private SSH key file>"
}


################################################################
# Configure ICP details
################################################################
variable "icp_install_user" {
    description = "The user with sudo access across nodes (users section of cloud-init)"
    default = "ubuntu"
}

variable "icp_install_user_password" {
   description = "Password for sudo access (leave empty if using passwordless sudo access)"
   default = ""
}

variable "icp_num_workers" {
    description = "The number of ICP worker nodes to provision"
    default = 1
}

variable "icp_version" {
    description = "ICP version number"
    default = "3.1.2"
}

variable "icp_architecture" {
    description = "x86 or ppc64le"
    default = "ppc64le"
}

variable "icp_download_location" {
    description = "HTTP wget location for ICP Enterprise Edition - ignored for community edition"
    default = ""
}

variable "icp_default_admin_password" {
    description = "Password to use for default admin user"
    default = "S3cure-icp-admin-passw0rd-default"
}

variable "icp_management_services" {
    type = "map"
    description = "Map of management services to enable/disable in icp config.yaml"
    default = {
        "istio" = "disabled"
        "metering" = "enabled"
    }
}

variable "docker_download_location" {
    description = "HTTP wget location for ICP provided Docker package"
    default = ""
}

#variable "openstack_floating_network_name" {
#    default = "admin_floating_net"
#}
#variable "openstack_availability_zone" {
#    default = "power"
#}
#variable "openstack_security_groups" {
#    default = ["default", "icp-rules"]
#}


################################################################
# Configure MCM details
################################################################
variable "mcm_download_location" {
    default = ""
}

variable "mcm_download_user" {
    default = ""
}

variable "mcm_download_password" {
    default = ""
}


################################################################
# Configure CAM common details
################################################################
variable "cam_version" {
    default = "3.1.0"
    description = "Version of Cloud Automation Manager to install"
}

variable "cam_product_id" {
    default = ""
    description = "Product Id text for Cloud Automation Manager (EE)"
}

################################################################
# Configure CAM online installation details
################################################################
variable "cam_docker_user" {
    default = ""
    description = "Docker Store user name, needs subscription to CAM"
}

variable "cam_docker_password" {
    default = ""
    description = "Docker Store API key OR password"
}

################################################################
# Configure CAM offline installation details (${cam_docker_user} needs to be empty)
################################################################
variable "cam_download_location" {
    default = ""
}

variable "cam_download_user" {
    default = ""
}

variable "cam_download_password" {
    default = ""
}

################################################################
# Configure SMT level for master node
################################################################
variable "smt_value_master" {
    description = "Number of threads per core. Value can be any of: on, off, 1, 2, 4, 8"
    default = ""
}
