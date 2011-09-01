# Larkc REST APIs bash access functions

# check to see if Larkc is running
# input $1 larkc platform URL
# output error message
# returns 0 if Larkc can be accessed ; 1 otherwise
function larkc_is_running {
	if [ -z "$1" ]; then
		echo "submit_workflow() error: missing larkc platform URL parameter#1 !"
		return 1
	fi
	curl -s -S --connect-timeout 3 --max-time 10 http://$1/workflows 2>&1
}

# submits the workflow description to the platform and returns the workflow id
# input $1 larkc platform URL
# input $2 workflow content
# output workflow id
# returns 0 if all ok ; 1 otherwise
function larkc_submit_workflow {
	if [ -z "$1" ]; then
		echo "submit_workflow() error: missing larkc platform URL parameter#1 !"
		return 1
	fi
	if [ -z "$2" ]; then
		echo "submit_workflow() error: missing workflow content parameter#2 !"
		return 1
	fi
	curl -s -S --connect-timeout 3 --max-time 10 --data-urlencode "workflow=$2" http://$1/workflow 2>&1
}

# obtains the endpoint URL of the given workflow id
# input $1 larkc platform URL
# input $2 workflow id
# input $3 endpoint name
# output endpoint URL
# returns 0 if all ok ; 1 otherwise
function larkc_get_workflow_endpoint {
	if [ -z "$1" ]; then
		echo "get_workflow_endpointO() error: missing larkc platform URL parameter#1 !"
		return 1
	fi
	if [ -z "$2" ]; then
		echo "get_workflow_endpointO() error: missing workflow id parameter#2 !"
		return 1
	fi
	if [ -z "$3" ]; then
		echo "get_workflow_endpointO() error: missing endpoint name parameter"
		return 1
	fi
	curl -s -S --connect-timeout 3 --max-time 10 "http://$1/workflow/$2/endpoint?urn=$3" 2>&1
}

# deletes the workflow identified by the workflow id
# input $1 larkc platform URL
# input $2 workflow id
# returns 0 if all ok ; 1 otherwise
function larkc_delete_workflow {
	if [ -z "$1" ]; then
		echo "delete_workflow() error: missing larkc platform URL parameter#1 !"
		return 1
	fi
	if [ -z "$2" ]; then
		echo "delete_workflow() error: missing workflow id parameter#2 !"
		return 1
	fi
	curl -s -S --connect-timeout 3 --max-time 10 -X DELETE "http://$1/rdf/workflows/$2" 2>&1
}

# sends a query to the given endpoint and returns the result
# input $1 endpoint URL
# input $2 query content
# output query result
# returns 0 if all ok ; 1 otherwise
function larkc_query_endpoint {
	if [ -z "$1" ]; then
		echo "query_endpoint() error: missing endpoint URL parameter#1 !"
		return 1
	fi
	if [ -z "$2" ]; then
		echo "query_endpoint() error: missing query content parameter#2 !"
		return 1
	fi
	curl -s -S --connect-timeout 3 --max-time 120 --data-urlencode "query=$2" "$1" 2>&1
}

# sends a query, read from file, to the given endpoint and returns the result
# input $1 endpoint URL
# input $2 file name containing the query
# output query result
# returns 0 if all ok ; 1 otherwise
function larkc_file_query_endpoint {
	if [ -z "$1" ]; then
		echo "query_endpoint() error: missing endpoint URL parameter#1 !"
		return 1
	fi
	if [ -z "$2" ]; then
		echo "query_endpoint() error: missing file name containing the query parameter#2 !"
		return 1
	fi
	if [ ! -f "$2" ]; then
		echo "query_endpoint() error: parameter#2 $2 not a file !"
		return 1
	fi
	curl -s -S --connect-timeout 3 --max-time 120 --data-urlencode "query@$2" "$1" 2>&1
}
