#!/bin/bash
set -euo pipefail

source helpers.sh
source ./config/env.sh


configure "Fail2Ban configuration"

if [ ! -f "${JAIL_CONF}" ]; then
	cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.conf.bak
	cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local
fi

if [ -f "${JAIL_LOCAL}" ]; then
	cp "${JAIL_LOCAL}" "${JAIL_LOCAL}.bak"
fi


if grep -qE "^\s*#?\s*ignoreip\s*=" "$JAIL_LOCAL"; then
    sed -i "s|^\s*#\?\s*ignoreip\s*=.*|ignoreip = 127.0.0.1/8 ${INTERNAL_NETWORK} ${EXTERNAL_IP}|" "$JAIL_LOCAL"
else
    echo "ignoreip = 127.0.0.1/8 ${INTERNAL_NETWORK} ${EXTERNAL_IP}" >> "$JAIL_LOCAL"
fi

if grep -qE "^\s*#?\s*bantime\s*=" "$JAIL_LOCAL"; then
    sed -i "s|^\s*#\?\s*bantime\s*=.*|bantime = -1|" "$JAIL_LOCAL"
else
    echo "bantime = -1" >> "$JAIL_LOCAL"
fi

if grep -qE "^\s*#?\s*findtime\s*=" "$JAIL_LOCAL"; then
    sed -i "s|^\s*#\?\s*findtime\s*=.*|findtime = 10m|" "$JAIL_LOCAL"
else
    echo "findtime = 10m" >> "$JAIL_LOCAL"
fi

if grep -qE "^\s*#?\s*maxretry\s*=" "$JAIL_LOCAL"; then
    sed -i "s|^\s*#\?\s*maxretry\s*=.*|maxretry = 3|" "$JAIL_LOCAL"
else
    echo "maxretry = 3" >> "$JAIL_LOCAL"
fi


# ssh
cat <<EOF > /etc/fail2ban/jail.d/sshd.conf
port    = ${SSH}
enabled = true
logpath = %(sshd_log)s
backend = %(sshd_backend)s

EOF

# apache
cat <<EOF > /etc/fail2ban/jail.d/apache.conf
[apache-auth]
enabled = true
port     = http,https
logpath  = %(apache_error_log)s

[apache-badbots]
# Ban hosts which agent identifies spammer robots crawling the web
# for email addresses. The mail outputs are buffered.
port     = http,https
enabled  = true
logpath  = %(apache_access_log)s
bantime  = 48h
maxretry = 1

[apache-noscript]
enabled  = true
port     = http,https
logpath  = %(apache_error_log)s

[apache-overflows]
enabled  = true
port     = http,https
logpath  = %(apache_error_log)s
maxretry = 2

[apache-nohome]
enabled  = true
port     = http,https
logpath  = %(apache_error_log)s
maxretry = 2

[apache-botsearch]
enabled  = true
port     = http,https
logpath  = %(apache_error_log)s
maxretry = 2

[apache-fakegooglebot]
enabled  = true
port     = http,https
logpath  = %(apache_access_log)s
maxretry = 1
ignorecommand = %(ignorecommands_dir)s/apache-fakegooglebot <ip>

[apache-modsecurity]
enabled  = true
port     = http,https
logpath  = %(apache_error_log)s
maxretry = 2

[apache-shellshock]
enabled = true
port    = http,https
logpath = %(apache_error_log)s
maxretry = 1

EOF

#php
cat <<EOF > /etc/fail2ban/jail.d/php.conf
# Ban attackers that try to use PHP's URL-fopen() functionality
# through GET/POST variables. - Experimental, with more than a year
# of usage in production environments.

[php-url-fopen]
enabled = true
port    = http,https
logpath = %(nginx_access_log)s
          %(apache_access_log)s

EOF