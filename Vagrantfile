# Please update the nodes info according to your laptop
nodes = [
  {:hostname => 'cfc-worker1', :ip => '192.168.122.11', :box => 'centos/7', :cpu => 2, :memory => 2048},
  {:hostname => 'cfc-worker2', :ip => '192.168.122.12', :box => 'centos/7', :cpu => 2, :memory => 2048},
  # Here, here, here, add more worker nodes here.
  {:hostname => 'cfc-master', :ip => '192.168.122.10', :box => 'centos/7', :cpu => 2, :memory => 1024},
]

# Please update the cfc_config according to your laptop network
cfc_config = '
network_type: calico
network_cidr: 10.1.0.0/16
service_cluster_ip_range: 10.0.0.0/24
ingress_enabled: true
ansible_user: vagrant
ansible_become: true
mesos_enabled: false
install_docker_py: true
'

# Please update if you want to use a specified version
cfc_version = 'latest'

cfc_hosts = "[master]\n#{nodes.last[:ip]}\n[proxy]\n#{nodes.last[:ip]}\n[worker]\n"
vagrant_hosts = "127.0.0.1 localhost\n"
nodes.each do |node|
  cfc_hosts = cfc_hosts + node[:ip] + "\n" unless (node == nodes.last && nodes.length != 1)
  vagrant_hosts = vagrant_hosts + "#{node[:ip]} #{node[:hostname]}\n"
end

Vagrant.configure(2) do |config|

  unless File.exists?('ssh_key')
    require "net/ssh"
    rsa_key = OpenSSL::PKey::RSA.new(2048)
    File.write('ssh_key', rsa_key.to_s)
    File.write('ssh_key.pub', "ssh-rsa #{[rsa_key.to_blob].pack("m0")}")
  end

  rsa_public_key = IO.read('ssh_key.pub')
  rsa_private_key = IO.read('ssh_key')

  config.vm.synced_folder ".", "/vagrant", disabled: true
  config.vm.provision "shell", inline: <<-SHELL
    echo "#{rsa_public_key}" >> /home/vagrant/.ssh/authorized_keys
    echo '[dockerrepo]' > /etc/yum.repos.d/docker.repo
    echo 'name=Docker Repository' >> /etc/yum.repos.d/docker.repo
    echo 'baseurl=https://yum.dockerproject.org/repo/main/centos/7/' >> /etc/yum.repos.d/docker.repo
    echo 'enabled=1' >> /etc/yum.repos.d/docker.repo
    echo 'gpgcheck=0' >> /etc/yum.repos.d/docker.repo
    yum clean all
    yum -y install docker-engine-1.12.3
    service network restart
    sysctl -w net.ipv4.ip_forward=1
    service docker start
    echo "#{vagrant_hosts}" > /etc/hosts
  SHELL

  nodes.each do |node|
    config.vm.define node[:hostname] do |nodeconfig|
      nodeconfig.vm.hostname = node[:hostname]
      nodeconfig.vm.box = node[:box]
      nodeconfig.vm.box_check_update = false
      nodeconfig.vm.network "private_network", ip: node[:ip]
      nodeconfig.vm.provider "virtualbox" do |virtualbox|
        virtualbox.gui = false
        virtualbox.cpus = node[:cpu]
        virtualbox.memory = node[:memory]
      end

      if node == nodes.last
        nodeconfig.vm.provision "shell", inline: <<-SHELL
          mkdir -p cluster
          echo "#{rsa_private_key}" > cluster/ssh_key
          echo "#{cfc_hosts}" > cluster/hosts
          echo "#{cfc_config}" > cluster/config.yaml
          docker run -e LICENSE=accept -v "$(pwd)/cluster":/installer/cluster ibmcom/cfc-installer:"#{cfc_version}" install
        SHELL
      end
    end
  end

end
