#!/bin/bash
vmfile=$1
vm=$(basename $1 ".id" | tr -d '\000-\011\013\014\016-\037\r')
idpath=$(cat $vmfile | tr -d '\000-\011\013\014\016-\037\r')
id=$(cat $idpath | tr -d '\000-\011\013\014\016-\037\r')
filepath="file_lists/$id.files"
# dd Block Size
bsize=512
# Rados Object size (4MB)
obj_size_M=$3
((obj_size=$obj_size_M*1024*1024))
outpath=$4/
# rbd size
rbdsize_g=$2
((rbdsize=$rbdsize_g*1024*1024*1024))

echo $id
echo $vm
echo $filepath
delm="------------------------"
echo $delm
echo "CEPH RECOVERY"
echo "Assemble $vm with ID $id"
echo $delm
echo "Searching file list"
if [[ ! -e "$filepath" ]]; then
	echo "[ERROR] No files for $vm ($id.files does not exist)"
	exit
fi

echo "$filepath found"
echo $delm
imgfile="$outpath$vm.raw"
if [ ! -d "data" ]; then
	mkdir "data"
fi

if [ -f $imgfile ]; then
	echo "Image $imagefile already exists"
	echo "Aborting recovery"
	exit
fi

echo "Output Image will be $imgfile"
echo $delm
count=$(cat $filepath | wc -l)
echo "There are $count blocks found"
echo "The output file will be created as a file of size $rbdsize Bytes"
echo "The blocksize is $bsize"
echo $delm
echo "Creating Image file..."
dd if=/dev/zero of=${imgfile} bs=1 count=0 seek=${rbdsize} 2>/dev/null
echo "Starting reassembly..."
curr=1
echo -ne "0%\r"
for i in $(cat $filepath); do
	ver=$(echo $i | rev | cut -d "/" -f 1 | rev | cut -d "." -f 3 | cut -d "_" -f 1)
        num=$((16#$ver))
	offset=$(($obj_size * $num / $bsize))
	res=$(dd if=$i of=$imgfile bs=$bsize conv=notrunc seek=${offset} status=none)
	#perc=$((($curr*100)/$count))
	perc=$((($num*obj_size*100)/$rbdsize))
	bar="$perc % ["
	for j in {1..100}; do
		if [ $j -gt $perc ]; then
			bar=$bar"_"
		else
			bar=$bar"#"
		fi
	done
	bar=$bar"]\r"
	echo -ne $bar
	curr=$(($curr+1))
done
echo -ne "100%"
echo ""
echo "Image written to $imgfile"
