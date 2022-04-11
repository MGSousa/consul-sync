#!/bin/bash

set -eo pipefail

curl -sSL https://func-e.io/install.sh | sudo bash -s -- -b /usr/local/bin

if [ "$1" = "M1" ]; then
	export FUNC_E_PLATFORM=darwin/amd64
fi;

func-e use 1.20.1

sudo cp ~/.func-e/versions/1.20.1/bin/envoy /usr/local/bin/

envoy --version
