#!/bin/bash
set -euo pipefail

# variables
EXCLUDED_FILES=(
	"20-iptables-4.sh"
	"21-iptables-6.sh"
)

# main
TODAY=$(date +"%Y_%m_%d")
PASSWORD=$(openssl rand 60 | openssl base64 -A)
# admin
USER="bibo"
# root
GROUP="bibo"
# home
HOME_DIR="/home/${USER}"

DOCUMENTS="${HOME_DIR}/Documents"
LOG_FILE="./logs/install.log"

# web
WEB_ROOT="/var/www/html"
# example
HOST_NAME="example"
# example.com
DOMAIN_NAME="example.com"
MAIL_DOMAIN_NAME="mail.${DOMAIN_NAME}"
# example.com
SITE_NAME="example.com"
SITE_ADDR="https://${SITE_NAME}"
# if needed
GIT_USER=""
GIT_PASSWORD=""
MYSQL_PASSWORD=""

# mod security
MOD_SECURITY_WHITELIST_LAN="192.168.0.0/24"
# public ip address
MOD_SECURITY_WHITELIST_REGEX="^@\.@\.@\.@"



# certificates

COUNTRY="BG"
STATE="Bulgaria"
LOCALITY="Sofia"
ORGANISATION="example"
ORGANISATION_UNIT="example"
COMMON_NAME="${DOMAIN_NAME}"
EMAIL="example@example.com"




APACHE2_CONF="/etc/apache2/apache2.conf"
MOD_EVASIVE="/etc/apache2/mods-available/evasive.conf"
MOD_SECURITY="/etc/apache2/conf-available/security.conf"
MOD_SECURITY_2="/etc/apache2/mods-available/security2.conf"
MOD_QOS="/etc/apache2/mods-available/qos.conf"
PHP_74_CONF="/etc/php/7.4"
PHP_80_CONF="/etc/php/8.0"
PHP_81_CONF="/etc/php/8.1"
PHP_82_CONF="/etc/php/8.2"
SESSION_NAME="PHPSESSID"

# network
CLOUDFLARE_IP_LIST="$HOME/Documents/cloudflare-ips.txt"

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

# Spoofing ips
SPOOFING_IPS=(
	""
)


# Create directories
DIRS=(
    "${HOME_DIR}/Downloads"
    "${HOME_DIR}/Documents"
    "${HOME_DIR}/Desktop"
    "${HOME_DIR}/Pictures"
)

# Install software
TOOLS=(
	"net-tools"
	"wget"
	"ufw"
	"htop"
	"dnsutils"
	"curl"
	"auditd"
	"sysstat"
	"unzip"
	"git"
	"fail2ban"
)

WEB=(
    "apache2"
    "php7.4"
    "php8.3"
    "php8.4"
    "redis"
    "varnish"
    "vsftpd"
    "libapache2-mod-security2"
    "libapache2-mod-evasive"
    "libapache2-mod-qos"
)

DATABASES=(
    "mariadb-server"
    "postgresql"
    "postgresql-contrib"
    "redis-server"
)

SECURITY=(
    "gnupg"
    "debsums"
    "cryptsetup"
    "chkrootkit"
    "clamav"
)
EMAIL=(
    "postfix"
    "mailutils"
)
SSL=(
	"certbot"
	"python3-certbot-apache"
	"letsencrypt"
)

FIREWALL=(
    "iptables"
    "iptables-persistent"
#    "psad"
#    "aide"
)

EXTRAS=(
	"software-properties-common"
	"apt-transport-https"
	"apt-show-versions"
	"ca-certificates"
	"libpam-cracklib"
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
