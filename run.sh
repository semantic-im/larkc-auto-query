#!/bin/bash
# Main script for starting Larkc Auto Query.
# See README for more info.

rundir=`dirname $0`

# check for existance of needed files and directories 
if [ ! -f "$rundir/script/configuration.sh" ]; then
	echo "Error: configuration.sh file not found!"
	exit 1
fi

if [ ! -f "$rundir/script/larkc-access-functions.sh" ]; then
	echo "Error: larkc-access-functions.sh file not found!"
	exit 1
fi

if [ ! -f "$rundir/script/autoquery.sh" ]; then
	echo "Error: autoquery.sh file not found!"
	exit 1
fi

if [ ! -d "$rundir/queries-to-execute" ]; then
	echo "Error: queries-to-execute directory not found!"
	exit 1
fi

# load configuration
source "$rundir/script/configuration.sh"

# load larkc access functions
source "$rundir/script/larkc-access-functions.sh"


# before starting, make sure Larkc is running.
msg=`larkc_is_running "$PLATFORM"` 
if [ "$?" -ne 0 ]; then
	echo "Error: Larkc is not running! Reason: $msg"
	exit 1
fi

# enumerate all directories from "queries-to-execute" directory
cd "$rundir/queries-to-execute"
for directory in * ; do
	if [ -d "$directory" ]; then
		"$rundir/script/autoquery.sh" "$directory" &
	fi
done
cd ..
