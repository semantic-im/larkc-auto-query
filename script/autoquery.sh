#!/bin/bash
# Script that takes as arguments a "workflow directory", creates the workflow from
# workflow.ttl and then sends the queries from "query*" or "queries*" files to the
# created workflow.

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


cq=0
ec=0
start_time=`date +%s`

# read workflow
workflow=`cat workflow*`
echo "$1 - $workflow"
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

# iterate over "query*" files
# they must contain one query per line
for queryfile in queries* ; do
	if [ -f "$queryfile" ]; then
		echo
		echo "$1 - Reading query file $queryfile"
		echo	
		count=0		
		while read query 
		do
			let count++
			echo "$1 - $count > Processing $query"
			output_query=`larkc_query_endpoint "$endpoint" "$query"`
			echo "$1 - The output for query $query is $output_query"
			echo "$1 - Done with query $query"
			echo
			sleep 5s
		done < $queryfile		
		echo "$1 - Processed $count queries from $queryfile"
	fi
done

for queryfile in query* ; do
	if [ -f "$queryfile" ]; then
		
		let ec++
		let cq++
		
		query=$(cat $queryfile)			
		echo "$1 - entering queryEndpoint"
		output_query=`larkc_file_query_endpoint "$endpoint" "$queryfile"`
		echo "$1 - exit queryEndpoint"
		
		echo "$1 - <EXECUTION_$ec>"
		
		echo "$1 - <QUERY_$cq>"
		#echo "$query"
		echo "$1 - </QUERY_$cq>"
		
		echo "$1 - <RESULT_$cq>"
		echo "$1 - $output_query"
		echo "$1 - </RESULT_$cq>"
		
		echo "$1 - </EXECUTION_$ec>"
		echo "$1 - <QUERY_FILE> $queryfile </QUERY_FILE>"
		#DO A SLEEP for 5 seconds BEFORE SUBMITTING A NEW QUERY -- HOPE WE DON'T GET REJECTED BY LLD SERVER
		sleep 5s

	fi
done
larkc_delete_workflow "$PLATFORM" "$wid"
	
end_time=`date +%s`
echo "$1 - Execution time was `expr $end_time - $start_time` s."
