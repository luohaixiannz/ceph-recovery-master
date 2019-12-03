#!/bin/bash
vmdir="vms"

for vmfile in $(ls -1 $vmdir); do
	vm=$(basename $vmdir/$vmfile ".id" | tr -d '\000-\011\013\014\016-\037\r')
	idpath=$(cat $vmdir/$vmfile | tr -d '\000-\011\013\014\016-\037\r')
	id=$(cat $idpath | tr -d '\000-\011\013\014\016-\037\r')
	echo "$vm has ID $id"
done
