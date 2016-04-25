#!/bin/sh
# OPS-PROVISIONING
# Adapted from auto-provisioning script for Openswitch.
#
#
#-----------------Set Variables------------
path="http://10.85.0.248"
mapfile="mapping.txt"
#------------------------------------------
#
#
#Executing script
#setting variables
mapping="$path/$mapfile"
timedate=$(date +"%Y.%m.%d-%H.%M")

# executable files used by this script
VTYSH=/usr/bin/vtysh
LOGGER=/usr/bin/logger
TMP_LOG_FILE=/var/log/autoprovisioning.log
FLAG_CONF="configure t"
# Log the specified message using logger and avarlso to
# the file /var/log/autoprovisioning.log
ECHO_LOG=0
log_msg() {
#    $LOGGER -i $1
    echo $1 >> $TMP_LOG_FILE
    if [ $ECHO_LOG == 1 ]
    then
        echo $1
    fi
}
echo $mapping
wget -O $mapfile $mapping

# The script starts now
# create the log file
touch $TMP_LOG_FILE
chmod +w $TMP_LOG_FILE

log_msg "$timedate <<Executing provisioning script: demo.sh>>"

#send to vtysh
cmd="-c '$FLAG_CONF'"
execute_cmd() {
	if [ "$1" == "exit" ] ; then
		temp="$VTYSH $cmd"
		#echo eval $temp
		if [ "$temp">/dev/null ] ; then
			eval $temp
			#log_msg "Executed: $cmd"
		else
			log_msg "Could not execute: $cmd"
			log_msg "$timedate <<Provisioning script exit: [command] error>>"#			exit
			exit
		fi

		cmd="-c '$FLAG_CONF'"
		return
	else
		cmd="$cmd -c '$@'"
		return 	       
	fi
}

#check if mapping file copied over
if [ ! -f $mapfile ]; then
    log_msg "$mapfile"
    log_msg "Mapping file not found.."
    exit 1
fi

mac_address=$(cat /sys/class/net/eth0/address)

#find the config in mapping file to match the macaddress
#saves error in log file
if grep -iF $mac_address $mapfile | grep -v '^#' >/dev/null ; then
	name=$(grep -iF $mac_address $mapfile | grep -v '^#' |tail -n1 | awk '{print $2;}')
	file=$path/$name
else 
	echo "Configuration for the mac address <"$mac_address"> is not set"
	echo "Provisioning script exit: [mac address] error"
	log_msg "Configuration for the mac address <"$mac_address"> is not set"
	log_msg "Provisioning script exit: [mac address] error"\\n
	#log_msg "Exiting"
	exit 1
fi

#check if config file was copied over
wget -O $name $file

if [ ! -f $name ]; then
    log_msg "Setup file not found.."
    exit 1
fi

#loop through all the lines in the config file
cat $name | while read line
do
	if [ "$line" != ""  ]; then
		execute_cmd $line
	fi #remove white lines
done

rm $name $mapfile
log_msg "$timedate <<Succesfully executed provisioning script>>"
