
NODES="vm-0-167 vm-0-175 vm-1-12 vm-1-13 vm-1-14 vm-1-15"
RESOURCES="load_avg mem_used"

for node in $NODES
do
	for resource in $RESOURCES
	do
	cat ${resource}.log | grep -A 1 $node --no-group-separator \
| grep $resource | sed 's/^.*=//g' | sed 's/M$//g' | sed 's/G$/*1000/' | bc -l > node_${node}_${resource}.dat
done
done