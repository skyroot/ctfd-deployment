#!/usr/bin/env bash

printusage() {
  echo "Usage: sudo $0"
}

if [ "$EUID" -ne 0 ]; then 
  echo "Failed: Please run as root."
  printusage
  exit
fi

# Get the DIR of this file
DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$DIR" ]]; then DIR="$PWD"; fi

# Install certutil if it is not installed
if ! foobar_loc="$(type -p "certutil")" || [[ -z $foobar_loc ]]; then
  apt-get update
  apt-get install libnss3-tools -y
fi



certfile="$DIR/../rootCA.crt"
certname="NCL Root Certificate Authority"

### For cert8 (legacy - DBM)
for certDB in $(find ~/ -name "cert8.db")
do
    certdir=$(dirname ${certDB});
    certutil -A -n "${certname}" -t "TCu,Cu,Tu" -i ${certfile} -d dbm:${certdir}
done

### For cert9 (SQL)
for certDB in $(find ~/ -name "cert9.db")
do
    certdir=$(dirname ${certDB});
    certutil -A -n "${certname}" -t "TCu,Cu,Tu" -i ${certfile} -d sql:${certdir}
done
