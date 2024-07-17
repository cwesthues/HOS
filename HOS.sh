#!/bin/sh

############################################################

cat > /var/environment.sh <<EOF
SHARED="/shared"
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
   . install_functions.sh
fi

case ${ID_LIKE} in
*rhel*|*fedora*)
   ESC="-e"
;;
esac

############################################################

ALL_ADD_ONS="Apptainer Aspera BLAST Blender DataManager easyEDA Explorer Geekbench Intel-HPCKit iRODS-shell Jupyter LS-DYNA LWS MatlabRuntime Multicluster Nextflow Octave OpenFOAM openMPI PlatformMPI ProcessManager R rDock RTM Sanger-in-a-box Simulator ScaleClient Spark Streamflow stress-ng Tensorflow Toil VeloxChem Yellowdog"

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
   write_apptainer_compute
   /tmp/apptainer_compute.sh
   mkdir -p ${SHARED}/apptainer/images
   rm -rf ${SHARED}/apptainer/images
   apptainer build ${SHARED}/apptainer/images/ubuntu.sif docker://ubuntu
   cd ${LSF_TOP}
   chmod -R 777  apptainer/images
   write_apptainer_master ${LSF_TOP}
   /tmp/apptainer_master.sh ${LSF_TOP} ${SHARED}
   write_apptainer_howto
   /tmp/apptainer_howto.sh
fi
#---------------  Apptainer ---------------

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

