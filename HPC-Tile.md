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

  Example values.json, mandatory settings:
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
  Optional settings in values.json
```
"cluster_prefix"                                   : "hpcaas_1234",
"observability_atracker_on_cos_enable"             : false,
"observability_monitoring_enable"                  : false,
"observability_monitoring_on_compute_nodes_enable" : false,
"observability_monitoring_plan"                    : "graduated-tier",
"scc_enable"                                       : false,
"scc_profile"                                      : "CIS IBM Cloud Foundations Benchmark",
"scc_profile_version"                              : "1.0.0",
"scc_location"                                     : "eu-de",
"scc_event_notification_plan"                      : "lite",
"vpc_cidr"                                         : "10.241.0.0/18",
"vpc_cluster_private_subnets_cidr_blocks"          : "[\"10.241.0.0/20\"]",
"vpc_cluster_login_private_subnets_cidr_blocks"    : "[\"10.241.16.0/28\"]",
"vpc_name"                                         : "__NULL__",
"cluster_subnet_ids"                               : "[]",
"login_subnet_id"                                  : "__NULL__",
"login_node_instance_type"                         : "bx2-2x8",
"management_node_instance_type"                    : "bx2-2x8",
"management_node_count"                            : "1",
"management_image_name"                            : "hpcaas-lsf10-rhel88-v9",
"compute_image_name"                               : "hpcaas-lsf10-rhel88-compute-v5",
"login_image_name"                                 : "hpcaas-lsf10-rhel88-compute-v5",
"custom_file_shares"                               : "[{mount_path=\"/shared\", size=100, iops=2000}]",
"storage_security_group_id"                        : "__NULL__",
"dns_instance_id"                                  : "__NULL__",
"dns_domain_name"                                  : "{compute = \"hpcaas1949.com\"}",
"dns_custom_resolver_id"                           : "__NULL__",
"enable_cos_integration"                           : false,
"cos_instance_name"                                : "__NULL__",
"enable_vpc_flow_logs"                             : false,
"vpn_enabled"                                      : false,
"key_management"                                   : "key_protect",
"kms_instance_name"                                : "__NULL__",
"kms_key_name"                                     : "__NULL__",
"hyperthreading_enabled"                           : true,
"enable_fip"                                       : true,
"enable_app_center"                                : false,
"app_center_gui_pwd"                               : "Password1%",
"app_center_high_availability"                     : false,
"enable_ldap"                                      : false,
"ldap_basedns"                                     : "hpcaas.com",
"ldap_server"                                      : "null",
"ldap_admin_password"                              : "Password1%",
"ldap_user_name"                                   : "ldapuser",
"ldap_user_password"                               : "Password1%",
"ldap_vsi_profile"                                 : "cx2-2x4",
"ldap_vsi_osimage_name"                            : "ibm-ubuntu-22-04-3-minimal-amd64-1",
"skip_iam_authorization_policy"                    : false,
"skip_iam_share_authorization_policy"              : false,
"existing_certificate_instance"                    : "__NULL__",
"bastion_instance_name"                            : "__NULL__",
"bastion_instance_public_ip"                       : "__NULL__",
"bastion_security_group_id"                        : "__NULL__",
"UNUSED_bastion_ssh_private_key"                   : ""
```
- 7.2 Via GUI
![Via CLIs!](/img/hpctile06.jpg)

Configure workspace
![Configure workspace!](/img/hpctile07.jpg)

Configure (mandatory) parameters 
![Configure parameters!](/img/hpctile08.jpg)

- 8 Check https://cloud.ibm.com/schematics/workspaces:
  ![Check workspaces!](/img/hpctile11.jpg)
  


