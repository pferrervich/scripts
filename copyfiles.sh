#!/bin/bash/
#Asks you the origin folder, the destination folder an then finds the files with the 
#size specified and copies them to the destination folder.
echo "Type the folder URI of the files you want to copy"
read dir1
echo "Type the folder URI where you want to copy the files" 
read dir2
echo "Type the size of the files that you want to copy ([+/-] k / M / G)"
read size

find $dir1 -type f -size $size -exec cp -nv {} $dir2/ \;
