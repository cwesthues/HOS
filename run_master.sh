#!/bin/sh

if test -f /root/custom_config.txt
then
   . /root/custom_config.txt
fi

############################################################

PACKAGE="Hybridcloud"
HOSTS_UP=""
HOSTNAME=`hostname -s`
case ${HOSTNAME} in
*onprem*)
   INSTALL_TYPE=ONPREM
   SETUP_TYPE="Terraform"
;;
*)
   INSTALL_TYPE=CLOUD
;;
esac

############################################################

. /etc/os-release

case ${ID_LIKE} in
*rhel*|*fedora*)
   ESC="-e"
   PSSH="pssh"
   PSCP="pscp.pssh"
;;
*debian*)
   PSSH="parallel-ssh"
   PSCP="parallel-scp"
;;
esac

############################################################

if test "${INSTALL_TYPE}" = "ONPREM"
then
   . /root/install_functions.sh
fi

############################################################

# Misc stuff
if test "${ROOTPWD}" = ""
then
   ROOTPWD="Password1%"
fi
if test "${ADDITIONAL_USERS}" = ""
then
   ADDITIONAL_USERS=""
fi
if test "${CUSTOM_BACKGROUND_IMAGE}" = ""
then
   CUSTOM_BACKGROUND_IMAGE=""
fi
if test "${SWAP}" = ""
then
   SWAP="2048" # in MB
fi
if test "${SHARED}" = ""
then
   SHARED="/shared"
fi

if test "${NFS_SHARES}" = ""
then
   NFS_SHARES="/shared"
fi

if test "${INSTALL_TYPE}" = "ONPREM"
then
  REGION="onprem"
fi

HPCTILE_JSON="/tmp/values.json"
ENVIRONMENT_SH="/var/environment.sh"

ID_RSA_PUB_BASE64="XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
ID_RSA_PRIV_BASE64="XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"

mkdir -p /root/.ssh
if test "${ID_RSA_PRIV_BASE64}" != "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
then
   echo "${ID_RSA_PRIV_BASE64}" | base64 -d > /root/.ssh/id_rsa
   chmod 600 /root/.ssh/id_rsa
fi
if test "${ID_RSA_PUB_BASE64}" != "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
then
   echo "${ID_RSA_PUB_BASE64}" | base64 -d > /root/.ssh/id_rsa.pub
   chmod 644 /root/.ssh/id_rsa.pub
   cp /root/.ssh/id_rsa.pub /root/.ssh/authorized_keys
   chmod 600 /root/.ssh/authorized_keys
fi

ID_RSA_PUB=`cat /root/.ssh/id_rsa.pub`
ID_RSA_PUB_BASE64=`cat /root/.ssh/id_rsa.pub | base64 -w0`
ID_RSA_PRIV=`cat /root/.ssh/id_rsa`
ID_RSA_PRIV_BASE64=`cat /root/.ssh/id_rsa | base64 -w0`

############################################################

# Cloud provider stuff

if test "${DEFAULT_NUM_STATIC_COMPUTE}" = ""
then
   DEFAULT_NUM_STATIC_COMPUTE="0"
fi

if test "${DEFAULT_NUM_STATIC_BAREMETAL}" = ""
then
   DEFAULT_NUM_STATIC_BAREMETAL="0"
fi

############################################################

# Add-On stuff

ALL_ADD_ONS_HPC_Tile="Apptainer Aspera BLAST Blender DataManager easyEDA Explorer Geekbench Intel-HPCKit iRODS-shell Jupyter LS-DYNA LWS MatlabRuntime Multicluster Nextflow Octave OpenFOAM openMPI PlatformMPI ProcessManager R rDock RTM Sanger-in-a-box Simulator ScaleClient Spark Streamflow stress-ng Tensorflow Toil VeloxChem Yellowdog"
ALL_ADD_ONS_Terraform="ApplicationCenter Apptainer Aspera BLAST Blender DataManager easyEDA Explorer Geekbench Guacamole HostFactory Intel-HPCKit iRODS-shell Jupyter LDAP LicenseScheduler LS-DYNA LSF LWS MatlabRuntime Monitoring Multicluster Nextflow NFS Octave OpenFOAM openMPI PlatformMPI Podman ProcessManager R rDock RDP ResourceConnector RTM Sanger-in-a-box Simulator SLURM ScaleClient Spark Streamflow stress-ng Symphony Tensorflow Toil VeloxChem VPN-C2S VPN-S2S Yellowdog"

DEFAULT_ADD_ONS_Onprem="Guacamole LSF Multicluster"
DEFAULT_ADD_ONS_HPC_Tile="Geekbench"
DEFAULT_ADD_ONS_Terraform="Guacamole LSF Multicluster ResourceConnector"

############################################################

ALL_JOBTYPES="Array GitNode Helloworld Webserver"

############################################################

# SLURM stuff
MUNGE_KEY="XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"

############################################################

# Symphony stuff
SYM_TOP="/opt/ibm/spectrumcomputing"
SYM_ENTITLEMENT_EGO="XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
SYM_ENTITLEMENT_SYM="XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"

############################################################

# CodeEgine
DOCKERUSER="cwesthues"
DOCKERTOKEN="XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
DEFAULT_RESOURCES="1x2"
ALL_RESOURCES="\
   0.125x0.25 0.125x0.5 0.125x1 \
   0.25x0.5 0.25x1 0.25x2 \
   0.5x1 0.5x2 0.5x4 \
   1x2 1x4 1x8 \
   2x4 2x8 2x16 \
   4x8 4x16 4x32 \
   6x12 6x24 6x48 \
   8x16 8x32 \
   10x20 10x40 \
   12x24 12x48"

############################################################

# OS stuff

ALL_OS_TERRAFORM="centos9 ubuntu2204 almalinux94 rhel88"
#ALL_OS_TERRAFORM="centos9 ubuntu2204"
if test "${DEFAULT_OS_TERRAFORM}" = ""
then
   #DEFAULT_OS_TERRAFORM="centos9"
   DEFAULT_OS_TERRAFORM="almalinux94"
fi
ALL_OS_HPCTILE="rhel"
if test "${DEFAULT_OS_HPCTILE}" = ""
then
   DEFAULT_OS_HPCTILE="rhel"
fi

############################################################

# Template stuff

ALL_TEMPLATE_TYPES="fileserver master compute failover multicluster login"
DEFAULT_TEMPLATES_SETUP="master compute"
DEFAULT_TEMPLATES_START="master"

############################################################

# LSF stuff

LSF_ADMIN="lsfadmin"
LSF_ENTITLEMENT="XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
LSF_TOP="/usr/share/lsf"
RC_DEMAND_POLICY="THRESHOLD[[1,1]]"  #Launch VM if more than 1 job (1st param) is pending for more than 1 minutes (2nd param)
LSB_RC_EXTERNAL_HOST_IDLE_TIME="30"  #Shutdown VMs if idle for more than 30 minutes
if test "${MAX_DYN_NODES}" = ""
then
   MAX_DYN_NODES=5
fi
if test "${COMPUTENODE_PREFIX}" = ""
then
   #COMPUTENODE_PREFIX="cn\\\${SHORT}"
   COMPUTENODE_PREFIX="ip-\\\${LONG}"
fi
############################################################

# IBM stuff

# WARNING: Make sure IP spoofing is allowed, see:
# https://cloud.ibm.com/docs/vpc?topic=vpc-ip-spoofing-about

if test "${IBMCLOUD_API_KEY}" = ""
then
   echo "Set IBMCLOUD_API_KEY"
   #export IBMCLOUD_API_KEY="XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
   #export NEW_IBMCLOUD_API_KEY="XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"   # itz-cp-emea
else
   echo "IBMCLOUD_API_KEY is already set"
fi

if test "${IBMCLOUD_RESOURCE_GROUP}" = ""
then
   export IBMCLOUD_RESOURCE_GROUP="geo-cwe"
fi

if test "${IBMCLOUD_ACCOUNT_ID}" = ""
then
   echo "Set IBMCLOUD_ACCOUNT_ID"
   #export IBMCLOUD_ACCOUNT_ID="XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
   #export NEW_IBMCLOUD_ACCOUNT_ID="XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"   # itz-cp-emea
else
   echo "IBMCLOUD_ACCOUNT_ID is already set"
fi

IBMCLOUD_REGIONS_TERRAFORM="eu-de eu-es eu-gb us-east us-south"
IBMCLOUD_REGIONS_HPCTILE="eu-de us-east us-south"
IBMCLOUD_REGIONS_CODEENGINE="eu-de eu-es eu-gb us-east us-south"

if test "${IBMCLOUD_DEFAULT_REGION}" = ""
then
   IBMCLOUD_DEFAULT_REGION="eu-de"
fi

if test "${IBMCLOUD_DEFAULT_SETUP_TYPE}" = ""
then
   IBMCLOUD_DEFAULT_SETUP_TYPE="Terraform"
fi

if test "${SPEC_fileserver_IBM_TYPE}" = ""
then
   SPEC_fileserver_IBM_TYPE="cx2-2x4"    # bx2-2x8
fi

if test "${SPEC_master_IBM_TYPE}" = ""
then
   SPEC_master_IBM_TYPE="cx2-2x4"        # bx2-2x8
fi

if test "${SPEC_compute_IBM_TYPE}" = ""
then
   SPEC_compute_IBM_TYPE="cx2-2x4"       # bx2-2x8
fi

if test "${SPEC_baremetal_IBM_TYPE}" = ""
then
   SPEC_baremetal_IBM_TYPE="bx2-metal-96x384"
fi

if test "${SPEC_failover_IBM_TYPE}" = ""
then
   SPEC_failover_IBM_TYPE="cx2-2x4"      # bx2-2x8
fi

if test "${SPEC_multicluster_IBM_TYPE}" = ""
then
   SPEC_multicluster_IBM_TYPE="cx2-2x4"  # bx2-2x8
fi

if test "${SPEC_login_IBM_TYPE}" = ""
then
   SPEC_login_IBM_TYPE="cx2-2x4"         # bx2-2x8
fi

IBM_COMPUTE_TYPES="\
bx2-128x512 bx2-16x64 bx2-2x8 bx2-32x128 bx2-48x192 bx2-4x16 bx2-64x256 bx2-8x32 bx2-96x384 \
cx2-128x256 cx2-16x32 cx2-2x4 cx2-32x64 cx2-48x96 cx2-4x8 cx2-64x128 cx2-8x16 cx2-96x192 \
gx2-16x128x1v100 gx2-16x128x2v100 gx2-32x256x2v100 gx2-8x64x1v100 \
mx2-128x1024 mx2-16x128 mx2-2x16 mx2-32x256 mx2-48x384 mx2-4x32 mx2-64x512 mx2-8x64 mx2-96x768"

if test "${IBM_DEFAULT_TYPES}" = ""
then
   IBM_DEFAULT_TYPES="cx2-2x4 cx2-4x8"
fi

if test "${IBM_BLOCKSTORAGE_DEFAULT_SIZE}" = ""
then
   IBM_BLOCKSTORAGE_DEFAULT_SIZE="0"
fi

############################################################

# Terraform stuff

#echo | ssh-keygen -b 2048 -t rsa  -q -N "" 1>/dev/null 2>/dev/null
PUBLIC_KEY=`cat /root/.ssh/id_rsa.pub`
TF_WORKDIR=/tmp/terraform_$$

############################################################

# DynDNS stuff

DYNDNS_DOMAIN=".ddnss.org"

############################################################

# Yellowdog stuff

YD_TOKEN="XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"

############################################################

# HPC-Tile stuff

# Let's find out what is our external IP
cat > /etc/sysctl.d/70-ipv6.conf <<EOF
net.ipv6.conf.all.disable_ipv6 = 1
net.ipv6.conf.default.disable_ipv6 = 1
EOF
sysctl --load /etc/sysctl.d/70-ipv6.conf 1>/dev/null 2>/dev/null
DEFAULT_MYEXTERNALIP=""
while test "${DEFAULT_MYEXTERNALIP}" = ""
do
   DEFAULT_MYEXTERNALIP=`curl ifconfig.me 2>/dev/null`
   sleep 1
done

DATE=`date +%H%M`
DEFAULT_APP_CENTER_GUI_PWD="Password1%"
DEFAULT_APP_CENTER_HIGH_AVAILABILITY="false"
DEFAULT_CLUSTER_ID="HPC-LSF-1"
DEFAULT_CLUSTER_PREFIX="hpcaas${DATE}"
DEFAULT_COMPUTE_IMAGE_NAME="hpcaas-lsf10-rhel88-compute-v5"
DEFAULT_CUSTOM_FILE_SHARES="[{mount_path=\\\"${SHARED}\\\", size=100, iops=2000}]"
DEFAULT_DNS_DOMAIN="${DEFAULT_CLUSTER_PREFIX}.com"
DEFAULT_ENABLE_APP_CENTER="false"
DEFAULT_ENABLE_LDAP="false"
DEFAULT_IBMCLOUD_API_KEY="XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
DEFAULT_KEY_MANAGEMENT="key_protect"
DEFAULT_LDAP_BASEDNS="hpcaas.com"
DEFAULT_LDAP_SERVER="null"
DEFAULT_LDAP_ADMIN_PASSWD="Password1%"
DEFAULT_LDAP_USER_NAME="ldapuser"
DEFAULT_LDAP_USER_PASSWD="Password1%"
DEFAULT_LDAP_VSI_OSIMAGE_NAME="ibm-ubuntu-22-04-3-minimal-amd64-1"
DEFAULT_LDAP_VSI_PROFILE="cx2-2x4"
DEFAULT_LOGIN_IMAGE_NAME="hpcaas-lsf10-rhel88-compute-v5"
DEFAULT_LOGIN_NODE_INSTANCE_TYPE="bx2-2x8"
#DEFAULT_MANAGEMENT_IMAGE_NAME="hpcaas-lsf10-rhel88-v8"  # v1.7.0
#DEFAULT_MANAGEMENT_IMAGE_NAME="hpcaas-lsf10-rhel88-v9"  # v1.7.1
DEFAULT_MANAGEMENT_IMAGE_NAME="hpcaas-lsf10-rhel88-v9"   # v1.7.2
DEFAULT_MANAGEMENT_NODE_COUNT="1"
DEFAULT_MANAGEMENT_NODE_INSTANCE_TYPE="bx2-2x8"
DEFAULT_OBSERVABILITY_ATRACK_ON_COS_ENABLE="false"
DEFAULT_OBSERVABILITY_MONITORING_ENABLE="false"
DEFAULT_OBSERVABILITY_MONITORING_ON_COMPUTE_NODES_ENABLE="false"
DEFAULT_OBSERVABILITY_MONITORING_PLAN="graduated-tier"
DEFAULT_RESERVATION_ID="Contract-IBM-FRA-TECHZONE"
DEFAULT_RESOURCE_GROUP="geo-cwe"
DEFAULT_SCC_ENABLE="false"
DEFAULT_SCC_PROFILE="CIS IBM Cloud Foundations Benchmark"
DEFAULT_SCC_PROFILE_VERSION="1.0.0"
DEFAULT_SCC_LOCATION="eu-de"
DEFAULT_SCC_EVENT_NOTIFICATION_PLAN="lite"
DEFAULT_SSH_KEY_NAME="key-arch-ibm-hpc"
DEFAULT_VPC_CIDR="10.241.0.0/18"
DEFAULT_VPC_CLUSTER_LOGIN_PRIVATE_SUBNETS_CIDR_BLOCKS="[\\\"10.241.16.0/28\\\"]"
DEFAULT_VPC_CLUSTER_PRIVATE_SUBNETS_CIDR_BLOCKS="[\\\"10.241.0.0/20\\\"]"
DEFAULT_VPN_ENABLED="false"
DEFAULT_ZONE="[\\\"eu-de-3\\\"]"

############################################################

# Firewall/port stuff

if test "${VPN_CIDR}" = ""
then
   VPN_CIDR="192.168.0.0/16"
fi

# Open dedicated ports:
TCP_PORTS="22 53 80 443 1191 1729 2049 3260 3306 3389 4046 5050 5901 6010 6817-6819 6878-6882 7869-7892 8080-8889 9080-9443 10080 11000-11019 31000-32255 56000-56255 60000-61000 63000-64000"
UDP_PORTS="7869"


# Good for ssh, LSF, NFS4 and Guacamole:
#TCP_PORTS="22 80 2049 6878-6882 7869-7892 3389 8088 11000-11019"
#UDP_PORTS="7869"

# Open all ports:
#TCP_PORTS="1-65535"
#UDP_PORTS="1-65535"

# Open no ports:
#TCP_PORTS=""
#UDP_PORTS=""

if test "${ADD_MYEXTERNALIP_AT_START}" = ""
then
   ADD_MYEXTERNALIP_AT_START="Y"    # Y or N
fi
if test "${ALLOWED_IP_ADDRESSES}" = ""
then
   ALLOWED_IP_ADDRESSES=""
fi

# 22          TCP SSH
# 80          TCP HTTP
# 88          TCP LDAP
# 111         TCP NFS
# 111         UDP NFS
# 389         TCP LDAP
# 443         TCP LDAP
# 443         TCP HTTPS/LDAP
# 1729        TCP DataManager
# 2049        TCP NFS
# 2049        UDP NFS
# 3389        TCP RDP
# 4046        TCP EXPLORER
# 5050        TCP SIMULATOR
# 5901        TCP VNC
# 6010        TCP X11/Blender
# 6817        TCP SLURMCTLD
# 6818        TCP SLURMD
# 6819        TCP SLURMDBD
# 6878        TCP LSF RES
# 6881        TCP LSF MBD
# 6882        TCP LSF SBD
# 7869        TCP LSF LIM
# 7869        UDP LSF LIM
# 8080        TCP PAC
# 8088        TCP LWS
# 8888        TCP PAC/EXPLORER
# 9200        TCP EXPLORER
# 9999        TCP EXPLORER
# 11000-11019 TCP LSF NIOS
# 33001       UDP Aspera
# 63000-64000 TCP SLURM SRUN

############################################################

# Port forward to master-onprem (Fritzbox) 

# 22    TCP SSH
# 80    TCP Guacamole
# 88    TCP LDAP
# 389   TCP LDAP
# 443   TCP LDAP
# 2049  TCP NFS
# 3389  TCP RDP
# 6878  TCP LSF RES
# 6881  TCP LSF MBD
# 6882  TCP LSF SBD
# 7869  TCP LSF LIM
# 7869  UDP LSF LIM
# 8080  TCP Guacamole
# 8081  TCP HTTP
# 8888  TCP PAC
# 33001 UDP Aspera

############################################################

rm -rf /root/Desktop/ssh-*
rm -rf /root/Desktop/RDP-*
rm -rf /root/Desktop/AC*
rm -rf /root/Desktop/Multicluster*
rm -rf /root/Desktop/Guacamole*

rm -rf ${ENVIRONMENT_SH}

############################################################

RED='\e[1;31m'
GREEN='\e[1;32m'
BLUE='\e[1;34m'
OFF='\e[0;0m'

############################################################

echo ${ESC} ""
echo ${ESC} "${BLUE}Locating SW repository outside VM${OFF}"
echo ${ESC} "${BLUE}=================================${OFF}"
CAND="/mnt/hgfs/*/work /mnt/hgfs/*/My/CD /media/*/work /media/*/My/CD /root"
LOC=""
for LOCX in ${CAND}
do
   if test -d ${LOCX}/${PACKAGE}
   then
      LOC="${LOCX}/${PACKAGE}"
      break
   fi
done

if test "${LOC}" = ""
then
   echo "Can't see ${PACKAGE} in any of ${CAND}"
else
   echo "SW repository found under ${LOC}"
fi

############################################################

if test "${INSTALL_TYPE}" = "CLOUD"
then
   ALL_POCS=`ls /root/PoCs 2>/dev/null`
   if test "${ALL_POCS}" != ""
   then

      echo ${ESC} ""
      echo ${ESC} "${BLUE}Select PoC settings${OFF}"
      echo ${ESC} "${BLUE}===================${OFF}"

      echo ${ALL_POCS} | awk '{for(i=1;i<=NF;i++){printf("%s\n",$i)}}' | tee -a /tmp/$$.pocs
      HEAD=`head -1 /tmp/$$.pocs | awk '{print $1}'`
      TAIL=`tail -1 /tmp/$$.pocs | awk '{print $1}'`
      echo
      echo -n "Select PoC [${HEAD} - ${TAIL}] (<Enter> for none): "
      read POC
      if test "${POC}" != ""
      then
         echo "You selected ${POC}"
         cp /root/PoCs/${POC}/* /root
         for BACKGROUND in `ls /usr/share/backgrounds/*.jpg /usr/share/backgrounds/*.png 2>/dev/null | egrep -v _ORIG`
         do
            cp /root/PoCs/${POC}/custom_image.jpg ${BACKGROUND}
            . /root/custom_config.txt
         done
      fi
   fi

   echo ${ESC} ""
   echo ${ESC} "${BLUE}Use HPC-Tile, Terraform or CodeEngine?${OFF}"
   echo ${ESC} "${BLUE}======================================${OFF}"
   echo
   echo -n "Select SETUP_TYPE [HPC-Tile|Terraform|CodeEngine] (<Enter> for '${IBMCLOUD_DEFAULT_SETUP_TYPE}'): "
   read SETUP_TYPE
   if test "${SETUP_TYPE}" = ""
   then
      SETUP_TYPE="${IBMCLOUD_DEFAULT_SETUP_TYPE}"
   fi
   case ${SETUP_TYPE} in
   HPC-Tile) IBMCLOUD_REGIONS="${IBMCLOUD_REGIONS_HPCTILE}" ;;
   Terraform) IBMCLOUD_REGIONS="${IBMCLOUD_REGIONS_TERRAFORM}" ;;
   CodeEngine) IBMCLOUD_REGIONS="${IBMCLOUD_REGIONS_CODEENGINE}" ;;
   esac

   echo ${ESC} ""
   echo ${ESC} "${BLUE}Select region you want to setup${OFF}"
   echo ${ESC} "${BLUE}===============================${OFF}"

   echo
   while test "${REGION}" = ""
   do
      echo "${IBMCLOUD_REGIONS}" | awk '{for(i=1;i<=NF;i++){printf("%s\n",$i)}}' | tee -a /tmp/$$.regions
      HEAD=`head -1 /tmp/$$.regions | awk '{print $1}'`
      TAIL=`tail -1 /tmp/$$.regions | awk '{print $1}'`
      echo
      echo -n "Select region [${HEAD} - ${TAIL}] (<Enter> for '${IBMCLOUD_DEFAULT_REGION}'): "
      read REGION
      if test "${REGION}" = ""
      then
         REGION="${IBMCLOUD_DEFAULT_REGION}"
      fi
   done

   case ${REGION} in
   eu-de)
      CIDR="10.243.0.0/18"
      #DEFAULT_ZONE="${DEFAULT_ZONE_FRANKFURT}"
   ;;
   eu-es)    CIDR="10.251.0.0/18";;
   eu-gb)    CIDR="10.242.0.0/18";;
   us-east)
      CIDR="10.241.0.0/18"
      #DEFAULT_ZONE="${DEFAULT_ZONE_DALLAS}"
   ;;
   us-south) CIDR="10.240.0.0/18";;
   esac
   echo
   echo "You selected ${REGION}"
   echo

   ############################################################

   case ${SETUP_TYPE} in
   HPC-Tile|Terraform)
      echo ${ESC} ""
      echo ${ESC} "${BLUE}Select OS you want to use${OFF}"
      echo ${ESC} "${BLUE}=========================${OFF}"

      echo
      while test "${OS}" = ""
      do
         case ${SETUP_TYPE} in
         HPC-Tile)
            ALL_OS="${ALL_OS_HPCTILE}"
            DEFAULT_OS="${DEFAULT_OS_HPCTILE}"
         ;;
         Terraform)
            ALL_OS="${ALL_OS_TERRAFORM}"
            DEFAULT_OS="${DEFAULT_OS_TERRAFORM}"
         ;;
         esac
         echo ${ALL_OS} | awk '{for(i=1;i<=NF;i++){printf("%-15.15s",$i);if($i=="almalinux94"){printf("(custom)\n")}else{printf("(stock)\n")}}}' | sort
         echo
         echo -n "Select OS (<Enter> for '${DEFAULT_OS}'): "
         read OS
         if test "${OS}" = ""
         then
            OS="${DEFAULT_OS}"
         fi
         case "${OS}" in
         rhel88)
            export IBMCLOUD_IMAGE="ibm-redhat-8-8-minimal-amd64-3";;
         centos9)
            export IBMCLOUD_IMAGE="ibm-centos-stream-9-amd64-1";;
         ubuntu2204)
            export IBMCLOUD_IMAGE="ibm-ubuntu-22-04-3-minimal-amd64-1";;
         almalinux94)
            export IBMCLOUD_IMAGE="almalinux94";;
         esac
      done
      echo
      echo "You selected ${OS}"
      echo

      ############################################################

      case ${SETUP_TYPE} in
      Terraform)
         echo ${ESC} ""
         echo ${ESC} "${BLUE}Select compute types you want to use${OFF}"
         echo ${ESC} "${BLUE}====================================${OFF}"

         echo
         while test "${COMPUTE_TYPES}" = ""
         do
            echo "${IBM_COMPUTE_TYPES}" | awk '{for(i=1;i<=NF;i++){printf("%s\n",$i)}}' > /tmp/$$.types
            egrep cx2- /tmp/$$.types | awk '{for(i=1;i<=NF;i++){printf("%s ",$i)}}END{printf("\n")}' 
            egrep bx2- /tmp/$$.types | awk '{for(i=1;i<=NF;i++){printf("%s ",$i)}}END{printf("\n")}'
            egrep mx2- /tmp/$$.types | awk '{for(i=1;i<=NF;i++){printf("%s ",$i)}}END{printf("\n")}'
            egrep gx2- /tmp/$$.types | awk '{for(i=1;i<=NF;i++){printf("%s ",$i)}}END{printf("\n")}'
            HEAD=`head -1 /tmp/$$.types | awk '{print $1}'`
            TAIL=`tail -1 /tmp/$$.types | awk '{print $1}'`
            echo
            echo -n "Select type(s) [${HEAD} - ${TAIL}] (<Enter> for '${IBM_DEFAULT_TYPES}'): "
            read COMPUTE_TYPES
            COMPUTE_TYPES=`echo ${COMPUTE_TYPES} | sed s/","/" "/g`
            if test "${COMPUTE_TYPES}" = ""
            then
               COMPUTE_TYPES="${IBM_DEFAULT_TYPES}"
            fi
         done
         echo
         echo "You selected ${COMPUTE_TYPES}"
         echo
      ;;
      HPC-Tile)
         # VERSION_LOCATOR_VALUE="1082e7d2-5e2f-0a11-a3bc-f88a8e1931fc.2d5609a9-d287-4286-9904-a25dee9b1f53-global"  # v1.7.0
         # VERSION_LOCATOR_VALUE="1082e7d2-5e2f-0a11-a3bc-f88a8e1931fc.c5b005ea-619d-40b7-ab48-e2a8d3b0d5cc-global"  # v1.7.1
         VERSION_LOCATOR_VALUE="1082e7d2-5e2f-0a11-a3bc-f88a8e1931fc.abed6d29-ff41-47d8-9ed6-afc3f8131821-global"    # v1.7.2
         # DEFAULT_IMAGE_NAME="hpcaas-lsf10-rhel88-v7"  # v1.7.0
         # DEFAULT_IMAGE_NAME="hpcaas-lsf10-rhel88-v9"  # v1.7.1
         DEFAULT_IMAGE_NAME="hpcaas-lsf10-rhel88-v9"    # v1.7.2
         case ${OS} in
         rhel)
            DEFAULT_COMPUTE_IMAGE_NAME="hpcaas-lsf10-rhel88-compute-v5"
         ;;
         ubuntu)
            DEFAULT_COMPUTE_IMAGE_NAME="hpcaas-lsf10-ubuntu2204-compute-v2"
         ;;
         esac
      ;;
      esac
   ;;
   esac
fi

############################################################

if test "${SETUP_TYPE}" = "HPC-Tile"
then
   echo -n "Do you want to enable LDAP? [y|n] (<Enter> for 'n'): "
   read INSTALL_LDAP
   if test "${INSTALL_LDAP}" = "y"
   then
      ENABLE_LDAP="true"
      echo -n "   Which LDAP Base DNS? (<Enter> for '${DEFAULT_LDAP_BASEDNS}'): "
      read LDAP_BASEDNS
      if test "${LDAP_BASEDNS}" = ""
      then
         LDAP_BASEDNS="${DEFAULT_LDAP_BASEDNS}"
      fi
      echo -n "   Which LDAP Server? (<Enter> for '${DEFAULT_LDAP_SERVER}'): "
      read LDAP_SERVER
      if test "${LDAP_SERVER}" = ""
      then
         LDAP_SERVER="${DEFAULT_LDAP_SERVER}"
      fi
      echo -n "   Which LDAP admin password? (<Enter> for '${DEFAULT_LDAP_ADMIN_PASSWD}'): "
      read LDAP_ADMIN_PASSWD
      if test "${LDAP_ADMIN_PASSWD}" = ""
      then
         LDAP_ADMIN_PASSWD="${DEFAULT_LDAP_ADMIN_PASSWD}"
      fi
      echo -n "   Which LDAP user name? (<Enter> for '${DEFAULT_LDAP_USER_NAME}'): "
      read LDAP_USER_NAME
      if test "${LDAP_USER_NAME}" = ""
      then
         LDAP_USER_NAME="${DEFAULT_LDAP_USER_NAME}"
      fi
      echo -n "   Which LDAP user password? (<Enter> for '${DEFAULT_LDAP_USER_PASSWD}'): "
      read LDAP_USER_PASSWD
      if test "${LDAP_USER_PASSWD}" = ""
      then
         LDAP_USER_PASSWD="${DEFAULT_LDAP_USER_PASSWD}"
      fi
      echo -n "   Which LDAP VSI image name? (<Enter> for '${DEFAULT_LDAP_VSI_OSIMAGE_NAME}'): "
      read LDAP_VSI_OSIMAGE_NAME
      if test "${LDAP_VSI_OSIMAGE_NAME}" = ""
      then
         LDAP_VSI_OSIMAGE_NAME="${DEFAULT_LDAP_VSI_OSIMAGE_NAME}"
      fi
      echo -n "   Which LDAP VSI profile? (<Enter> for '${DEFAULT_LDAP_VSI_PROFILE}'): "
      read LDAP_VSI_PROFILE
      if test "${LDAP_VSI_PROFILE}" = ""
      then
         LDAP_VSI_PROFILE="${DEFAULT_LDAP_VSI_PROFILE}"
      fi
   else
      ENABLE_LDAP="${DEFAULT_ENABLE_LDAP}"
      LDAP_BASEDNS="${DEFAULT_LDAP_BASEDNS}"
      LDAP_SERVER="${DEFAULT_LDAP_SERVER}"
      LDAP_ADMIN_PASSWD="${DEFAULT_LDAP_ADMIN_PASSWD}"
      LDAP_USER_NAME="${DEFAULT_LDAP_USER_NAME}"
      LDAP_USER_PASSWD="${DEFAULT_LDAP_USER_PASSWD}"
      LDAP_VSI_OSIMAGE_NAME="${DEFAULT_LDAP_VSI_OSIMAGE_NAME}"
      LDAP_VSI_PROFILE="${DEFAULT_LDAP_VSI_PROFILE}"
   fi
   echo -n "Do you want to enable VPN? [y|n] (<Enter> for 'n'): "
   read INSTALL_VPN
   if test "${INSTALL_VPN}" = "y"
   then
      VPN_ENABLED="true"
   else
      VPN_ENABLED="${DEFAULT_VPN_ENABLED}"
   fi
   echo -n "Do you want to enable AppCenter? [y|n] (<Enter> for 'n'): "
   read INSTALL_APPCENTER
   if test "${INSTALL_APPCENTER}" = "y"
   then
      ENABLE_APP_CENTER="true"
      echo -n "   Do you want to enable AppCenter High Availability? [y|n] (<Enter> for 'n'): "
      read APPCENTER_HIGH_AVAILABILITY
      if test "${APPCENTER_HIGH_AVAILABILITY}" = "y"
      then
         APP_CENTER_HIGH_AVAILABILITY="true"
      else
         APP_CENTER_HIGH_AVAILABILITY="${DEFAULT_APP_CENTER_HIGH_AVAILABILITY}"
      fi
      echo -n "   Which AppCenter GUI Password? (<Enter> for '${DEFAULT_APP_CENTER_GUI_PWD}'): "
      read APP_CENTER_GUI_PWD
      if test "${APP_CENTER_GUI_PWD}" = ""
      then
         APP_CENTER_GUI_PWD="${DEFAULT_APP_CENTER_GUI_PWD}"
      fi
   else
      ENABLE_APP_CENTER="${DEFAULT_ENABLE_APP_CENTER}"
      APP_CENTER_GUI_PWD="${DEFAULT_APP_CENTER_GUI_PWD}"
      APP_CENTER_HIGH_AVAILABILITY="${DEFAULT_APP_CENTER_HIGH_AVAILABILITY}"
   fi

   echo -n "Do you want to enable Observability Atracker on COS? (<Enter> for '${DEFAULT_OBSERVABILITY_ATRACK_ON_COS_ENABLE}'): "
   read OBSERVABILITY_ATRACK_ON_COS_ENABLE
   if test "${OBSERVABILITY_ATRACK_ON_COS_ENABLE}" = ""
   then
      OBSERVABILITY_ATRACK_ON_COS_ENABLE="${DEFAULT_OBSERVABILITY_ATRACK_ON_COS_ENABLE}"
   fi

   OBSERVABILITY_MONITORING_PLAN="${DEFAULT_OBSERVABILITY_MONITORING_PLAN}"
   echo -n "Do you want to enable Observability Monitoring? (<Enter> for '${DEFAULT_OBSERVABILITY_MONITORING_ENABLE}'): "
   read OBSERVABILITY_MONITORING_ENABLE
   if test "${OBSERVABILITY_MONITORING_ENABLE}" = ""
   then
      OBSERVABILITY_MONITORING_ENABLE="${DEFAULT_OBSERVABILITY_MONITORING_ENABLE}"
   fi


   echo -n "Do you want to enable Observability Monitoring on computenodes? (<Enter> for '${DEFAULT_OBSERVABILITY_MONITORING_ON_COMPUTE_NODES_ENABLE}'): "
   read OBSERVABILITY_MONITORING_ON_COMPUTE_NODES_ENABLE
   if test "${OBSERVABILITY_MONITORING_ON_COMPUTE_NODES_ENABLE}" = ""
   then
      OBSERVABILITY_MONITORING_ON_COMPUTE_NODES_ENABLE="${DEFAULT_OBSERVABILITY_MONITORING_ON_COMPUTE_NODES_ENABLE}"
   fi

   SCC_PROFILE="${DEFAULT_SCC_PROFILE}"
   SCC_PROFILE_VERSION="${DEFAULT_SCC_PROFILE_VERSION}"   
   SCC_LOCATION="${DEFAULT_SCC_LOCATION}"   
   SCC_EVENT_NOTIFICATION_PLAN="${DEFAULT_SCC_EVENT_NOTIFICATION_PLAN}"   
   echo -n "Do you want to enable SCC? (<Enter> for '${DEFAULT_SCC_ENABLE}'): "
   read SCC_ENABLE
   if test "${SCC_ENABLE}" = ""
   then
      SCC_ENABLE="${DEFAULT_SCC_ENABLE}"
   fi

   echo

   echo ${ESC} "${BLUE}Common settings${OFF}"
   for ITEM in \
      CLUSTER_ID CLUSTER_PREFIX COMPUTE_IMAGE_NAME CUSTOM_FILE_SHARES \
      DNS_DOMAIN \
      IBMCLOUD_API_KEY KEY_MANAGEMENT LOGIN_IMAGE_NAME \
      LOGIN_NODE_INSTANCE_TYPE MANAGEMENT_IMAGE_NAME MANAGEMENT_NODE_COUNT \
      MANAGEMENT_NODE_INSTANCE_TYPE MYEXTERNALIP RESERVATION_ID \
      RESOURCE_GROUP SSH_KEY_NAME VPC_CIDR \
      VPC_CLUSTER_LOGIN_PRIVATE_SUBNETS_CIDR_BLOCKS \
      VPC_CLUSTER_PRIVATE_SUBNETS_CIDR_BLOCKS ZONE
   do
      eval echo -n "Specify ${ITEM} \(\<Enter\> for \'\$DEFAULT_${ITEM}\'\): "
      read ${ITEM}
      eval VAR="\$${ITEM}"
      if test "${VAR}" = ""
      then
         eval ${ITEM}="\$DEFAULT_${ITEM}"
      fi
   done
fi

############################################################

case ${SETUP_TYPE} in
HPC-Tile|Terraform)
   echo ${ESC} ""
   echo ${ESC} "${BLUE}Select Add-On's${OFF}"
   echo ${ESC} "${BLUE}===============${OFF}"

   while test "${ADD_ONS}" = ""
   do
      echo
      if test "${DEFAULT_ADD_ONS}" = ""
      then
         case ${INSTALL_TYPE} in
         ONPREM)
            ALL_ADD_ONS="${ALL_ADD_ONS_Terraform}"
            DEFAULT_ADD_ONS="${DEFAULT_ADD_ONS_Onprem}"
         ;;
         CLOUD)
            case ${SETUP_TYPE} in
            HPC-Tile)
               ALL_ADD_ONS="${ALL_ADD_ONS_HPC_Tile}"
               DEFAULT_ADD_ONS="${DEFAULT_ADD_ONS_HPC_Tile}"
            ;;
            Terraform)
               ALL_ADD_ONS="${ALL_ADD_ONS_Terraform}"
               DEFAULT_ADD_ONS="${DEFAULT_ADD_ONS_Terraform}"
            ;;
            esac
         ;;
         esac
      fi
      echo ${ALL_ADD_ONS} | awk '{for(i=1;i<=NF;i++){printf("%s\n",$i)}}' | sort > /tmp/$$.addons
      HEAD=`head -1 /tmp/$$.addons | awk '{print $1}'`
      TAIL=`tail -1 /tmp/$$.addons | awk '{print $1}'`
      COLS=`tput cols`
      STRING=`cat /tmp/$$.addons | awk '{printf("%s ",$1)}'`
      NEW_LINE=""
      while test "${STRING}" != ""
      do
         NEW_WORD=`echo ${STRING} | awk '{print $1}'`
         NEW_WORD_LENGTH=`echo ${NEW_WORD} | wc -c`
         NEW_LENGTH=`echo ${NEW_LINE} | wc -c`
         NEW_TOTAL_LENGTH=`expr ${NEW_LENGTH} + ${NEW_WORD_LENGTH} + 1`
         if test "${NEW_TOTAL_LENGTH}" -le ${COLS}
         then
            if test "${NEW_LINE}" = ""
            then
               NEW_LINE="${NEW_WORD}"
            else
               NEW_LINE="${NEW_LINE} ${NEW_WORD}"
            fi
            STRING=`echo ${STRING} | awk '{for(i=2;i<=NF;i++){printf("%s ",$i)}}'`
         else
            echo "${NEW_LINE}"
            NEW_LINE=""
         fi
      done
      echo "${NEW_LINE}"
      echo
      echo -n "Select Add-On(s) [${HEAD} - ${TAIL}] (<Enter> for '${DEFAULT_ADD_ONS}'): "
      read ADD_ONS
      ADD_ONS=`echo ${ADD_ONS} | sed s/","/" "/g`
      if test "${ADD_ONS}" = ""
      then
         ADD_ONS="${DEFAULT_ADD_ONS}"
      fi
   done
   echo
   echo "You selected ${ADD_ONS}"
;;
esac

############################################################

if test "${INSTALL_TYPE}" = "CLOUD"
then
   if test "`echo ${ADD_ONS} | egrep LSF`" != ""
   then
      for LINK in $LINKS
      do
         NAME=`echo ${LINK} | awk 'BEGIN{FS="#"}{print $1}'`
         URL=`echo ${LINK} | awk 'BEGIN{FS="#"}{print $2}'`
         DESKTOP_LINK="/root/Desktop/${NAME}.desktop"
         cat << EOF> ${DESKTOP_LINK}
[Desktop Entry]
Type=Application
Terminal=false
Exec=firefox ${URL}
Name=${NAME}
Icon=firefox
EOF
         gio set ${DESKTOP_LINK} "metadata::trusted" true >/dev/null 2>&1
         chmod 755 "${DESKTOP_LINK}"
      done
   fi
fi

############################################################

write_environment_sh () {
   cat > ${ENVIRONMENT_SH} <<EOF
export SETUP_TYPE="${SETUP_TYPE}"
export CLUSTERADMIN="${CLUSTERADMIN}"
export LSF_ADMIN="${LSF_ADMIN}"
export DYNDNS_DOMAIN="${DYNDNS_DOMAIN}"
export REGION="${REGION}"
export ROOTPWD="${ROOTPWD}"
export COMPUTE_TYPES="${COMPUTE_TYPES}"
export COMPUTENODE_PREFIX="${COMPUTENODE_PREFIX}"
export ID_RSA_PUB_BASE64="${ID_RSA_PUB_BASE64}"
export ID_RSA_PRIV_BASE64="${ID_RSA_PRIV_BASE64}"
export LSF_ENTITLEMENT="${LSF_ENTITLEMENT}"
export MUNGE_KEY="${MUNGE_KEY}"
export SHARED="${SHARED}"
export NFS_SHARES="${NFS_SHARES}"
export IBMCLOUD_API_KEY="${IBMCLOUD_API_KEY}"
export IBMCLOUD_RESOURCE_GROUP="${IBMCLOUD_RESOURCE_GROUP}"
EOF

   if test "${ADDITIONAL_USERS}" != ""
   then
      echo "export ADDITIONAL_USERS=\"${ADDITIONAL_USERS}\"" >> ${ENVIRONMENT_SH}
   fi
   if test "${SWAP}" != ""
   then
      echo "export SWAP=\"${SWAP}\"" >> ${ENVIRONMENT_SH}
   fi
   RET=`echo " ${ADD_ONS} " | fgrep ' ApplicationCenter '`
   if test "${RET}" != ""
   then
      echo "export WITH_APPLICATIONCENTER=Y" >> ${ENVIRONMENT_SH}
   fi
   RET=`echo " ${ADD_ONS} " | fgrep ' Apptainer '`
   if test "${RET}" != ""
   then
      echo "export WITH_APPTAINER=Y" >> ${ENVIRONMENT_SH}
   fi
   RET=`echo " ${ADD_ONS} " | fgrep ' Aspera '`
   if test "${RET}" != ""
   then
      echo "export WITH_ASPERA=Y" >> ${ENVIRONMENT_SH}
   fi
   RET=`echo " ${ADD_ONS} " | fgrep ' BLAST '`
   if test "${RET}" != ""
   then
      echo "export WITH_BLAST=Y" >> ${ENVIRONMENT_SH}
   fi
   RET=`echo " ${ADD_ONS} " | fgrep ' Blender '`
   if test "${RET}" != ""
   then
      echo "export WITH_BLENDER=Y" >> ${ENVIRONMENT_SH}
   fi
   RET=`echo " ${ADD_ONS} " | fgrep ' DataManager '`
   if test "${RET}" != ""
   then
      echo "export WITH_DATAMANAGER=Y" >> ${ENVIRONMENT_SH}
   fi
   RET=`echo " ${ADD_ONS} " | fgrep ' easyEDA '`
   if test "${RET}" != ""
   then
      echo "export WITH_EASYEDA=Y" >> ${ENVIRONMENT_SH}
   fi
   RET=`echo " ${ADD_ONS} " | fgrep ' Explorer '`
   if test "${RET}" != ""
   then
      echo "export WITH_EXPLORER=Y" >> ${ENVIRONMENT_SH}
   fi
   RET=`echo " ${ADD_ONS} " | fgrep ' Geekbench '`
   if test "${RET}" != ""
   then
      echo "export WITH_GEEKBENCH=Y" >> ${ENVIRONMENT_SH}
   fi
   RET=`echo " ${ADD_ONS} " | fgrep ' Guacamole '`
   if test "${RET}" != ""
   then
      echo "export WITH_GUACAMOLE=Y" >> ${ENVIRONMENT_SH}
   fi
   RET=`echo " ${ADD_ONS} " | fgrep ' HostFactory '`
   if test "${RET}" != ""
   then
      echo "export WITH_HOSTFACTORY=Y" >> ${ENVIRONMENT_SH}
   fi
   RET=`echo " ${ADD_ONS} " | fgrep ' Intel-HPCKit '`
   if test "${RET}" != ""
   then
      echo "export WITH_INTELHPCKIT=Y" >> ${ENVIRONMENT_SH}
   fi
   RET=`echo " ${ADD_ONS} " | fgrep ' iRODS-shell '`
   if test "${RET}" != ""
   then
      echo "export WITH_IRODS=Y" >> ${ENVIRONMENT_SH}
   fi
   RET=`echo " ${ADD_ONS} " | fgrep ' Jupyter '`
   if test "${RET}" != ""
   then
      echo "export WITH_JUPYTER=Y" >> ${ENVIRONMENT_SH}
   fi
   RET=`echo " ${ADD_ONS} " | fgrep ' LDAP '`
   if test "${RET}" != ""
   then
      echo "export WITH_LDAP=Y" >> ${ENVIRONMENT_SH}
   fi
   RET=`echo " ${ADD_ONS} " | fgrep ' LicenseScheduler '`
   if test "${RET}" != ""
   then
      echo "export WITH_LICENSESCHEDULER=Y" >> ${ENVIRONMENT_SH}
   fi
   RET=`echo " ${ADD_ONS} " | fgrep ' LS-DYNA '`
   if test "${RET}" != ""
   then
      echo "export WITH_LSDYNA=Y" >> ${ENVIRONMENT_SH}
   fi
   RET=`echo " ${ADD_ONS} " | fgrep ' LSF '`
   if test "${RET}" != ""
   then
      echo "export WITH_LSF=Y" >> ${ENVIRONMENT_SH}
   fi
   RET=`echo " ${ADD_ONS} " | fgrep ' LWS '`
   if test "${RET}" != ""
   then
      echo "export WITH_LWS=Y" >> ${ENVIRONMENT_SH}
   fi
   RET=`echo " ${ADD_ONS} " | fgrep ' MatlabRuntime '`
   if test "${RET}" != ""
   then
      echo "export WITH_MATLABRUNTIME=Y" >> ${ENVIRONMENT_SH}
   fi
   RET=`echo " ${ADD_ONS} " | fgrep ' Monitoring '`
   if test "${RET}" != ""
   then
      echo "export WITH_MONITORING=Y" >> ${ENVIRONMENT_SH}
   fi
   RET=`echo " ${ADD_ONS} " | fgrep ' Multicluster '`
   if test "${RET}" != ""
   then
      echo "export WITH_MULTICLUSTER=Y" >> ${ENVIRONMENT_SH}
   fi
   RET=`echo " ${ADD_ONS} " | fgrep ' Nextflow '`
   if test "${RET}" != ""
   then
      echo "export WITH_NEXTFLOW=Y" >> ${ENVIRONMENT_SH}
   fi
   RET=`echo " ${ADD_ONS} " | fgrep ' NFS '`
   if test "${RET}" != ""
   then
      echo "export WITH_NFS=Y" >> ${ENVIRONMENT_SH}
   fi
   RET=`echo " ${ADD_ONS} " | fgrep ' OpenFOAM '`
   if test "${RET}" != ""
   then
      echo "export WITH_OPENFOAM=Y" >> ${ENVIRONMENT_SH}
   fi
   RET=`echo " ${ADD_ONS} " | fgrep ' Octave '`
   if test "${RET}" != ""
   then
      echo "export WITH_OCTAVE=Y" >> ${ENVIRONMENT_SH}
   fi
   RET=`echo " ${ADD_ONS} " | fgrep ' openMPI '`
   if test "${RET}" != ""
   then
      echo "export WITH_OPENMPI=Y" >> ${ENVIRONMENT_SH}
   fi
   RET=`echo " ${ADD_ONS} " | fgrep ' PlatformMPI '`
   if test "${RET}" != ""
   then
      echo "export WITH_PLATFORMMPI=Y" >> ${ENVIRONMENT_SH}
   fi
   RET=`echo " ${ADD_ONS} " | fgrep ' Podman '`
   if test "${RET}" != ""
   then
      echo "export WITH_PODMAN=Y" >> ${ENVIRONMENT_SH}
   fi
   RET=`echo " ${ADD_ONS} " | fgrep ' ProcessManager '`
   if test "${RET}" != ""
   then
      echo "export WITH_PROCESSMANAGER=Y" >> ${ENVIRONMENT_SH}
   fi
   RET=`echo " ${ADD_ONS} " | fgrep ' R '`
   if test "${RET}" != ""
   then
      echo "export WITH_R=Y" >> ${ENVIRONMENT_SH}
   fi
   RET=`echo " ${ADD_ONS} " | fgrep ' rDock '`
   if test "${RET}" != ""
   then
      echo "export WITH_RDOCK=Y" >> ${ENVIRONMENT_SH}
   fi
   RET=`echo " ${ADD_ONS} " | fgrep ' RDP '`
   if test "${RET}" != ""
   then
      echo "export WITH_RDP=Y" >> ${ENVIRONMENT_SH}
   fi
   RET=`echo " ${ADD_ONS} " | fgrep ' ResourceConnector '`
   if test "${RET}" != ""
   then
      echo "export WITH_RESOURCE_CONNECTOR=Y" >> ${ENVIRONMENT_SH}
   fi
   RET=`echo " ${ADD_ONS} " | fgrep ' RTM '`
   if test "${RET}" != ""
   then
      echo "export WITH_RTM=Y" >> ${ENVIRONMENT_SH}
   fi
   RET=`echo " ${ADD_ONS} " | fgrep ' Sanger-in-a-box '`
   if test "${RET}" != ""
   then
      echo "export WITH_SANGER_IN_A_BOX=Y" >> ${ENVIRONMENT_SH}
   fi
   RET=`echo " ${ADD_ONS} " | fgrep ' ScaleClient '`
   if test "${RET}" != ""
   then
      echo "export WITH_SCALECLIENT=Y" >> ${ENVIRONMENT_SH}
   fi
   RET=`echo " ${ADD_ONS} " | fgrep ' Simulator '`
   if test "${RET}" != ""
   then
      echo "export WITH_SIMULATOR=Y" >> ${ENVIRONMENT_SH}
   fi
   RET=`echo " ${ADD_ONS} " | fgrep ' SLURM '`
   if test "${RET}" != ""
   then
      echo "export WITH_SLURM=Y" >> ${ENVIRONMENT_SH}
   fi
   RET=`echo " ${ADD_ONS} " | fgrep ' Spark '`
   if test "${RET}" != ""
   then
      echo "export WITH_SPARK=Y" >> ${ENVIRONMENT_SH}
   fi
   RET=`echo " ${ADD_ONS} " | fgrep ' Streamflow '`
   if test "${RET}" != ""
   then
      echo "export WITH_STREAMFLOW=Y" >> ${ENVIRONMENT_SH}
   fi
   RET=`echo " ${ADD_ONS} " | fgrep ' stress-ng '`
   if test "${RET}" != ""
   then
      echo "export WITH_STRESSNG=Y" >> ${ENVIRONMENT_SH}
   fi
   RET=`echo " ${ADD_ONS} " | fgrep ' Symphony '`
   if test "${RET}" != ""
   then
      echo "export WITH_SYMPHONY=Y" >> ${ENVIRONMENT_SH}
   fi
   RET=`echo " ${ADD_ONS} " | fgrep ' Tensorflow '`
   if test "${RET}" != ""
   then
      echo "export WITH_TENSORFLOW=Y" >> ${ENVIRONMENT_SH}
   fi
   RET=`echo " ${ADD_ONS} " | fgrep ' Toil '`
   if test "${RET}" != ""
   then
      echo "export WITH_TOIL=Y" >> ${ENVIRONMENT_SH}
   fi
   RET=`echo " ${ADD_ONS} " | fgrep ' VeloxChem '`
   if test "${RET}" != ""
   then
      echo "export WITH_VELOXCHEM=Y" >> ${ENVIRONMENT_SH}
   fi
   RET=`echo " ${ADD_ONS} " | fgrep ' Yellowdog '`
   if test "${RET}" != ""
   then
      echo "export WITH_YELLOWDOG=Y" >> ${ENVIRONMENT_SH}
      echo "export YD_TOKEN=\"${YD_TOKEN}\"" >> ${ENVIRONMENT_SH}
   fi
   if test "`echo ${TEMPLATES} | egrep failover`" != ""
   then
      echo "export WITH_FAILOVER=Y" >> ${ENVIRONMENT_SH}
   fi
   # Set dependencies, e.g. Octave requires Podman and LSF
   # In case this dependencies were not explicitly set...
   RET=`cat ${ENVIRONMENT_SH} | egrep -i '(WITH_APPLICATION_CENTER|WITH_APPTAINER|WITH_ASPERA|WITH_BLAST|WITH_BLENDER|WITH_DATAMANAGER|WITH_EASYEDA| WITH_EXPLORER|WITH_GEEKBENCH|WITH_INTELHPCKIT|WITH_IRODS|WITH_JUPYTER|WITH_LICENSESCHEDULER|WITH_LSDYNA|WITH_LWS|WITH_MATLABRUNTIME|WITH_MULTICLUSTER|WITH_NEXTFLOW|WITH_OCTAVE|WITH_OPENFOAM|WITH_OPENMPI|WITH_PLATFORMMPI|WITH_PROCESSMANAGER|WITH_R|WITH_RDOCK|WITH_RESOURCE_CONNECTOR|WITH_RTM|WITH_SANGER_IN_A_BOX|WITH_SPARK|WITH_STREAMFLOW|WITH_TENSORFLOW|WITH_TOIL|WITH_VELOXCHEM)'`
   if test "${RET}" != ""
   then
      if test "${SETUP_TYPE}" = "Terraform"
      then
         ADD_ONS="${ADD_ONS} LSF"
         if test "`egrep WITH_LSF ${ENVIRONMENT_SH}`" = ""
         then
            echo "export WITH_LSF=\"Y\"" >> ${ENVIRONMENT_SH}
         fi
      fi
   fi
   RET=`cat ${ENVIRONMENT_SH} | egrep -i '(WITH_HOSTFACTORY)'`
   if test "${RET}" != ""
   then
      ADD_ONS="${ADD_ONS} Symphony"
      if test "`egrep WITH_SYMPHONY ${ENVIRONMENT_SH}`" = ""
      then
         echo "export WITH_SYMPHONY=\"Y\"" >> ${ENVIRONMENT_SH}
      fi
   fi
   RET=`cat ${ENVIRONMENT_SH} | egrep -i '(WITH_OCTAVE|WITH_OPENFOAM|WITH_NEXTFLOW|WITH_TENSORFLOW)'`
   if test "${RET}" != ""
   then
      ADD_ONS="${ADD_ONS} Podman"
      if test "`egrep WITH_PODMAN ${ENVIRONMENT_SH}`" = ""
      then
         echo "export WITH_PODMAN=\"Y\"" >> ${ENVIRONMENT_SH}
      fi
   fi
   RET=`cat ${ENVIRONMENT_SH} | egrep -i '(WITH_BLENDER|WITH_MATLABRUNTIME|WITH_NEXTFLOW|WITH_OPENMPI|WITH_PLATFORMMPI|WITH_SANGER_IN_A_BOX|WITH_SPARK|WITH_STREAMFLOW|WITH_VELOXCHEM)'`
   if test "${RET}" != ""
   then
      ADD_ONS="${ADD_ONS} NFS"
      if test "`egrep WITH_NFS ${ENVIRONMENT_SH}`" = ""
      then
         echo "export WITH_NFS=\"Y\"" >> ${ENVIRONMENT_SH}
      fi
   fi
   if test "`echo ${ADD_ONS} | egrep LSF`" != ""
   then
       cat >> ${ENVIRONMENT_SH} <<EOF
export LSB_RC_EXTERNAL_HOST_IDLE_TIME="${LSB_RC_EXTERNAL_HOST_IDLE_TIME}"
export LSF_ENTITLEMENT="${LSF_ENTITLEMENT}"
export LSF_TOP="${LSF_TOP}"
export RC_DEMAND_POLICY="${RC_DEMAND_POLICY}"
export MAX_DYN_NODES="${MAX_DYN_NODES}"
EOF
   fi
   if test "`echo ${ADD_ONS} | egrep Symphony`" != ""
   then
      cat >> ${ENVIRONMENT_SH} <<EOF
export SYM_TOP="${SYM_TOP}"
export SYM_ENTITLEMENT_EGO="${SYM_ENTITLEMENT_EGO}"
export SYM_ENTITLEMENT_SYM="${SYM_ENTITLEMENT_SYM}"
EOF
   fi
   chmod 755 ${ENVIRONMENT_SH}
}

############################################################

write_hpctile_json () {
   cat > ${HPCTILE_JSON} <<EOF
{
"_____comment1": "MANDATORY:",
"ibmcloud_api_key"                                 : "${IBMCLOUD_API_KEY}",
"resource_group"                                   : "${RESOURCE_GROUP}",
"reservation_id"                                   : "${RESERVATION_ID}",
"cluster_id"                                       : "${CLUSTER_ID}",
"bastion_ssh_keys"                                 : "[\"${SSH_KEY_NAME}\"]",
"compute_ssh_keys"                                 : "[\"${SSH_KEY_NAME}\"]",
"remote_allowed_ips"                               : "[\"${MYEXTERNALIP}\"]",
"zones"                                            : "${ZONE}",
"_____comment2": "OPTIONAL:",
"cluster_prefix"                                   : "${CLUSTER_PREFIX}",
"observability_atracker_on_cos_enable"             : ${OBSERVABILITY_ATRACK_ON_COS_ENABLE},
"observability_monitoring_enable"                  : ${OBSERVABILITY_MONITORING_ENABLE},
"observability_monitoring_on_compute_nodes_enable" : ${OBSERVABILITY_MONITORING_ON_COMPUTE_NODES_ENABLE},
"observability_monitoring_plan"                    : "${OBSERVABILITY_MONITORING_PLAN}",
"scc_enable"                                       : ${SCC_ENABLE},
"scc_profile"                                      : "${SCC_PROFILE}",
"scc_profile_version"                              : "${SCC_PROFILE_VERSION}",
"scc_location"                                     : "${SCC_LOCATION}",
"scc_event_notification_plan"                      : "${SCC_EVENT_NOTIFICATION_PLAN}",
"vpc_cidr"                                         : "${VPC_CIDR}",
"vpc_cluster_private_subnets_cidr_blocks"          : "${VPC_CLUSTER_PRIVATE_SUBNETS_CIDR_BLOCKS}",
"vpc_cluster_login_private_subnets_cidr_blocks"    : "${VPC_CLUSTER_LOGIN_PRIVATE_SUBNETS_CIDR_BLOCKS}",
"vpc_name"                                         : "__NULL__",
"cluster_subnet_ids"                               : "[]",
"login_subnet_id"                                  : "__NULL__",
"login_node_instance_type"                         : "${LOGIN_NODE_INSTANCE_TYPE}",
"management_node_instance_type"                    : "${MANAGEMENT_NODE_INSTANCE_TYPE}",
"management_node_count"                            : "${MANAGEMENT_NODE_COUNT}",
"management_image_name"                            : "${MANAGEMENT_IMAGE_NAME}",
"compute_image_name"                               : "${COMPUTE_IMAGE_NAME}",
"login_image_name"                                 : "${LOGIN_IMAGE_NAME}",
"custom_file_shares"                               : "${CUSTOM_FILE_SHARES}",
"storage_security_group_id"                        : "__NULL__",
"dns_instance_id"                                  : "__NULL__",
"dns_domain_name"                                  : "{compute = \"${DEFAULT_DNS_DOMAIN}\"}",
"dns_custom_resolver_id"                           : "__NULL__",
"enable_cos_integration"                           : false,
"cos_instance_name"                                : "__NULL__",
"enable_vpc_flow_logs"                             : false,
"vpn_enabled"                                      : ${VPN_ENABLED},
"key_management"                                   : "${KEY_MANAGEMENT}",
"kms_instance_name"                                : "__NULL__",
"kms_key_name"                                     : "__NULL__",
"hyperthreading_enabled"                           : true,
"enable_fip"                                       : true,
"enable_app_center"                                : ${ENABLE_APP_CENTER},
"app_center_gui_pwd"                               : "${APP_CENTER_GUI_PWD}",
"app_center_high_availability"                     : ${APP_CENTER_HIGH_AVAILABILITY},
"enable_ldap"                                      : ${ENABLE_LDAP},
"ldap_basedns"                                     : "${LDAP_BASEDNS}",
"ldap_server"                                      : "${LDAP_SERVER}",
"ldap_admin_password"                              : "${LDAP_ADMIN_PASSWD}",
"ldap_user_name"                                   : "${LDAP_USER_NAME}",
"ldap_user_password"                               : "${LDAP_USER_PASSWD}",
"ldap_vsi_profile"                                 : "${LDAP_VSI_PROFILE}",
"ldap_vsi_osimage_name"                            : "${LDAP_VSI_OSIMAGE_NAME}",
"skip_iam_authorization_policy"                    : false,
"skip_iam_share_authorization_policy"              : false,
"existing_certificate_instance"                    : "__NULL__",
"bastion_instance_name"                            : "__NULL__",
"bastion_instance_public_ip"                       : "__NULL__",
"bastion_security_group_id"                        : "__NULL__",
"UNUSED_bastion_ssh_private_key"                   : ""
}
EOF
}

############################################################

install_SW_APIS () {
   RET=`which xfreerdp 2>/dev/null`
   if test "${RET}" = ""
   then
      echo ${ESC} ""
      echo ${ESC} "${BLUE}Install freerdp${OFF}"
      echo ${ESC} "${BLUE}===============${OFF}"

      if test -f ${LOC}/SW/freerdp-2.4.1-5.el9.x86_64.rpm
      then
         rpm -i --nodeps ${LOC}/SW/freerdp-2.4.1-5.el9.x86_64.rpm 1>/dev/null 2>/dev/null
         rpm -i --nodeps ${LOC}/SW/freerdp-libs-2.4.1-5.el9.x86_64.rpm 1>/dev/null 2>/dev/null
         rpm -i --nodeps ${LOC}/SW/libwinpr-2.4.1-5.el9.x86_64.rpm 1>/dev/null 2>/dev/null
      else
         yum install -y freerdp 1>/dev/null 2>/dev/null
      fi
   fi

   RET=`which terraform 2>/dev/null`
   if test "${RET}" = ""
   then
      echo ${ESC} ""
      echo ${ESC} "${BLUE}Install Terraform${OFF}"
      echo ${ESC} "${BLUE}=================${OFF}"

      if test -f ${LOC}/SW/terraform-1.5.0-1.x86_64.rpm
      then
         rpm -i --nodeps ${LOC}/SW/terraform-1.5.0-1.x86_64.rpm 1>/dev/null 2>/dev/null
      else
         yum install -y yum-utils 1>/dev/null 2>/dev/null
         yum-config-manager --add-repo https://rpm.releases.hashicorp.com/RHEL/hashicorp.repo 1>/dev/null 2>/dev/null
         yum -y install terraform 1>/dev/null 2>/dev/null
      fi
   fi
   RET=`which ibmcloud 2>/dev/null`
   if test "${RET}" = ""
   then
      echo ${ESC} ""
      echo ${ESC} "${BLUE}Install IBM CLI${OFF}"
      echo ${ESC} "${BLUE}===============${OFF}"

      # curl -L https://download.clis.cloud.ibm.com/ibm-cloud-cli/2.17.1/IBM_Cloud_CLI_2.17.1_amd64.tar.gz -o /tmp/IBM_Cloud_CLI.tar.gz
      if test -f ${LOC}/SW/IBM_Cloud_CLI.tar.gz
      then
         cd /tmp
         tar -xf ${LOC}/SW/IBM_Cloud_CLI.tar.gz
         chmod 755 /tmp/Bluemix_CLI/install
         /tmp/Bluemix_CLI/install -q
      else
         curl -fsSL https://clis.cloud.ibm.com/install/linux | sh 1>/dev/null 2>/dev/null
      fi
      #rm -rf /root/.bluemix
      for PLUGIN in catalogs-management schematics vpc-infrastructure secrets-manager monitoring cloud-dns-services code-engine
      do
         RET=`ls ${LOC}/SW/${PLUGIN}* 2>/dev/null`
         if test "${RET}" = ""
         then
            ibmcloud plugin install ${PLUGIN} -f 1>/dev/null 2>/dev/null
         else
            # ibmcloud plugin download ${PLUGIN} -d ${LOC}/SW
            ibmcloud plugin install ${RET} -f 1>/dev/null 2>/dev/null
         fi
      done
   fi

   RET=`ibmcloud account list 2>/dev/null`
   if test "${RET}" = ""
   then
      echo ${ESC} ""
      echo ${ESC} "${BLUE}Login @ IBM-Cloud${OFF}"
      echo ${ESC} "${BLUE}=================${OFF}"
      ibmcloud login -r ${REGION} -q 2>/dev/null | egrep '(Account:|User:)'
      RET=`ibmcloud resource groups | egrep ${IBMCLOUD_RESOURCE_GROUP}`
      if test "${RET}" = ""
      then
         ibmcloud resource group-create ${IBMCLOUD_RESOURCE_GROUP} 1>/dev/null 2>/dev/null
      fi
      ibmcloud target -g ${IBMCLOUD_RESOURCE_GROUP} 1>/dev/null 2>/dev/null
      ibmcloud is target --gen 2 1>/dev/null 2>/dev/null
   fi
}

############################################################

setup_hpctile () {
   RET=`egrep zone ${HPCTILE_JSON} | awk 'BEGIN{FS="\""}{print $5}' | awk 'BEGIN{FS="-"}{for(i=1;i<NF;i++){printf("%s",$i);if(i<(NF-1)){printf("-")}}}'`
   case $RET in
   us-east*) export IBMCLOUD_DEFAULT_REGION="us-east"
   ;;
   eu-de*) export IBMCLOUD_DEFAULT_REGION="eu-de"
   ;;
   esac
   install_SW_APIS

   rm -rf /root/Desktop/AppCenter*.desktop
   rm -rf /root/Desktop/guacamole*.desktop
   rm -rf /root/Desktop/ssh*.desktop
   rm -rf /root/Desktop/RDP*.desktop
   PID=`ps auxww | egrep watchdog.sh | egrep -v grep | awk '{print $2}'`
   if test "${PID}" != ""
   then
      kill -9 ${PID}
   fi
}

############################################################

cleanup_terraform () {
   REGION=$1
   echo "Cleaning up in ${REGION}"

   ibmcloud target -r ${REGION} -c ${IBMCLOUD_ACCOUNT_ID} 1>/dev/null

   echo "   Look for workspaces"
   for WORKSPACE in `ibmcloud schematics workspace list 2>/dev/null | egrep ACTIVE | egrep -v INACTIVE | awk '{print $2}'`
   do
      echo "   Destroy active workspace ${WORKSPACE} (~12min.)"
      ibmcloud schematics destroy --id ${WORKSPACE} --force 1>/dev/null 2>/dev/null
      echo -n "   "
      RET=""
      while test "${RET}" = ""
      do
         echo -n "."
         sleep 10
         RET=`ibmcloud schematics workspace list 2>/dev/null | egrep ${WORKSPACE} | egrep INACTIVE`
      done
   done
   for WORKSPACE in `ibmcloud schematics workspace list 2>/dev/null | egrep '(INACTIVE|FAILED)' | awk '{print $2}'`
   do
      echo "      Delete workspace ${WORKSPACE}"
      ibmcloud schematics workspace delete --id ${WORKSPACE} --force 1>/dev/null 2>/dev/null
      echo -n "   "
      RET="x"
      while test "${RET}" = ""
      do
         echo -n "."
         sleep 10
         RET=`ibmcloud schematics workspace list | egrep ${WORKSPACE}`
      done
      echo
   done

   DNSINSTANCES=`ibmcloud dns instances | egrep '(active)' | awk '{print $1}'`
   echo "   Look for DNS instances"
   while test "${DNSINSTANCES}" != ""
   do
      DNSINSTANCES=`ibmcloud dns instances | egrep '(active)' | awk '{print $1}'`
      for DNSINSTANCE in ${DNSINSTANCES}
      do
         echo "   Look for DNS zones"
         DNSZONES=`ibmcloud dns zones -i ${DNSINSTANCE} | egrep '(ACTIVE|PENDING_NETWORK_ADD)' | awk '{print $1}'`
         for DNSZONE in ${DNSZONES}
         do
            echo "   Look for DNS permitted networks"
            DNSPERMITTEDNETWORKS=`ibmcloud dns permitted-networks ${DNSZONE} -i ${DNSINSTANCE} | egrep '(ACTIVE)' | awk '{print $2}'`
            for DNSPERMITTEDNETWORK in ${DNSPERMITTEDNETWORKS}
            do
               echo "      Delete permitted network ${DNSPERMITTEDNETWORK}"
               ibmcloud dns permitted-network-remove -f ${DNSZONE} ${DNSPERMITTEDNETWORK} -i ${DNSINSTANCE} 1>/dev/null 2>/dev/null
            done
            echo "      Delete DNS zone ${DNSZONE}"
            ibmcloud dns zone-delete  -f ${DNSZONE} -i ${DNSINSTANCE} 1>/dev/null 2>/dev/null
         done
         echo "   Look for DNS custom resolver"
         CUSTOMRESOLVERS=`ibmcloud dns custom-resolvers -i ${DNSINSTANCE} | egrep '(HEALTHY)' | awk '{print $1}'`
         for CUSTOMRESOLVER in ${CUSTOMRESOLVERS}
         do
            echo "   Disable DNS custom resolver ${CUSTOMRESOLVER}"
            ibmcloud dns custom-resolver-update  ${CUSTOMRESOLVER} --enabled false -i ${DNSINSTANCE} 1>/dev/null 2>/dev/null
            echo "   Delete DNS custom resolver ${CUSTOMRESOLVER}"
            ibmcloud dns custom-resolver-delete -f ${CUSTOMRESOLVER} -i ${DNSINSTANCE} 1>/dev/null 2>/dev/null
         done
         echo "      Terminate DNS instance ${DNSINSTANCE}"
         ibmcloud dns instance-delete -f ${DNSINSTANCE} 1>/dev/null 2>/dev/null
      done
   done

   MON_INSTANCES=`ibmcloud monitoring service-instances 2>/dev/null | egrep 'active' | awk '{print $1}'`
   echo "   Look for monitoring instances"
   while test "${MON_INSTANCES}" != ""
   do
      MON_INSTANCES=`ibmcloud monitoring service-instances 2>/dev/null| egrep 'active' | awk '{print $1}'`
      for MON_INSTANCE in ${MON_INSTANCES}
      do
         echo "      Terminate monitoring instance ${MON_INSTANCE}"
         ibmcloud resource service-instance-delete ${MON_INSTANCE} -f --recursive 1>/dev/null 2>/dev/null
      done
   done

   SECRETS_MANAGERS=`ibmcloud resource service-instances | fgrep "secrets-manager" | awk '{print $1}'`
   echo "   Look for secrets-manager"
   while test "${SECRETS_MANAGERS}" != ""
   do
      SECRETS_MANAGERS=`ibmcloud resource service-instances | fgrep "secrets-manager" | awk '{print $1}'`
      for SECRETS_MANAGER in ${SECRETS_MANAGERS}
      do
         echo "      Terminate secrets-manager ${SECRETS_MANAGER}"
         ibmcloud resource service-instance-delete -f ${SECRETS_MANAGER} 1>/dev/null 2>/dev/null
      done
      sleep 5      
   done

   SECRETS_MANAGER_RECLAMATIONS=`ibmcloud resource reclamations | egrep secrets-manager | awk '{print $1}'`
   echo "   Look for secrets-manager reclamations"
   while test "${SECRETS_MANAGER_RECLAMATIONS}" != ""
   do
      SECRETS_MANAGER_RECLAMATIONS=`ibmcloud resource reclamations | egrep secrets-manager | awk '{print $1}'`
      for SECRETS_MANAGER_RECLAMATION in ${SECRETS_MANAGER_RECLAMATIONS}
      do
         echo "      Terminate secrets-manager reclamation${SECRETS_MANAGER_RECLAMATION}"
         ibmcloud resource reclamation-delete -f ${SECRETS_MANAGER_RECLAMATION} 1>/dev/null 2>/dev/null
      done
   done

   SHARES=`ibmcloud is shares | egrep '(stable)' | awk '{print $1}'`
   echo "   Look for shares"
   while test "${SHARES}" != ""
   do
      SHARES=`ibmcloud is shares | egrep '(stable)' | awk '{print $1}'`
      for SHARE in ${SHARES}
      do
         echo "      Delete share ${SHARE}"
         ibmcloud is share-delete -f ${SHARE} 1>/dev/null 2>/dev/null
      done
   done

   INSTANCES=`ibmcloud is instances | egrep '(running|stopped)' | awk '{print $1}'`
   echo "   Look for instances"
   while test "${INSTANCES}" != ""
   do
      INSTANCES=`ibmcloud is instances | egrep '(running|stopped)' | awk '{print $1}'`
      for INSTANCE in ${INSTANCES}
      do
         echo "      Terminate instance ${INSTANCE}"
         ibmcloud is instance-delete -f ${INSTANCE} 1>/dev/null 2>/dev/null
      done
   done

   BARE_METAL_SERVERS=`ibmcloud is bare-metal-servers --all-resource-groups | egrep '(running|stopped)' | awk '{print $1}'`
   echo "   Look for bare metal servers"
   while test "${BARE_METAL_SERVERS}" != ""
   do
      BARE_METAL_SERVERS=`ibmcloud is bare-metal-servers --all-resource-groups | egrep '(running|stopped)' | awk '{print $1}'`
      for BARE_METAL_SERVER in ${BARE_METAL_SERVERS}
      do
         echo "      Stop ${BARE_METAL_SERVER}"
         ibmcloud is bare-metal-server-stop -f ${BARE_METAL_SERVER} 1>/dev/null 2>/dev/null
         RET=""
         while test "${RET}" = ""
         do
            RET=`ibmcloud is bare-metal-server ${BARE_METAL_SERVER} | egrep Status | egrep stopped`
            sleep 5
         done
         echo "      Delete ${BARE_METAL_SERVER}"
         ibmcloud is bare-metal-server-delete -f ${BARE_METAL_SERVER} 1>/dev/null 2>/dev/null
      done
   done

   echo "   Look for volumes"
   VOLUMES=`ibmcloud is volumes | egrep available | awk '{print $1}'`
   while test "${VOLUMES}" != ""
   do
      VOLUMES=`ibmcloud is volumes | egrep available | awk '{print $1}'`
      for VOLUME in ${VOLUMES}
      do
         echo "      Delete volume ${VOLUME}"
         ibmcloud is volume-delete -f ${VOLUME} 1>/dev/null 2>/dev/null
      done
   done

   echo "   Look for vpn-gateways"
   while test "`ibmcloud is vpn-gateways | egrep '(available|stable)'`" != ""
   do
      for VPN_GATEWAY in `ibmcloud is vpn-gateways | egrep '(available|stable)' | awk '{print $1}'`
      do
         echo "      Delete vpn-gateway ${VPN_GATEWAY}"
         ibmcloud is vpn-gateway-delete -f ${VPN_GATEWAY} 1>/dev/null 2>/dev/null
      done
   done

   echo "   Look for vpn-servers"
   while test "`ibmcloud is vpn-servers | egrep '(available|stable)'`" != ""
   do
      for VPN_SERVER in `ibmcloud is vpn-servers | egrep '(available|stable)' | awk '{print $1}'`
      do
         echo "      Delete vpn-server ${VPN_SERVER}"
         ibmcloud is vpn-server-delete -f ${VPN_SERVER} 1>/dev/null 2>/dev/null
      done
   done

   echo "   Look for subnets"
   while test "`ibmcloud is subnets | egrep available`" != ""
   do
      for SUBNET in `ibmcloud is subnets | egrep available | awk '{print $1}'`
      do
         echo "      Delete subnet ${SUBNET}"
         ibmcloud is subnet-delete -f ${SUBNET} 1>/dev/null 2>/dev/null
      done
   done

   GATEWAYS=`ibmcloud is public-gateways | egrep available | awk '{print $1}'`
   echo "   Look for gateways"
   while test "${GATEWAYS}" != ""
   do
      GATEWAYS=`ibmcloud is public-gateways | egrep available | awk '{print $1}'`
      for GATEWAY in ${GATEWAYS}
      do
         echo "      Delete gateway ${GATEWAY}"
         ibmcloud is public-gateway-delete -f ${GATEWAY} 1>/dev/null 2>/dev/null
      done
   done

   echo "   Look for floating IPs"
   while test "`ibmcloud is floating-ips | egrep available`" != ""
   do
      for FIP in `ibmcloud is floating-ips | egrep available | awk '{print $1}'`
      do
         echo "      Release ${FIP}"
         ibmcloud is floating-ip-release -f ${FIP} 1>/dev/null 2>/dev/null
      done
   done
   echo "   Look for VPCs"
   while test "`ibmcloud is vpcs | egrep available`" != ""
   do
      for VPC in `ibmcloud is vpcs | egrep available | awk '{print $1}'`
      do
         echo "      Delete VPC ${VPC}"
         ibmcloud is vpc-delete -f ${VPC} 1>/dev/null 2>/dev/null
      done
   done
   echo "   Look for keys"
   while test "`ibmcloud is keys | egrep rsa`" != ""
   do
      for KEY in `ibmcloud is keys | egrep rsa | awk '{print $1}'`
      do
         echo "      Delete key ${KEY}"
         ibmcloud is key-delete -f ${KEY} 1>/dev/null 2>/dev/null
      done
   done

   #echo "   Look for resourcegroups"
   #while test "`ibmcloud resource groups | egrep -v '(default|Retrieving|OK|Name|ffsdf|2024050712h15)'`" != ""
   #do
   #   for RG in `ibmcloud resource groups| egrep -v '(default|Retrieving|OK|Name|ffsdf|2024050712h15)' | awk '{print $1}'`
   #   do
   #      echo "      Delete RG ${RG}"
   #      ibmcloud resource group-delete -f ${RG} 1>/dev/null 2>/dev/null
   #   done
   #done
}

############################################################

cleanup_hpctile () {
   echo ${ESC} ""
   echo ${ESC} "${BLUE}Cleaning up${OFF}"
   echo ${ESC} "${BLUE}===========${OFF}"

   #setup_hpctile
   gnome-terminal --zoom=0.7 --geometry 90x10 -e "bash -c \"/usr/bin/watchdog.sh\"" 1>/dev/null 2>/dev/null &
   ibmcloud login -r ${REGION} -q 2>/dev/null | egrep '(Account:|User:)'
   ibmcloud target -g ${IBMCLOUD_RESOURCE_GROUP} 1>/dev/null 2>/dev/null
   ibmcloud is target --gen 2 1>/dev/null 2>/dev/null


   IP_BASTION=`ibmcloud is instances | egrep bastion  | awk '{print $5}'`
   if test "${IP_BASTION}" != ""
   then
      IP_LOGIN=`ibmcloud is instances | egrep login | awk '{print $4}'`
   else
      IP_LOGIN=`ibmcloud is instances | egrep login | awk '{print $5}'`
   fi

   IP_MGMT1=`ibmcloud is instances | egrep mgmt-1 | awk '{print $4}'`
   rm -rf /root/.ssh/known_hosts*
   if test "${IP_LOGIN}" != "" -a "${IP_MGMT1}" != ""
   then
      if test "${IP_BASTION}" != ""
      then
         DEST=${IP_BASTION}
      else
         DEST=${IP_LOGIN}
      fi
      echo "There's a login node running under ${IP_LOGIN}"
      echo "There's a mgmt node running under ${IP_MGMT1}"      
      NUM_COMPUTE=`ssh -J ubuntu@${DEST} lsfadmin@${IP_MGMT1} bhosts 2>/dev/null | egrep -v '(mgmt|HOST_NAME)' | wc -l`
      echo "There are ${NUM_COMPUTE} compute nodes running."
      if test "${NUM_COMPUTE}" != "0"
      then
         echo "Closing all queues."
         ssh -J ubuntu@${DEST} lsfadmin@${IP_MGMT1} badmin qclose all 1>/dev/null 2>/dev/null
         echo "Killing all jobs"
         ssh -J ubuntu@${DEST} lsfadmin@${IP_MGMT1} bkill -u all 0 1>/dev/null 2>/dev/null
         echo "Sleep 10 min."
         sleep 600
      fi
   fi
  echo "Look for workspaces"
   for WORKSPACE in `ibmcloud schematics workspace list 2>/dev/null | egrep ACTIVE | egrep -v INACTIVE | awk '{print $2}'`
   do
      echo "   Destroy active workspace ${WORKSPACE} (~12min.)"
      ibmcloud schematics destroy --id ${WORKSPACE} --force 1>/dev/null 2>/dev/null
      echo -n "   "
      RET=""
      while test "${RET}" = ""
      do
         echo -n "."
         sleep 10
         RET=`ibmcloud schematics workspace list 2>/dev/null | egrep ${WORKSPACE} | egrep INACTIVE`
      done
   done
   echo

   for WORKSPACE in `ibmcloud schematics workspace list 2>/dev/null | egrep '(INACTIVE|FAILED)' | awk '{print $2}'`
   do
      echo "   Delete workspace ${WORKSPACE}"
      ibmcloud schematics workspace delete --id ${WORKSPACE} --force 1>/dev/null 2>/dev/null
      echo -n "   "
      RET="x"
      while test "${RET}" = ""
      do
         echo -n "."
         sleep 10
         RET=`ibmcloud schematics workspace list | egrep ${WORKSPACE}`
      done
   done
   echo

   echo "Look for keys"
   while test "`ibmcloud is keys | egrep rsa`" != ""
   do
      for KEY in `ibmcloud is keys | egrep rsa | awk '{print $1}'`
      do
         echo "   Delete key ${KEY}"
         ibmcloud is key-delete -f ${KEY} 1>/dev/null 2>/dev/null
      done
   done
}

############################################################

refer_to_existing_instance_hpctile () {
   setup
   echo ${ESC} ""
   echo ${ESC} "${BLUE}Refer to existing instance${OFF}"
   echo ${ESC} "${BLUE}==========================${OFF}"

   IP_BASTION=`ibmcloud is instances | egrep bastion  | awk '{print $5}'`
   IP_LOGIN=`ibmcloud is instances | egrep login | awk '{print $4}'`
   IP_MGMT1=`ibmcloud is instances | egrep mgmt-1 | awk '{print $4}'`

   if test "${INSTALL_LDAP}" = "y"
   then
      IP_LDAP1=`ibmcloud is instances | egrep ldap-1 | awk '{print $4}'`
   fi
   if test "${INSTALL_VPN}" = "y"
   then
      IP_VPN=`ibmcloud is vpns | egrep stable | awk '{print $7}'`
   fi

   if test "${IP_LOGIN}" != ""
   then
      if test "${IP_BASTION}" != ""
      then
         echo "Ext. IP bastion: ${IP_BASTION}"
         echo "Int. IP login:   ${IP_LOGIN}"
         echo "Int. IP mgmt-1:  ${IP_MGMT1}"
      else
         echo "Ext. IP login:  ${IP_LOGIN}"
         echo "Int. IP mgmt-1: ${IP_MGMT1}"
      fi
      if test "${INSTALL_LDAP}" = "y"
      then
         echo "Int. IP ldap-1:  ${IP_LDAP1}"
      fi
      if test "${INSTALL_VPN}" = "y"
      then
         echo "Ext. VPN-IP:    ${IP_VPN}"
      fi
      echo
      rm -rf /root/.ssh/known_hosts*

      DESKTOP_LINK="/root/Desktop/ssh.desktop"
      cat << EOF> ${DESKTOP_LINK}
[Desktop Entry]
Type=Application
Terminal=true
Exec=ssh -J ubuntu@${IP_BASTION} lsfadmin@${IP_MGMT1}
Name=ssh
Icon=computer
EOF
      gio set ${DESKTOP_LINK} "metadata::trusted" true >/dev/null 2>&1
      chmod 755 "${DESKTOP_LINK}"
   fi
   scp -J ubuntu@${IP_BASTION} /root/install_wrapper.sh lsfadmin@${IP_MGMT1}:/tmp 1>/dev/null 2>/dev/null
   scp -J ubuntu@${IP_BASTION} /root/install_functions.sh lsfadmin@${IP_MGMT1}:/tmp 1>/dev/null 2>/dev/null
   scp -J ubuntu@${IP_BASTION} /root/run_master.sh lsfadmin@${IP_MGMT1}:/tmp 1>/dev/null 2>/dev/null
   scp -J ubuntu@${IP_BASTION} /var/environment.sh lsfadmin@${IP_MGMT1}:/tmp 1>/dev/null 2>/dev/null


   ssh -J ubuntu@${IP_BASTION} lsfadmin@${IP_MGMT1} sudo cp /tmp/install_wrapper.sh /usr/bin
   ssh -J ubuntu@${IP_BASTION} lsfadmin@${IP_MGMT1} sudo cp /tmp/install_functions.sh /usr/bin
   ssh -J ubuntu@${IP_BASTION} lsfadmin@${IP_MGMT1} sudo cp /tmp/run_master.sh /usr/bin
   ssh -J ubuntu@${IP_BASTION} lsfadmin@${IP_MGMT1} sudo cp /tmp/environment.sh /var
   ssh -J ubuntu@${IP_BASTION} lsfadmin@${IP_MGMT1} sudo /usr/bin/install_wrapper.sh
}

############################################################

new_instance_hpctile () {
   echo ${ESC} ""
   echo ${ESC} "${BLUE}Creating new instance of IBM Cloud HPC${OFF}"
   echo ${ESC} "${BLUE}======================================${OFF}"

   setup_hpctile
   #gnome-terminal --zoom=0.7 --geometry 90x10 -e "bash -c \"/usr/bin/watchdog.sh\"" 1>/dev/null 2>/dev/null &

#   SSH_KEY_NAME=`egrep ^\"ssh_key_name\" ${HPCTILE_JSON} | awk 'BEGIN{FS="\""}{print $4}'`
   echo "Creating ssh key ${SSH_KEY_NAME}"
   ibmcloud is key-create ${SSH_KEY_NAME} "${ID_RSA_PUB}" 1>/dev/null 2>/dev/null

   echo "Installing from catalog (~25min.)"
   echo "   executing 'ibmcloud target -r ${IBMCLOUD_DEFAULT_REGION} -g default'"
   ibmcloud target -r ${IBMCLOUD_DEFAULT_REGION} -g default 1>/dev/null 2>/dev/null
   echo "   executing 'ibmcloud catalog install --timeout 2700 --vl ${VERSION_LOCATOR_VALUE} --workspace-region ${IBMCLOUD_DEFAULT_REGION} --override-values ${HPCTILE_JSON}'"
   ibmcloud catalog install --timeout 2700 --vl ${VERSION_LOCATOR_VALUE} --workspace-region ${IBMCLOUD_DEFAULT_REGION} --override-values ${HPCTILE_JSON}

   RET=""
   while test "${RET}" = ""
   do
      RET=`ibmcloud schematics workspace list | egrep ACTIVE`
      sleep 30
      echo -n "."
   done
   echo

   ibmcloud login -r ${REGION} -q 1>/dev/null 2>/dev/null
   ibmcloud target -g ${IBMCLOUD_RESOURCE_GROUP} 1>/dev/null 2>/dev/null
   ibmcloud is target --gen 2 1>/dev/null 2>/dev/null

   IP_BASTION=`ibmcloud is instances | egrep bastion  | awk '{print $5}'`
   IP_LOGIN=`ibmcloud is instances | egrep login | awk '{print $4}'`
   IP_MGMT1=`ibmcloud is instances | egrep mgmt-1 | awk '{print $4}'`

   if test "${INSTALL_LDAP}" = "y"
   then
      IP_LDAP1=`ibmcloud is instances | egrep ldap-1 | awk '{print $4}'`
   fi
   if test "${INSTALL_VPN}" = "y"
   then
      IP_VPN=`ibmcloud is vpns | egrep stable | awk '{print $7}'`
   fi

   if test "${IP_LOGIN}" != ""
   then
      echo "Ext. IP bastion: ${IP_BASTION}"
      echo "Int. IP login:   ${IP_LOGIN}"
      echo "Int. IP mgmt-1:  ${IP_MGMT1}"
      if test "${INSTALL_LDAP}" = "y"
      then
         echo "Int. IP ldap-1:  ${IP_LDAP1}"
      fi
      if test "${INSTALL_VPN}" = "y"
      then
         echo "Ext. VPN-IP:    ${IP_VPN}"
      fi
      echo

#      CUSTOM_MULTICLUSTER=`egrep ^\"custom_multicluster\" ${HPCTILE_JSON} | awk 'BEGIN{FS="\""}{print $4}'`
#      MASTER_UP=`ping -c 1 ${MASTER_IP} | fgrep " 0% packet loss"`
#      if test "${CUSTOM_MULTICLUSTER}" != "" -a "${MASTER_UP}" != ""
#      then
#         echo "Handling MultiCluster"
#         CLUSTER_ID=`egrep cluster_id ${HPCTILE_JSON} | awk 'BEGIN{FS="\""}{print $4}'`
#         cat > /tmp/configure_multicluster.sh <<EOF1
##!/bin/sh
#
#LSF_SHARED="/usr/share/lsf/conf/lsf.shared"
#echo "${MY_IP} hpc-cloud master-onprem.myhpccloud.net" >> /etc/hosts
#cp \${LSF_SHARED} \${LSF_SHARED}_ORIG
#cat \${LSF_SHARED}_ORIG | sed -n 1,/"Begin Cluster"/p > \${LSF_SHARED}_MOD
#cat >> \${LSF_SHARED}_MOD <<EOF2
#ClusterName     Servers
#${CLUSTER_ID} hpc-cloud
#onprem  master-onprem
#EOF2
#cat \${LSF_SHARED}_ORIG | sed -n /"End Cluster"/,/dummy/p >> \${LSF_SHARED}_MOD
#mv \${LSF_SHARED}_MOD \${LSF_SHARED}
#
#echo "LSF_CALL_LIM_WITH_TCP=Y" >> /usr/share/lsf/conf/lsf.conf
#
#sed -i s/"QUEUE_NAME   = normal"/"QUEUE_NAME   = normal\nSNDJOBS_TO   = normal@${CLUSTER_ID}"/g /usr/share/lsf/conf/lsbatch/onprem/configdir/lsb.queues
#systemctl restart lsfd
#EOF1
#         chmod 755 /tmp/configure_multicluster.sh
#         scp /tmp/configure_multicluster.sh ${MASTER_IP}:/tmp 1>/dev/null 2>/dev/null
#         ssh ${MASTER_IP} /tmp/configure_multicluster.sh
#
#         cat > /tmp/port_forward.sh <<EOF
##!/bin/sh
#IP_LOGIN=\`ibmcloud is instances | egrep login | awk '{print \$5}'\`
#IP_MGMT1=\`ibmcloud is instances | egrep mgmt-1 | awk '{print \$4}'\`
#for PORT in 6878 6881 6882 7869
#do
#   ssh -L \${PORT}:localhost:\${PORT} -J ubuntu@\${DEST} lsfadmin@\${IP_MGMT1} sleep 86400 &
#done
#EOF
#         chmod 755 /tmp/port_forward.sh
#         /tmp/port_forward.sh &
#      fi
#

      if test "${IP_BASTION}" != ""
      then
         DEST=${IP_BASTION}
      else
         DEST=${IP_LOGIN}
      fi
      rm -rf /root/.ssh/known_hosts*

      DESKTOP_LINK="/root/Desktop/ssh.desktop"
      cat << EOF> ${DESKTOP_LINK}
[Desktop Entry]
Type=Application
Terminal=true
Exec=ssh -J ubuntu@${DEST} lsfadmin@${IP_MGMT1}
Name=ssh
Icon=computer
EOF
      gio set ${DESKTOP_LINK} "metadata::trusted" true >/dev/null 2>&1
      chmod 755 "${DESKTOP_LINK}"

      rm -rf /root/.ssh/known_hosts*
      echo "Copying install_functions.sh and install_wrapper.sh to master"
      if test "${IP_BASTION}" != ""
      then
         DEST=${IP_BASTION}
      else
         DEST=${IP_LOGIN}
      fi
      echo "Copying install_wrapper.sh install_functions.sh environment.sh to master"
      scp -J ubuntu@${DEST} /root/install_wrapper.sh lsfadmin@${IP_MGMT1}:/tmp 1>/dev/null 2>/dev/null
      scp -J ubuntu@${DEST} /root/install_functions.sh lsfadmin@${IP_MGMT1}:/tmp 1>/dev/null 2>/dev/null
      scp -J ubuntu@${DEST} /var/environment.sh lsfadmin@${IP_MGMT1}:/tmp 1>/dev/null 2>/dev/null
      ssh -J ubuntu@${DEST} lsfadmin@${IP_MGMT1}  "echo \"export ROLE=master\" >> /tmp/environment.sh"
      ssh -J ubuntu@${DEST} lsfadmin@${IP_MGMT1} sudo cp /tmp/install_wrapper.sh /usr/bin
      ssh -J ubuntu@${DEST} lsfadmin@${IP_MGMT1} sudo cp /tmp/install_functions.sh /usr/bin
      ssh -J ubuntu@${DEST} lsfadmin@${IP_MGMT1} sudo cp /tmp/environment.sh /var/environment.sh
      echo "Running install_wrapper.sh"

      ssh -J ubuntu@${DEST} lsfadmin@${IP_MGMT1} sudo "touch /var/log/install.log"
      ssh -J ubuntu@${DEST} lsfadmin@${IP_MGMT1} sudo "chmod 777 /var/log/install.log"
      gnome-terminal --zoom=0.7 --geometry 80x30 --title "install_wrapper.sh on ${VM}-${REGION}" -e "ssh -J ubuntu@${DEST} lsfadmin@${IP_MGMT1} tail -f /var/log/install.log" > /dev/null 2> /dev/null &
      ssh -J ubuntu@${DEST} lsfadmin@${IP_MGMT1} "sudo /usr/bin/install_wrapper.sh >> /var/log/install.log 2>&1" &
      ALL_DONE="N"
      while test "${ALL_DONE}" = "N"
      do
         ALL_DONE="Y"
         RES=`ssh -J ubuntu@${DEST} lsfadmin@${IP_MGMT1} "cat /tmp/STATUS 2>/dev/null"`
         if test "${RES}" != "Finished"
         then
            ALL_DONE="N"
         fi
         sleep 10
         echo -n "."
      done
      echo
      PIDS=`ps auxww | egrep "tail -f" | egrep -v grep | awk '{print $2}'`
      kill -9 ${PIDS} 1>/dev/null 2>/dev/null

#      if test "${INSTALL_LDAP}" = "y"
#      then
#         cat > /tmp/new_ldap_user.sh <<EOF1
##!/bin/sh
#
## Based upon:
## https://cloud.ibm.com/docs/allowlist/hpc-service?topic=hpc-service-create-ldap-user
#
#echo -n "Enter new username: "
#read LDAP_USER
#echo -n "Enter password: "
#read NEW_LDAP_USER_PASSWORD
#
#LAST_UID=\`ldapsearch -Q -LLL -Y EXTERNAL -H ldapi:/// | egrep uidNumber | awk '{print \$2}' | sort -n | uniq | tail -1\`
#UNIQUE_USER_ID=\`expr \${LAST_UID} + 1\`
#echo "Assigning new ID \${UNIQUE_USER_ID}"
#
#export BASE_DN="hpcaas.com"
#export OU_NAME="People"
#export LDAP_ADMIN_PASSWORD="${CUSTOM_LDAP_ADMIN_PASSWD}"
#
#SLAPDDASSWD=\`slappasswd -s "\${NEW_LDAP_USER_PASSWORD}"\`
#
#cat > /tmp/\${LDAP_USER}.ldif <<EOF2
#dn: uid=\${LDAP_USER},ou=\${OU_NAME},dc=\${BASE_DN%%.*},dc=\${BASE_DN#*.}
#objectClass: inetOrgPerson
#objectClass: posixAccount
#objectClass: shadowAccount
#uid: \${LDAP_USER}
#sn: \${LDAP_USER}
#givenName: \${LDAP_USER}
#cn: \${LDAP_USER}
#displayName: \${LDAP_USER}
#uidNumber: \${UNIQUE_USER_ID}
#gidNumber: 5000
#userPassword: \${SLAPDDASSWD}
#gecos: \${LDAP_USER}
#loginShell: /bin/bash
#homeDirectory: /home/\${LDAP_USER}
#EOF2
#
#ldapadd -x -D "cn=admin,dc=\${BASE_DN%%.*},dc=\${BASE_DN#*.}" -w "\${LDAP_ADMIN_PASSWORD}" -f "/tmp/\${LDAP_USER}.ldif"
#EOF1
#         chmod 755 /tmp/new_ldap_user.sh
#
#         echo "Copying new_ldap_user.sh to ldap"
#         scp -J ubuntu@${DEST} /tmp/new_ldap_user.sh ubuntu@${IP_LDAP1}:/home/ubuntu/new_ldap_user.sh 1>/dev/null 2>/dev/null
#      fi
#      echo
#      echo "Executing install_wrapper.sh on master"
#      ssh -J ubuntu@${DEST} lsfadmin@${IP_MGMT1} /tmp/install_wrapper.sh
#      #echo "Removing values.json on master"
#      #ssh -J ubuntu@${DEST} lsfadmin@${IP_MGMT1} rm -rf ${HPCTILE_JSON}
#      echo
#      echo "E.g. ssh -J ubuntu@${DEST} lsfadmin@${IP_MGMT1}"
#      echo "E.g. scp -J ubuntu@${DEST} /tmp/test.txt lsfadmin@${IP_MGMT1}:/tmp"
#      echo
#
#      APPCENTER_TRUE=`egrep ^\"enable_app_center\" ${HPCTILE_JSON} | egrep true`
#      if test "${APPCENTER_TRUE}" != ""
#      then
#         echo "AppCenter: ssh -L 8443:localhost:8443 -J ubuntu@${DEST} lsfadmin@${IP_MGMT1}"
#         echo "           firefox https://localhost:8443"
#         cat > /usr/bin/run_applicationcenter.sh <<EOF
##!/bin/sh
#ssh -L 8443:localhost:8443 -J ubuntu@${DEST} lsfadmin@${IP_MGMT1} sleep 86400 &
#sleep 5
#firefox https://localhost:8443
#EOF
#         chmod 755 /usr/bin/run_applicationcenter.sh
#         DESKTOP_LINK="/root/Desktop/applicationcenter.desktop"
#         cat << EOF> ${DESKTOP_LINK}
#[Desktop Entry]
#Type=Application
#Terminal=false
#Exec=/usr/bin/run_applicationcenter.sh
#Name=AppCenter
#Icon=firefox
#EOF
#         gio set ${DESKTOP_LINK} "metadata::trusted" true >/dev/null 2>&1
#         chmod 755 "${DESKTOP_LINK}"
#      fi
#
#      GUACAMOLE_TRUE=`egrep ^\"custom_guacamole\" ${HPCTILE_JSON} | awk 'BEGIN{FS="\""}{print $4}'`
#      if test "${GUACAMOLE_TRUE}" != ""
#      then
#         echo "Guacamole: ssh -L 8080:localhost:8080 -J ubuntu@${DEST} lsfadmin@${IP_MGMT1}"
#         echo "           firefox http://localhost:8080"
#         cat > /usr/bin/run_guacamole.sh <<EOF
##!/bin/sh
#PID=\`ps auxww | egrep "ssh -L 8080" | egrep -v grep | awk '{print \$2}'\`
#kill -9 \${PID} 1>/dev/null 2>/dev/null
#ssh -L 8080:localhost:8080 -J ubuntu@${DEST} lsfadmin@${IP_MGMT1} sleep 86400 &
#sleep 5
#firefox http://localhost:8080
#EOF
#         chmod 755 /usr/bin/run_guacamole.sh
#         DESKTOP_LINK="/root/Desktop/guacamole.desktop"
#         cat << EOF> ${DESKTOP_LINK}
#[Desktop Entry]
#Type=Application
#Terminal=false
#Exec=/usr/bin/run_guacamole.sh
#Name=guacamole
#Icon=firefox
#EOF
#         gio set ${DESKTOP_LINK} "metadata::trusted" true >/dev/null 2>&1
#         chmod 755 "${DESKTOP_LINK}"
#      fi
#
#      RDP_TRUE=`egrep ^\"custom_rdp\" ${HPCTILE_JSON} | awk 'BEGIN{FS="\""}{print $4}'`
#      if test "${RDP_TRUE}" != ""
#      then
#         echo "RDP:       ssh -L 3389:localhost:3389 -J ubuntu@${DEST} lsfadmin@${IP_MGMT1}"
#         echo "           rdesktop -k de -r clipboard:no -u lsfadmin -p ${DEFAULT_CUSTOM_RDP_PASSWD} localhost"
#         cat > /usr/bin/run_rdp.sh <<EOF
##!/bin/sh
#ssh -L 3389:localhost:3389 -J ubuntu@${DEST} lsfadmin@${IP_MGMT1} sleep 86400 &
#sleep 5
#echo "yes" | rdesktop -k de -r clipboard:no -u lsfadmin -p ${DEFAULT_CUSTOM_RDP_PASSWD} localhost
#EOF
#         chmod 755 /usr/bin/run_rdp.sh
#         DESKTOP_LINK="/root/Desktop/RDP.desktop"
#         cat << EOF> ${DESKTOP_LINK}
#[Desktop Entry]
#Type=Application
#Terminal=false
#Exec=/usr/bin/run_rdp.sh
#Name=RDP
#Icon=preferences-desktop-remote-desktop
#EOF
#         gio set ${DESKTOP_LINK} "metadata::trusted" true >/dev/null 2>&1
#         chmod 755 "${DESKTOP_LINK}"
#      fi
#      if test "${INSTALL_LDAP}" = "y"
#      then
#         echo "LDAP:           ssh -J ubuntu@${DEST} ubuntu@${IP_LDAP1}"
#         echo "New LDAP user:  ssh -J ubuntu@${DEST} ubuntu@${IP_LDAP1} /home/ubuntu/new_ldap_user.sh"
#      fi














   else
      echo "Look at https://cloud.ibm.com/schematics/workspaces"
   fi
}

############################################################

create_access_postboot_service () {
   cat > /tmp/access.sh <<EOF
#!/bin/sh
sleep 10
egrep -v '(PasswordAuthentication|PermitRootLogin)' /etc/ssh/sshd_config > /etc/ssh/sshd_config_NEW
mv /etc/ssh/sshd_config_NEW /etc/ssh/sshd_config
echo "PasswordAuthentication yes" >> /etc/ssh/sshd_config
echo "PermitRootLogin yes" >> /etc/ssh/sshd_config
chmod 600 /etc/ssh/sshd_config
systemctl restart sshd
echo "${ROOTPWD}" | passwd --stdin root
mkdir -p /root/.ssh
echo "${ID_RSA_PRIV_BASE64}" | base64 -d > /root/.ssh/id_rsa
chmod 600 /root/.ssh/id_rsa
echo "${ID_RSA_PUB_BASE64}" | base64 -d > /root/.ssh/id_rsa.pub
chmod 644 /root/.ssh/id_rsa.pub
cp /root/.ssh/id_rsa.pub /root/.ssh/authorized_keys
chmod 600 /root/.ssh/authorized_keys
EOF
   chmod 755 /tmp/access.sh

   cat > /tmp/postboot.service <<EOF
[Unit]
After=network.target nfs.service sshd.service
[Service]
RemainAfterExit=yes
ExecStart=/usr/bin/postboot.sh
StandardOutput=syslog
StandardError=syslog
SyslogIdentifier=postboot
[Install]
WantedBy=multi-user.target
EOF

   cat > /tmp/postboot.conf <<EOF
if \$programname == 'postboot' then /var/log/postboot.log
& stop
EOF
}

create_terraform_files () {
   REGION=`echo $* | awk 'BEGIN{FS="@"}{print $2}'`
   TEMPLATES=`echo $* | awk 'BEGIN{FS="@"}{print $3}'`
   echo "Create Terraform files in region ${REGION} for template(s) ${TEMPLATES}"
   cat > /etc/sysctl.d/70-ipv6.conf <<EOF
net.ipv6.conf.all.disable_ipv6 = 1
net.ipv6.conf.default.disable_ipv6 = 1
EOF
   sysctl --load /etc/sysctl.d/70-ipv6.conf 1>/dev/null 2>/dev/null
   MYEXTERNALIP=""
   while test "${MYEXTERNALIP}" = ""
   do
      MYEXTERNALIP=`curl ifconfig.me 2>/dev/null`
      sleep 5
   done
   case $ACTION in
   Setup_nodes_Terraform)
      USE_IPS="${MYEXTERNALIP}"
   ;;
   Start_nodes_Terraform)
      USE_IPS="${ALLOWED_IP_ADDRESSES}"
      if test "${ADD_MYEXTERNALIP_AT_START}" = "Y"
      then
         USE_IPS="${USE_IPS} ${MYEXTERNALIP}"
      fi
   ;;
   esac

   for REGION in ${REGION}
   do
      ibmcloud target -r ${REGION} 1>/dev/null
      mkdir -p ${TF_WORKDIR}/${REGION}_create
      echo "Create Terraform file ${TF_WORKDIR}/${REGION}_create/main.tf"
      cat > ${TF_WORKDIR}/${REGION}_create/main.tf <<EOF
terraform {
    required_providers {
        ibm = {
        source = "IBM-Cloud/ibm"
        }
    }
}
provider "ibm" {
  region             = "${REGION}"
}
EOF
      DEF_EXISTS=`ibmcloud is vpcs | egrep available | egrep scale | awk '{print $2}' | sed s/"-vpc"//g`
      if  test "${DEF_EXISTS}" = ""
      then 
         VPCID="ibm_is_vpc.${DEFNAME}-vpc.id"
         SSHKEYID="ibm_is_ssh_key.${DEFNAME}-ssh.id"
         SUBNETID="ibm_is_subnet.${DEFNAME}-subnet.id"

         if test "${IBMCLOUD_RESOURCE_GROUP}" != ""
         then
            RESOURCEGROUPID="\"`ibmcloud resource groups | egrep geo-cwe | awk '{print $2}'`\""
         else
            RESOURCEGROUPID="ibm_resource_group.${DEFNAME}-rg.id"
         fi
         SECURITYGROUPID="ibm_is_security_group.${DEFNAME}-sg.id"

         if test "${IBMCLOUD_RESOURCE_GROUP}" = ""
         then
            cat >> ${TF_WORKDIR}/${REGION}_create/main.tf <<EOF

resource "ibm_resource_group" "${DEFNAME}-rg" {
  name     = "${DEFNAME}-rg"
}

EOF
         fi


         cat >> ${TF_WORKDIR}/${REGION}_create/main.tf <<EOF
resource "ibm_is_vpc" "${DEFNAME}-vpc" {
  name = "${DEFNAME}-vpc"
  resource_group = ${RESOURCEGROUPID}
  tags = [ "${DEFNAME}-vpc" ]
}

resource "ibm_is_ssh_key" "${DEFNAME}-ssh" {
  name       = "${DEFNAME}-ssh"
  resource_group = ${RESOURCEGROUPID}
  public_key = "${PUBLIC_KEY}"
}

resource "ibm_is_subnet" "${DEFNAME}-subnet" {
  name            = "${DEFNAME}-subnet"
  vpc             = ${VPCID}
  zone            = "${REGION}-1"
  ipv4_cidr_block = "${CIDR}"
  tags = [ "${DEFNAME}-subnet" ]
  resource_group = ${RESOURCEGROUPID}
}

resource "ibm_is_security_group" "${DEFNAME}-sg" {
  name = "${DEFNAME}-sg"
  vpc  = ${VPCID}
  resource_group = ${RESOURCEGROUPID}
}

resource "ibm_is_public_gateway" "${DEFNAME}-public-gateway" {
  name = "${DEFNAME}-public-gateway"
  vpc  = ${VPCID}
  zone = "${REGION}-1"
  resource_group = ${RESOURCEGROUPID}
}

resource "ibm_is_subnet_public_gateway_attachment" "${DEFNAME}-attachment" {
  subnet                = ${SUBNETID}
  public_gateway         = ibm_is_public_gateway.${DEFNAME}-public-gateway.id
}

EOF
     else
         echo
         echo "Found existing ${DEF_EXISTS}"
         DEFNAME="${DEF_EXISTS}"
         VPCID=`ibmcloud is vpcs | egrep available | egrep scale | awk '{print $1}'`
         VPCID="\"${VPCID}\""
         echo "   Existing VPCID ${VPCID}"
         SSHKEYID=`ibmcloud is keys | egrep rsa | awk '{print $1}'`
         SSHKEYID="\"${SSHKEYID}\""
         echo "   Existing SSHKEYID ${SSHKEYID}"
         SUBNETID=`ibmcloud is subnets | egrep scale | egrep comp | awk '{print $1}'`
         SUBNETID="\"${SUBNETID}\""
         echo "   Existing SUBNETID ${SUBNETID}"
         RESOURCEGROUPID=`ibmcloud resource groups | egrep def- | sort | tail -1 | awk '{print $2}'`
         RESOURCEGROUPID="\"${RESOURCEGROUPID}\""
         echo "   Existing RESOURCEGROUPID ${RESOURCEGROUPID}"

         SECURITYGROUPID=`ibmcloud is security-groups | egrep scale | egrep storage | awk '{print $1}'`
         SECURITYGROUPID="\"${SECURITYGROUPID}\""
         echo "   Existing SECURITYGROUPID ${SECURITYGROUPID}"
      fi

      CNT=1
      for port in $TCP_PORTS
      do
         if test "`echo $port | fgrep '-'`" != ""
         then
            minport=`echo $port | awk 'BEGIN{FS="-"}{print $1}'`
            maxport=`echo $port | awk 'BEGIN{FS="-"}{print $2}'`
         else
            minport=$port
            maxport=$port
         fi
          cat >> ${TF_WORKDIR}/${REGION}_create/main.tf <<EOF
resource "ibm_is_security_group_rule" "${DEFNAME}-rule-tcp-${CNT}" {
  group     = ${SECURITYGROUPID}
  direction = "inbound"
  remote   = "${CIDR}"
  tcp {
    port_min = $minport
    port_max = $maxport
  }
}
EOF
         CNT=`expr $CNT + 1`
      done
      CNT=1
      for port in $UDP_PORTS
      do
         if test "`echo $port | fgrep '-'`" != ""
         then
            minport=`echo $port | awk 'BEGIN{FS="-"}{print $1}'`
            maxport=`echo $port | awk 'BEGIN{FS="-"}{print $2}'`
         else
            minport=$port
            maxport=$port
         fi
         cat >> ${TF_WORKDIR}/${REGION}_create/main.tf <<EOF
resource "ibm_is_security_group_rule" "${DEFNAME}-rule-udp-${CNT}" {
  group     = ${SECURITYGROUPID}
  direction = "inbound"
  remote   = "${CIDR}"
  udp {
    port_min = $minport
    port_max = $maxport
  }
}
EOF
         CNT=`expr $CNT + 1`
      done
      # ICMP
      cat >> ${TF_WORKDIR}/${REGION}_create/main.tf <<EOF
resource "ibm_is_security_group_rule" "${DEFNAME}-rule-icmp" {
  group     = ${SECURITYGROUPID}
  direction = "inbound"
  remote   = "${CIDR}"
  icmp {
  }
}
EOF
      cat >> ${TF_WORKDIR}/${REGION}_create/main.tf <<EOF
resource "ibm_is_security_group_rule" "${DEFNAME}-rule-vpn" {
  group     = ${SECURITYGROUPID}
  direction = "inbound"
  udp {
    port_min = 443
    port_max = 443
  }
}
EOF
      for ip in ${USE_IPS}
      do
         CNT=1
         cat >> ${TF_WORKDIR}/${REGION}_create/main.tf <<EOF
resource "ibm_is_security_group_rule" "${DEFNAME}-rule-allowed-ip-${CNT}" {
  group     = ${SECURITYGROUPID}
  direction = "inbound"
  remote     = "${ip}"
}
EOF
         CNT=`expr $CNT + 1`
      done
      cat >> ${TF_WORKDIR}/${REGION}_create/main.tf <<EOF
resource "ibm_is_security_group_rule" "${DEFNAME}-rule-outbound" {
  group     = ${SECURITYGROUPID}
  direction = "outbound"
}
EOF
      if test "${TCP_PORT}" != "" -o "${TCP_PORT}" != ""
      then
         cat >> ${TF_WORKDIR}/${REGION}_create/main.tf <<EOF
resource "ibm_is_security_group_rule" "${DEFNAME}-rule-icmp" {
  group      = ${SECURITYGROUPID}
  direction  = "inbound"
  icmp {
  }
}
EOF
      fi

      if test "`echo ${ADD_ONS} | egrep VPN-S2S`" != "" -a "${ACTION}" = "Start_nodes_Terraform"
      then
         cat >> ${TF_WORKDIR}/${REGION}_create/main.tf <<EOF
resource "ibm_is_vpn_gateway" "${DEFNAME}-vpn-gateway" {
  name   = "${DEFNAME}-vpn-gateway"
  subnet = ${SUBNETID}
  mode   = "policy"
}

resource "ibm_is_vpn_gateway_connection" "${DEFNAME}-vpn-gateway-connection" {
  name           = "${DEFNAME}-vpn-gateway-connection"
  vpn_gateway    = ibm_is_vpn_gateway.${DEFNAME}-vpn-gateway.id
  peer_address   = ibm_is_vpn_gateway.${DEFNAME}-vpn-gateway.public_ip_address
  preshared_key  = "${ROOTPWD}"
  local_cidrs    = [ibm_is_subnet.${DEFNAME}-subnet.ipv4_cidr_block]
  peer_cidrs     = ["${VPN_CIDR}"]
  admin_state_up = "true"
}

EOF
      fi

      if test "`echo ${ADD_ONS} | egrep VPN-C2S`" != "" -a "${ACTION}" = "Start_nodes_Terraform"
      then
         cat >> ${TF_WORKDIR}/${REGION}_create/main.tf <<EOF

# Based upon:
# https://cloud.ibm.com/docs/secrets-manager?topic=secrets-manager-root-certificate-authorities&interface=terraform

resource "ibm_resource_instance" "${DEFNAME}-secrets-manager" {
  name =   "${DEFNAME}-secrets-manager"
  service  = "secrets-manager"
  plan     = "trial"
  location = "${REGION}"
  timeouts {
    create = "20m"
  }
}

resource "ibm_sm_secret_group" "${DEFNAME}_secret_group" {
  instance_id = ibm_resource_instance.${DEFNAME}-secrets-manager.guid
  region      = "${REGION}"
  name        = "${DEFNAME}_secret_group"
}

resource "ibm_sm_private_certificate_configuration_root_ca" "${DEFNAME}-private-certificate-root-CA" {
  instance_id                       = ibm_resource_instance.${DEFNAME}-secrets-manager.guid
  region                            = "${REGION}"
  name                              = "my_root_CA"
  common_name                       = "root.ibm.com"
  max_ttl                           = "8760h"
  max_path_length                   = 1
  organization                      = ["IBM"]
  country                           = ["DE"]
  crl_distribution_points_encoded   = false
  crl_disable                       = false
  issuing_certificates_urls_encoded = true
}

resource "ibm_sm_private_certificate_configuration_intermediate_ca" "${DEFNAME}-intermediate-CA" {
  instance_id                       = ibm_resource_instance.${DEFNAME}-secrets-manager.guid
  name                              = "my_intermediate_CA"
  common_name                       = "ibm.com"
  signing_method                    = "internal"
  issuer                            = ibm_sm_private_certificate_configuration_root_ca.${DEFNAME}-private-certificate-root-CA.name
  organization                      = ["IBM"]
  country                           = ["DE"]
  max_ttl                           = "8760h"
  crl_distribution_points_encoded   = false
  crl_disable                       = false
  issuing_certificates_urls_encoded = true
}

resource "ibm_sm_private_certificate_configuration_template" "${DEFNAME}-certificate-template" {
  instance_id           = ibm_resource_instance.${DEFNAME}-secrets-manager.guid
  region                = "${REGION}"
  name                  = "my_template"
  certificate_authority = ibm_sm_private_certificate_configuration_intermediate_ca.${DEFNAME}-intermediate-CA.name
  organization          = ["IBM"]
  country               = ["DE"]
  allow_any_name        = true
  client_flag           = true
  server_flag           = true
}

resource "ibm_sm_private_certificate" "${DEFNAME}-private-certificate" {  
  instance_id          = ibm_resource_instance.${DEFNAME}-secrets-manager.guid
  region               = "${REGION}"
  name                 = "private-certificate"
  common_name          = "my.example.com"
  certificate_template = ibm_sm_private_certificate_configuration_template.${DEFNAME}-certificate-template.name
  ttl                  = "90d"
}

resource "ibm_is_vpn_server" "${DEFNAME}-vpn-server" {
  certificate_crn = ibm_sm_private_certificate.${DEFNAME}-private-certificate.crn
  client_authentication {
    method    = "certificate"
    client_ca_crn = ibm_sm_private_certificate.${DEFNAME}-private-certificate.crn
  }
  client_ip_pool         = "${VPN_CIDR}"
  client_idle_timeout    = 2800
  enable_split_tunneling = true
  name                   = "vpn-server"
  port                   = 443
  protocol               = "udp"
  subnets                = [${SUBNETID}]
  security_groups        = [${SECURITYGROUPID}]
}

resource "ibm_is_vpn_server_route" "${DEFNAME}-vpn-route" {
  name        = "vpn-server-route"
  vpn_server  = ibm_is_vpn_server.${DEFNAME}-vpn-server.id
  action      = "translate"
EOF
         case ${REGION} in
         eu-de)
            cat >> ${TF_WORKDIR}/${REGION}_create/main.tf <<EOF
  destination = "10.243.0.0/19"
EOF
         ;;
         eu-es)
            cat >> ${TF_WORKDIR}/${REGION}_create/main.tf <<EOF
  destination = "10.251.32.0/19"
EOF
         ;;
         eu-gb)
            cat >> ${TF_WORKDIR}/${REGION}_create/main.tf <<EOF
  destination = "10.242.0.0/19"
EOF
         ;;
         us-east)
            cat >> ${TF_WORKDIR}/${REGION}_create/main.tf <<EOF
  destination = "10.241.0.0/19"
EOF
         ;;
         us-south)
            cat >> ${TF_WORKDIR}/${REGION}_create/main.tf <<EOF
  destination = "10.240.0.0/19"
EOF
         ;;
         esac
         cat >> ${TF_WORKDIR}/${REGION}_create/main.tf <<EOF
}
EOF
      fi

      if test "`echo ${ADD_ONS} | egrep Monitoring`" != "" -a "${ACTION}" = "Start_nodes_Terraform"
      then
         cat >> ${TF_WORKDIR}/${REGION}_create/main.tf <<EOF
resource "ibm_resource_instance" "${DEFNAME}-monitoring-instance" {
  name = "${DEFNAME}-monitoring-instance"
  service = "sysdig-monitor"
  plan = "lite"
  location = "${REGION}"
  tags = ["monitoring", "public"]
  parameters = {
    default_receiver= true
  }
}

#module "cluster_sysdig_attach" {
#  source = "terraform-ibm-modules/cluster/ibm//modules/configure-sysdig-monitor"
#  cluster            = var.cluster
#  sysdig_instance_id = data.ibm_resource_instance.resource_instance.guid
#  private_endpoint   = var.private_endpoint
#  sysdig_access_key  = var.sysdig_access_key
#  create_timeout       = var.create_timeout
#  update_timeout       = var.update_timeout
#  delete_timeout       = var.delete_timeout
#}

EOF
      fi
      for VM in ${TEMPLATES}
      do
         case ${ACTION} in
         Setup_nodes_Terraform)
            IMG_ID=`ibmcloud is images | egrep ${IBMCLOUD_IMAGE} | awk '{print $1}'`
            if test "${IMG_ID}" = ""
            then
               echo "ERROR, can't get IMG_ID for ${IBMCLOUD_IMAGE}"
               exit
            fi
         ;;
         Start_nodes_Terraform)
            LATEST=`ibmcloud is images | egrep ${VM}-${REGION} | awk '{print $2}' | sort -n | tail -1`
            echo
            echo "Found latest image ${LATEST}"
            echo
            IMG_ID=`ibmcloud is images | egrep ${LATEST} | awk '{print $1}'`
            if test "${IMG_ID}" = ""
            then
               echo "ERROR, can't get IMG_ID for ${LATEST}"
               exit
            fi
            if test "${IBM_BLOCKSTORAGE_SIZE}" != "0" -a "${VM}" = "master"
            then
               cat >> ${TF_WORKDIR}/${REGION}_create/main.tf <<EOF
 
resource "ibm_is_instance_volume_attachment" "${DEFNAME}-blockstorage" {
  instance = ibm_is_instance.${DEFNAME}-instance-master.id
  name                               = "${DEFNAME}-blockstorage"
  profile                            = "general-purpose"
  capacity                           = "${IBM_BLOCKSTORAGE_SIZE}"
  delete_volume_on_attachment_delete = true
  delete_volume_on_instance_delete   = true
  volume_name                        = "${DEFNAME}-blockstorage"
}
EOF
            fi
         ;;
         esac

         TYPE=`eval echo \\$SPEC_${VM}_IBM_TYPE`

         cat >> ${TF_WORKDIR}/${REGION}_create/main.tf <<EOF
resource "ibm_is_floating_ip" "${DEFNAME}-fip-${VM}" {
  name   = "${DEFNAME}-fip-${VM}"
  resource_group = ${RESOURCEGROUPID}
  target = ibm_is_instance.${DEFNAME}-instance-${VM}.primary_network_interface[0].id
}

resource "ibm_is_instance" "${DEFNAME}-instance-${VM}" {
  name    = "${VM}-${REGION}"
  image = "${IMG_ID}"
  profile = "${TYPE}"
  resource_group = ${RESOURCEGROUPID}
  primary_network_interface {
    subnet = ${SUBNETID}
    security_groups = [${SECURITYGROUPID}]
    allow_ip_spoofing = true
  }

  vpc  = ${VPCID}
  zone = "${REGION}-1"
  keys = [${SSHKEYID}]

}
EOF
         if test "${USE_IPS}" != ""
         then
            cat >> ${TF_WORKDIR}/${REGION}_create/main.tf <<EOF
output "ip-${VM}-${REGION}" {
  value =  ibm_is_floating_ip.${DEFNAME}-fip-${VM}.address
}
output "id-${VM}-${REGION}" {
  value = ibm_is_instance.${DEFNAME}-instance-${VM}.id
}

EOF
         fi
      done
      if test "${ACTION}" = "Start_nodes_Terraform" -a "${NUM_STATIC_BAREMETAL}" != 0
      then
         VM="baremetal"
         LATEST=`ibmcloud is images | egrep compute-${REGION} | awk '{print $2}' | sort -n | tail -1`
         echo
         echo "Found latest image ${LATEST}"
         echo
         IMG_ID=`ibmcloud is images | egrep ${LATEST} | awk '{print $1}'`
         if test "${IMG_ID}" = ""
         then
            echo "ERROR, can't get IMG_ID for ${LATEST}"
            exit
         fi

         TYPE=`eval echo \\$SPEC_${VM}_IBM_TYPE`
         CNT=${NUM_STATIC_BAREMETAL}
         while test "${CNT}" -gt 0
         do
            cat >> ${TF_WORKDIR}/${REGION}_create/main.tf <<EOF
resource "ibm_is_bare_metal_server" "${DEFNAME}-instance-${VM}-${CNT}" {
  name    = "${VM}-${CNT}-${REGION}"
  image = "${IMG_ID}"
  profile = "${TYPE}"
  resource_group = ${RESOURCEGROUPID}

  primary_network_interface {
    subnet = ${SUBNETID}
    security_groups = [${SECURITYGROUPID}]
    allow_ip_spoofing = true
    enable_infrastructure_nat = true
  }

  vpc  = ${VPCID}
  zone = "${REGION}-1"
  keys = [${SSHKEYID}]

}
EOF
            CNT=`expr $CNT - 1`
         done
      fi

      if test "${ACTION}" = "Start_nodes_Terraform" -a "${NUM_STATIC_COMPUTE}" != 0
      then
         VM="compute"
         LATEST=`ibmcloud is images | egrep ${VM}-${REGION} | awk '{print $2}' | sort -n | tail -1`
         echo
         echo "Found latest image ${LATEST}"
         echo
         IMG_ID=`ibmcloud is images | egrep ${LATEST} | awk '{print $1}'`
         if test "${IMG_ID}" = ""
         then
            echo "ERROR, can't get IMG_ID for ${LATEST}"
            exit
         fi

         TYPE=`eval echo \\$SPEC_${VM}_IBM_TYPE`
         CNT=${NUM_STATIC_COMPUTE}
         while test "${CNT}" -gt 0
         do
            cat >> ${TF_WORKDIR}/${REGION}_create/main.tf <<EOF
# NO external IP for compute:
#resource "ibm_is_floating_ip" "${DEFNAME}-fip-${VM}-${CNT}" {
#  name   = "${DEFNAME}-fip-${VM}-${CNT}"
#  target = ibm_is_instance.${DEFNAME}-instance-${VM}-${CNT}.primary_network_interface[0].id
#}

resource "ibm_is_instance" "${DEFNAME}-instance-${VM}-${CNT}" {
  name    = "${VM}-${CNT}-${REGION}"
  image = "${IMG_ID}"
  profile = "${TYPE}"
  resource_group = ${RESOURCEGROUPID}

  primary_network_interface {
    subnet = ${SUBNETID}
    security_groups = [${SECURITYGROUPID}]
    allow_ip_spoofing = true
  }

  vpc  = ${VPCID}
  zone = "${REGION}-1"
  keys = [${SSHKEYID}]
}

# NO external IP for compute:
#output "ip-${VM}-${CNT}-${REGION}" {
#  value =  ibm_is_floating_ip.${DEFNAME}-fip-${VM}-${CNT}.address
#}
output "id-${VM}-${CNT}-${REGION}" {
  value = ibm_is_instance.${DEFNAME}-instance-${VM}-${CNT}.id
}

EOF
            CNT=`expr $CNT - 1`
         done
      fi









   done
}

apply_terraform_files () {
   REGION=`echo $* | awk 'BEGIN{FS="@"}{print $2}'`
   echo "Apply Terraform files in region ${REGION}"
   echo "   Apply Terraform file ${TF_WORKDIR}/${REGION}_create/main.tf"
   gnome-terminal --title "terraform apply ${REGION}" --zoom=0.7 --geometry 125x35 --title "terraform apply ${REGION}" -e "bash -c \"echo ${ESC} \\\"\033]11;#DDFFFF\007\\\" ; cd ${TF_WORKDIR}/${REGION}_create ; terraform init ; terraform apply -auto-approve ; sleep 60\"" > /dev/null 2> /dev/null &
}

wait_all_nodes_up () {
   REGION=`echo $* | awk 'BEGIN{FS="@"}{print $2}'`
   TEMPLATES=`echo $* | awk 'BEGIN{FS="@"}{print $3}'`

# Don't wait for compute nodes, as they will have no external IP
#   if test "${NUM_STATIC_COMPUTE}" != 0 -a "${ACTION}" = "Start_nodes_Terraform"
#   then
#      VM="compute"
#      CNT="${NUM_STATIC_COMPUTE}"
#      while test "${CNT}" -gt 0
#      do
#         TEMPLATES="${TEMPLATES} ${VM}-${CNT}"
#         CNT=`expr $CNT - 1`
#      done
#   fi

   if test "${USE_IPS}" != ""
   then
      echo "Waiting for all nodes up"
      ALL_UP="n"
      while test "${ALL_UP}" = "n"
      do
         ALL_UP="y"
         cd ${TF_WORKDIR}/${REGION}_create
         for VM in ${TEMPLATES}
         do
            IP=`terraform output ip-${VM}-${REGION} 2>/dev/null | sed s/"\""//g`
            RET=`timeout 15 ssh root@${IP} uname -a 2>/dev/null | egrep Linux`
            if test "${RET}" = ""
            then
               ALL_UP="n"
            fi
         done
         sleep 5
         echo -n "."
      done
      echo

      cd ${TF_WORKDIR}/${REGION}_create
      for VM in ${TEMPLATES}
      do
         IP=`terraform output ip-${VM}-${REGION} 2>/dev/null | sed s/"\""//g`
         ID=`terraform output id-${VM}-${REGION} 2>/dev/null | sed s/"\""//g`
         echo "${VM}-${REGION}: ${IP} ${ID}"
      done
      echo
      echo "All VMs are up and running now."
      echo
   fi
}

run_install_on_all_VMs () {
   REGION=`echo $* | awk 'BEGIN{FS="@"}{print $2}'`
   TEMPLATES=`echo $* | awk 'BEGIN{FS="@"}{print $3}'`

   echo "Running install_wrapper.sh on all VMs"
   cd ${TF_WORKDIR}/${REGION}_create
   for VM in ${TEMPLATES}
   do
      IP=`terraform output ip-${VM}-${REGION} 2>/dev/null | sed s/"\""//g`
      scp ${ENVIRONMENT_SH} root@${IP}:${ENVIRONMENT_SH} 1>/dev/null 2>/dev/null
      scp /root/install_functions.sh root@${IP}:/usr/bin/install_functions.sh 1>/dev/null 2>/dev/null
      scp /root/install_wrapper.sh root@${IP}:/usr/bin/install_wrapper.sh 1>/dev/null 2>/dev/null
      if test -f "${CUSTOM_BACKGROUND_IMAGE}"
      then
         scp ${CUSTOM_BACKGROUND_IMAGE} root@${IP}:/var/custom_image.jpg 1>/dev/null 2>/dev/null
      fi
      ssh root@${IP} "echo \"export REGION=\\\"${REGION}\\\"\" >> ${ENVIRONMENT_SH}"
      ssh root@${IP} "echo \"export ROLE=\\\"${VM}\\\"\" >> ${ENVIRONMENT_SH}"
      if test "${CLUSTERNAME}" = ""
      then
         ssh root@${IP} "echo \"export CLUSTERNAME=\\\"${REGION}\\\"\" >> ${ENVIRONMENT_SH}"
      else
         ssh root@${IP} "echo \"export CLUSTERNAME=\\\"${CLUSTERNAME}\\\"\" >> ${ENVIRONMENT_SH}"
      fi
      ssh root@${IP} "echo \"export MYHOSTNAME=\\\"${VM}-${REGION}\\\"\" >> ${ENVIRONMENT_SH}"
      ssh root@${IP} "touch /var/log/install.log"
      gnome-terminal --zoom=0.7 --geometry 80x30 --title "install_wrapper.sh on ${VM}-${REGION}" -e "bash -c \"ssh root@${IP} tail -f /var/log/install.log\"" > /dev/null 2> /dev/null &
      scp /root/postboot.sh root@${IP}:/usr/bin/postboot.sh 1>/dev/null 2>/dev/null
      scp /tmp/postboot.service root@${IP}:/usr/lib/systemd/system/postboot.service 1>/dev/null 2>/dev/null
      scp /tmp/postboot.conf root@${IP}:/etc/rsyslog.d/postboot.conf 1>/dev/null 2>/dev/null
      ssh root@${IP} systemctl enable postboot 1>/dev/null 2>/dev/null
      ssh root@${IP} "/usr/bin/install_wrapper.sh > /var/log/install.log 2>&1" &
   done

   ALL_DONE="N"
   while test "${ALL_DONE}" = "N"
   do
      ALL_DONE="Y"
      cd ${TF_WORKDIR}/${REGION}_create
      for VM in ${TEMPLATES}
      do
         IP=`terraform output ip-${VM}-${REGION} 2>/dev/null | sed s/"\""//g`
         RES=`ssh root@${IP} cat /tmp/STATUS 2>/dev/null`
         if test "${RES}" != "Finished"
         then
            ALL_DONE="N"
         fi
      done
      sleep 10
      echo -n "."
   done
   echo
   echo "All install scripts are done."
}

save_images () {
   rm -rf /tmp/save_*
   REGION=`echo $* | awk 'BEGIN{FS="@"}{print $2}'`
   TEMPLATES=`echo $* | awk 'BEGIN{FS="@"}{print $3}'`
   echo "Saving images"

   cd ${TF_WORKDIR}/${REGION}_create
   for VM in ${TEMPLATES}
   do
      cat > /tmp/save_${VM}-${REGION}-${DATE}.sh <<EOF
#!/bin/sh
export IBMCLOUD_API_KEY="${IBMCLOUD_API_KEY}"
export IBMCLOUD_RESOURCE_GROUP="${IBMCLOUD_RESOURCE_GROUP}"
cd ${TF_WORKDIR}/${REGION}_create
ID=\`terraform output id-${VM}-${REGION} | sed s/"\""//g\`
echo "Stopping ${VM}-${REGION} with ID ${ID}"

ibmcloud login -r ${REGION} -q 1>/dev/null 2>/dev/null
ibmcloud target -g ${IBMCLOUD_RESOURCE_GROUP} 1>/dev/null 2>/dev/null
ibmcloud is target --gen 2 1>/dev/null 2>/dev/null
echo -n "VM stopping"
RET="1"
while test \${RET} != "0"
do
   ibmcloud is instance-stop -f \${ID} 1>/dev/null 2>/dev/null
   RET=\$?
   echo -n "."
   sleep 5
done
echo

echo -n "Wait for VM stopped"
while test "\`ibmcloud is instances 2>/dev/null | egrep ${VM}-${REGION} | egrep stopped\`" = ""
do
   echo -n "."
   sleep 5
done
echo

IMG=""
while test "\${IMG}" = ""
do
   IMG=\`ibmcloud is instance \${ID} --output JSON 2>/dev/null | fgrep "                \"id\":" | head -1 | awk 'BEGIN{FS="\""}{print \$4}'\`
done
echo "Source is \${IMG}"

echo -n "Creating image ${VM}-${REGION}-${DATE}"
RET="1"
while test \${RET} != "0"
do
   ibmcloud is image-create ${VM}-${REGION}-${DATE} --source-volume \${IMG} 1>/dev/null 2>/dev/null
   RET=\$?
   echo -n "."
   sleep 5
done
echo

echo -n "Wait for image saved"
SAVED=""
while test "\${SAVED}" != "available"
do
   STRING="\`ibmcloud is images 2>/dev/null | egrep ${VM}-${REGION}-${DATE} | egrep '(available|failed)'\`"
   if test "\`echo \${STRING} | egrep available\`" != ""
   then
      SAVED="available"
   fi
   if test "\`echo \${STRING} | egrep failed\`" != ""
   then
      SAVED="failed"
      ID=\`echo \${STRING} | awk '{print \$1}'\`
      echo
      echo -n "Save FAILED, delete image \${ID}"
      ibmcloud is image-delete \${ID} -f 1>/dev/null 2>/dev/null
      echo
      sleep 30
      echo -n "Save FAILED, save again ${VM}-${REGION}-${DATE}"
      RET="1"
      while test \${RET} != "0"
      do
         ibmcloud is image-create ${VM}-${REGION}-${DATE} --source-volume \${IMG} 1>/dev/null 2>/dev/null
         RET=\$?
         echo -n "."
         sleep 20
      done
      echo
      echo "Kicked on save again."
   fi
   echo -n "."
   sleep 20
done
echo
echo "Image ${VM}-${REGION}-${DATE} saved."
sleep 20
EOF
      chmod 755 /tmp/save_${VM}-${REGION}-${DATE}.sh
      gnome-terminal --zoom=0.7 --geometry 80x15 --title "/tmp/save_${VM}-${REGION}-${DATE}.sh" -e "bash -c \"echo ${ESC} \\\"\033]11;#DDFFFF\007\\\";/tmp/save_${VM}-${REGION}-${DATE}.sh\"" > /dev/null 2> /dev/null &
   done
   ALL_SAVED="n"
   while test "${ALL_SAVED}" = "n"
   do
      ALL_SAVED="y"
      #ibmcloud login -r ${REGION} -q 1>/dev/null 2>/dev/null
      for VM in ${TEMPLATES}
      do
         RET=`ibmcloud is images 2>/dev/null | egrep ${VM}-${REGION}-${DATE} | egrep available`
         if test "${RET}" = ""
         then
            ALL_SAVED="n"
         fi
      done
      echo -n "."
      sleep 10
   done
   echo
   echo "All images saved."
   cleanup_terraform ${REGION}
}

############################################################
while true
do
   ############################################################

   case ${INSTALL_TYPE} in
   ONPREM)
      ACTION="Setup_nodes_Terraform"
   ;;
   CLOUD)
      DATE=`date +%Y%m%d%Hh%M`
      DEFNAME="def-${DATE}"

      case ${SETUP_TYPE} in
      HPC-Tile|Terraform)
         ############################################################
         echo ${ESC} ""
         echo ${ESC} "${BLUE}Set environment${OFF}"
         echo ${ESC} "${BLUE}===============${OFF}"

         ACTION=""
         case ${SETUP_TYPE} in
         HPC-Tile)
            while test "${ACTION}" = ""
            do
               echo ${ESC} ""
               echo ${ESC} "   1 Cleanup all"
               echo ${ESC} "   2 Refer to existing instance"
               echo ${ESC} "   3 New cluster instance"
               echo ${ESC} ""
               echo -n "   Which action do you want to run? [1-3]? "
               read ANS
               case ${ANS} in
                  1) ACTION="Cleanup_all_HPC-Tile" ;;
                  2) ACTION="Refer_to_existing_instance_HPC-Tile" ;;
                  3) ACTION="New_cluster_instance_HPC-Tile" ;;
               esac
            done
         ;;
         Terraform)
            while test "${ACTION}" = ""
            do
               echo ${ESC} ""
               echo ${ESC} "   1 Cleanup"
               echo ${ESC} "   2 Setup nodes"
               echo ${ESC} "   3 Start nodes"
               echo ${ESC} ""
               echo -n "   Which action do you want to run? [1-3]? "
               read ANS
               case ${ANS} in
                  1) ACTION="Cleanup_Terraform" ;;
                  2) ACTION="Setup_nodes_Terraform" ;;
                  3) ACTION="Start_nodes_Terraform" ;;
               esac
            done
         ;;
         esac
      ;;
      CodeEngine)
         JOBTYPE=""
         while test "${JOBTYPE}" = ""
         do
            echo ${ESC} ""
            echo ${ESC} "${BLUE}Select jobtype/demo you want to use${OFF}"
            echo ${ESC} "${BLUE}===================================${OFF}"
            echo ${ALL_JOBTYPES} | awk '{for(i=1;i<=NF;i++){printf("%s\n",$i)}}' | sort
            echo
            echo -n "Select jobtype/demo : "
            read JOBTYPE
         done
         echo
         echo "You selected ${JOBTYPE}"
         echo

         echo ${ESC} ""
         echo ${ESC} "${BLUE}Select cores and memory to use${OFF}"
         echo ${ESC} "${BLUE}==============================${OFF}"

         for PAIR in `echo ${ALL_RESOURCES} | awk '{for(i=1;i<=NF;i++){printf("%s\n",$i)}}' | sort -n`
         do
            echo ${PAIR} | awk 'BEGIN{FS="x"}{printf("%+5s cores and %+4s GB memory (%sx%s)\n",$1,$2,$1,$2)}'
         done

         echo -n "Select combination (<Enter> for '${DEFAULT_RESOURCES}'): "
         read ANSWER
         if test "${ANSWER}" = ""
         then
            ANSWER="${DEFAULT_RESOURCES}"
         fi
         echo
         echo "You selected ${ANSWER}"
         echo
         CORES=`echo ${ANSWER} | awk 'BEGIN{FS="x"}{print $1}'`
         MEM=`echo ${ANSWER} | awk 'BEGIN{FS="x"}{print $2}'`

         RESOURCES="--cpu ${CORES} --memory ${MEM}G"
         ACTION="Setup_CodeEngine"
      ;;
      esac
   ;;
   esac

   ############################################################

   if test "${INSTALL_TYPE}" = "CLOUD"
   then
      case $ACTION in
      Setup_nodes_Terraform)
         echo ${ESC} ""
         echo ${ESC} "${BLUE}Select template types you want to create${OFF}"
         echo ${ESC} "${BLUE}========================================${OFF}"
         TEMPLATES=""
         while test "${TEMPLATES}" = ""
         do
            echo
            echo ${ALL_TEMPLATE_TYPES} | awk '{for(i=1;i<=NF;i++){printf("%s\n",$i)}}' | sort | tee -a /tmp/$$.templates
            HEAD=`head -1 /tmp/$$.templates | awk '{print $1}'`
            TAIL=`tail -1 /tmp/$$.templates | awk '{print $1}'`
            echo
            echo -n "Select template(s) [${HEAD} - ${TAIL}] (<Enter> for '${DEFAULT_TEMPLATES_SETUP}'): "
            read TEMPLATES
            TEMPLATES=`echo ${TEMPLATES} | sed s/","/" "/g`
            if test "${TEMPLATES}" = ""
            then
               TEMPLATES="${DEFAULT_TEMPLATES_SETUP}"
            fi
         done
         echo
         echo "You selected ${TEMPLATES}"
      ;;
      Start_nodes_Terraform)
         echo ${ESC} ""
         echo ${ESC} "${BLUE}Select template types you want to start${OFF}"
         echo ${ESC} "${BLUE}=======================================${OFF}"
         TEMPLATES=""
         while test "${TEMPLATES}" = ""
         do
            echo
            echo ${ALL_TEMPLATE_TYPES} | awk '{for(i=1;i<=NF;i++){printf("%s\n",$i)}}' | sort | tee -a /tmp/$$.templates
            HEAD=`head -1 /tmp/$$.templates | awk '{print $1}'`
            TAIL=`tail -1 /tmp/$$.templates | awk '{print $1}'`
            echo
            echo -n "Select template(s) [${HEAD} - ${TAIL}] (<Enter> for '${DEFAULT_TEMPLATES_START}'): "
            read TEMPLATES
            TEMPLATES=`echo ${TEMPLATES} | sed s/","/" "/g`
            if test "${TEMPLATES}" = ""
            then
               TEMPLATES="${DEFAULT_TEMPLATES_START}"
            fi
         done
         echo
         echo "You selected ${TEMPLATES}"

         echo ${ESC} ""
         echo ${ESC} "${BLUE}Select number of static compute nodes to start${OFF}"
         echo ${ESC} "${BLUE}==============================================${OFF}"
         echo
         echo -n "Number of virtual nodes (<Enter> for ${DEFAULT_NUM_STATIC_COMPUTE}): "
         read NUM_STATIC_COMPUTE
         if test "${NUM_STATIC_COMPUTE}" = ""
         then
            NUM_STATIC_COMPUTE="${DEFAULT_NUM_STATIC_COMPUTE}"
         fi
         echo "You selected ${NUM_STATIC_COMPUTE}"

         echo
         echo -n "Number of baremetal nodes (<Enter> for ${DEFAULT_NUM_STATIC_BAREMETAL}): "
         read NUM_STATIC_BAREMETAL
         if test "${NUM_STATIC_BAREMETAL}" = ""
         then
            NUM_STATIC_BAREMETAL="${DEFAULT_NUM_STATIC_BAREMETAL}"
         fi
         echo "You selected ${NUM_STATIC_BAREMETAL}"

         echo ${ESC} ""
         echo ${ESC} "${BLUE}Select blockstorage size attached to master${OFF}"
         echo ${ESC} "${BLUE}===========================================${OFF}"

         echo
         echo -n "Select blockstorage size (in GB) (<Enter> for '${IBM_BLOCKSTORAGE_DEFAULT_SIZE}'): "
         read ANSWER
         if test "${ANSWER}" = ""
         then
            IBM_BLOCKSTORAGE_SIZE="${IBM_BLOCKSTORAGE_DEFAULT_SIZE}"
         else
            IBM_BLOCKSTORAGE_SIZE="${ANSWER}"
         fi

         echo
         echo "You selected ${IBM_BLOCKSTORAGE_SIZE}"
         echo
      ;;
      Setup_CodeEngine)
         # Combinations of cores and mem
         #  https://cloud.ibm.com/docs/codeengine?topic=codeengine-mem-cpu-combo
#cwecwe
         DATE=`date +%Y%m%d-%Hh%M`
         PROJECT="project-${DATE}"
         JOBNAME="job-${DATE}"
         APPNAME="app-${DATE}"
         BUILD="build-${DATE}"
         IMAGE="myimage:${DATE}"
         ###########################################################
         RET=`which git 2>/dev/null`
         if test "${RET}" = ""
         then
            echo ${ESC} ""
            echo ${ESC} "${BLUE}Install GIT${OFF}"
            echo ${ESC} "${BLUE}===========${OFF}"

            case ${ID_LIKE} in
            *rhel*|*fedora*)
               yum -y install git 1>/dev/null 2>/dev/null
            ;;
            *debian*)
            apt-get -y install git 1>/dev/null 2>/dev/null
            ;;
            esac
         fi
         ############################################################

         if test ! -d /root/CodeEngine
         then
            echo ${ESC} ""
            echo ${ESC} "${BLUE}Cloning https://github.com/IBM/CodeEngine${OFF}"
            echo ${ESC} "${BLUE}=========================================${OFF}"
            git clone https://github.com/IBM/CodeEngine 1>/dev/null 2>/dev/null
         fi

         ############################################################

         RET=`which ibmcloud 2>/dev/null`
         if test "${RET}" = ""
         then
            echo ${ESC} ""
            echo ${ESC} "${BLUE}Install IBM CLI${OFF}"
            echo ${ESC} "${BLUE}===============${OFF}"

            curl -fsSL https://clis.cloud.ibm.com/install/linux | sh 1>/dev/null 2>/dev/null
            for PLUGIN in code-engine
            do
               ibmcloud plugin install ${PLUGIN} -f 1>/dev/null 2>/dev/null
            done
         fi

         ############################################################
         RET=`ibmcloud account list 2>/dev/null`
         if test "${RET}" = ""
         then
            echo ${ESC} ""
            echo ${ESC} "${BLUE}Login @ IBM-Cloud${OFF}"
            echo ${ESC} "${BLUE}=================${OFF}"
            ibmcloud login -r ${REGION} -q 2>/dev/null | egrep '(Account:|User:)'
            RET=`ibmcloud resource groups | egrep ${IBMCLOUD_RESOURCE_GROUP}`
            if test "${RET}" = ""
            then
               ibmcloud resource group-create ${IBMCLOUD_RESOURCE_GROUP} 1>/dev/null 2>/dev/null
            fi
         fi
         ############################################################

         echo
         echo "############################################################"
         echo "Set target:"
         echo ${ESC} "${BLUE}   ibmcloud target -r ${REGION} -g ${IBMCLOUD_RESOURCE_GROUP}${OFF}"
         ibmcloud target -r ${REGION} -g ${IBMCLOUD_RESOURCE_GROUP}
         echo "############################################################"
         echo

         echo
         echo "############################################################"
         echo "List projects:"
         echo ${ESC} "${BLUE}   ibmcloud ce project list${OFF}"
         ibmcloud ce project list
         echo "############################################################"
         echo

         for OLDPROJECT in `ibmcloud ce project list | egrep ${REGION} | awk '{print $1}'`
         do
            echo
            echo "############################################################"
            echo "Delete project ${OLDPROJECT}"
            echo ${ESC} "${BLUE}   ibmcloud ce project delete --name ${OLDPROJECT} --hard -f${OFF}"
            ibmcloud ce project delete --name ${OLDPROJECT} --hard -f
            echo "############################################################"
            echo
         done

         echo
         echo "############################################################"
         echo "Create new project ${PROJECT}"
         echo ${ESC} "${BLUE}   ibmcloud ce project create --name ${PROJECT}${OFF}"
         ibmcloud ce project create --name ${PROJECT}
         echo "############################################################"
         echo

         echo
         echo "############################################################"
         echo "Select project ${PROJECT}"
         echo ${ESC} "${BLUE}   ibmcloud ce project select --name ${PROJECT}${OFF}"
         ibmcloud ce project select --name ${PROJECT}
         echo "############################################################"
         echo

         case ${JOBTYPE} in
         Array)
            echo
            echo "############################################################"
            echo "Create new job ${JOBNAME}"
            echo ${ESC} "${BLUE}   ibmcloud ce job create --name ${JOBNAME} --image icr.io/codeengine/helloworld ${RESOURCES} --array-size 5 --cmd \"/bin/sh\" --arg \"-c\" --arg \"echo \\\"I am index \\\$JOB_INDEX\" on host \\\$HOSTNAME\"${OFF}"
            ibmcloud ce job create --name ${JOBNAME} --image icr.io/codeengine/helloworld ${RESOURCES} --array-size 5 --cmd "/bin/sh" --arg "-c" --arg "echo \"I am index \$JOB_INDEX\" on host \$HOSTNAME"
            echo "############################################################"
            echo
         ;;
         Helloworld)
            echo
            echo "############################################################"
            echo "Create new job ${JOBNAME}"
            echo ${ESC} "${BLUE}   ibmcloud ce job create --name ${JOBNAME} --image icr.io/codeengine/helloworld ${RESOURCES}${OFF}"
            ibmcloud ce job create --name ${JOBNAME} --image icr.io/codeengine/helloworld ${RESOURCES}
            echo "############################################################"
            echo
         ;;
         GitNode)
            echo
            echo "############################################################"
            echo "Docker login"
            echo ${ESC} "${BLUE}   docker login -u ${DOCKERUSER} -p ${DOCKERTOKEN} docker.io${OFF}"
            touch /etc/containers/nodocker
            docker login -u ${DOCKERUSER} -p ${DOCKERTOKEN} docker.io
            echo "############################################################"
            echo

            echo
            echo "############################################################"
            echo "Write Dockerfile"
            cat > Dockerfile <<EOF
FROM docker.io/library/ubuntu:latest
RUN apt update \
&& apt install -y git curl
EOF
            echo "############################################################"
            echo

            echo
            echo "############################################################"
            echo "Docker build"
            echo ${ESC} "${BLUE}   docker build -t docker.io/${DOCKERUSER}/${IMAGE} .${OFF}"
            docker build -t docker.io/${DOCKERUSER}/${IMAGE} .
            echo "############################################################"
            echo

            echo
            echo "############################################################"
            echo "Docker push"
            echo ${ESC} "${BLUE}   docker push docker.io/${DOCKERUSER}/${IMAGE}${OFF}"
            docker push docker.io/${DOCKERUSER}/${IMAGE}
            echo "############################################################"
            echo

            echo "############################################################"
            echo "Create new job ${JOBNAME}"
            echo ${ESC} "${BLUE}   ibmcloud ce job create --name ${JOBNAME} --image docker.io/${DOCKERUSER}/${IMAGE} ${RESOURCES} --command /bin/sh --argument \"-c\" --argument \"echo START ; git clone https://github.com/samtools/htslib ; ls -al htslib ; echo END\"${OFF}"
            ibmcloud ce job create --name ${JOBNAME} --image docker.io/${DOCKERUSER}/${IMAGE} ${RESOURCES} --command /bin/sh --argument "-c" --argument "echo START ; git clone https://github.com/samtools/htslib ; ls -al htslib ; echo END"
            echo "############################################################"
            echo
         ;;
         Webserver)
            echo
            echo "############################################################"
            echo "Create new application ${APPNAME}"
            echo ${ESC} "${BLUE}   ibmcloud ce application create --name ${APPNAME} --image icr.io/codeengine/helloworld ${RESOURCES}${OFF}"
            ibmcloud ce application create --name ${APPNAME} --image icr.io/codeengine/helloworld ${RESOURCES}
            echo "############################################################"
            echo
         ;;
         esac

         case ${JOBTYPE} in
         Helloworld|GitNode|Array)
            echo
            echo "############################################################"
            echo "Get job details of ${JOBNAME}"
            echo ${ESC} "${BLUE}   ibmcloud ce job get --name ${JOBNAME}${OFF}"
            ibmcloud ce job get --name ${JOBNAME}
            echo "############################################################"
            echo

            echo
            echo "############################################################"
            echo "Run/submit job ${JOBNAME}"
            echo ${ESC} "${BLUE}   ibmcloud ce jobrun submit --job ${JOBNAME}${OFF}"
            ibmcloud ce jobrun submit --job ${JOBNAME}
            echo

            echo
            echo "############################################################"
            echo "List jobruns until job failed or finishd"
            PENDING="1"
            RUNNING="1"
            while test "${PENDING}" != "0" -o "${RUNNING}" != "0"
            do
               echo ${ESC} "${BLUE}   ibmcloud ce jobrun list${OFF}"
               ibmcloud ce jobrun list
               sleep 2
               PENDING=`ibmcloud ce jobrun list | egrep ${JOBNAME} | awk '{print $3}'`
               RUNNING=`ibmcloud ce jobrun list | egrep ${JOBNAME} | awk '{print $4}'`
            done
            echo "############################################################"
            echo

            echo
            echo "############################################################"
            JOBRUN_NAME=`ibmcloud ce jobrun list | egrep task | awk '{print $1}'`
            echo "Jobrun logs"
            echo ${ESC} "${BLUE}   ibmcloud ce jobrun logs --jobrun ${JOBRUN_NAME}${OFF}"
            ibmcloud ce jobrun logs --jobrun ${JOBRUN_NAME}
            echo "############################################################"
            echo

            echo
            echo "############################################################"
            JOBRUN_NAME=`ibmcloud ce jobrun list | egrep task | awk '{print $1}'`
            echo "Delete jobrun ${JOBRUN_NAME}"
            echo ${ESC} "${BLUE}   ibmcloud ce jobrun  delete --name ${JOBRUN_NAME} -f${OFF}"
            ibmcloud ce jobrun  delete --name ${JOBRUN_NAME} -f
            echo "############################################################"
            echo
            echo
            echo "############################################################"
            echo "Delete job ${JOBNAME}"
            echo ${ESC} "${BLUE}   ibmcloud ce job delete --name ${JOBNAME} -f${OFF}"
            ibmcloud ce job delete --name ${JOBNAME} -f
            echo "############################################################"
            echo
         ;;
         Webserver)
            echo
            echo "############################################################"
            echo "Get application details of ${APPNAME}"
            echo ${ESC} "${BLUE}   ibmcloud ce application get --name ${APPNAME}${OFF}"
            ibmcloud ce application get --name ${APPNAME}
            echo "############################################################"
            echo

            echo
            echo "############################################################"
            echo "Get application URL of ${APPNAME}"
            echo ${ESC} "${BLUE}   ibmcloud ce application get --name ${APPNAME} | egrep ^URL | awk '{print \$2}'${OFF}"
            URL=`ibmcloud ce application get --name ${APPNAME} | egrep ^URL | awk '{print $2}'`
            cat <<EOF

Browse to ${URL}

EOF
            echo "############################################################"
            echo

            echo -n "Press <Enter> key to delete application"
            read DUMMY

            echo
            echo "############################################################"
            echo "Delete application ${APPNAME}"
            echo ${ESC} "${BLUE}   ibmcloud ce application delete --name ${APPNAME} -f${OFF}"
            ibmcloud ce application delete --name ${APPNAME} -f
            echo "############################################################"
            echo
         ;;
         esac

         echo
         echo "############################################################"
         echo "Delete project ${PROJECT}"
         echo ${ESC} "${BLUE}   ibmcloud ce project delete --name ${PROJECT} --hard -f${OFF}"
         ibmcloud ce project delete --name ${PROJECT} --hard -f
         echo "############################################################"
         echo
      ;;
      esac
      install_SW_APIS
   fi
   ############################################################

   case ${INSTALL_TYPE} in
   ONPREM)
      RET=`which status_watchdog.sh 2>/dev/null`
      if test "${RET}" = ""
      then
         echo ${ESC} ""
         echo ${ESC} "${BLUE}Create status_watchdog.sh${OFF}"
         echo ${ESC} "${BLUE}=========================${OFF}"
         cat > /usr/bin/status_watchdog.sh <<EOF
#!/bin/sh

. /etc/os-release

case \${ID_LIKE} in
*rhel*|*fedora*)
   ESC="-e"
;;
esac

echo \${ESC} "\033]11;#FFFFDD\007"

RED='\e[1;31m'
GREEN='\e[1;32m'
BLUE='\e[1;34m'
OFF='\e[0;0m'
HOSTS_UP=\`nmap -T5 -sn 192.168.1.10-15 | egrep "Nmap scan report" | awk '{print \$5}' | awk 'BEGIN{FS="."}{print \$1}' | awk '{X=X" "\$1}END{print X}'\`

while true
do
   clear
   echo "Node:                Status:"
   for NODE in \$HOSTS_UP
   do
      STATUS=\`ssh \$NODE cat /tmp/STATUS\`
      STRING=\`echo \$NODE \$STATUS | awk '{printf("%-20.20s %s\n",\$1,\$2)}'\`
      echo \${ESC} "\${GREEN}\${STRING}\${OFF}"

   done
   sleep 5
done
EOF
         chmod 755 /usr/bin/status_watchdog.sh
      fi
   ;;
   CLOUD)
      RET=`which watchdog.sh 2>/dev/null`
      if test "${RET}" = ""
      then
         echo ${ESC} ""
         echo ${ESC} "${BLUE}Create watchdog.sh${OFF}"
         echo ${ESC} "${BLUE}==================${OFF}"
         cat > /usr/bin/watchdog.sh <<EOF
#!/bin/sh

RED='\e[1;31m'
GREEN='\e[1;32m'
BLUE='\e[1;34m'
OFF='\e[0;0m'

echo ${ESC} "\033]11;#FFFFDD\007"
TIMEOUT="15"

. ${ENVIRONMENT_SH}

ibmcloud login --no-region -q 1>/dev/null 2>/dev/null
ibmcloud target -g \${IBMCLOUD_RESOURCE_GROUP} 1>/dev/null 2>/dev/null
ibmcloud is target --gen 2 1>/dev/null 2>/dev/null

while true
do
   rm -rf /tmp/instances.txt
   ibmcloud target -r \${REGION} 1>/dev/null 2>/dev/null
   ibmcloud is instances 2>/dev/null | egrep -v '(ID|instances in |No instances were found)' | awk '{printf("'\${REGION}'#%s#%s#%s#%s\n",\$2,\$3,\$4,\$5)}' >> /tmp/instances.txt 2>/dev/null
   ibmcloud is bare-metal-servers 2>/dev/null | egrep -v '(ID|Listing bare metal|No bare metal servers were found)' | awk '{printf("'\${REGION}'#%s#%s#%s#%s\n",\$2,\$3,\$4,\$5)}' >> /tmp/instances.txt 2>/dev/null

   clear
   echo ${ESC} "\${BLUE}Cloud instances\${OFF} @ "\`date +%H:%M:%S\`
   echo ${ESC} "Region          Instance                     Status       Int-IP           Ext-IP"
   echo ${ESC} "------          --------                     ------       ------           ------"
   for LINE in \`cat /tmp/instances.txt 2>/dev/null | sort | uniq\`
   do
      STRING=\`echo \${LINE} | awk 'BEGIN{FS="#"}{printf("%-14.14s  %-27.27s  %-11.11s  %-15.15s  %-15.15s\n",\$1,\$2,\$3,\$4,\$5)}'\`
      if test "\`echo \${STRING} | egrep running\`" = ""
      then
         echo ${ESC} "\${STRING}"
      else
         echo ${ESC} "\${GREEN}\${STRING}\${OFF}"
      fi
   done
   sleep \${TIMEOUT}
done
EOF
         chmod 755 /usr/bin/watchdog.sh
      fi
   ;;
   esac

   ############################################################

   case $ACTION in
   Cleanup_Terraform)
      cleanup_terraform ${REGION}
   ;;
   Cleanup_all_HPC-Tile)
      cleanup_hpctile
   ;;
   Refer_to_existing_instance_HPC-Tile)
      refer_to_existing_instance_hpctile
   ;;
   New_cluster_instance_HPC-Tile)
      write_environment_sh
      write_hpctile_json
      cleanup_hpctile
      new_instance_hpctile
   ;;
   Setup_nodes_Terraform)
      write_environment_sh
      case ${INSTALL_TYPE} in
      ONPREM)
         if test "${HOSTS_UP}" = ""
         then
            echo ${ESC} ""
            echo ${ESC} "${BLUE}Finding out which nodes are up${OFF}"
            echo ${ESC} "${BLUE}==============================${OFF}"

            HOSTS_UP=`nmap -T5 -sn 192.168.1.11-15 | egrep "Nmap scan report" | awk '{print $5}' | awk 'BEGIN{FS="."}{print $1}' | awk '{X=X" "$1}END{print X}'`
            echo ${ESC} "Hosts that are up:${GREEN}${HOSTS_UP}${OFF}"
         fi
         echo
         ${PSCP} -H "${HOSTS_UP}" -t 0 ${ENVIRONMENT_SH} ${ENVIRONMENT_SH}
         ${PSCP} -H "${HOSTNAME} ${HOSTS_UP}" -t 0 /root/install_functions.sh /usr/bin/install_functions.sh
         ${PSCP} -H "${HOSTNAME} ${HOSTS_UP}" -t 0 /root/install_wrapper.sh /usr/bin/install_wrapper.sh
         ${PSSH} -H "${HOSTS_UP}" -t 0 "echo \"export ROLE=compute\" >> ${ENVIRONMENT_SH}"
         ${PSSH} -H "${HOSTNAME}" -t 0 "echo \"export ROLE=master\" >> ${ENVIRONMENT_SH}"
         gnome-terminal --zoom=0.7 --geometry 50x10 -e "bash -c \"/usr/bin/status_watchdog.sh\"" 1>/dev/null 2>/dev/null &
         echo
         echo "Running install_wrapper.sh on all VMs"
         ${PSSH} -H "${HOSTNAME} ${HOSTS_UP}" -t 0 /usr/bin/install_wrapper.sh
         PID=`ps auxww | egrep status_watchdog.sh | egrep -v grep | awk '{print $2}'`
         kill -9 ${PID} 1>/dev/null 2>/dev/null
         exit
      ;;
      CLOUD)
         create_access_postboot_service
         echo
         create_terraform_files @${REGION}@${TEMPLATES}
         gnome-terminal --zoom=0.7 --geometry 90x15 -e "bash -c \"/usr/bin/watchdog.sh\"" 1>/dev/null 2>/dev/null &
         echo
         apply_terraform_files @${REGION}
         echo
         wait_all_nodes_up @${REGION}@${TEMPLATES}
         run_install_on_all_VMs @${REGION}@${TEMPLATES}
         save_images @${REGION}@${TEMPLATES}
         PID=`ps auxww | egrep watchdog.sh | egrep -v grep | awk '{print $2}'`
         kill -9 ${PID}
         echo
      ;;
      esac
   ;;
   Start_nodes_Terraform)
      rm -rf /root/Desktop/ssh-*
      rm -rf /root/Desktop/RDP-*
      rm -rf /root/Desktop/AC*
      rm -rf /root/Desktop/Explorer*
      rm -rf /root/Desktop/Multicluster*
      rm -rf /root/Desktop/Guacamole*

      #cleanup_terraform ${REGION}

      create_terraform_files @${REGION}@${TEMPLATES}

      gnome-terminal --zoom=0.7 --geometry 90x15 -e "bash -c \"/usr/bin/watchdog.sh\"" 1>/dev/null 2>/dev/null &

      apply_terraform_files @${REGION}
      wait_all_nodes_up @${REGION}@${TEMPLATES}

      cd ${TF_WORKDIR}/${REGION}_create
      for VM in ${TEMPLATES}
      do
         IP=`terraform output ip-${VM}-${REGION} 2>/dev/null | sed s/"\""//g`
         ID=`terraform output id-${VM}-${REGION} 2>/dev/null | sed s/"\""//g`
         echo "${VM}-${REGION}: ${IP} ${ID}"

         DESKTOP_LINK="/root/Desktop/ssh-${VM}-${REGION}.desktop"
         MOD_PASSWD=`echo ${ROOTPWD} | sed s/"%"/"%%"/g`
         cat << EOF> ${DESKTOP_LINK}
[Desktop Entry]
Type=Application
Terminal=true
Exec=ssh root@${IP}
Name=ssh-${VM}-${REGION}
Icon=computer
EOF
         gio set ${DESKTOP_LINK} "metadata::trusted" true >/dev/null 2>&1
         chmod 755 "${DESKTOP_LINK}"
         if test "`echo ${ADD_ONS} | egrep ApplicationCenter`" != ""
         then
            if test "${VM}" = "master"
            then
               DESKTOP_LINK="/root/Desktop/AC-${REGION}.desktop"
               cat << EOF> ${DESKTOP_LINK}
[Desktop Entry]
Type=Application
Terminal=false
Exec=firefox http://${IP}:8888
Name=AC ${REGION}
Icon=firefox
EOF
               gio set ${DESKTOP_LINK} "metadata::trusted" true >/dev/null 2>&1
               chmod 755 "${DESKTOP_LINK}"
            fi
         fi

         if test "`echo ${ADD_ONS} | egrep Explorer`" != ""
         then
            if test "${VM}" = "master"
            then
               DESKTOP_LINK="/root/Desktop/Explorer-${REGION}.desktop"
               cat << EOF> ${DESKTOP_LINK}
[Desktop Entry]
Type=Application
Terminal=false
Exec=firefox http://${IP}:9999
Name=Explorer ${REGION}
Icon=firefox
EOF
               gio set ${DESKTOP_LINK} "metadata::trusted" true >/dev/null 2>&1
               chmod 755 "${DESKTOP_LINK}"
            fi
         fi
         if test "`echo ${ADD_ONS} | egrep RDP`" != ""
         then
            if test "${VM}" = "master"
            then
               DESKTOP_LINK="/root/Desktop/RDP-${VM}-${REGION}.desktop"
               cat << EOF> ${DESKTOP_LINK}
[Desktop Entry]
Type=Application
Terminal=false
Exec=xfreerdp /v:${IP} /cert-ignore
Name=RDP-${VM}-${REGION}
Icon=preferences-desktop-remote-desktop
EOF
               gio set ${DESKTOP_LINK} "metadata::trusted" true >/dev/null 2>&1
               chmod 755 "${DESKTOP_LINK}"
            fi
         fi

         if test "`echo ${ADD_ONS} | egrep Guacamole`" != ""
         then
            if test "${VM}" = "master"
            then
               DESKTOP_LINK="/root/Desktop/Guacamole-${VM}-${REGION}.desktop"
               cat << EOF> ${DESKTOP_LINK}
[Desktop Entry]
Type=Application
Terminal=false
Exec=firefox -width 1024 -height 753 http://${IP}
Name=Guacamole-${VM}-${REGION}
Icon=preferences-desktop-remote-desktop
EOF
               gio set ${DESKTOP_LINK} "metadata::trusted" true >/dev/null 2>&1
               chmod 755 "${DESKTOP_LINK}"
            fi
         fi
      done
      echo "All VMs are running now."
      ;;
   esac
done
