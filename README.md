# The power-ops repository
The power-ops repository is both an Ansible repository and a repository for auxiliary code or scripts, intended to host community-developed automated provisioning and configuration of Operational Management tools capable of running and/or managing OpenPOWER Systems. It is hosted in GitHub at the following location:
[https://github.com/IBM/power-ops/](https://github.com/IBM/power-ops/tree/master/)
&nbsp;
# Contents
There are 3 main sections in this repository:
- *bringup* contains playbooks to bring up and teardown OpenPOWER nodes as either controllers or endpoints in the Operational Management infrastructure. You can choose to use either bare metal nodes (in which case you can skip the "bringup.yml" playbook) or to use a virtualization infrastructure to create virtual nodes (currently only the Nutanix AHV hypervisor is supported, but we intend to support more options in the future).
- *build* contains playbooks to create rpm or deb packages of required tools when no packages are yet available for the Power architecture. These packages are later pushed into a "repository" node and make available for the "deploy" playbooks for installation on the controller or endpoint nodes.
- *deploy* contains playbooks to install and configure the Operational Management stack on deployment nodes according to their role: either controllers (whiere the server-side components run) or endpoints (where client-side components run). The endpoint nodes consist of the majority of the nodes provisioned, and controller nodes can be sized and created as needed depending on the number of endpoints to be monitored. Different tools have different controller sizing needs depending on the number of endpoints they manage or the amount of data that they keep.
In addition, the following sections hold important deployment data:
- *inventory* contains the hosts file that is either automatically generated (if your infrastructure is virtual and created via the bringup.yml playbook) or where you manually list the bare metal nodes you want to provision.
- *scripts* contains sample scripts that show how to properly call Ansible to execute the playbooks, for deifferent scenarios, or contains additional auxiliary scripts.
- *state* contains the Ansible vault file which holds a secret key used to encode passwords or other secret data used in the playbook yml files as variables. It is used in conjuction with the "scripts/enc.sh" script to perform the encoding (you can then get the encoded string and use it as a variable in your yml file.
- *vars* contains the main variables used by all playbooks. These variables define how the deployment and configuration will occur. There are variables specific to the target environments (e.g. aix.yml, debian.yml, redhat.yml, nutanix.yml) or specific to the component being deployed (e.g. crassd.yml, elasticsearch.yml, netdata.yml, etc.). Please review these variables and use appropriate values for your environment.
&nbsp;
# Further Documentation
Living documentation can be found in the *docs* directory in this repository. We will try to document the main deployment options and variables, organized in a similar fashion as the *vars* directory. For each main supported environment or component we'll have a corresponding document which describes in more detail what can be done to tailor your deployment for your needs.
The entry point for the documentation is the [main](docs/main.md) document, which also contains an index to all other documentation pages.
&nbsp;
# Getting Started
To do a simple deployment these are the minimum steps you will need to perform:
1. Define a **provisioner** node in your network that has access to all other nodes you want to deploy to. As preparation you need to perform 2 tasks on that node:
- Install Ansible, by following the instructions here: *https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html*
- Configure all your deployment nodes to be passwordless-accessible via root ssh from the provisioner node.
2. Clone the repository and go to the project's directory
```shell
git clone git@github.com:IBM/power-ops.git
cd power-ops
```
3. (optional) Change the Ansible vault password
```shell
sed -i "s/passw0rd/<your_new_password_here>/g" state/vault.key
```
4. Generate new encoded secrets for your deployment. These are the variables you should look at:
- *<OS>.yml:password* (where OS is aix, debian or redhat). This is the password that will be set for the root user at each of the nodes in the cluster (done in the prepare.yml playbook in the bringup section).
- (if creating virtual nodes) *nutanix.yml/clusters/<your_cluster_name>:password*. This is the password for your Nutanix cluster user. You may also want to consider changing the *username* variable (which uses the "admin" user by default).
```shell
scripts/enc.sh "<your_new_secret_password>"
```
Then replace the value at the corresponding variable on *vars/[nutanix|debian|redhat|aix].yml*.
5. (optional) Adjust deployment parameters as needed by reviewing and changing the variable values at the *vars* directory. Each file in there has important parameters for each of the supported environments and components used in the deployment.
6. (optional) If creating virtual nodes adjust your deployment's topology and parameters at *vars/nutanix.yml*. The *vms* array contains a list of dictionaries, each one representing a virtual node.
Please consult this project's documentation at [nutanix.md](docs/nutanix.md) for more information on how to configure each virtual node you wish to create. To deploy these new virtual nodes issue now the following command:
```shell
scripts/run.sh bringup/bringup.yml localhost,
```
7. Adjust your inventory file to reflect all nodes in your deployment. If you are using virtual nodes from the previous step the bringup.yml playbook will have automatically generated the virtual node entries and added them to the inventory file.
The inventory file is *inventory/hosts* and it can have a mix of both virtual and bare metal nodes (bare metal nodes are the ones you must manually add in this step). Note that each node has "roles" that will govern what playbooks will run in them:
- **controller** nodes are where the Operational Management server-side components will be installed.
- **endpoint** nodes are where the Operational Management client-side components will be installed.
- **builder** nodes are where some of the components build tasks will run (you need one each for each kind of operating system family your deployment needs).
- **repository** node is where the result of the builds are pushed to and where the deployment nodes pull the components from during the "deploy" section playbooks.
8. Prepare your deployment nodes. This normalizes each node with users, passwords, keys, prereqs and other details needed for the sub-sequent deployment phases. To do this run the following command:
```shell
scripts/run.sh bringup/prepare.yml inventory/hosts
```
9. (only needed once) Build the commponents that currently have no distributions for the Power platform. This step is executed in the nodes with *builder* role assigned to them in the inventory and the results are copied to the node with *repository* role. This is the command needed:
```shell
scripts/run.sh build/main.yml inventory/hosts
```
10. Deploy the Operational Management stack to your controller and endpoint nodes using the following command:
```shell
scripts/run.sh deploy/main.yml inventory/hosts
```

As a convenience steps 6, 8-10 are implemented in a script: *scripts/all.sh*.

Once all the steps of the deployment are performed you can login to the Operational Management tools to see each of the dashboards:
- Elasticsearch shows the indexes for Logstash and Metricbeat that hold the cluster alerts and metrics:
*http://<controller_ip_address>:9200/_cat/indices?v*
- Kinana shows 3 dashboards, one each for Power Firmware Alerts, Endpoint Alerts/Logs and Endpoint Metrics:
*https://<controller_ip_address>:8443/app/kibana*
(default credentials are kibana/kibana, unless changed on corresponding variables prior to deployment)
- Netdata shows runtime metrics from Power Firmware (and optionally from endpoints if additional plugins are enabled prior to deployment):
*http://<controller_ip_address>:19999*

Enjoy!!!
