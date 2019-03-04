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
# Create Master Nodes
################################################################
resource "openstack_compute_instance_v2" "icp-master-vm" {
    name      = "${var.instance_prefix}-master-${random_id.rand.hex}"
    image_id  = "${var.openstack_image_id}"
    flavor_id = "${var.openstack_flavor_id_master_node}"
    key_pair  = "${openstack_compute_keypair_v2.icp-key-pair.name}"
    network {
        name = "${var.openstack_network_name}"
    }
    user_data = "${data.template_file.bootstrap_init.rendered}"
}

data "template_file" "bootstrap_init" {
    template = "${file("bootstrap_icp_master.sh")}"
    vars {
        icp_architecture = "${var.icp_architecture}"
        docker_download_location = "${var.docker_download_location}"
        smt_value_master = "${var.smt_value_master}"
    }
}

resource "null_resource" "wait-for-master" {
    provisioner "remote-exec" {
        connection {
            type        = "ssh"
            user        = "${var.icp_install_user}"
            private_key = "${file(var.openstack_ssh_key_file)}"
            host        = "${openstack_compute_instance_v2.icp-master-vm.*.network.0.fixed_ip_v4}"
            timeout         = "15m"
        }
        inline = [
            "echo DONE"
        ]
    }
}

################################################################
# Create Worker Nodes
################################################################
resource "openstack_compute_instance_v2" "icp-worker-vm" {
    count     = "${var.icp_num_workers}"
    name      = "${format("${var.instance_prefix}-worker-${random_id.rand.hex}-%02d", count.index+1)}"
    image_id  = "${var.openstack_image_id}"
    flavor_id = "${var.openstack_flavor_id_worker_node}"
    key_pair  = "${openstack_compute_keypair_v2.icp-key-pair.name}"
    network {
        name = "${var.openstack_network_name}"
    }
    user_data = "${data.template_file.bootstrap_worker.rendered}"
}

data "template_file" "bootstrap_worker" {
    template = "${file("bootstrap_icp_worker.sh")}"
    vars {
        docker_download_location = "${var.docker_download_location}"
    }
}
