#!/bin/bash

# variables

# main
TODAY=$(date +"%Y_%m_%d")
PASSWORD=`openssl rand 60 | openssl base64 -A`
# admin
USER=""
# root
GROUP=""
HOME="/home/${USER}"
DOCUMENTS="${HOME}/Documents"
LOG_FILE="/var/log/install_script.log"

# web
WEB_ROOT="/var/www/html"
# example
HOST_NAME=""
# example.com
DOMAIN_NAME=""
MAIL_DOMAIN_NAME="mail.${DOMAIN_NAME}"
# example.com
SITE_NAME=""
SITE_ADDR="https://${SITE_NAME}"
# if needed
GIT_USER=""
GIT_PASSWORD=""
MYSQL_PASSWORD=""

# zabbix
ZABBIX_DB=""
ZABBIX_USER=""
ZABBIX_PASSWORD=""
# varnish
VARNISH_HOST=""

# mod security
MOD_SECURITY_WHITELIST_LAN="192.168.0.0/24"
# public ip address
MOD_SECURITY_WHITELIST_REGEX="^@\.@\.@\.@"



# certificates

COUNTRY="BG"
STATE="Bulgaria"
LOCALITY="Sofia"
ORGANISATION="biboletin"
ORGANISATION_UNIT="biboletin"
COMMON_NAME="${DOMAIN_NAME}"
EMAIL=""




APACHE2_CONF="/etc/apache2/apache2.conf"
MOD_EVASIVE="/etc/apache2/mods-available/evasive.conf"
MOD_SECURITY="/etc/apache2/conf-available/security.conf"
MOD_SECURITY_2="/etc/apache2/mods-available/security2.conf"
MOD_QOS="/etc/apache2/mods-available/qos.conf"
PHP_74_CONF="/etc/php/7.4"
PHP_80_CONF="/etc/php/8.0"
PHP_81_CONF="/etc/php/8.1"
SESSION_NAME="PHPSESSID"

# network
IS_ROUTER="false"
# 192.168.0.1
SERVER_IP=""
# 1.2.3.4
EXTERNAL_IP=""
# 192.168.0.0/24
INTERNAL_NETWORK=""
# eno1
MAIN_NETWORK_INTERFACE=$(route | grep '^default' | grep -o '[^ ]*$')
SECOND_NETWORK_INTERFACE=""
LOOPBACK="lo"

# ports
SSH=22
PROFTP=21
HTTP=80
HTTPS=443
SMTP=25
IMAP=143
IMAPS=993
POP3=110
POP3S=995
DNS=53

# Create directories
DIRS=(
    "Downloads"
    "Documents"
    "Desktop"
    "Pictures"
)
# Install software
SOFTWARE=(
    "net-tools"
    "wget"
    "software-properties-common"
    "curl"
    "apache2"
    "mariadb-server"
    "php"
    "php8.1"
    "php8.2"
    "libapache2-mod-security2"
    "libapache2-mod-evasive"
    "libapache2-mod-qos"
    "libpam-cracklib"
    "apt-show-versions"
    "git"
    "fail2ban"
    "certbot"
    "python3-certbot-apache"
    "letsencrypt"
    "auditd"
    "sysstat"
    "chkrootkit"
    "clamav"
    "redis-server"
    "postfix"
    "mailutils"
    "vsftpd"
    "iptables"
    "iptables-persistent"
    "gnupg"
    "debsums"
    "cryptsetup"
    "varnish"
    "psad"
    "aide"
    "redis"
    "unzip"
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
    "apcu"
    "imagick"
    "gmp"
)

APACHE_MODULES=(
    "headers"
    "rewrite"
    "ssl"
    "evasive"
    "security"
    "proxy"
    "http2"
    "env"
    "dir"
    "mime"
)
