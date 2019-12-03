#!/bin/bash

OSDDIR=$1

# Loop all OSDs
for x in $(ls $OSDDIR); do
	echo Scanning $x
	# SEARCH ALL _head directories
	for y in $(find $OSDDIR/$x/current -type d -size +1b | grep _head); do
		find $y -type f -name *udata* >> files.list.all.tmp
		find $y -type f -name *uid* >> vms.list.all.tmp
	done
done

mkdir file_lists

# Sort collected data by Header
echo "Preparing UDATA files"
for l in $(cat files.list.all.tmp | rev | cut -d "/" -f 1 | rev | cut -d "." -f 2 | sort -u); do
	cat files.list.all.tmp | grep $l | sort -u -k4,4 -t "." -s  >> file_lists/$l.files
done
#rm files.list.all.tmp
echo "UDATA files ready"


mkdir vms
# Scan VM IDs
echo "Extracting VM IDs"
for l in $(cat vms.list.all.tmp | sort -u); do
	vm=$(echo $l | rev | cut -d "/" -f 1 | rev | cut -d "." -f 2 | cut -d "_" -f 1)
	echo $l > vms/$vm.id
done
echo "VM IDs extracted"

#rm vms.list.all.tmp
