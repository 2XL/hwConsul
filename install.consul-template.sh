#!/usr/bin/env bash

#!/bin/bash

CONSUL_VERSION=0.16.0
MACHINE_TYPE=`uname -m`


if [ -f consul-template ]; then
  exit 0
fi

which unzip

if [ $? -ne 0 ]; then
  sudo apt-get update
  sudo apt-get install -y unzip
fi

if [ "$OSTYPE" == "linux-gnu" ]; then
        # ...
        DIST="linux"
elif [ "$OSTYPE" == "darwin"* ]; then
        # Mac OSX
        DIST="darwin"
else
        # Unknown.
        echo "Distro not available, please rollback to manual install"
        echo "https://www.consul.io/downloads.html"
        exit 1
fi


if [ ${MACHINE_TYPE} == 'x86_64' ]; then
  ARCH=amd64
else
  ARCH=386
fi

URI=https://releases.hashicorp.com/consul-template/${CONSUL_VERSION}/
FILENAME=consul-template_${CONSUL_VERSION}_${DIST}_${ARCH}.zip

wget $URI$FILENAME
unzip $FILENAME
rm $FILENAME
