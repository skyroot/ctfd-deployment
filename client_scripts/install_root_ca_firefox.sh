#!/usr/bin/env bash

if [ "$EUID" -ne 0 ]; then 
  echo "Failed: Please run as root."
  printusage
  exit
fi

# Get the DIR of this file
DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$DIR" ]]; then DIR="$PWD"; fi

# Install certutil if required
if ! foobar_loc="$(type -p "certutil")" || [[ -z $foobar_loc ]]; then
  apt-get update
  apt-get install libnss3-tools -y
fi

certificateFile="$DIR/rootCA.crt"
certificateName="NCL Root Certificate Authority" 
for certDB in $(find  ~/.mozilla* -name "cert8.db")
do
  certDir=$(dirname ${certDB});
  echo "Installing '${certificateName}' into ${certDir}"
 certutil -A -n "${certificateName}" -t "TCu,Cuw,Tuw" -i ${certificateFile} -d ${certDir}
done
