#!/bin/sh

############################################################

RED='\e[1;31m'
GREEN='\e[1;32m'
BLUE='\e[1;34m'
OFF='\e[0;0m'

############################################################

. /etc/os-release

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

