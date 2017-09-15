# Deploy IBM Cloud Private on Softlayer

## Deploy using Vagrant:

TBD

## Deploy on IBM Cloud (softlayer)

### Prepare your local machine:


The first thing you need to do is to clone this repo down and set up to use softlayer cli and ansible:

```bash
$ git clone https://github.com/IBM/deploy-ibm-cloud-private.git
$ cd deploy-ibm-cloud-private
$ sudo pip install -r requirements.txt
```

Next you need to prepare the softlayer CLI with your credentials:

```bash
$ slcli config setup
Username: XXXXXX
API Key or Password: XXXXXXXXXXXXXXXXXXXXX
Endpoint (public|private|custom) [public]:
Timeout [0]:
:..............:..................................................................:
:         name : value                                                            :
:..............:..................................................................:
:     Username : XXXXXX                                                           :
:      API Key : XXXXXXXXXXXXXXXXXXXXX                                            :
: Endpoint URL : https://api.softlayer.com/xmlrpc/v3.1/                           :
:      Timeout : not set                                                          :
:..............:..................................................................:
Are you sure you want to write settings to "/home/XXXX/.softlayer"? [Y/n]: Y
```

Create a SSH key to use:

```bash
$ ssh-keygen -f cluster/ssh_key -P ""
Generating public/private rsa key pair.
Overwrite (y/n)? y
Your identification has been saved in /home/XXXX/.ssh/cuttle-demo.
Your public key has been saved in /home/XXXX/.ssh/cuttle-demo.pub.
$ slcli sshkey add -f cluster/ssh_key.pub icp-key
$ slcli sshkey list               
:........:....................:.................................................:.......:
:   id   :       label        :                   fingerprint                   : notes :
:........:....................:.................................................:.......:
: 926125 :    icp-key     : 2c:ba:f4:8d:0c:4f:35:3d:fb:98:0b:30:b3:2e:a4:09 :   -   :
:........:....................:.................................................:.......:
```

> Set the `sl_ssh_key` variable in `clusters/config.yaml` with the id
  from the output of the `slcli sshkey list` command.

Pick a datacenter and a VLAN to deploy to:

```
slcli vlan list
:.........:........:......:..........:............:..........:.................:............:
:    id   : number : name : firewall : datacenter : hardware : virtual_servers : public_ips :
:.........:........:......:..........:............:..........:.................:............:
: 2073387 :  866   :  -   :    No    :   dal09    :    0     :        1        :     61     :
: 2073385 :  812   :  -   :    No    :   dal09    :    0     :        1        :     13     :
```

> Set the `sl_datacenter` and `sl_vlan` variables in `clusters/config.yaml`
  using the datacenter name (ex dal09) and vlan id (ex 2073387). Unless you're very familiar
  with your softlayer account you may need to use the softlayer
  web portal to pick a VLAN to use.  If you skip this step SL will pick a random vlan and you
  may not be able to communicate on the backend network.

### Provision the Softlayer VMs

Using ansible playbooks we've prepared you can create the VMs necessary to deploy ICP:

_While the playbook runs fast, it can take some time for the systems to actually come online and be ready._

```bash
$ ansible-playbook playbooks/create_sl_vms.yml
PLAY [create servers] ****************************************************************************************************************************************************************

TASK [Include cluster vars] **********************************************************************************************************************************************************
ok: [localhost]

TASK [create master] *****************************************************************************************************************************************************************
changed: [localhost] => (item=icp-master01)

TASK [create workers] ****************************************************************************************************************************************************************
changed: [localhost] => (item=icp-worker01)
changed: [localhost] => (item=icp-worker02)

PLAY RECAP ***************************************************************************************************************************************************************************
localhost                  : ok=3    changed=2    unreachable=0    failed=0   
```


While the above systems are being created we can slipstream the softlayer python libraries into
the IBM Cloud Private deployer so that we can use the [Softlayer Dynamic Inventory](cluster/hosts):

```bash
$ docker build -t ibmcom/cfc-installer:1.1.0-sl .
Sending build context to Docker daemon  120.3kB
Step 1/2 : FROM ibmcom/cfc-installer:1.1.0
 ---> 91bc38bcb3a8
Step 2/2 : RUN apt-get update &&     apt-get install -y python-pip &&     pip install softlayer
 ---> Using cache
 ---> 20dd79bda317
Successfully built 20dd79bda317
Successfully tagged ibmcom/cfc-installer:1.1.0-sl
```

Once the systems are online you should be able to prepare them for the ICP install using the following
Ansible playbook.

```bash
$ ssh-add cluster/ssh_key
$ ansible-playbook -i hosts prepare_sl_vms.yml -u root

PLAY [ensure connectivity to all nodes] **********************************************************************************************************************************************

TASK [check if python is installed] **************************************************************************************************************************************************
ok: [169.46.198.209]
ok: [169.46.198.195]
ok: [169.46.198.216]
...
...
PLAY RECAP ***************************************************************************************************************************************************************************
169.46.198.195             : ok=8    changed=6    unreachable=0    failed=0   
169.46.198.209             : ok=8    changed=6    unreachable=0    failed=0   
169.46.198.216             : ok=8    changed=6    unreachable=0    failed=0   
```


Once that playbook has finished running we can use our modified deployer to deploy ICP:

```bash
$ cat ~/.softlayer
[softlayer]
username = XXXXX
api_key = YYYY
$ docker run -e SL_USERNAME=XXXXX -e SL_API_KEY=YYYY -e LICENSE=accept --net=host --rm -t -v "$(pwd)/cluster":/installer/cluster ibmcom/cfc-installer:1.1.0-sl install
...
...
PLAY RECAP *********************************************************************
169.46.198.XXX             : ok=44   changed=22   unreachable=0    failed=0   
169.46.198.YYY             : ok=69   changed=39   unreachable=0    failed=0   
169.46.198.ZZZ             : ok=45   changed=22   unreachable=0    failed=0   


POST DEPLOY MESSAGE ************************************************************

UI URL is https://169.46.198.XXX:8443 , default username/password is admin/admin

```
## Accessing IBM Cloud Private

Access the URL using the username, password provided in last few lines of the ICP deployment

![ICP Login Page](images/icp-login-page.png)

Click on `admin` on the top right hand corner of the screen to bring up a menu and select "Configure Client".

![ICP Configure Client](images/icp-configure-client.png)

Copy and Paste the provided commands into a shell:

```bash
kubectl config set-cluster cfc --server=https://169.46.198.216:8001 --insecure-skip-tls-verify=true
kubectl config set-context cfc --cluster=cfc
kubectl config set-credentials user --token=eyJhbGciOiJSUzI1NiIsImtpZCI6IjY5NjI2ZDJkNjM2NjYzMmQ3MzY1NzI3NjY5NjM2NTJkNmI2NTc5NjkiLCJ0eXAiOiJKV1QifQ.eyJhdWQiOiJjZmMtc2VydmljZSIsImV4cCI6MTUwNTc5MTMwOCwiaWF0IjoxNTA1NzQ4MTA4LCJpc3MiOiJodHRwczovL21hc3Rlci5jZmM6ODQ0My9hY3MvYXBpL3YxL2F1dGgiLCJwcm9qZWN0cyI6WyJkZWZhdWx0Il0sInN1YiI6ImFkbWluIn0.wnjScyVuUUJyqt7AW4J6PrZ135dp8nWQTUmAqcjja15vaY4GQsu2lpZTn6AhmzQNWYfaYcLwc1ApcRBAB3h9oQlJOpSMI96U9XDYcMi1_i1AX8zN1EAFnklURK6TKPMy2OfNx8KOoWHTtRqBm-NDcla25aCpIrdHi7P9OPB2dcrHv7cYLBNwB6zWnzkM1EnRXYQIXDtKs1iX1K-A5Ph0Si3LIUg3LOjNML3Yn2D7vCWdItaGs86EE-2R2VVkYsLO19G09KwcLnhf5CmxxTjPDp2dOQjfwIFWbTmVQCFORtqj2Gt3X2EQFBwSru-e9M-fYcUiv6bqpd7WLufo-7q3bg
kubectl config set-context cfc --user=user --namespace=default
kubectl config use-context cfc
```

Check that you can run some basic commands against the cluster:

```bash
$ Client Version: version.Info{Major:"1", Minor:"6", GitVersion:"v1.6.4", GitCommit:"d6f433224538d4f9ca2f7ae19b252e6fcb66a3ae", GitTreeState:"clean", BuildDate:"2017-05-19T18:44:27Z", GoVersion:"go1.7.5", Compiler:"gc", Platform:"linux/amd64"}
Server Version: version.Info{Major:"1", Minor:"5", GitVersion:"v1.5.2", GitCommit:"08e099554f3c31f6e6f07b448ab3ed78d0520507", GitTreeState:"clean", BuildDate:"2017-02-05T08:03:16Z", GoVersion:"go1.7.5", Compiler:"gc", Platform:"linux/amd64"}
$ kubectl get nodes
NAME             STATUS                     AGE       VERSION
169.46.198.195   Ready                      34m       v1.5.2
169.46.198.209   Ready                      34m       v1.5.2
169.46.198.216   Ready,SchedulingDisabled   36m       v1.5.2
```

From here you should be able to interact with ICP via either the Web UI or the `kubectl` command.