#!/bin/bash


# main
TODAY=$(date +"%Y_%m_%d")
PASSWORD=`openssl rand 60 | openssl base64 -A`
USER="user"
GROUP="user"
HOME="/home/${USER}"
DOCUMENTS=${HOME}/Documents

# web
WEB_ROOT="/var/www/html"
HOST_NAME="example"
DOMAIN_NAME="example.com"
SITE_NAME="example.com"
SITE_ADDR="https://${SITE_NAME}"

APACHE2_CONF="/etc/apache2/apache2.conf"
MOD_EVASIVE="/etc/apache2/mods-available/evasive.conf"
MOD_SECURITY="/etc/apache2/conf-available/security.conf"
PHP_74_CONF="/etc/php/7.4"
PHP_80_CONF="/etc/php/8.0"
PHP_81_CONF="/etc/php/8.1"
SESSION_NAME="PHPSESSID"


APACHE_MODULES=(
    "headers"
    "rewrite"
    "ssl"
    "evasive"
    "proxy"
    "http2"
)

echo "Allow apache modules"
for module in ${APACHE_MODULES[*]}; do
    a2enmod $module
    echo "a2enmod" $module
done

echo "Configure apache conf"
# Set apache2 timeout
sed -i 's/Timeout 300/Timeout 60/' ${APACHE2_CONF}
# Set DH algorithms
if ! grep -q 'SSLCipherSuite' ${APACHE2_CONF}; then
    echo "SSLProtocol all -SSLv2 -SSLv3 -TLSv1 -TLSv1.1" >> ${APACHE2_CONF}
    echo "SSLCipherSuite ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-C>" >> ${APACHE2_CONF}
fi

echo "Configure_mod_evasive"
# Configure mod_evasive
if [ -f "$MOD_EVASIVE" ]; then
    if grep -q "#DOSHashTableSize" ${MOD_EVASIVE}; then
        sed -i "s/#DOSHashTableSize/DOSHashTableSize/g" ${MOD_EVASIVE}
    else 
        sed -i "s/# DOSHashTableSize/DOSHashTableSize/g" ${MOD_EVASIVE}
    fi
    ######
    if grep -q "#DOSPageCount" ${MOD_EVASIVE}; then
        sed -i "s/#DOSPageCount/DOSPageCount/g" ${MOD_EVASIVE}
    else 
        sed -i "s/# DOSPageCount/DOSPageCount/g" ${MOD_EVASIVE}
    fi
    ######
    if grep -q "#DOSSiteCount" ${MOD_EVASIVE}; then
        sed -i "s/#DOSSiteCount/DOSSiteCount/g" ${MOD_EVASIVE}
    else 
        sed -i "s/# DOSSiteCount/DOSSiteCount/g" ${MOD_EVASIVE}
    fi
    ######
    if grep -q "#DOSPageInterval" ${MOD_EVASIVE}; then
        sed -i "s/#DOSPageInterval/DOSPageInterval/g" ${MOD_EVASIVE}
    else 
        sed -i "s/# DOSPageInterval/DOSPageInterval/g" ${MOD_EVASIVE}
    fi
    ######
    if grep -q "#DOSSiteInterval" ${MOD_EVASIVE}; then
        sed -i "s/#DOSSiteInterval/DOSSiteInterval/g" ${MOD_EVASIVE}
    else 
        sed -i "s/# DOSSiteInterval/DOSSiteInterval/g" ${MOD_EVASIVE}
    fi
    ######
    if grep -q "#DOSBlockingPeriod" ${MOD_EVASIVE}; then
        sed -i "s/#DOSBlockingPeriod/DOSBlockingPeriod/g" ${MOD_EVASIVE}
    else 
        sed -i "s/# DOSBlockingPeriod/DOSBlockingPeriod/g" ${MOD_EVASIVE}
    fi
    ######
fi

echo "configure_mod_security"
# # Configure mod_security
# # Hide Server info
# # Set security headers
# ######
if [ -f "${MOD_SECURITY}" ]; then
    if grep -q "#ServerTokens Full" ${MOD_SECURITY}; then
        sed -i "s/#ServerTokens Full/ServerTokens Prod/g" ${MOD_SECURITY}
    else
        sed -i "s/# ServerTokens Full/ServerTokens Prod/g" ${MOD_SECURITY}
    fi
    ######
    if grep -q "#ServerSignature On" ${MOD_SECURITY}; then
        sed -i "s/#ServerSignature On/ServerSignature Off/g" ${MOD_SECURITY}
    else 
        sed -i "s/# ServerSignature On/ServerSignature Off/g" ${MOD_SECURITY}
    fi
    ######
    if grep -q "#TraceEnable Off" ${MOD_SECURITY}; then
        sed -i "s/#TraceEnable On/TraceEnable Off/g" ${MOD_SECURITY}
    else 
        sed -i "s/# TraceEnable On/TraceEnable Off/g" ${MOD_SECURITY}
    fi
    ######
    if grep -q "#Header set X-Content-Type-Options: \"nosniff\"" ${MOD_SECURITY}; then
        sed -i "s/#Header set X-Content-Type-Options: \"nosniff\"/Header set X-Content-Type-Options: \"nosniff\"/g" ${MOD_SECURITY}
    else 
        sed -i "s/# Header set X-Content-Type-Options: \"nosniff\"/Header set X-Content-Type-Options: \"nosniff\"/g" ${MOD_SECURITY}
    fi
    ######
    if grep -q "#Header set X-Frame-Options: \"sameorigin\"" ${MOD_SECURITY}; then
        sed -i "s/#Header set X-Frame-Options: \"sameorigin\"/Header set X-Frame-Options: \"sameorigin\"/g" ${MOD_SECURITY}
    else 
        sed -i "s/# Header set X-Frame-Options: \"sameorigin\"/Header set X-Frame-Options: \"sameorigin\"/g" ${MOD_SECURITY}
    fi
    ######
    echo "FileETag None" >> ${MOD_SECURITY}
    echo "Header set X-XSS-Protection '1; mode=block'" >> ${MOD_SECURITY}
    echo "Header unset Server" >> ${MOD_SECURITY}
    echo "Header unset ETag" >> ${MOD_SECURITY}
    echo "Header set Strict-Transport-Security 'max-age=31536000; includeSubDomains; preload'" >> ${MOD_SECURITY}
    echo "Header set X-Permitted-Cross-Domain-Policies 'none'" >> ${MOD_SECURITY}
    echo "Header set Referrer-Policy 'strict-origin'" >> ${MOD_SECURITY}
    echo "Header set Expect-CT 'enforce, max-age=43200, report-uri=\"$SITE_ADDR\"'" >> ${MOD_SECURITY}
    echo "#Header set Content-Security-Policy: default-src 'self'" >> ${MOD_SECURITY}
    echo "Header set Feature-Policy: camera: 'none'; vr: 'none'; microphone: 'none';  payment: 'none'; midi: 'none'; microphone: 'none'" >> ${MOD_SECURITY}
    echo "Header edit Set-Cookie ^(.*)$ $1;HttpOnly;Secure" >> ${MOD_SECURITY}
fi

echo "Configure php 7.4 apache"
if [ -f "${PHP_74_CONF}/apache2/php.ini" ]; then
    echo "EDIT ${PHP_74_CONF}/apache2/php.ini"

    sed -i "s/expose_php = On/expose_php = Off/g" ${PHP_74_CONF}/apache2/php.ini
    sed -i "s/max_execution_time = 30/max_execution_time = 120/g" ${PHP_74_CONF}/apache2/php.ini
    sed -i "s/memory_limit = 128M/memory_limit = 512M/g" ${PHP_74_CONF}/apache2/php.ini
    sed -i "s/post_max_size = 8M/post_max_size = 20M/g" ${PHP_74_CONF}/apache2/php.ini
    sed -i "s/upload_max_filesize = 2M/upload_max_filesize = 10M/g" ${PHP_74_CONF}/apache2/php.ini
    sed -i "s/allow_url_fopen = On/allow_url_fopen = Off/g" ${PHP_74_CONF}/apache2/php.ini
    sed -i "s/;date.timezone =/date.timezone = Europe\/Sofia/g" ${PHP_74_CONF}/apache2/php.ini
    sed -i "s/session.use_strict_mode = 0/session.use_strict_mode = 1/g" ${PHP_74_CONF}/apache2/php.ini
    sed -i "s/session.name = PHPSESSID/session.name = ${SESSION_NAME}/g" ${PHP_74_CONF}/apache2/php.ini
    sed -i "s/session.cookie_httponly =/session.cookie_httponly = 1/g" ${PHP_74_CONF}/apache2/php.ini
    sed -i "s/session.cookie_samesite =/session.cookie_samesite =\"lax\"/g" ${PHP_74_CONF}/apache2/php.ini
    sed -i "s/;opcache.enable=1/opcache.enable=1/g" ${PHP_74_CONF}/apache2/php.ini
    sed -i "s/;opcache.memory_consumption=128/opcache.memory_consumption=128/g" ${PHP_74_CONF}/apache2/php.ini
    sed -i "s/;opcache.max_accelerated_files=10000/opcache.max_accelerated_files=10000/g" ${PHP_74_CONF}/apache2/php.ini
    sed -i "s/;opcache.revalidate_freq=2/opcache.revalidate_freq=2/g" ${PHP_74_CONF}/apache2/php.ini
fi

echo "Configure php 74 CGI"
if [ -f "${PHP_74_CONF}/cgi/php.ini" ]; then
    sed -i "s/expose_php = On/expose_php = Off/g" ${PHP_74_CONF}/cgi/php.ini
    sed -i "s/max_execution_time = 30/max_execution_time = 120/g" ${PHP_74_CONF}/cgi/php.ini
    sed -i "s/memory_limit = 128M/memory_limit = 512M/g" ${PHP_74_CONF}/cgi/php.ini
    sed -i "s/post_max_size = 8M/post_max_size = 20M/g" ${PHP_74_CONF}/cgi/php.ini
    sed -i "s/upload_max_filesize = 2M/upload_max_filesize = 10M/g" ${PHP_74_CONF}/cgi/php.ini
    sed -i "s/allow_url_fopen = On/allow_url_fopen = Off/g" ${PHP_74_CONF}/cgi/php.ini
    sed -i "s/;date.timezone =/date.timezone = Europe/Sofia/g" ${PHP_74_CONF}/cgi/php.ini
    sed -i "s/session.use_strict_mode = 0/session.use_strict_mode = 1/g" ${PHP_74_CONF}/cgi/php.ini
    sed -i "s/session.name = PHPSESSID/session.name = ${SESSION_NAME}/g" ${PHP_74_CONF}/cgi/php.ini
    sed -i "s/session.cookie_httponly =/session.cookie_httponly = 1/g" ${PHP_74_CONF}/cgi/php.ini
    sed -i "s/session.cookie_samesite =/session.cookie_samesite = \"lax\"/g" ${PHP_74_CONF}/cgi/php.ini
    sed -i "s/;opcache.enable=1/opcache.enable=1/g" ${PHP_74_CONF}/cgi/php.ini
    sed -i "s/;opcache.memory_consumption=128/opcache.memory_consumption=128/g" ${PHP_74_CONF}/cgi/php.ini
    sed -i "s/;opcache.max_accelerated_files=10000/opcache.max_accelerated_files=10000/g" ${PHP_74_CONF}/cgi/php.ini
    sed -i "s/;opcache.revalidate_freq=2/opcache.revalidate_freq=100/g" ${PHP_74_CONF}/cgi/php.ini
fi

echo "configure_php_74_fpm"
if [ -f "${PHP_74_CONF}/fpm/php.ini" ]; then
    sed -i "s/expose_php = On/expose_php = Off/g" ${PHP_74_CONF}/fpm/php.ini
    sed -i "s/max_execution_time = 30/max_execution_time = 120/g" ${PHP_74_CONF}/fpm/php.ini
    sed -i "s/memory_limit = 128M/memory_limit = 512M/g" ${PHP_74_CONF}/fpm/php.ini
    sed -i "s/post_max_size = 8M/post_max_size = 20M/g" ${PHP_74_CONF}/fpm/php.ini
    sed -i "s/upload_max_filesize = 2M/upload_max_filesize = 10M/g" ${PHP_74_CONF}/fpm/php.ini
    sed -i "s/allow_url_fopen = On/allow_url_fopen = Off/g" ${PHP_74_CONF}/fpm/php.ini
    sed -i "s/;date.timezone =/date.timezone = Europe/Sofia/g" ${PHP_74_CONF}/fpm/php.ini
    sed -i "s/session.use_strict_mode = 0/session.use_strict_mode = 1/g" ${PHP_74_CONF}/fpm/php.ini
    sed -i "s/session.name = PHPSESSID/session.name = ${SESSION_NAME}/g" ${PHP_74_CONF}/fpm/php.ini
    sed -i "s/session.cookie_httponly =/session.cookie_httponly = 1/g" ${PHP_74_CONF}/fpm/php.ini
    sed -i "s/session.cookie_samesite =/session.cookie_samesite = \"lax\"/g" ${PHP_74_CONF}/fpm/php.ini
    sed -i "s/;opcache.enable=1/opcache.enable=1/g" ${PHP_74_CONF}/fpm/php.ini
    sed -i "s/;opcache.memory_consumption=128/opcache.memory_consumption=128/g" ${PHP_74_CONF}/fpm/php.ini
    sed -i "s/;opcache.max_accelerated_files=10000/opcache.max_accelerated_files=10000/g" ${PHP_74_CONF}/fpm/php.ini
    sed -i "s/;opcache.revalidate_freq=2/opcache.revalidate_freq=100/g" ${PHP_74_CONF}/fpm/php.ini
fi

echo "configure_php_74_cli"
if [ -f "${PHP_74_CONF}/cli/php.ini" ]; then
    sed -i "s/expose_php = On/expose_php = Off/g" ${PHP_74_CONF}/cli/php.ini
    sed -i "s/max_execution_time = 30/max_execution_time = 120/g" ${PHP_74_CONF}/cli/php.ini
    sed -i "s/memory_limit = 128M/memory_limit = 512M/g" ${PHP_74_CONF}/cli/php.ini
    sed -i "s/post_max_size = 8M/post_max_size = 20M/g" ${PHP_74_CONF}/cli/php.ini
    sed -i "s/upload_max_filesize = 2M/upload_max_filesize = 10M/g" ${PHP_74_CONF}/cli/php.ini
    sed -i "s/allow_url_fopen = On/allow_url_fopen = Off/g" ${PHP_74_CONF}/cli/php.ini
    sed -i "s/;date.timezone =/date.timezone = Europe/Sofia/g" ${PHP_74_CONF}/cli/php.ini
    sed -i "s/session.use_strict_mode = 0/session.use_strict_mode = 1/g" ${PHP_74_CONF}/cli/php.ini
    sed -i "s/session.name = PHPSESSID/session.name = ${SESSION_NAME}/g" ${PHP_74_CONF}/cli/php.ini
    sed -i "s/session.cookie_httponly =/session.cookie_httponly = 1/g" ${PHP_74_CONF}/cli/php.ini
    sed -i "s/session.cookie_samesite =/session.cookie_samesite = \"lax\"/g" ${PHP_74_CONF}/cli/php.ini
    sed -i "s/;opcache.enable=1/opcache.enable=1/g" ${PHP_74_CONF}/cli/php.ini
    sed -i "s/;opcache.memory_consumption=128/opcache.memory_consumption=128/g" ${PHP_74_CONF}/cli/php.ini
    sed -i "s/;opcache.max_accelerated_files=10000/opcache.max_accelerated_files=10000/g" ${PHP_74_CONF}/cli/php.ini
    sed -i "s/;opcache.revalidate_freq=2/opcache.revalidate_freq=100/g" ${PHP_74_CONF}/cli/php.ini
fi

echo "configure_php_80_apache"
if [ -d "${PHP_80_CONF}/apache/" ]; then
    sed -i "s/expose_php = On/expose_php = Off/g" ${PHP_80_CONF}/apache2/php.ini
    sed -i "s/max_execution_time = 30/max_execution_time = 120/g" ${PHP_80_CONF}/apache2/php.ini
    sed -i "s/memory_limit = 128M/memory_limit = 512M/g" ${PHP_80_CONF}/apache2/php.ini
    sed -i "s/post_max_size = 8M/post_max_size = 20M/g" ${PHP_80_CONF}/apache2/php.ini
    sed -i "s/upload_max_filesize = 2M/upload_max_filesize = 10M/g" ${PHP_80_CONF}/apache2/php.ini
    sed -i "s/allow_url_fopen = On/allow_url_fopen = Off/g" ${PHP_80_CONF}/apache2/php.ini
    sed -i "s/;date.timezone =/date.timezone = Europe/Sofia/g" ${PHP_80_CONF}/apache2/php.ini
    sed -i "s/session.use_strict_mode = 0/session.use_strict_mode = 1/g" ${PHP_80_CONF}/apache2/php.ini
    sed -i "s/session.name = PHPSESSID/session.name = ${SESSION_NAME}/g" ${PHP_80_CONF}/apache2/php.ini
    sed -i "s/session.cookie_httponly =/session.cookie_httponly = 1/g" ${PHP_80_CONF}/apache2/php.ini
    sed -i "s/session.cookie_samesite =/session.cookie_samesite = \"lax\"/g" ${PHP_80_CONF}/apache2/php.ini
    sed -i "s/;opcache.enable=1/opcache.enable=1/g" ${PHP_80_CONF}/apache2/php.ini
    sed -i "s/;opcache.memory_consumption=128/opcache.memory_consumption=128/g" ${PHP_80_CONF}/apache2/php.ini
    sed -i "s/;opcache.max_accelerated_files=10000/opcache.max_accelerated_files=10000/g" ${PHP_80_CONF}/apache2/php.ini
    sed -i "s/;opcache.revalidate_freq=2/opcache.revalidate_freq=100/g" ${PHP_80_CONF}/apache2/php.ini
fi

echo "configure_php_80_cgi"
if [ -d "${PHP_80_CONF}/cgi/" ]; then
    sed -i "s/expose_php = On/expose_php = Off/g" ${PHP_80_CONF}/cgi/php.ini
    sed -i "s/max_execution_time = 30/max_execution_time = 120/g" ${PHP_80_CONF}/cgi/php.ini
    sed -i "s/memory_limit = 128M/memory_limit = 512M/g" ${PHP_80_CONF}/cgi/php.ini
    sed -i "s/post_max_size = 8M/post_max_size = 20M/g" ${PHP_80_CONF}/cgi/php.ini
    sed -i "s/upload_max_filesize = 2M/upload_max_filesize = 10M/g" ${PHP_80_CONF}/cgi/php.ini
    sed -i "s/allow_url_fopen = On/allow_url_fopen = Off/g" ${PHP_80_CONF}/cgi/php.ini
    sed -i "s/;date.timezone =/date.timezone = Europe/Sofia/g" ${PHP_80_CONF}/cgi/php.ini
    sed -i "s/session.use_strict_mode = 0/session.use_strict_mode = 1/g" ${PHP_80_CONF}/cgi/php.ini
    sed -i "s/session.name = PHPSESSID/session.name = ${SESSION_NAME}/g" ${PHP_80_CONF}/cgi/php.ini
    sed -i "s/session.cookie_httponly =/session.cookie_httponly = 1/g" ${PHP_80_CONF}/cgi/php.ini
    sed -i "s/session.cookie_samesite =/session.cookie_samesite = \"lax\"/g" ${PHP_80_CONF}/cgi/php.ini
    sed -i "s/;opcache.enable=1/opcache.enable=1/g" ${PHP_80_CONF}/cgi/php.ini
    sed -i "s/;opcache.memory_consumption=128/opcache.memory_consumption=128/g" ${PHP_80_CONF}/cgi/php.ini
    sed -i "s/;opcache.max_accelerated_files=10000/opcache.max_accelerated_files=10000/g" ${PHP_80_CONF}/cgi/php.ini
    sed -i "s/;opcache.revalidate_freq=2/opcache.revalidate_freq=100/g" ${PHP_80_CONF}/cgi/php.ini
fi

echo "configure_php_80_fpm"
if [ -d "${PHP_80_CONF}/fpm/" ]; then
    sed -i "s/expose_php = On/expose_php = Off/g" ${PHP_80_CONF}/fpm/php.ini
    sed -i "s/max_execution_time = 30/max_execution_time = 120/g" ${PHP_80_CONF}/fpm/php.ini
    sed -i "s/memory_limit = 128M/memory_limit = 512M/g" ${PHP_80_CONF}/fpm/php.ini
    sed -i "s/post_max_size = 8M/post_max_size = 20M/g" ${PHP_80_CONF}/fpm/php.ini
    sed -i "s/upload_max_filesize = 2M/upload_max_filesize = 10M/g" ${PHP_80_CONF}/fpm/php.ini
    sed -i "s/allow_url_fopen = On/allow_url_fopen = Off/g" ${PHP_80_CONF}/fpm/php.ini
    sed -i "s/;date.timezone =/date.timezone = Europe/Sofia/g" ${PHP_80_CONF}/fpm/php.ini
    sed -i "s/session.use_strict_mode = 0/session.use_strict_mode = 1/g" ${PHP_80_CONF}/fpm/php.ini
    sed -i "s/session.name = PHPSESSID/session.name = ${SESSION_NAME}/g" ${PHP_80_CONF}/fpm/php.ini
    sed -i "s/session.cookie_httponly =/session.cookie_httponly = 1/g" ${PHP_80_CONF}/fpm/php.ini
    sed -i "s/session.cookie_samesite =/session.cookie_samesite = \"lax\"/g" ${PHP_80_CONF}/fpm/php.ini
    sed -i "s/;opcache.enable=1/opcache.enable=1/g" ${PHP_80_CONF}/fpm/php.ini
    sed -i "s/;opcache.memory_consumption=128/opcache.memory_consumption=128/g" ${PHP_80_CONF}/fpm/php.ini
    sed -i "s/;opcache.max_accelerated_files=10000/opcache.max_accelerated_files=10000/g" ${PHP_80_CONF}/fpm/php.ini
    sed -i "s/;opcache.revalidate_freq=2/opcache.revalidate_freq=100/g" ${PHP_80_CONF}/fpm/php.ini
fi

echo "configure_php_80_cli"
if [ -d "${PHP_80_CONF}/cli/" ]; then
    sed -i "s/expose_php = On/expose_php = Off/g" ${PHP_80_CONF}/cli/php.ini
    sed -i "s/max_execution_time = 30/max_execution_time = 120/g" ${PHP_80_CONF}/cli/php.ini
    sed -i "s/memory_limit = 128M/memory_limit = 512M/g" ${PHP_80_CONF}/cli/php.ini
    sed -i "s/post_max_size = 8M/post_max_size = 20M/g" ${PHP_80_CONF}/cli/php.ini
    sed -i "s/upload_max_filesize = 2M/upload_max_filesize = 10M/g" ${PHP_80_CONF}/cli/php.ini
    sed -i "s/allow_url_fopen = On/allow_url_fopen = Off/g" ${PHP_80_CONF}/cli/php.ini
    sed -i "s/;date.timezone =/date.timezone = Europe/Sofia/g" ${PHP_80_CONF}/cli/php.ini
    sed -i "s/session.use_strict_mode = 0/session.use_strict_mode = 1/g" ${PHP_80_CONF}/cli/php.ini
    sed -i "s/session.name = PHPSESSID/session.name = ${SESSION_NAME}/g" ${PHP_80_CONF}/cli/php.ini
    sed -i "s/session.cookie_httponly =/session.cookie_httponly = 1/g" ${PHP_80_CONF}/cli/php.ini
    sed -i "s/session.cookie_samesite =/session.cookie_samesite = \"lax\"/g" ${PHP_80_CONF}/cli/php.ini
    sed -i "s/;opcache.enable=1/opcache.enable=1/g" ${PHP_80_CONF}/cli/php.ini
    sed -i "s/;opcache.memory_consumption=128/opcache.memory_consumption=128/g" ${PHP_80_CONF}/cli/php.ini
    sed -i "s/;opcache.max_accelerated_files=10000/opcache.max_accelerated_files=10000/g" ${PHP_80_CONF}/cli/php.ini
    sed -i "s/;opcache.revalidate_freq=2/opcache.revalidate_freq=100/g" ${PHP_80_CONF}/cli/php.ini
fi

echo "configure_php_81_apache"
if [ -d "${PHP_81_CONF}/apache/" ]; then
    sed -i "s/expose_php = On/expose_php = Off/g" ${PHP_81_CONF}/apache2/php.ini
    sed -i "s/max_execution_time = 30/max_execution_time = 120/g" ${PHP_81_CONF}/apache2/php.ini
    sed -i "s/memory_limit = 128M/memory_limit = 512M/g" ${PHP_81_CONF}/apache2/php.ini
    sed -i "s/post_max_size = 8M/post_max_size = 20M/g" ${PHP_81_CONF}/apache2/php.ini
    sed -i "s/upload_max_filesize = 2M/upload_max_filesize = 10M/g" ${PHP_81_CONF}/apache2/php.ini
    sed -i "s/allow_url_fopen = On/allow_url_fopen = Off/g" ${PHP_81_CONF}/apache2/php.ini
    sed -i "s/;date.timezone =/date.timezone = Europe/Sofia/g" ${PHP_81_CONF}/apache2/php.ini
    sed -i "s/session.use_strict_mode = 0/session.use_strict_mode = 1/g" ${PHP_81_CONF}/apache2/php.ini
    sed -i "s/session.name = PHPSESSID/session.name = ${SESSION_NAME}/g" ${PHP_81_CONF}/apache2/php.ini
    sed -i "s/session.cookie_httponly =/session.cookie_httponly = 1/g" ${PHP_81_CONF}/apache2/php.ini
    sed -i "s/session.cookie_samesite =/session.cookie_samesite = \"lax\"/g" ${PHP_81_CONF}/apache2/php.ini
    sed -i "s/;opcache.enable=1/opcache.enable=1/g" ${PHP_81_CONF}/apache2/php.ini
    sed -i "s/;opcache.memory_consumption=128/opcache.memory_consumption=128/g" ${PHP_81_CONF}/apache2/php.ini
    sed -i "s/;opcache.max_accelerated_files=10000/opcache.max_accelerated_files=10000/g" ${PHP_81_CONF}/apache2/php.ini
    sed -i "s/;opcache.revalidate_freq=2/opcache.revalidate_freq=100/g" ${PHP_81_CONF}/apache2/php.ini
fi

echo "Setting up php 8.1 FPM"
if [ -d "${PHP_81_CONF}/fpm/" ]; then
    sed -i "s/expose_php = On/expose_php = Off/g" ${PHP_81_CONF}/fpm/php.ini
    sed -i "s/max_execution_time = 30/max_execution_time = 120/g" ${PHP_81_CONF}/fpm/php.ini
    sed -i "s/memory_limit = 128M/memory_limit = 512M/g" ${PHP_81_CONF}/fpm/php.ini
    sed -i "s/post_max_size = 8M/post_max_size = 20M/g" ${PHP_81_CONF}/fpm/php.ini
    sed -i "s/upload_max_filesize = 2M/upload_max_filesize = 10M/g" ${PHP_81_CONF}/fpm/php.ini
    sed -i "s/allow_url_fopen = On/allow_url_fopen = Off/g" ${PHP_81_CONF}/fpm/php.ini
    sed -i "s/;date.timezone =/date.timezone = Europe/Sofia/g" ${PHP_81_CONF}/fpm/php.ini
    sed -i "s/session.use_strict_mode = 0/session.use_strict_mode = 1/g" ${PHP_81_CONF}/fpm/php.ini
    sed -i "s/session.name = PHPSESSID/session.name = ${SESSION_NAME}/g" ${PHP_81_CONF}/fpm/php.ini
    sed -i "s/session.cookie_httponly =/session.cookie_httponly = 1/g" ${PHP_81_CONF}/fpm/php.ini
    sed -i "s/session.cookie_samesite =/session.cookie_samesite = \"lax\"/g" ${PHP_81_CONF}/fpm/php.ini
    sed -i "s/;opcache.enable=1/opcache.enable=1/g" ${PHP_81_CONF}/fpm/php.ini
    sed -i "s/;opcache.memory_consumption=128/opcache.memory_consumption=128/g" ${PHP_81_CONF}/fpm/php.ini
    sed -i "s/;opcache.max_accelerated_files=10000/opcache.max_accelerated_files=10000/g" ${PHP_81_CONF}/fpm/php.ini
    sed -i "s/;opcache.revalidate_freq=2/opcache.revalidate_freq=100/g" ${PHP_81_CONF}/fpm/php.ini
fi

echo "Setting up php 8.1 CLI"
if [ -d "${PHP_81_CONF}/cli/" ]; then
    sed -i "s/expose_php = On/expose_php = Off/g" ${PHP_81_CONF}/cli/php.ini
    sed -i "s/max_execution_time = 30/max_execution_time = 120/g" ${PHP_81_CONF}/cli/php.ini
    sed -i "s/memory_limit = 128M/memory_limit = 512M/g" ${PHP_81_CONF}/cli/php.ini
    sed -i "s/post_max_size = 8M/post_max_size = 20M/g" ${PHP_81_CONF}/cli/php.ini
    sed -i "s/upload_max_filesize = 2M/upload_max_filesize = 10M/g" ${PHP_81_CONF}/cli/php.ini
    sed -i "s/allow_url_fopen = On/allow_url_fopen = Off/g" ${PHP_81_CONF}/cli/php.ini
    sed -i "s/;date.timezone =/date.timezone = Europe/Sofia/g" ${PHP_81_CONF}/cli/php.ini
    sed -i "s/session.use_strict_mode = 0/session.use_strict_mode = 1/g" ${PHP_81_CONF}/cli/php.ini
    sed -i "s/session.name = PHPSESSID/session.name = ${SESSION_NAME}/g" ${PHP_81_CONF}/cli/php.ini
    sed -i "s/session.cookie_httponly =/session.cookie_httponly = 1/g" ${PHP_81_CONF}/cli/php.ini
    sed -i "s/session.cookie_samesite =/session.cookie_samesite = \"lax\"/g" ${PHP_81_CONF}/cli/php.ini
    sed -i "s/;opcache.enable=1/opcache.enable=1/g" ${PHP_81_CONF}/cli/php.ini
    sed -i "s/;opcache.memory_consumption=128/opcache.memory_consumption=128/g" ${PHP_81_CONF}/cli/php.ini
    sed -i "s/;opcache.max_accelerated_files=10000/opcache.max_accelerated_files=10000/g" ${PHP_81_CONF}/cli/php.ini
    sed -i "s/;opcache.revalidate_freq=2/opcache.revalidate_freq=100/g" ${PHP_81_CONF}/cli/php.ini
fi