#!/bin/sh

resources[1]='load_avg'
resources[2]='mem_used'

RESOURCE_FILES[1]=${1}/load_avg.log
RESOURCE_FILES[2]=${1}/mem_used.log


for res_id in `seq 1 2`
do
	result=`qstat -F ${resources[res_id]}`
	timestamp=`date --utc +%Y%m%d_%H%M%SZ`
	echo $timestamp >> ${RESOURCE_FILES[$res_id]}
	for node in `qconf -sel`
	do
		node=${node/.ostk.dkfz-heidelberg.de/}
		echo "$result" | grep -A1 $node >> ${RESOURCE_FILES[$res_id]}
	done
done

