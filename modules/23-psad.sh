#!/bin/bash
set -euo pipefail

source helpers.sh
source ./config/env.sh

cat <<EOF > /etc/psad/psad.conf
EMAIL_ADDRESSES               ${LOCAL_EMAIL_ADDR};    # Or your real email
HOSTNAME                      ${DOMAIN_NAME};
ENABLE_AUTO_IDS               Y
ENABLE_AUTO_IDS_EMAILS        Y
AUTO_IDS_DANGER_LEVEL         5
ENABLE_PSADWATCHD             Y
IPT_SYSLOG_FILE               /var/log/syslog    # or /var/log/messages depending on your distro

EOF