# H-O-S
## How to setup a HPC-Tile instance

The [Docs](https://cloud.ibm.com/docs/allowlist/hpc-service?topic=hpc-service-overview)
are a good starting point.

Here are the steps to instantiate a HPC Tile:


1. Make sure you have a proper IBM Cloud account

2. Get your IBMCLOUD_ACCOUNT_ID ![Get IBMCLOUD_ACCOUNT_ID!](/img/hpctile09.jpg)
3. Get (or create) your IBMCLOUD_API_KEY ![Get IBMCLOUD_API_KEY!](/img/hpctile10.jpg)

4. Create a new ssh key, more details [here](https://cloud.ibm.com/docs/vpc?topic=vpc-ssh-keys)
![Create key!](/img/hpctile01.jpg)
5. In the Cloud Catalog, search for 'HPC' and select 'IBM Cloud HPC'
![Cloud Catalog!](/img/hpctile02.jpg)
6. Select 'Review deployment options'
![Deployment options!](/img/hpctile03.jpg)
7. Instantiate the HPC Tile
- 7.1 Via CLI
  ![Via CLIs!](/img/hpctile04.jpg)

  Example values.json:
```
{
"ibmcloud_api_key"                                 : "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX",
"resource_group"                                   : "XXXXXXX",
"reservation_id"                                   : "XXXXXXXXXXXXXXXXXXXXXXXXX",
"cluster_id"                                       : "XXXXXXXXX",
"bastion_ssh_keys"                                 : "[\"key-arch-ibm-hpc\"]",
"compute_ssh_keys"                                 : "[\"key-arch-ibm-hpc\"]",
"remote_allowed_ips"                               : "[\"11.22.33.44\"]",
"zones"                                            : "[\"eu-de-3\"]"
}
```
- 7.2 Via GUI
![Via CLIs!](/img/hpctile06.jpg)

Configure workspace
![Configure workspace!](/img/hpctile07.jpg)

Configure (mandatory) parameters 
![Configure parameters!](/img/hpctile08.jpg)

- 8 Check https://cloud.ibm.com/schematics/workspaces:
  ![Check workspaces!](/img/hpctile11.jpg)
  


