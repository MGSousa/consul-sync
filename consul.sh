#!/bin/bash

set -eo pipefail

TYPE=$1
VERSION="0.5.2" #TODO: change this
BASE_NAME=$(basename "$0")
BASE_PATH=$(dirname "$0")
RELEASE="/etc/*-release"

# shellcheck disable=SC2086
OS=$( (grep ID_LIKE ${RELEASE} || grep ID ${RELEASE}) | awk -F= '{print $2}')

install_envoy() {
	./envoy.sh
}

install_consul() {
	install_envoy
	# install consul
	case $OS in
	    "arch")
	      	sudo pacman -Sy && sudo pacman --noconfirm -Sy consul
	      	;;
            "debian")	
	    	curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
		sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
		sudo apt-get update && sudo apt-get install consul
		;;
	    "rhel fedora")
		sudo yum install -y yum-utils
		sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/RHEL/hashicorp.repo
		sudo yum -y install consul
		;;
	    *)
		echo "Dist [$OS] not supported!"
		;;
	esac	
}

install_cts() {
	# shellcheck disable=SC2086
	wget -nv https://releases.hashicorp.com/consul-terraform-sync/${VERSION}/consul-terraform-sync_${VERSION}_linux_amd64.zip -O cts.zip && \
	unzip cts.zip && rm -rf cts.zip \
	sudo mv consul-terraform-sync /usr/local/bin/
}

dev() {
	consul agent -dev
}

prod() {
	cp "$BASE_PATH"/consul.hcl /etc/consul.d/
	
}

case "$TYPE" in
  dev)
    dev
    ;;
  prod)
    prod
    ;;
  install)
    install_consul
    install_cts
    ;;
  *)
    echo "Usage: $BASE_NAME {dev|prod|install}"
    exit 1
esac
