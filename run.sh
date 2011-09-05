#!/bin/bash
# Main script for starting Larkc Auto Query.
# See README for more info.

# change to the directory where run.sh script is located
rundir=`dirname $0`
cd "$rundir"

# check for existance of needed files and directories 
if [ ! -f "./script/configuration.sh" ]; then
	echo "Error: configuration.sh file not found!"
	exit 1
fi

if [ ! -f "./script/larkc-access-functions.sh" ]; then
	echo "Error: larkc-access-functions.sh file not found!"
	exit 1
fi

if [ ! -f "./script/autoquery.sh" ]; then
	echo "Error: autoquery.sh file not found!"
	exit 1
fi

if [ ! -d "./queries-to-execute" ]; then
	echo "Error: queries-to-execute directory not found!"
	exit 1
fi

# load configuration
source "./script/configuration.sh"

# load larkc access functions
source "./script/larkc-access-functions.sh"


# before starting, make sure Larkc is running.
msg=`larkc_is_running "$PLATFORM"` 
if [ "$?" -ne 0 ]; then
	echo "Error: Larkc is not running! Reason: $msg"
	exit 1
fi

# enumerate all directories from "queries-to-execute" directory
cd "./queries-to-execute"
for directory in * ; do
	if [ -d "$directory" ]; then
		"../script/autoquery.sh" "$directory" &
	fi
done
# wait for the launched jobs to finish
wait
