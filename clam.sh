#!/bin/bash

folder_scan="/home/jb/Desktop/analyse_file"

clamscan -r "$folder_scan"
status=$?

# 0 = RAS
# 1 = infecté 
# 2 = erreur 

if [ $status -eq 1 ]; then
    echo "INFECTE"
fi


