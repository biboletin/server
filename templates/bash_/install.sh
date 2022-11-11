#!/bin/bash

# Install software
SOFTWARE=(
    "software-properties-common"
    "apache2"
    "mysql-server"
    "php"
    "php7.4"
    "php8.0"
    "php8.1"
    "libapache2-mod-security2"
    "libapache2-mod-evasive"
    "libapache2-mod-qos"
    "libpam-cracklib"
    "libpam-pwquality"
    "apt-show-versions"
    "git"
    "fail2ban"
    "certbot"
    "letsencrypt"
    "auditd"
    "sysstat"
    "chkrootkit"
    "clamav"
    "redis-server"
    "net-tools"
    "postfix"
    "mailutils"
    "vsftpd"
    "iptables"
    "iptables-persistent"
    "gnupg"
    "debsums"
    "cryptsetup"
    "varnish"
)

# Install php extensions
PHP_EXTENSIONS=(
    "cli"
    "fpm"
    "common"
    "mysql"
    "zip"
    "gd"
    "mbstring"
    "curl"
    "bcmath"
    "fileinfo"
    "tokenizer"
    "ctype"
    "pdo"
    "xml"
    "xmlwriter"
    "xmlreader"
    "zip"
    "apcu"
    "imagick"
    "gmp"
)


yes | apt update
yes | apt upgrade


for app in ${SOFTWARE[*]}; do
    if ! command ${app} -v &> /dev/null
    then
        apt --assume-yes install $app
    fi

    if [ "php7.4" == $app ] || [ "php8.0" == $app ] || [ "php8.1" == $app ]; then
        for lib in ${PHP_EXTENSIONS[*]}; do
            apt --assume-yes install $app'-'$lib
        done
    fi
done

echo "Add php and apache repositories"
yes | add-apt-repository ppa:ondrej/php
yes | add-apt-repository ppa:ondrej/apache2