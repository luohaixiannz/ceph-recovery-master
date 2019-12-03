# Ceph Data Recovery
Tested with Ceph *Hammer*
## What these tools are for
These tools are useful to rescue RBD Images stored on Ceph OSDs when everything except the OSDs are lost or broken.
The tools allow you to extract the images from mounted OSDs without any Ceph Service running, so having physical OSDs mounted via network or locally is the only real requirement.

## Requirements
* OSDs must be accessible (filesystem)
* Have enough storage available to save the extracted images
* Patience - some steps need much time
* Screen? You should use screen when using ssh - some steps take multiple hours!

## Steps
To recover the data, two steps are needed:
1. Collect available data (Parts of the images distributed over all OSDs)
2. Reassemble the blocks

## Setup
1. Clone this repo to a place of your choice. Make sure that you have at least a few hundrets MB space in this directory.
2. Create a new subfolder `osds` in this folder.
3. Choose one of the following options or mix them:
3.1. Attach all OSDs as local storage. For every OSD create a subfolder in the `osds` folder and mount it there.
3.2  Use sshfs to mount OSDs over network / ssh

### Check
Your directory structure should look like this:  
```
| ..
| .
| assamble.sh
| collect_files.sh
| list_ids.sh
+- outputs
+- osds
 +- osd1
 +- osd2
 +- .......
```

## Step 1: Collect files
Quite easy:  
`./collect_files.sh osds`

This could take a bit longer. Depends on your mount strategy (local vs sshfs) and your network.

### First result
You have some new folders now: `vms` and `file_lists`.  
You should only be interested in the `vms` folder. It contains files named like your VM Images.  
Use `list_ids.sh` to print all VM Images found in step 1.

## Step 2: Recover Image
Now we have everything to reassemble an image. The parts belonging to a specific Image are known and listed in files stored in `file_lists`.  
To restore an image you need **4** information:
1. The name of the Image (`vms/vm-xyz-disk-n.id`)
2. the object size of the rbd, it is called 'order size' in rbd feature, it's value common to see 2M, 4M, 8M, you can use rbd info pool_name/rbd_name to see what the value is it
3. The size of the original image in GB. So when the VM disk was 32GB in total (not used space!), you should use **32**.  
  **Important**: If you are unsure about the actual disk size, choose a size which is **larger**! You can add some Bytes, MBytes or GBytes just to be sure
4. A destination folder. Just a folder with enough free space to store your image of the specified size. (e.g. `outputs/`)

Having these 4 information you can restore the image:  
`./assemble.sh vms/vm-xyz-disk-n.id 2 32 outputs/`

This will process all parts of the image and write it to a single image file. After this you can mount this image and access data or just put it back to a new cluster. 

**Repeat this for every disk image you need**.
