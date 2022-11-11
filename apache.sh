#!/bin/bash

a2enmod headers rewrite ssl evasive proxy envvars http2 qos &> ${LOG_FILE}
# a2enconf php7.4-fpm

# Set DH algorithms
# if ! grep -q 'SSLCipherSuite' ${APACHE2CONF}; then
#     echo "SSLProtocol all -SSLv2 -SSLv3 -TLSv1 -TLSv1.1" >> ${APACHE2CONF}
#     echo "SSLCipherSuite ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-C>" >> ${APACHE2CONF}
# fi

# Set apache2 timeout
# sed -i 's/Timeout 300/Timeout 60/' ${APACHE2CONF}


if [ -f "$MOD_EVASIVE" ]; then
    echo "- Configure mod_evasive"
    
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

# # Configure mod_security
# # Hide Server info
# # Set security headers
# ######
if [ -f "$MOD_SECURITY" ]; then
    echo "- Configure mod_security"
    
    # sed -i "s/ServerTokens/#ServerTokens/g" ${MOD_SECURITY}
    # sed -i "s/ServerSignature/#ServerSignature/g" ${MOD_SECURITY}
    # sed -i "s/TraceEnable/#TraceEnable/g" ${MOD_SECURITY}
    
    if grep -q "#ServerTokens OS" ${MOD_SECURITY}; then
        sed -i "s/#ServerTokens OS/ServerTokens Prod/g" ${MOD_SECURITY}
    else
        sed -i "s/# ServerTokens OS/ServerTokens Prod/g" ${MOD_SECURITY}
    fi
    ######
    if grep -q "#ServerSignature On" ${MOD_SECURITY}; then
        sed -i "s/#ServerSignature On/ServerSignature Off/g" ${MOD_SECURITY}
    else
        sed -i "s/# ServerSignature On/ServerSignature Off/g" ${MOD_SECURITY}
    fi
    ######
    if grep -q "#TraceEnable Off" ${MOD_SECURITY}; then
        sed -i "s/#TraceEnable Off/TraceEnable Off/g" ${MOD_SECURITY}
    else
        sed -i "s/# TraceEnable Off/TraceEnable Off/g" ${MOD_SECURITY}
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
    echo "Header set Content-Security-Policy: \"default-src 'self'\"" >> ${MOD_SECURITY}
    echo "Header set Feature-Policy: \"camera: 'none'; vr: 'none'; microphone: 'none';  payment: 'none'; midi: 'none'; microphone: 'none'\"" >> ${MOD_SECURITY}
    echo "Header edit Set-Cookie ^(.*)$ $1;HttpOnly;Secure" >> ${MOD_SECURITY}
fi



{
    if [ -f "${PHP_74_CONF}/apache2/php.ini" ]; then
        echo "- Configure php 7.4 apache"
        
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
}

{
    if [ -f "${PHP_74_CONF}/cgi/php.ini" ]; then
        echo "- Configure php 7.4 cgi"
        
        sed -i "s/expose_php = On/expose_php = Off/g" ${PHP_74_CONF}/cgi/php.ini
        sed -i "s/max_execution_time = 30/max_execution_time = 120/g" ${PHP_74_CONF}/cgi/php.ini
        sed -i "s/memory_limit = 128M/memory_limit = 512M/g" ${PHP_74_CONF}/cgi/php.ini
        sed -i "s/post_max_size = 8M/post_max_size = 20M/g" ${PHP_74_CONF}/cgi/php.ini
        sed -i "s/upload_max_filesize = 2M/upload_max_filesize = 10M/g" ${PHP_74_CONF}/cgi/php.ini
        sed -i "s/allow_url_fopen = On/allow_url_fopen = Off/g" ${PHP_74_CONF}/cgi/php.ini
        sed -i "s/;date.timezone =/date.timezone = Europe\/Sofia/g" ${PHP_74_CONF}/cgi/php.ini
        sed -i "s/session.use_strict_mode = 0/session.use_strict_mode = 1/g" ${PHP_74_CONF}/cgi/php.ini
        sed -i "s/session.name = PHPSESSID/session.name = ${SESSION_NAME}/g" ${PHP_74_CONF}/cgi/php.ini
        sed -i "s/session.cookie_httponly =/session.cookie_httponly = 1/g" ${PHP_74_CONF}/cgi/php.ini
        sed -i "s/session.cookie_samesite =/session.cookie_samesite = \"lax\"/g" ${PHP_74_CONF}/cgi/php.ini
        sed -i "s/;opcache.enable=1/opcache.enable=1/g" ${PHP_74_CONF}/cgi/php.ini
        sed -i "s/;opcache.memory_consumption=128/opcache.memory_consumption=128/g" ${PHP_74_CONF}/cgi/php.ini
        sed -i "s/;opcache.max_accelerated_files=10000/opcache.max_accelerated_files=10000/g" ${PHP_74_CONF}/cgi/php.ini
        sed -i "s/;opcache.revalidate_freq=2/opcache.revalidate_freq=100/g" ${PHP_74_CONF}/cgi/php.ini
    fi
}

{
    if [ -f "${PHP_74_CONF}/fpm/php.ini" ]; then
        echo "- Configure php 7.4 fpm"
        
        sed -i "s/expose_php = On/expose_php = Off/g" ${PHP_74_CONF}/fpm/php.ini
        sed -i "s/max_execution_time = 30/max_execution_time = 120/g" ${PHP_74_CONF}/fpm/php.ini
        sed -i "s/memory_limit = 128M/memory_limit = 512M/g" ${PHP_74_CONF}/fpm/php.ini
        sed -i "s/post_max_size = 8M/post_max_size = 20M/g" ${PHP_74_CONF}/fpm/php.ini
        sed -i "s/upload_max_filesize = 2M/upload_max_filesize = 10M/g" ${PHP_74_CONF}/fpm/php.ini
        sed -i "s/allow_url_fopen = On/allow_url_fopen = Off/g" ${PHP_74_CONF}/fpm/php.ini
        sed -i "s/;date.timezone =/date.timezone = Europe\/Sofia/g" ${PHP_74_CONF}/fpm/php.ini
        sed -i "s/session.use_strict_mode = 0/session.use_strict_mode = 1/g" ${PHP_74_CONF}/fpm/php.ini
        sed -i "s/session.name = PHPSESSID/session.name = ${SESSION_NAME}/g" ${PHP_74_CONF}/fpm/php.ini
        sed -i "s/session.cookie_httponly =/session.cookie_httponly = 1/g" ${PHP_74_CONF}/fpm/php.ini
        sed -i "s/session.cookie_samesite =/session.cookie_samesite = \"lax\"/g" ${PHP_74_CONF}/fpm/php.ini
        sed -i "s/;opcache.enable=1/opcache.enable=1/g" ${PHP_74_CONF}/fpm/php.ini
        sed -i "s/;opcache.memory_consumption=128/opcache.memory_consumption=128/g" ${PHP_74_CONF}/fpm/php.ini
        sed -i "s/;opcache.max_accelerated_files=10000/opcache.max_accelerated_files=10000/g" ${PHP_74_CONF}/fpm/php.ini
        sed -i "s/;opcache.revalidate_freq=2/opcache.revalidate_freq=100/g" ${PHP_74_CONF}/fpm/php.ini
    fi
}

{
    if [ -f "${PHP_74_CONF}/cli/php.ini" ]; then
        echo "- Configure php 7.4 cli"
        
        sed -i "s/expose_php = On/expose_php = Off/g" ${PHP_74_CONF}/cli/php.ini
        sed -i "s/max_execution_time = 30/max_execution_time = 120/g" ${PHP_74_CONF}/cli/php.ini
        sed -i "s/memory_limit = 128M/memory_limit = 512M/g" ${PHP_74_CONF}/cli/php.ini
        sed -i "s/post_max_size = 8M/post_max_size = 20M/g" ${PHP_74_CONF}/cli/php.ini
        sed -i "s/upload_max_filesize = 2M/upload_max_filesize = 10M/g" ${PHP_74_CONF}/cli/php.ini
        sed -i "s/allow_url_fopen = On/allow_url_fopen = Off/g" ${PHP_74_CONF}/cli/php.ini
        sed -i "s/;date.timezone =/date.timezone = Europe\/Sofia/g" ${PHP_74_CONF}/cli/php.ini
        sed -i "s/session.use_strict_mode = 0/session.use_strict_mode = 1/g" ${PHP_74_CONF}/cli/php.ini
        sed -i "s/session.name = PHPSESSID/session.name = ${SESSION_NAME}/g" ${PHP_74_CONF}/cli/php.ini
        sed -i "s/session.cookie_httponly =/session.cookie_httponly = 1/g" ${PHP_74_CONF}/cli/php.ini
        sed -i "s/session.cookie_samesite =/session.cookie_samesite = \"lax\"/g" ${PHP_74_CONF}/cli/php.ini
        sed -i "s/;opcache.enable=1/opcache.enable=1/g" ${PHP_74_CONF}/cli/php.ini
        sed -i "s/;opcache.memory_consumption=128/opcache.memory_consumption=128/g" ${PHP_74_CONF}/cli/php.ini
        sed -i "s/;opcache.max_accelerated_files=10000/opcache.max_accelerated_files=10000/g" ${PHP_74_CONF}/cli/php.ini
        sed -i "s/;opcache.revalidate_freq=2/opcache.revalidate_freq=100/g" ${PHP_74_CONF}/cli/php.ini
    fi
}

{
    if [ -d "${PHP_80_CONF}/apache/" ]; then
        echo "- Configure php 8.0 apache"
        
        sed -i "s/expose_php = On/expose_php = Off/g" ${PHP_80_CONF}/apache2/php.ini
        sed -i "s/max_execution_time = 30/max_execution_time = 120/g" ${PHP_80_CONF}/apache2/php.ini
        sed -i "s/memory_limit = 128M/memory_limit = 512M/g" ${PHP_80_CONF}/apache2/php.ini
        sed -i "s/post_max_size = 8M/post_max_size = 20M/g" ${PHP_80_CONF}/apache2/php.ini
        sed -i "s/upload_max_filesize = 2M/upload_max_filesize = 10M/g" ${PHP_80_CONF}/apache2/php.ini
        sed -i "s/allow_url_fopen = On/allow_url_fopen = Off/g" ${PHP_80_CONF}/apache2/php.ini
        sed -i "s/;date.timezone =/date.timezone = Europe\/Sofia/g" ${PHP_80_CONF}/apache2/php.ini
        sed -i "s/session.use_strict_mode = 0/session.use_strict_mode = 1/g" ${PHP_80_CONF}/apache2/php.ini
        sed -i "s/session.name = PHPSESSID/session.name = ${SESSION_NAME}/g" ${PHP_80_CONF}/apache2/php.ini
        sed -i "s/session.cookie_httponly =/session.cookie_httponly = 1/g" ${PHP_80_CONF}/apache2/php.ini
        sed -i "s/session.cookie_samesite =/session.cookie_samesite = \"lax\"/g" ${PHP_80_CONF}/apache2/php.ini
        sed -i "s/;opcache.enable=1/opcache.enable=1/g" ${PHP_80_CONF}/apache2/php.ini
        sed -i "s/;opcache.memory_consumption=128/opcache.memory_consumption=128/g" ${PHP_80_CONF}/apache2/php.ini
        sed -i "s/;opcache.max_accelerated_files=10000/opcache.max_accelerated_files=10000/g" ${PHP_80_CONF}/apache2/php.ini
        sed -i "s/;opcache.revalidate_freq=2/opcache.revalidate_freq=100/g" ${PHP_80_CONF}/apache2/php.ini
    fi
}

{
    if [ -d "${PHP_80_CONF}/cgi/" ]; then
        echo "- Configure php 8.0 cgi"
        
        sed -i "s/expose_php = On/expose_php = Off/g" ${PHP_80_CONF}/cgi/php.ini
        sed -i "s/max_execution_time = 30/max_execution_time = 120/g" ${PHP_80_CONF}/cgi/php.ini
        sed -i "s/memory_limit = 128M/memory_limit = 512M/g" ${PHP_80_CONF}/cgi/php.ini
        sed -i "s/post_max_size = 8M/post_max_size = 20M/g" ${PHP_80_CONF}/cgi/php.ini
        sed -i "s/upload_max_filesize = 2M/upload_max_filesize = 10M/g" ${PHP_80_CONF}/cgi/php.ini
        sed -i "s/allow_url_fopen = On/allow_url_fopen = Off/g" ${PHP_80_CONF}/cgi/php.ini
        sed -i "s/;date.timezone =/date.timezone = Europe\/Sofia/g" ${PHP_80_CONF}/cgi/php.ini
        sed -i "s/session.use_strict_mode = 0/session.use_strict_mode = 1/g" ${PHP_80_CONF}/cgi/php.ini
        sed -i "s/session.name = PHPSESSID/session.name = ${SESSION_NAME}/g" ${PHP_80_CONF}/cgi/php.ini
        sed -i "s/session.cookie_httponly =/session.cookie_httponly = 1/g" ${PHP_80_CONF}/cgi/php.ini
        sed -i "s/session.cookie_samesite =/session.cookie_samesite = \"lax\"/g" ${PHP_80_CONF}/cgi/php.ini
        sed -i "s/;opcache.enable=1/opcache.enable=1/g" ${PHP_80_CONF}/cgi/php.ini
        sed -i "s/;opcache.memory_consumption=128/opcache.memory_consumption=128/g" ${PHP_80_CONF}/cgi/php.ini
        sed -i "s/;opcache.max_accelerated_files=10000/opcache.max_accelerated_files=10000/g" ${PHP_80_CONF}/cgi/php.ini
        sed -i "s/;opcache.revalidate_freq=2/opcache.revalidate_freq=100/g" ${PHP_80_CONF}/cgi/php.ini
    fi
}

{
    if [ -d "${PHP_80_CONF}/fpm/" ]; then
        echo "- Configure php 8.0 fpm"
        
        sed -i "s/expose_php = On/expose_php = Off/g" ${PHP_80_CONF}/fpm/php.ini
        sed -i "s/max_execution_time = 30/max_execution_time = 120/g" ${PHP_80_CONF}/fpm/php.ini
        sed -i "s/memory_limit = 128M/memory_limit = 512M/g" ${PHP_80_CONF}/fpm/php.ini
        sed -i "s/post_max_size = 8M/post_max_size = 20M/g" ${PHP_80_CONF}/fpm/php.ini
        sed -i "s/upload_max_filesize = 2M/upload_max_filesize = 10M/g" ${PHP_80_CONF}/fpm/php.ini
        sed -i "s/allow_url_fopen = On/allow_url_fopen = Off/g" ${PHP_80_CONF}/fpm/php.ini
        sed -i "s/;date.timezone =/date.timezone = Europe\/Sofia/g" ${PHP_80_CONF}/fpm/php.ini
        sed -i "s/session.use_strict_mode = 0/session.use_strict_mode = 1/g" ${PHP_80_CONF}/fpm/php.ini
        sed -i "s/session.name = PHPSESSID/session.name = ${SESSION_NAME}/g" ${PHP_80_CONF}/fpm/php.ini
        sed -i "s/session.cookie_httponly =/session.cookie_httponly = 1/g" ${PHP_80_CONF}/fpm/php.ini
        sed -i "s/session.cookie_samesite =/session.cookie_samesite = \"lax\"/g" ${PHP_80_CONF}/fpm/php.ini
        sed -i "s/;opcache.enable=1/opcache.enable=1/g" ${PHP_80_CONF}/fpm/php.ini
        sed -i "s/;opcache.memory_consumption=128/opcache.memory_consumption=128/g" ${PHP_80_CONF}/fpm/php.ini
        sed -i "s/;opcache.max_accelerated_files=10000/opcache.max_accelerated_files=10000/g" ${PHP_80_CONF}/fpm/php.ini
        sed -i "s/;opcache.revalidate_freq=2/opcache.revalidate_freq=100/g" ${PHP_80_CONF}/fpm/php.ini
    fi
}

{
    if [ -d "${PHP_80_CONF}/cli/" ]; then
        echo "- Configure php 8.0 cli"
        
        sed -i "s/expose_php = On/expose_php = Off/g" ${PHP_80_CONF}/cli/php.ini
        sed -i "s/max_execution_time = 30/max_execution_time = 120/g" ${PHP_80_CONF}/cli/php.ini
        sed -i "s/memory_limit = 128M/memory_limit = 512M/g" ${PHP_80_CONF}/cli/php.ini
        sed -i "s/post_max_size = 8M/post_max_size = 20M/g" ${PHP_80_CONF}/cli/php.ini
        sed -i "s/upload_max_filesize = 2M/upload_max_filesize = 10M/g" ${PHP_80_CONF}/cli/php.ini
        sed -i "s/allow_url_fopen = On/allow_url_fopen = Off/g" ${PHP_80_CONF}/cli/php.ini
        sed -i "s/;date.timezone =/date.timezone = Europe\/Sofia/g" ${PHP_80_CONF}/cli/php.ini
        sed -i "s/session.use_strict_mode = 0/session.use_strict_mode = 1/g" ${PHP_80_CONF}/cli/php.ini
        sed -i "s/session.name = PHPSESSID/session.name = ${SESSION_NAME}/g" ${PHP_80_CONF}/cli/php.ini
        sed -i "s/session.cookie_httponly =/session.cookie_httponly = 1/g" ${PHP_80_CONF}/cli/php.ini
        sed -i "s/session.cookie_samesite =/session.cookie_samesite = \"lax\"/g" ${PHP_80_CONF}/cli/php.ini
        sed -i "s/;opcache.enable=1/opcache.enable=1/g" ${PHP_80_CONF}/cli/php.ini
        sed -i "s/;opcache.memory_consumption=128/opcache.memory_consumption=128/g" ${PHP_80_CONF}/cli/php.ini
        sed -i "s/;opcache.max_accelerated_files=10000/opcache.max_accelerated_files=10000/g" ${PHP_80_CONF}/cli/php.ini
        sed -i "s/;opcache.revalidate_freq=2/opcache.revalidate_freq=100/g" ${PHP_80_CONF}/cli/php.ini
    fi
}

{
    if [ -d "${PHP_81_CONF}/apache/" ]; then
        echo "- Configure php 8.1 apache"
        
        sed -i "s/expose_php = On/expose_php = Off/g" ${PHP_81_CONF}/apache2/php.ini
        sed -i "s/max_execution_time = 30/max_execution_time = 120/g" ${PHP_81_CONF}/apache2/php.ini
        sed -i "s/memory_limit = 128M/memory_limit = 512M/g" ${PHP_81_CONF}/apache2/php.ini
        sed -i "s/post_max_size = 8M/post_max_size = 20M/g" ${PHP_81_CONF}/apache2/php.ini
        sed -i "s/upload_max_filesize = 2M/upload_max_filesize = 10M/g" ${PHP_81_CONF}/apache2/php.ini
        sed -i "s/allow_url_fopen = On/allow_url_fopen = Off/g" ${PHP_81_CONF}/apache2/php.ini
        sed -i "s/;date.timezone =/date.timezone = Europe\/Sofia/g" ${PHP_81_CONF}/apache2/php.ini
        sed -i "s/session.use_strict_mode = 0/session.use_strict_mode = 1/g" ${PHP_81_CONF}/apache2/php.ini
        sed -i "s/session.name = PHPSESSID/session.name = ${SESSION_NAME}/g" ${PHP_81_CONF}/apache2/php.ini
        sed -i "s/session.cookie_httponly =/session.cookie_httponly = 1/g" ${PHP_81_CONF}/apache2/php.ini
        sed -i "s/session.cookie_samesite =/session.cookie_samesite = \"lax\"/g" ${PHP_81_CONF}/apache2/php.ini
        sed -i "s/;opcache.enable=1/opcache.enable=1/g" ${PHP_81_CONF}/apache2/php.ini
        sed -i "s/;opcache.memory_consumption=128/opcache.memory_consumption=128/g" ${PHP_81_CONF}/apache2/php.ini
        sed -i "s/;opcache.max_accelerated_files=10000/opcache.max_accelerated_files=10000/g" ${PHP_81_CONF}/apache2/php.ini
        sed -i "s/;opcache.revalidate_freq=2/opcache.revalidate_freq=100/g" ${PHP_81_CONF}/apache2/php.ini
    fi
}

{
    if [ -d "${PHP_81_CONF}/fpm/" ]; then
        echo "- Configure php 8.1 fpm"
        
        sed -i "s/expose_php = On/expose_php = Off/g" ${PHP_81_CONF}/fpm/php.ini
        sed -i "s/max_execution_time = 30/max_execution_time = 120/g" ${PHP_81_CONF}/fpm/php.ini
        sed -i "s/memory_limit = 128M/memory_limit = 512M/g" ${PHP_81_CONF}/fpm/php.ini
        sed -i "s/post_max_size = 8M/post_max_size = 20M/g" ${PHP_81_CONF}/fpm/php.ini
        sed -i "s/upload_max_filesize = 2M/upload_max_filesize = 10M/g" ${PHP_81_CONF}/fpm/php.ini
        sed -i "s/allow_url_fopen = On/allow_url_fopen = Off/g" ${PHP_81_CONF}/fpm/php.ini
        sed -i "s/;date.timezone =/date.timezone = Europe\/Sofia/g" ${PHP_81_CONF}/fpm/php.ini
        sed -i "s/session.use_strict_mode = 0/session.use_strict_mode = 1/g" ${PHP_81_CONF}/fpm/php.ini
        sed -i "s/session.name = PHPSESSID/session.name = ${SESSION_NAME}/g" ${PHP_81_CONF}/fpm/php.ini
        sed -i "s/session.cookie_httponly =/session.cookie_httponly = 1/g" ${PHP_81_CONF}/fpm/php.ini
        sed -i "s/session.cookie_samesite =/session.cookie_samesite = \"lax\"/g" ${PHP_81_CONF}/fpm/php.ini
        sed -i "s/;opcache.enable=1/opcache.enable=1/g" ${PHP_81_CONF}/fpm/php.ini
        sed -i "s/;opcache.memory_consumption=128/opcache.memory_consumption=128/g" ${PHP_81_CONF}/fpm/php.ini
        sed -i "s/;opcache.max_accelerated_files=10000/opcache.max_accelerated_files=10000/g" ${PHP_81_CONF}/fpm/php.ini
        sed -i "s/;opcache.revalidate_freq=2/opcache.revalidate_freq=100/g" ${PHP_81_CONF}/fpm/php.ini
    fi
}

{
    if [ -d "${PHP_81_CONF}/cgi/" ]; then
        echo "- Configure php 8.1 cgi"
        
        sed -i "s/expose_php = On/expose_php = Off/g" ${PHP_81_CONF}/cgi/php.ini
        sed -i "s/max_execution_time = 30/max_execution_time = 120/g" ${PHP_81_CONF}/cgi/php.ini
        sed -i "s/memory_limit = 128M/memory_limit = 512M/g" ${PHP_81_CONF}/cgi/php.ini
        sed -i "s/post_max_size = 8M/post_max_size = 20M/g" ${PHP_81_CONF}/cgi/php.ini
        sed -i "s/upload_max_filesize = 2M/upload_max_filesize = 10M/g" ${PHP_81_CONF}/cgi/php.ini
        sed -i "s/allow_url_fopen = On/allow_url_fopen = Off/g" ${PHP_81_CONF}/cgi/php.ini
        sed -i "s/;date.timezone =/date.timezone = Europe\/Sofia/g" ${PHP_81_CONF}/cgi/php.ini
        sed -i "s/session.use_strict_mode = 0/session.use_strict_mode = 1/g" ${PHP_81_CONF}/cgi/php.ini
        sed -i "s/session.name = PHPSESSID/session.name = ${SESSION_NAME}/g" ${PHP_81_CONF}/cgi/php.ini
        sed -i "s/session.cookie_httponly =/session.cookie_httponly = 1/g" ${PHP_81_CONF}/cgi/php.ini
        sed -i "s/session.cookie_samesite =/session.cookie_samesite = \"lax\"/g" ${PHP_81_CONF}/cgi/php.ini
        sed -i "s/;opcache.enable=1/opcache.enable=1/g" ${PHP_81_CONF}/cgi/php.ini
        sed -i "s/;opcache.memory_consumption=128/opcache.memory_consumption=128/g" ${PHP_81_CONF}/cgi/php.ini
        sed -i "s/;opcache.max_accelerated_files=10000/opcache.max_accelerated_files=10000/g" ${PHP_81_CONF}/cgi/php.ini
        sed -i "s/;opcache.revalidate_freq=2/opcache.revalidate_freq=100/g" ${PHP_81_CONF}/cgi/php.ini
    fi
}

{
    if [ -d "${PHP_81_CONF}/cli/" ]; then
        echo "- Configure php 8.1 cli"
        
        sed -i "s/expose_php = On/expose_php = Off/g" ${PHP_81_CONF}/cli/php.ini
        sed -i "s/max_execution_time = 30/max_execution_time = 120/g" ${PHP_81_CONF}/cli/php.ini
        sed -i "s/memory_limit = 128M/memory_limit = 512M/g" ${PHP_81_CONF}/cli/php.ini
        sed -i "s/post_max_size = 8M/post_max_size = 20M/g" ${PHP_81_CONF}/cli/php.ini
        sed -i "s/upload_max_filesize = 2M/upload_max_filesize = 10M/g" ${PHP_81_CONF}/cli/php.ini
        sed -i "s/allow_url_fopen = On/allow_url_fopen = Off/g" ${PHP_81_CONF}/cli/php.ini
        sed -i "s/;date.timezone =/date.timezone = Europe\/Sofia/g" ${PHP_81_CONF}/cli/php.ini
        sed -i "s/session.use_strict_mode = 0/session.use_strict_mode = 1/g" ${PHP_81_CONF}/cli/php.ini
        sed -i "s/session.name = PHPSESSID/session.name = ${SESSION_NAME}/g" ${PHP_81_CONF}/cli/php.ini
        sed -i "s/session.cookie_httponly =/session.cookie_httponly = 1/g" ${PHP_81_CONF}/cli/php.ini
        sed -i "s/session.cookie_samesite =/session.cookie_samesite = \"lax\"/g" ${PHP_81_CONF}/cli/php.ini
        sed -i "s/;opcache.enable=1/opcache.enable=1/g" ${PHP_81_CONF}/cli/php.ini
        sed -i "s/;opcache.memory_consumption=128/opcache.memory_consumption=128/g" ${PHP_81_CONF}/cli/php.ini
        sed -i "s/;opcache.max_accelerated_files=10000/opcache.max_accelerated_files=10000/g" ${PHP_81_CONF}/cli/php.ini
        sed -i "s/;opcache.revalidate_freq=2/opcache.revalidate_freq=100/g" ${PHP_81_CONF}/cli/php.ini
    fi
}



# systemctl restart apache2.service

