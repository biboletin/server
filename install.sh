#!/bin/bash


# if [[ $EUID -ne 0 ]]; then
#     echo "This script must be run as root"
#     exit 1
# fi

source helpers.sh

banner

source variables.sh

create_directories() {
    for dir in "${DIRS[@]}"; do
    main_message "Create $dir"
        if [ ! -d "${dir}" ]; then
            mkdir -p /home/${USER}/$dir
            chown -R ${USER}:${GROUP} /home/${USER}/${dir}
        fi
    done
}
install_software() {
    main_message "Installing software"
    source download.sh
}

configure_iptables() {
    main_message "Configure iptables"
    load_spinner
    source iptables.sh
}

configure_apache() {
    main_message "Configure LAMP"
    # main_message "NE PRAVI PROMENI V PHP konfiguraciite zarado php 7.4"
    load_spinner
    source apache.sh
}

backup_files() {
    main_message "Backup files before configuration"
    source backup_files.sh
    main_message "All files are with prefix \"backup.\" in their corresponding directory"
}

configure_files() {
    source configure.sh
}


# source permissions.sh

# yes | apt update
# yes | apt upgrade


# create_directories
# install_software
# configure_iptables
# backup_files
# configure_apache

configure_files
# configure_permissions

# configure_filesystem


# yes | apt update
# yes | apt upgrade

# echo "Generated password for redis: ${PASSWORD}"