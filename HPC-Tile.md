# H-O-S
## How to setup a HPC-Tile instance

The [Docs](https://cloud.ibm.com/docs/allowlist/hpc-service?topic=hpc-service-overview)
are a good starting point.

Here are the steps to instantiate a HPC Tile:

1. Create a new ssh key, more details [here](https://cloud.ibm.com/docs/vpc?topic=vpc-ssh-keys)
![Create key!](/img/hpctile01.jpg)
2. In the Cloud Catalog, search for 'HPC' and select 'IBM Cloud HPC'
![Cloud Catalog!](/img/hpctile02.jpg)
3. Select 'Review deployment options'
![Deployment options!](/img/hpctile03.jpg)
4. Instantiate the HPC Tile
   
   4.1 Via CLI
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
   4.2 Via GUI
   ![Via CLIs!](/img/hpctile06.jpg)
   blabla
   
   Configure workspace1
   ![Configure workspace!](/img/hpctile07.jpg)
   bbbbbb
   
   dsfsdf

sdsdfsdfsdf

   


ddfsdfsdf
