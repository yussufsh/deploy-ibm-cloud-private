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
provider "openstack" {
    user_name   = "${var.openstack_user_name}"
    password    = "${var.openstack_password}"
    tenant_name = "${var.openstack_project_name}"
    domain_name = "${var.openstack_domain_name}"
    auth_url    = "${var.openstack_auth_url}"
    insecure    = true
}

################################################################
# Genrate random id for naming
################################################################
resource "random_id" "rand" {
    byte_length = 2
}

################################################################
# Configure the OpenStack Keypair
################################################################
resource "openstack_compute_keypair_v2" "icp-key-pair" {
    name       = "terraform-icp-key-pair-${random_id.rand.hex}"
    public_key = "${file("${var.openstack_ssh_key_file}.pub")}"
}
