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

# Enable NTP
/usr/bin/timedatectl set-ntp on
# Need to set vm.max_map_count to at least 262144
/sbin/sysctl -w vm.max_map_count=262144
/bin/echo "vm.max_map_count=262144" | /usr/bin/tee -a /etc/sysctl.conf

# Now for distro dependent stuff
if [ -f /etc/redhat-release ]; then
#RHEL specific steps
        # Disable the firewall
        systemctl stop firewalld
        systemctl disable firewalld
        yum -y remove docker docker-engine docker.io
        yum -y install docker-ce
        systemctl start docker

else
# Ubuntu specific steps

        # Disable the firewall
        /usr/sbin/ufw disable
        # Prepare the system for updates, install Docker and install Python
        /usr/bin/apt update
        # We'll use docker-ce (vs docker.io as ce/ee is what is supported by ICP)
        # Make sure we're not running some old version of docker
        /usr/bin/apt-get --assume-yes purge docker
        /usr/bin/apt-get --assume-yes purge docker-engine
        /usr/bin/apt-get --assume-yes purge docker.io
        /usr/bin/apt-get --assume-yes install \
        apt-transport-https \
        ca-certificates \
        curl \
        software-properties-common

        /usr/bin/apt update
        /usr/bin/apt-get --assume-yes install docker-ce python python-pip
fi


# Ensure the hostname is resolvable
IP=`/sbin/ip -4 -o addr show dev eth0 | awk '{split($4,a,"/");print a[1]}'`
/bin/echo "${IP} $(hostname)" >> /etc/hosts

exit 0
