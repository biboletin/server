#!/bin/bash
set -euo pipefail

# Helper functions for the web server configurator
# This script provides utility functions for displaying messages, loading spinners, and creating backups.

banner() {
    clear
    echo "
***************************************************
*               Web server configurator           *
***************************************************
"
}

update_packages() {
	info "Updating package lists..."

	apt-get update -y

	if [ $? -ne 0 ]; then
		error "Failed to update package lists"
	fi

	info "Upgrading installed packages..."

	apt-get upgrade -y

	if [ $? -ne 0 ]; then
		error "Failed to upgrade installed packages"
	fi

	apt-get autoremove -y
	apt-get autoclean -y
}

# Informative messages
info() {
    echo -e "\e[36m[INFO]\e[00m $1"
}

# Warning messages
warning() {
    echo -e "\e[93m[WARNING]\e[00m $1"
}

# Error messages
error() {
    echo -e "\e[31m[ERROR]\e[00m $1"
    exit 1
}

# Success messages
success() {
    echo -e "\e[32m[SUCCESS]\e[00m $1"
}

# Prechecks
precheck() {
	echo -e "\e[93m[PRECHECK]\e[00m $1"
}

# Installing messages
installing() {
	echo -e "\e[34m[INSTALL]\e[00m $1"
}

# Configuration messages
configure() {
	echo -e "\e[34m[CONFIGURE]\e[00m $1"
}

# Function to install packages if not already installed
install_packages() {
	local packages=("$@")

	for pkg in "${packages[@]}"; do
        if ! dpkg -s "$pkg" >/dev/null 2>&1; then
            plus_sign "Installing $pkg..."
#            apt install -y "$pkg"
        else
            minus_sign "$pkg already installed"
        fi
    done
}

plus_sign() {
#    echo -e "\e[34m-------------------------------------------------------------\e[00m"
    echo -e "\e[93m[+]\e[00m $1"
#    echo -e "\e[34m-------------------------------------------------------------\e[00m"
#    echo ""
}
minus_sign() {
#    echo -e "\e[34m-------------------------------------------------------------\e[00m"
    echo -e "\e[35m[-]\e[00m $1"
#    echo -e "\e[34m-------------------------------------------------------------\e[00m"
#    echo ""
}

load_spinner() {
    bar="++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
    barlength=${#bar}
    i=0
    while ((i < 100)); do
        n=$((i * barlength / 100))
        printf "\e[00;34m\r[%-${barlength}s]\e[00m" "${bar:0:n}"
        ((i += RANDOM % 5 + 2))
        sleep 0.02
    done
    echo -e "\033[2K"
}

#
create_copy() {
    echo "$1"
    file="$(basename "$1")"
    path="$(dirname "$1")"

    cp "$1 ${path}/backup.${file}"
}
