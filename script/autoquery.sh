#!/bin/bash
# Script that takes as arguments a "workflow directory", creates the workflow from
# workflow.ttl and then sends the queries from "query*" or "queries*" files to the
# created workflow.


# trap SIGHUP, SIGINT or SIGTERM signals and try to terminate all child processes before exit
set -m
trap 'echo "terminate signal received; trying to terminate all child processes and then exit."; for job in `jobs -p` ; do kill $job ; done ; exit 1;' SIGHUP SIGINT SIGTERM

echo "$1 - Starting autoquery"

# check that we were called with "workflow directory" as argument
if [ -z "$1" ]; then
	echo "$1 - Error: missing workflow directory parameter!"
	exit 1
fi
if [ ! -d "$1" ]; then
	echo "$1 - Error: $1 not a valid directory!"
	exit 1
fi

rundir=`dirname $0`

# load configuration
source "$rundir/configuration.sh"

# load larkc access functions
source "$rundir/larkc-access-functions.sh"

# start processing workflow directory
cd "$1"
start_time=`date +%s`
# read workflow
workflow=`cat workflow*`
# create workflow and obtain the id
wid=`larkc_submit_workflow "$PLATFORM" "$workflow"`
if [ $? -ne 0 ]; then
	echo "$1 - Error creating the workflow! Reason: $wid"
	exit 1
fi
echo "$1 - workflow_id is: $wid"
# obtain the endpoint URL
endpoint=`larkc_get_workflow_endpoint "$PLATFORM" "$wid" "$EID"`
if [ $? -ne 0 ]; then
	echo "$1 - Error obtaining the endpoint URL! Reason: $endpoint"
	exit 1
fi
echo "$1 - endpoint URL is: $endpoint"

# iterate over "queries*" files
# each file can contain than one query that must be separated by line end terminator
for queryfile in queries* ; do
	if [ -f "$queryfile" ]; then
		echo
		echo "$1 - Reading queries file $queryfile"
		echo	
		count=0		
		while read query 
		do
			let count++
			echo "$1 - Processing query $count from file $queryfile"
			output_query=`larkc_query_endpoint "$endpoint" "$query"`
			echo "$1 - Query $count from file $queryfile result output size is ${#output_query}"
			echo
			sleep 1s
		done < $queryfile		
		echo "$1 - Finished processing $count queries from file $queryfile."
	fi
done
# iterate over "query*" files
# each file must contain only one query
for queryfile in query* ; do
	if [ -f "$queryfile" ]; then
		let count++
		query=$(cat $queryfile)			
		echo "$1 - Processing query $count from file $queryfile"
		output_query=`larkc_file_query_endpoint "$endpoint" "$queryfile"`
		if [ $? -ne 0 ]; then
			echo "$1 - Query $count from file $queryfile result ERROR: $output_query"
		else
			echo "$1 - Query $count from file $queryfile result output size is ${#output_query}"
			sleep 1s
		fi
	fi
done
# calculated total execution time
end_time=`date +%s`
echo "$1 - Finished execution. Total execution time was `expr $end_time - $start_time` s."
# try to delete created workflow
workflow_delete_result=`larkc_delete_workflow "$PLATFORM" "$wid"`
if [ $? -ne 0 ]; then
	echo "$1 - Error deleting workflow $wid! Reason: $workflow_delete_result"
fi
