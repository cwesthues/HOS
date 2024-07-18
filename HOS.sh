#!/bin/sh

############################################################

FOUND_SHARED=`cat /etc/fstab | egrep ^[0-9] | egrep -v "/mnt/lsf" | awk '{print $2}'`
echo -n "Enter shared path (<Enter> for '${FOUND_SHARED}'): "
read SHARED
if test "${SHARED}" = ""
then
   SHARED="${FOUND_SHARED}"
fi


cat > /var/environment.sh <<EOF
SHARED="${SHARED}"
LSF_TOP="/opt/ibm/lsf"
EOF
chmod 755 /var/environment.sh
. /var/environment.sh


############################################################

RED='\e[1;31m'
GREEN='\e[1;32m'
BLUE='\e[1;34m'
OFF='\e[0;0m'

############################################################

. /etc/os-release
if test ! -f install_functions.sh
then
   echo "ERROR: install_functions.sh not found, exiting."
   exit 1
else
   . ./install_functions.sh
fi

case ${ID_LIKE} in
*rhel*|*fedora*)
   ESC="-e"
;;
esac

############################################################

ALL_ADD_ONS="Apptainer Aspera BLAST DataManager Intel-HPCKit iRODS-shell LS-DYNA MatlabRuntime Nextflow Octave R rDock Sanger-in-a-box Spark Streamflow stress-ng Tensorflow Toil VeloxChem"

echo ${ESC} ""
echo ${ESC} "${BLUE}Select Add-On's${OFF}"
echo ${ESC} "${BLUE}===============${OFF}"

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
echo -n "Select Add-On(s) [${HEAD} - ${TAIL}]: "
read ADD_ONS
ADD_ONS=`echo ${ADD_ONS} | sed s/","/" "/g`
echo
echo "You selected ${ADD_ONS}"

#---------------  Apptainer ---------------
RET=`echo " ${ADD_ONS} " | fgrep ' Apptainer '`
if test "${RET}" != ""
then
   write_apptainer_master ${LSF_TOP}
   /tmp/apptainer_master.sh ${LSF_TOP} ${SHARED}
   mkdir -p ${SHARED}/apptainer/images
   rm -rf ${SHARED}/apptainer/images/*
   apptainer build ${SHARED}/apptainer/images/ubuntu.sif docker://ubuntu
   chmod -R 777  ${SHARED}/apptainer/images
   write_apptainer_howto
   /tmp/apptainer_howto.sh
fi
#---------------  Apptainer ---------------

#-----------------  Aspera ----------------
RET=`echo " ${ADD_ONS} " | fgrep ' Aspera '`
if test "${RET}" != ""
then
   write_aspera_master
   /tmp/aspera_master.sh
   write_aspera_howto
   /tmp/aspera_howto.sh
fi
#-----------------  Aspera ----------------

#-----------------  BLAST -----------------
RET=`echo " ${ADD_ONS} " | fgrep ' BLAST '`
if test "${RET}" != ""
then
   write_blast
   /tmp/blast.sh ${SHARED}
   write_blast_howto
   /tmp/blast_howto.sh
fi
#-----------------  BLAST -----------------

#--------------  Datamanager --------------
RET=`echo " ${ADD_ONS} " | fgrep ' DataManager '`
if test "${RET}" != ""
then
   write_datamanager_master
   /tmp/datamanager_master.sh ${LSF_TOP}
   write_datamanager_howto
   /tmp/datamanager_howto.sh
fi
#--------------  Datamanager --------------

#-------------  Intel-HPCKit --------------
RET=`echo " ${ADD_ONS} " | fgrep ' Intel-HPCKit '`
if test "${RET}" != ""
then
   write_intelhpckit
   /tmp/intelhpckit.sh
fi
#-------------  Intel-HPCKit --------------

#--------------  iRODS-shell --------------
RET=`echo " ${ADD_ONS} " | fgrep ' iRODS-shell '`
if test "${RET}" != ""
then
   write_irods
   /tmp/irods.sh
fi
#--------------  iRODS-shell --------------

#----------------  LS-DYNA ----------------
RET=`echo " ${ADD_ONS} " | fgrep ' LS-DYNA '`
if test "${RET}" != ""
then
   write_lsdyna_compute
   /tmp/lsdyna_compute.sh
fi
#----------------  LS-DYNA ----------------

#-------------  MatlabRuntime -------------
RET=`echo " ${ADD_ONS} " | fgrep ' MatlabRuntime '`
if test "${RET}" != ""
then
   write_matlab_master ${SHARED}
   /tmp/matlab_master.sh
   write_matlab_howto ${SHARED}
   /tmp/matlab_howto.sh
fi
#-------------  MatlabRuntime -------------

#---------------  Nextflow ----------------
RET=`echo " ${ADD_ONS} " | fgrep ' Nextflow '`
if test "${RET}" != ""
then
   write_nextflow_master
   /tmp/nextflow_master.sh ${LSF_TOP}
   write_nextflow_howto
   /tmp/nextflow_howto.sh ${SHARED} ${LSF_TOP}
fi
#---------------  Nextflow ----------------

#-----------------  Octave ----------------
RET=`echo " ${ADD_ONS} " | fgrep ' Octave '`
if test "${RET}" != ""
then
   write_octave_compute
   /tmp/octave_compute.sh
   write_octave_master
   /tmp/octave_master.sh ${LSF_TOP}
   write_octave_howto
   /tmp/octave_howto.sh
fi
#-----------------  Octave ----------------

#-------------------  R -------------------
RET=`echo " ${ADD_ONS} " | fgrep ' R '`
if test "${RET}" != ""
then
   write_r
   /tmp/r.sh
   write_r_howto
   /tmp/r_howto.sh
fi
#-------------------  R -------------------

#-----------------  rDock -----------------
RET=`echo " ${ADD_ONS} " | fgrep ' rDock '`
if test "${RET}" != ""
then
   write_rdock
   /tmp/rdock.sh
   write_rdock_howto
   /tmp/rdock_howto.sh
fi
#-----------------  rDock -----------------

#------------  Sanger-in-a-box ------------
RET=`echo " ${ADD_ONS} " | fgrep ' Sanger-in-a-box '`
if test "${RET}" != ""
then
   write_sanger_in_a_box_master
   /tmp/sanger_in_a_box_master.sh ${SHARED} ${LSF_TOP}
   write_sanger_in_a_box_howto
   /tmp/sanger_in_a_box_howto.sh ${SHARED}
fi      
#------------  Sanger-in-a-box ------------

#-----------------  Spark -----------------
RET=`echo " ${ADD_ONS} " | fgrep ' Spark '`
if test "${RET}" != ""
then
   write_spark_compute
   /tmp/spark_compute.sh ${LSF_TOP}
   write_spark_master
   /tmp/spark_master.sh ${LSF_TOP} ${SHARED}
   write_spark_howto
   /tmp/spark_howto.sh ${SHARED}
fi
#-----------------  Spark -----------------

#---------------  Streamflow --------------
RET=`echo " ${ADD_ONS} " | fgrep ' Streamflow '`
if test "${RET}" != ""
then
   write_streamflow_master
   /tmp/streamflow_master.sh ${SHARED}
   write_streamflow_howto
   /tmp/streamflow_howto.sh ${SHARED}
fi
#---------------  Streamflow --------------

#---------------  stress-ng ---------------
RET=`echo " ${ADD_ONS} " | fgrep ' stress-ng '`
if test "${RET}" != ""
then
   write_stressng_compute
   /tmp/stressng_compute.sh ${LSF_TOP}
   write_stressng_howto
   /tmp/stressng_howto.sh
fi
#---------------  stress-ng ---------------

#---------------  Tensorflow ---------------
RET=`echo " ${ADD_ONS} " | fgrep ' Tensorflow '`
if test "${RET}" != ""
then
   write_tensorflow_master
   /tmp/tensorflow_master.sh ${LSF_TOP}
   write_tensorflow_howto
   /tmp/tensorflow_howto.sh
   write_tensorflow_compute
   /tmp/tensorflow_compute.sh
fi
#---------------  Tensorflow ---------------

#------------------  Toil ------------------
RET=`echo " ${ADD_ONS} " | fgrep ' Toil '`
if test "${RET}" != ""
then
      write_toil_master
      /tmp/toil_master.sh
       write_toil_howto
      /tmp/toil_howto.sh ${SHARED}
      write_toil_compute
      /tmp/toil_compute.sh
fi
#------------------  Toil ------------------

#----------------  VeloxChem ---------------
RET=`echo " ${ADD_ONS} " | fgrep ' VeloxChem '`
if test "${RET}" != ""
then
   write_veloxchem_compute
   /tmp/veloxchem_compute.sh
   write_veloxchem_master
   /tmp/veloxchem_master.sh ${SHARED}
    write_veloxchem_howto
   /tmp/veloxchem_howto.sh ${SHARED}
fi
#----------------  VeloxChem ---------------
