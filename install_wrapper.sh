#!/bin/sh
 
. /usr/bin/install_functions.sh

############################################################

. /etc/os-release

case ${ID_LIKE} in
*rhel*|*fedora*)
   ESC="-e"
;;
*debian*)
;;
esac

############################################################

echo ${ESC} "\033]11;#DDDDDD\007"
RED='\e[1;31m'
GREEN='\e[1;32m'
BLUE='\e[1;34m'
OFF='\e[0;0m'

############################################################

. /var/environment.sh

#----- 1 Common stuff -----
echo
echo ${ESC} "${BLUE}Common stuff${OFF}"
echo "Common_stuff" > /tmp/STATUS
write_common_stuff
/tmp/common_stuff.sh ${ROOTPWD} ${SWAP} ${ID_RSA_PRIV_BASE64} ${ID_RSA_PUB_BASE64} ${ADDITIONAL_USERS}
#----- 1 Common stuff -----

case ${ROLE} in
compute)
   #----- 1 Cloudprovider API -----
   if test "${REGION}" != "onprem"
   then
      echo
      echo ${ESC} "${BLUE}Installing Cloudprovider API${OFF}"
      echo "Cloudprovider_API" > /tmp/STATUS
      write_cloudprovider_api
      /tmp/cloudprovider_api.sh ${REGION} ${IBMCLOUD_API_KEY}
   fi
   #----- 1 Cloudprovider API -----
   if test "${WITH_LDAP}" = "Y"
   then
      #------------ 1 LDAP -----------
      echo
      echo ${ESC} "${BLUE}Installing LDAP${OFF}"
      echo "LDAP" > /tmp/STATUS
      write_ldap
      /tmp/ldap.sh ldap-onprem.myhpccloud.net ${ROOTPWD}
      write_ldap_howto
      /tmp/ldap_howto.sh
      #------------ 1 LDAP -----------
   fi
   if test "${WITH_LSF}" = "Y"
   then
      #------------ 1 LSF -----------
      echo
      echo ${ESC} "${BLUE}Installing LSF${OFF}"
      echo "LSF" > /tmp/STATUS
      write_lsf
      /tmp/lsf.sh compute ${LSF_TOP} ${LSF_ENTITLEMENT} cluster-${REGION} master-${REGION}
      #------------ 1 LSF -----------
   fi
   if test "${WITH_NFS}" = "Y"
   then
      #------------ 1 NFS -----------
      echo ${ESC} "${BLUE}Installing NFS${OFF}"
      echo "NFS" > /tmp/STATUS
      write_nfs_compute
      /tmp/nfs_compute.sh master-${REGION} ${NFS_SHARES}
      #------------ 1 NFS -----------
   fi
   if test "${WITH_SLURM}" = "Y"
   then
      #------------ 1 SLURM -----------
      echo
      echo ${ESC} "${BLUE}Installing SLURM${OFF}"
      echo "SLURM" > /tmp/STATUS
      write_slurm_compute
      /tmp/slurm_compute.sh master-${REGION} ${MUNGE_KEY}
      #------------ 1 SLURM -----------
   fi
   if test "${WITH_SYMPHONY}" = "Y"
   then
      #------------ 1 Symphony -----------
      echo
      echo ${ESC} "${BLUE}Installing Symphony${OFF}"
      echo "Symphony" > /tmp/STATUS
      write_symphony
      /tmp/symphony.sh compute ${SYM_TOP} ${SYM_ENTITLEMENT_EGO} ${SYM_ENTITLEMENT_SYM} cluster-${REGION} master-${REGION} ${ROOTPWD}
      #------------ 1 Symphony -----------
   fi
   if test "${WITH_PODMAN}" = "Y"
   then
      #------------ 1 Podman -----------
      echo
      echo ${ESC} "${BLUE}Installing Podman${OFF}"
      echo "Podman" > /tmp/STATUS
      write_podman_compute
      /tmp/podman_compute.sh
      #------------ 1 Podman -----------
   fi
   if test "${WITH_APPTAINER}" = "Y"
   then
      #----- 2 Apptainer -----
      echo
      echo ${ESC} "${BLUE}Installing Apptainer${OFF}"
      echo "Apptainer" > /tmp/STATUS
      write_apptainer_compute
      /tmp/apptainer_compute.sh
      mkdir -p ${LSF_TOP}/apptainer/images
      apptainer build ${LSF_TOP}/apptainer/images/ubuntu.sif docker://ubuntu
      cd ${LSF_TOP}
      chmod -R 777  apptainer/images
      #----- 2 Apptainer -----
   fi
   if test "${WITH_BLAST}" = "Y"
   then
      #----- 2 Blast -----
      echo
      echo ${ESC} "${BLUE}Installing BLAST${OFF}"
      echo "BLAST" > /tmp/STATUS
      write_blast
      /tmp/blast.sh
      #----- 2 Blast -----
   fi
   if test "${WITH_BLENDER}" = "Y"
   then
      #----- 2 Blender -----
      echo
      echo ${ESC} "${BLUE}Installing Blender${OFF}"
      echo "Blender" > /tmp/STATUS
      write_blender_compute
      /tmp/blender_compute.sh
      #----- 2 Blender -----
   fi
   if test "${WITH_EASYEDA}" = "Y"
   then
      #------------ 2 easyEDA -----------
      echo
      echo ${ESC} "${BLUE}Installing easyEDA${OFF} (~2m)"
      echo "easyEDA" > /tmp/STATUS
      write_easyeda_compute
      /tmp/easyeda_compute.sh
      #------------ 2 easyEDA -----------
   fi
   if test "${WITH_GEEKBENCH}" = "Y"
   then
      #-------- 2 Geekbench -------
      echo
      echo ${ESC} "${BLUE}Install Geekbench${OFF}"
      echo "Geekbench" > /tmp/STATUS 
      write_geekbench_compute
      /tmp/geekbench_compute.sh 
      #-------- 2 Geekbench -------
   fi
   if test "${WITH_INTELHPCKIT}" = "Y"
   then
      #------------ 2 Intel-HPCKit -----------
      echo
      echo ${ESC} "${BLUE}Installing Intel-HPCKit${OFF}"
      echo "Intel-HPCKit" > /tmp/STATUS
      write_intelhpckit
      /tmp/intelhpckit.sh
      #------------ 2 Intel-HPCKit -----------
   fi
   if test "${WITH_IRODS}" = "Y"
   then
      #------------ 2 iRODS-shell -----------
      echo
      echo ${ESC} "${BLUE}Installing iRODS-shell${OFF}"
      echo "iRODS-shell" > /tmp/STATUS
      write_irods
      /tmp/irods.sh
      #------------ 2 iRODS-shell -----------
   fi
   if test "${WITH_JUPYTER}" = "Y"
   then
      #------------ 2 Jupyter -----------
      echo
      echo ${ESC} "${BLUE}Installing Jupyter${OFF}"
      echo "Jupyter" > /tmp/STATUS
      write_jupyter_compute
      /tmp/jupyter_compute.sh
      #------------ 2 Jupyter -----------
   fi
   if test "${WITH_LSDYNA}" = "Y"
   then
      #------------ 2 LS-DYNA -----------
      echo
      echo ${ESC} "${BLUE}Installing LS-DYNA${OFF}"
      echo "LS-DYNA" > /tmp/STATUS
      write_lsdyna_compute
      /tmp/lsdyna_compute.sh
      #------------ 2 LS-DYNA -----------
   fi
   if test "${WITH_MONITORING}" = "Y"
   then
      #----- 2 Monitoring -----
      echo
      echo ${ESC} "${BLUE}Installing Monitoring${OFF}"
      echo "Monitoring" > /tmp/STATUS
      write_monitoring
      /tmp/monitoring.sh
      #----- 2 Monitoring -----
   fi
   if test "${WITH_NEXTFLOW}" = "Y"
   then
      #------------ 2 Nextflow -----------
      echo
      echo ${ESC} "${BLUE}Installing Nextflow${OFF}"
      echo "Nextflow" > /tmp/STATUS
      write_nextflow_compute
      /tmp/nextflow_compute.sh
      #------------ 2 Nextflow -----------
   fi
   if test "${WITH_OCTAVE}" = "Y"
   then
      #------------ 2 Octave -----------
      echo
      echo ${ESC} "${BLUE}Installing Octave${OFF}"
      echo "Octave" > /tmp/STATUS
      write_octave_compute
      /tmp/octave_compute.sh
      #------------ 2 Octave -----------
   fi
   if test "${WITH_OPENFOAM}" = "Y"
   then
      #------------ 2 OpenFOAM -----------
      echo
      echo ${ESC} "${BLUE}Installing OpenFOAM${OFF}"
      echo "openFOAM" > /tmp/STATUS
      write_openfoam_compute
      /tmp/openfoam_compute.sh
      #------------ 2 OpenFOAM -----------
   fi
   if test "${WITH_OPENMPI}" = "Y"
   then
      #------------ 2 openMPI -----------
      echo
      echo ${ESC} "${BLUE}Installing openMPI${OFF}"
      echo "openMPI" > /tmp/STATUS
      write_openmpi_compute
      /tmp/openmpi_compute.sh ${LSF_TOP} ${SHARED}
      #------------ 2 openMPI -----------
   fi
   if test "${WITH_PLATFORMMPI}" = "Y"
   then
      #------------ 2 PlatformMPI -----------
      echo
      echo ${ESC} "${BLUE}Installing PlatformMPI${OFF}"
      echo "PlatformMPI" > /tmp/STATUS
      write_platformmpi_compute
      /tmp/platformmpi_compute.sh ${LSF_TOP} ${SHARED}
      #------------ 2 PlatformMPI -----------
   fi
   if test "${WITH_R}" = "Y"
   then
      #------------ 2 R -----------
      echo
      echo ${ESC} "${BLUE}Installing R${OFF}"
      echo "R" > /tmp/STATUS
      write_r
      /tmp/r.sh
      #------------ 2 R -----------
   fi
   if test "${WITH_RDOCK}" = "Y"
   then
      #------------ 2 rDock -----------
      echo
      echo ${ESC} "${BLUE}Installing rDock${OFF}"
      echo "rDock" > /tmp/STATUS
      write_rdock
      /tmp/rdock.sh
      #------------ 2 rDock -----------
   fi
   if test "${WITH_SANGER_IN_A_BOX}" = "Y"
   then
      #------------ 2 Sanger-in-a-box -----------
      echo
      echo ${ESC} "${BLUE}Installing Sanger-in-a-box${OFF}"
      echo "Sanger-in-a-box" > /tmp/STATUS
      write_sanger_in_a_box_compute
      /tmp/sanger_in_a_box_compute.sh ${SHARED}
      #------------ 2 Sanger-in-a-box -----------
   fi
   if test "${WITH_SCALECLIENT}" = "Y"
   then
      #------------ 2 ScaleClient -----------
      echo
      echo ${ESC} "${BLUE}Installing ScaleClient${OFF}"
      echo "ScaleClient" > /tmp/STATUS
      write_scaleclient
      /tmp/scaleclient.sh
      #------------ 2 ScaleClient -----------
   fi
   if test "${WITH_SPARK}" = "Y"
   then
      #------------ 2 Spark -----------
      echo
      echo ${ESC} "${BLUE}Installing Spark${OFF}"
      echo "Spark" > /tmp/STATUS
      write_spark_compute
      /tmp/spark_compute.sh ${LSF_TOP}
      #------------ 2 Spark -----------
   fi
   if test "${WITH_STRESSNG}" = "Y"
   then
      #------------ 2 stress-ng -----------
      echo
      echo ${ESC} "${BLUE}Installing stress-ng${OFF}"
      echo "stress-ng" > /tmp/STATUS
      write_stressng_compute
      /tmp/stressng_compute.sh ${LSF_TOP}
      #------------ 2 Spark -----------
   fi
   if test "${WITH_TENSORFLOW}" = "Y"
   then
      #------------ 2 Tensorflow -----------
      echo
      echo ${ESC} "${BLUE}Installing Tensorflow${OFF}"
      echo "Tensorflow" > /tmp/STATUS
      write_tensorflow_compute
      /tmp/tensorflow_compute.sh
      #------------ 2 Tensorflow -----------
   fi
   if test "${WITH_TOIL}" = "Y"
   then
      #------------ 2 Toil -----------
      echo
      echo ${ESC} "${BLUE}Installing Toil${OFF}"
      echo "Toil" > /tmp/STATUS
      write_toil_compute
      /tmp/toil_compute.sh
      #------------ 2 Toil -----------
   fi
   if test "${WITH_VELOXCHEM}" = "Y"
   then
      #------------ 2 Veloxchem -----------
      echo
      echo ${ESC} "${BLUE}Installing VeloxChem${OFF}"
      echo "VeloxChem" > /tmp/STATUS
      write_veloxchem_compute
      /tmp/veloxchem_compute.sh
      #------------ 2 Veloxchem -----------
   fi
   if test "${WITH_YELLOWDOG}" = "Y"
   then
      #------------ 2 Yellowdog -----------
      echo
      echo ${ESC} "${BLUE}Installing Yellowdog${OFF}"
      echo "Yellowdog" > /tmp/STATUS
      write_yellowdog
      /tmp/yellowdog.sh
      #------------ 2 Yellowdog -----------
   fi
;;
master)
   #----- 1 Hostname_DynDNS -----
   if test "${REGION}" != "onprem" -a "${SETUP_TYPE}" != "HPC-Tile" 
   then   
      echo
      echo ${ESC} "${BLUE}Hostname & DynDNS${OFF}"
      echo "Hostname_DynDNS" > /tmp/STATUS
      write_hostname_dyndns
      /tmp/hostname_dyndns.sh ${MYHOSTNAME}
   fi
   #----- 1 Hostname_DynDNS -----
   #----- 1 Cloudprovider API -----
   if test "${REGION}" != "onprem"   
   then
      echo
      echo ${ESC} "${BLUE}Installing Cloudprovider API${OFF}"
      echo "Cloudprovider_API" > /tmp/STATUS
      write_cloudprovider_api
      /tmp/cloudprovider_api.sh ${REGION} ${IBMCLOUD_API_KEY}
   fi
   #----- 1 Cloudprovider API -----
   if test "${WITH_ASPERA}" = "Y"
   then
      #----- 1 Aspera -----
      echo
      echo ${ESC} "${BLUE}Installing Aspera${OFF}"
      echo "Aspera" > /tmp/STATUS
      write_aspera_master
      /tmp/aspera_master.sh
      write_aspera_howto
      /tmp/aspera_howto.sh
      #----- 1 Aspera -----
   fi
   if test "${WITH_LSF}" = "Y"
   then
      #------------ 1 LSF -----------
      echo
      echo ${ESC} "${BLUE}Installing LSF${OFF}"
      echo "LSF" > /tmp/STATUS
      write_lsf
      /tmp/lsf.sh master ${LSF_TOP} ${LSF_ENTITLEMENT} cluster-${REGION} master-${REGION}
      #------------ 1 LSF -----------
   fi
   if test "${WITH_GUACAMOLE}" = "Y"
   then
      #-------- 1 Guacamole -------
      echo
      echo ${ESC} "${BLUE}Install  Guacamole${OFF}"
      echo "Guacamole" > /tmp/STATUS
      write_guacamole_master
      /tmp/guacamole_master.sh ${ROOTPWD} 80
      #-------- 1 Guacamole -------
   fi
   if test "${WITH_LDAP}" = "Y"
   then
      #------------ 1 LDAP -----------
      echo
      echo ${ESC} "${BLUE}Installing LDAP${OFF}"
      echo "LDAP" > /tmp/STATUS
      write_ldap
      /tmp/ldap.sh ldap-onprem.myhpccloud.net ${ROOTPWD}
      write_ldap_howto
      /tmp/ldap_howto.sh
      #------------ 1 LDAP -----------
   fi
   if test "${WITH_NFS}" = "Y"
   then
      #------------ 1 NFS -----------
      echo
      echo ${ESC} "${BLUE}Installing NFS${OFF}"
      echo "NFS" > /tmp/STATUS
      write_nfs_master
      /tmp/nfs_master.sh ${NFS_SHARES}
      #------------ 1 NFS -----------
   fi
   if test "${WITH_RDP}" = "Y"
   then
      #------------ 1 RDP -----------
      echo
      echo ${ESC} "${BLUE}Installing RDP${OFF}"
      echo "RDP" > /tmp/STATUS
      write_rdp_master
      /tmp/rdp_master.sh ${ROOTPWD}
      #------------ 1 RDP -----------
   fi
   if test "${WITH_SLURM}" = "Y"
   then
      #------------ 1 SLURM -----------
      echo
      echo ${ESC} "${BLUE}Installing SLURM${OFF}"
      echo "SLURM" > /tmp/STATUS
      write_slurm_master
      /tmp/slurm_master.sh master-${REGION} ${MUNGE_KEY}
      write_slurm_howto
      /tmp/slurm_howto.sh
      #------------ 1 SLURM -----------
   fi
   if test "${WITH_SYMPHONY}" = "Y"
   then
      #------------ 1 Symphony -----------
      echo
      echo ${ESC} "${BLUE}Installing Symphony${OFF}"
      echo "Symphony" > /tmp/STATUS
      write_symphony
      /tmp/symphony.sh master ${SYM_TOP} ${SYM_ENTITLEMENT_EGO} ${SYM_ENTITLEMENT_SYM} cluster-${REGION} master-${REGION} ${ROOTPWD}
      write_symphony_howto
      /tmp/symphony_howto.sh
      #------------ 1 Symphony -----------
   fi
   if test "${WITH_PODMAN}" = "Y"
   then
      #------------ 1 Podman -----------
      echo
      echo ${ESC} "${BLUE}Installing Podman${OFF}"
      echo "Podman" > /tmp/STATUS
      write_podman_master
      /tmp/podman_master.sh ${LSF_TOP}
      write_podman_howto
      /tmp/podman_howto.sh
      #------------ 1 Podman -----------
   fi
   if test "${WITH_APPLICATIONCENTER}" = "Y"
   then
      #------------ 2 AppicationCenter -----------
      echo
      echo ${ESC} "${BLUE}Installing ApplicationCenter${OFF}"
      echo "Application_Center" > /tmp/STATUS
      write_application_center_master
      /tmp/application_center_master.sh ${LSF_TOP} 8888
      write_application_center_howto
      /tmp/application_center_howto.sh 8888
      #------------ 2 AppicationCenter -----------
   fi
   if test "${WITH_APPTAINER}" = "Y"
   then
      #----- 2 Apptainer -----
      echo
      echo ${ESC} "${BLUE}Configuring Apptainer${OFF}"
      echo "Apptainer" > /tmp/STATUS
      write_apptainer_master ${LSF_TOP}
      /tmp/apptainer_master.sh ${LSF_TOP} ${LSF_TOP}
      write_apptainer_howto
      /tmp/apptainer_howto.sh
      #----- 2 Apptainer -----
   fi
   if test "${WITH_BLAST}" = "Y"
   then
      #----- 2 Blast -----
      echo
      echo ${ESC} "${BLUE}Installing BLAST${OFF}"
      echo "BLAST" > /tmp/STATUS
      write_blast
      /tmp/blast.sh
      write_blast_howto
      /tmp/blast_howto.sh
      #----- 2 Blast -----
   fi
   if test "${WITH_BLENDER}" = "Y"
   then
      #----- 2 Blender -----
      echo
      echo ${ESC} "${BLUE}Installing Blender${OFF}"
      echo "Blender" > /tmp/STATUS
      write_blender_master
      /tmp/blender_master.sh ${LSF_TOP} ${SHARED}
      write_blender_howto
      /tmp/blender_howto.sh ${SHARED}
      #----- 2 Blender -----
   fi
   if test "${WITH_DATAMANAGER}" = "Y"
   then
      #-------- 2 Datamanager -------
      echo
      echo ${ESC} "${BLUE}Install datamanager${OFF}"
      echo "Datamanager" > /tmp/STATUS
      write_datamanager_master
      /tmp/datamanager_master.sh ${LSF_TOP}
      write_datamanager_howto
      /tmp/datamanager_howto.sh
      #-------- 2 Datamanager -------
   fi
   if test "${WITH_EASYEDA}" = "Y"
   then
      #-------- 2 easyEDA -------
      echo
      echo ${ESC} "${BLUE}Install  easyEDA${OFF}"
      echo "easyEDA" > /tmp/STATUS
      write_easyeda_master
      /tmp/easyeda_master.sh ${LSF_TOP}
      write_easyeda_howto
      /tmp/easyeda_howto.sh
      #-------- 2 easyEDA -------
   fi
   if test "${WITH_EXPLORER}" = "Y"
   then
      #-------- 2 Explorer -------
      echo
      echo ${ESC} "${BLUE}Install  Explorer${OFF}"
      echo "Explorer" > /tmp/STATUS
      write_explorer_master
      /tmp/explorer_master.sh ${LSF_TOP}
      write_explorer_howto
      /tmp/explorer_howto.sh
      #-------- 2 Explorer -------
   fi
   if test "${WITH_GEEKBENCH}" = "Y"
   then
      #-------- 2 Geekbench -------
      echo
      echo ${ESC} "${BLUE}Install Geekbench${OFF}"
      echo "Geekbench" > /tmp/STATUS
      write_geekbench_howto
      /tmp/geekbench_howto.sh 
      #-------- 2 Geekbench -------
   fi
   if test "${WITH_HOSTFACTORY}" = "Y"
   then
      #-------- 2 Hostfactory -------
      echo
      echo ${ESC} "${BLUE}Install  HostFactory${OFF}"
      echo "HostFactory" > /tmp/STATUS
      write_hostfactory_master
      /tmp/hostfactory_master.sh ${SYM_TOP} ${IBMCLOUD_API_KEY}
      #-------- 2 Hostfactory -------
   fi
   if test "${WITH_INTELHPCKIT}" = "Y"
   then
      #------------ 2 Intel-HPCKit -----------
      echo
      echo ${ESC} "${BLUE}Installing Intel-HPCKit${OFF}"
      echo "Intel-HPCKit" > /tmp/STATUS
      write_intelhpckit
      /tmp/intelhpckit.sh
      write_intelhpckit_howto
      /tmp/intelhpckit_howto.sh
      #------------ 2 Intel-HPCKit -----------
   fi
   if test "${WITH_IRODS}" = "Y"
   then
      #------------ 2 iRODS-shell -----------
      echo
      echo ${ESC} "${BLUE}Installing iRODS-shell${OFF}"
      echo "iRODS-shell" > /tmp/STATUS
      write_irods
      /tmp/irods.sh
      write_irods_howto
      /tmp/irods_howto.sh
      #------------ 2 iRODS-shell -----------
   fi
   if test "${WITH_JUPYTER}" = "Y"
   then
      #------------ 2 Jupyter -----------
      echo
      echo ${ESC} "${BLUE}Installing Jupyter${OFF}"
      echo "Jupyter" > /tmp/STATUS
      write_jupyter_howto
      /tmp/jupyter_howto.sh
      #------------ 2 Jupyter -----------
   fi
   if test "${WITH_LICENSESCHEDULER}" = "Y"
   then
      #------------ 2 LicenseScheduler -----------
      echo
      echo ${ESC} "${BLUE}Installing LicenseScheduler${OFF}"
      echo "LicenseSchedule" > /tmp/STATUS
      write_licensescheduler_master
      /tmp/licensescheduler_master.sh ${LSF_TOP}
      write_licensescheduler_howto
      /tmp/licensescheduler_howto.sh
      #------------ 2 LicenseScheduler -----------
   fi
   if test "${WITH_LSDYNA}" = "Y"
   then
      #----- 2 LS-DYNA -----
      echo
      echo ${ESC} "${BLUE}Installing LS-DYNA${OFF}"
      echo "LS-DYNA" > /tmp/STATUS
      write_lsdyna_howto
      /tmp/lsdyna_howto.sh
      #----- 2 LS-DYNA -----
   fi
   if test "${WITH_LWS}" = "Y"
   then
      #----- 2 LWS -----
      echo
      echo ${ESC} "${BLUE}Installing LWS${OFF}"
      echo "LWS" > /tmp/STATUS
      write_lws_master
      /tmp/lws_master.sh ${LSF_TOP}
      write_lws_howto
      /tmp/lws_howto.sh
      #----- 2 LWS -----
   fi
   if test "${WITH_MATLABRUNTIME}" = "Y"
   then
      #----- 2 Matlab -----
      echo
      echo ${ESC} "${BLUE}Installing Matlab${OFF}"
      echo "Matlab" > /tmp/STATUS
      write_matlab_master ${SHARED}
      /tmp/matlab_master.sh
      write_matlab_howto ${SHARED}
      /tmp/matlab_howto.sh
      #----- 2 Matlab -----
   fi
   if test "${WITH_MONITORING}" = "Y"
   then
      #----- 2 Monitoring -----
      echo
      echo ${ESC} "${BLUE}Installing Monitoring${OFF}"
      echo "Monitoring" > /tmp/STATUS
      write_monitoring
      /tmp/monitoring.sh
      #----- 2 Monitoring -----
   fi
   if test "${WITH_MULTICLUSTER}" = "Y"
   then
      #------------ 2 MultiCluster -----------
      echo
      echo ${ESC} "${BLUE}Configuring MultiCluster${OFF}"
      echo "Multicluster" > /tmp/STATUS
      write_multicluster_master
      if test "${REGION}" = "onprem"
      then
         /tmp/multicluster_master.sh ${LSF_TOP}
      else
         /tmp/multicluster_master.sh ${LSF_TOP}
      fi
      write_multicluster_howto
      /tmp/multicluster_howto.sh
      #------------ 2 MultiCluster -----------
   fi
   if test "${WITH_NEXTFLOW}" = "Y"
   then
      #------------ 2 Nextflow -----------
      echo
      echo ${ESC} "${BLUE}Installing Nextflow${OFF}"
      echo "Nextflow" > /tmp/STATUS
      write_nextflow_master
      /tmp/nextflow_master.sh ${LSF_TOP}
      write_nextflow_howto
      /tmp/nextflow_howto.sh ${SHARED} ${LSF_TOP}
      #------------ 2 Nextflow -----------
   fi
   if test "${WITH_OCTAVE}" = "Y"
   then
      #------------ 2 Octave -----------
      echo
      echo ${ESC} "${BLUE}Installing Octave${OFF}"
      echo "Octave" > /tmp/STATUS
      write_octave_master
      /tmp/octave_master.sh ${LSF_TOP}
      write_octave_howto
      /tmp/octave_howto.sh
      #------------ 2 Octave -----------
   fi
   if test "${WITH_OPENFOAM}" = "Y"
   then
      #------------ 2 OpenFOAM -----------
      echo
      echo ${ESC} "${BLUE}Installing OpenFOAM${OFF}"
      echo "openFOAM" > /tmp/STATUS
      write_openfoam_master
      /tmp/openfoam_master.sh ${LSF_TOP} ${SHARED}
      write_openfoam_howto
      /tmp/openfoam_howto.sh ${SHARED}
      #------------ 2 OpenFOAM -----------
   fi
   if test "${WITH_OPENMPI}" = "Y"
   then
      #------------ 2 openMPI -----------
      echo
      echo ${ESC} "${BLUE}Installing openMPI${OFF}"
      echo "openMPI" > /tmp/STATUS
      write_openmpi_master
      /tmp/openmpi_master.sh ${LSF_TOP} ${SHARED}
      write_openmpi_howto
      /tmp/openmpi_howto.sh ${SHARED}
      #------------ 2 openMPI -----------
   fi
   if test "${WITH_PLATFORMMPI}" = "Y"
   then
      #------------ 2 PlatformMPI -----------
      echo
      echo ${ESC} "${BLUE}Installing PlatformMPI${OFF}"
      echo "PlatformMPI" > /tmp/STATUS
      write_platformmpi_master
      /tmp/platformmpi_master.sh ${LSF_TOP} ${SHARED}
      write_platformmpi_howto
      /tmp/platformmpi_howto.sh ${SHARED}
      #------------ 2 PlatformMPI -----------
   fi
   if test "${WITH_PROCESSMANAGER}" = "Y"
   then
      #------------ 2 ProcessManager -----------
      echo
      echo ${ESC} "${BLUE}Installing ProcessManager${OFF}"
      echo "ProcessManager" > /tmp/STATUS
      write_process_manager_master
      /tmp/process_manager_master.sh ${LSF_TOP}
      write_process_manager_howto
      /tmp/process_manager_howto.sh
      #------------ 2 ProcessManager -----------
   fi
   if test "${WITH_R}" = "Y"
   then
      #------------ 2 R -----------
      echo
      echo ${ESC} "${BLUE}Installing R${OFF}"
      echo "R" > /tmp/STATUS
      write_r_howto
      /tmp/r_howto.sh
      #------------ 2 R -----------
   fi
   if test "${WITH_RDOCK}" = "Y"
   then
      #------------ 2 rDock -----------
      echo
      echo ${ESC} "${BLUE}Installing rDock${OFF}"
      echo "rDock" > /tmp/STATUS
      write_rdock_howto
      /tmp/rdock_howto.sh
      #------------ 2 rDock -----------
   fi
   if test "${WITH_RESOURCE_CONNECTOR}" = "Y"
   then
      #------------ 2 Resource Connector -----------
      echo
      echo ${ESC} "${BLUE}Configuring Resource Connector${OFF}"
      echo "ResourceConnector" > /tmp/STATUS
      write_resource_connector_master
      /tmp/resource_connector_master.sh ${LSF_TOP} ${IBMCLOUD_API_KEY}
      write_resource_connector_howto
      /tmp/resource_connector_howto.sh ${LSF_TOP}
      #------------ 2 Resource Connector -----------
   fi
   if test "${WITH_RTM}" = "Y"
   then
      #------------ 2 RTM -----------
      echo
      echo ${ESC} "${BLUE}Installing RTM${OFF}"
      echo "RTM" > /tmp/STATUS
      write_rtm_master
      /tmp/rtm_master.sh
      write_rtm_howto
      /tmp/rtm_howto.sh
      #------------ 2 RTM -----------
   fi
   if test "${WITH_SANGER_IN_A_BOX}" = "Y"
   then
      #------------ 2 Sanger-in-a-box -----------
      echo
      echo ${ESC} "${BLUE}Installing Sanger-in-a-box${OFF}"
      echo "Sanger-in-a-box" > /tmp/STATUS
      write_sanger_in_a_box_master
      /tmp/sanger_in_a_box_master.sh ${SHARED} ${LSF_TOP}
      write_sanger_in_a_box_howto
      /tmp/sanger_in_a_box_howto.sh ${SHARED}
      #------------ 2 Sanger-in-a-box -----------
   fi
   if test "${WITH_SCALECLIENT}" = "Y"
   then
      #------------ 2 ScaleClient -----------
      echo
      echo ${ESC} "${BLUE}Installing ScaleClient${OFF}"
      echo "ScaleClient" > /tmp/STATUS
      write_scaleclient
      /tmp/scaleclient.sh
      #------------ 2 ScaleClient -----------
   fi
   if test "${WITH_SIMULATOR}" = "Y"
   then
      #------------ 2 Simulator -----------
      echo
      echo ${ESC} "${BLUE}Installing LSF Simulator${OFF}"
      echo "LSF Simulator" > /tmp/STATUS
      write_simulator_master
      /tmp/simulator_master.sh 
      write_simulator_howto
      /tmp/simulator_howto.sh
      #------------ 2 Simulator -----------
   fi
   if test "${WITH_SPARK}" = "Y"
   then
      #------------ 2 Spark -----------
      echo
      echo ${ESC} "${BLUE}Installing Spark${OFF}"
      echo "Spark" > /tmp/STATUS
      write_spark_master
      /tmp/spark_master.sh ${LSF_TOP} ${SHARED}
      write_spark_howto
      /tmp/spark_howto.sh ${SHARED}
      #------------ 2 Spark -----------
   fi
   if test "${WITH_STREAMFLOW}" = "Y"
   then
      #------------ 2 Streamflow -----------
      echo
      echo ${ESC} "${BLUE}Installing Streamflow${OFF}"
      echo "Streamflow" > /tmp/STATUS
      write_streamflow_master
      /tmp/streamflow_master.sh ${SHARED}
      write_streamflow_howto
      /tmp/streamflow_howto.sh ${SHARED}
      #------------ 2 Streamflow -----------
   fi
   if test "${WITH_STRESSNG}" = "Y"
   then
      #------------ 2 stress-ng -----------
      echo
      echo ${ESC} "${BLUE}Installing stress-ng${OFF}"
      echo "stress-ng" > /tmp/STATUS
      write_stressng_howto
      /tmp/stressng_howto.sh
      #------------ 2 stress-ng -----------
   fi
   if test "${WITH_TENSORFLOW}" = "Y"
   then
      #------------ 2 Tensorflow -----------
      echo
      echo ${ESC} "${BLUE}Installing Tensorflow${OFF}"
      echo "Tensorflow" > /tmp/STATUS
      write_tensorflow_master
      /tmp/tensorflow_master.sh ${LSF_TOP}
      write_tensorflow_howto
      /tmp/tensorflow_howto.sh
      #------------ 2 Tensorflow -----------
   fi
   if test "${WITH_TOIL}" = "Y"
   then
      #------------ 2 Toil -----------
      echo
      echo ${ESC} "${BLUE}Installing Toil${OFF}"
      echo "Toil" > /tmp/STATUS
      write_toil_master
      /tmp/toil_master.sh
       write_toil_howto
      /tmp/toil_howto.sh ${SHARED}
      #------------ 2 Toil -----------
   fi
   if test "${WITH_VELOXCHEM}" = "Y"
   then
      #------------ 2 Veloxchem -----------
      echo
      echo ${ESC} "${BLUE}Installing VeloxChem${OFF}"
      echo "VeloxChem" > /tmp/STATUS
      write_veloxchem_master
      /tmp/veloxchem_master.sh ${SHARED}
       write_veloxchem_howto
      /tmp/veloxchem_howto.sh ${SHARED}
      #------------ 2 Veloxchem -----------
   fi
   if test "${WITH_YELLOWDOG}" = "Y"
   then
      #------------ 2 Yellowdog -----------
      echo
      echo ${ESC} "${BLUE}Installing Yellowdog${OFF}"
      echo "Yellowdog" > /tmp/STATUS
      write_yellowdog
      /tmp/yellowdog.sh
      #------------ 2 Yellowdog -----------
   fi
;;
esac

##########################################################################

echo ${ESC} "${BLUE}############################################################${OFF}"
echo ${ESC} "${BLUE}######################## Finished ##########################${OFF}"
echo ${ESC} "${BLUE}############################################################${OFF}"
echo "Finished" > /tmp/STATUS
