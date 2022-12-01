#!/bin/bash

echo "/etc/hosts"
cp /etc/hosts /etc/backup.hosts

echo "/etc/fstab"
cp /etc/fstab /etc/backup.fstab

echo "/etc/hostname"
cp /etc/hostname /etc/backup.hostname

echo "/etc/bash.bashrc"
cp /etc/bash.bashrc /etc/backup.bash.bashrc

echo "/etc/profile"
cp /etc/profile /etc/backup.profile

echo "/home/$USER/.bashrc"
cp /home/$USER/.bashrc /home/$USER/backup.bashrc

echo "/etc/login.defs"
cp /etc/login.defs /etc/backup.login.defs

echo "/etc/pam.d/login"
cp /etc/pam.d/login /etc/pam.d/backup.login

echo "/etc/pam.d/common-password"
cp /etc/pam.d/common-password /etc/pam.d/backup.common-password


echo "/etc/apache2/apache2.conf"
cp /etc/apache2/apache2.conf /etc/apache2/backup.apache2.conf

echo "/etc/apache2/ports.conf"
cp /etc/apache2/ports.conf /etc/apache2/backup.ports.conf

echo "/etc/apache2/conf-available/security.conf"
cp /etc/apache2/conf-available/security.conf /etc/apache2/conf-available/backup.security.conf

echo "/etc/apache2/mods-available/security2.conf"
cp /etc/apache2/mods-available/security2.conf /etc/apache2/mods-available/backup.security2.conf

echo "/etc/apache2/mods-available/evasive.conf"
cp /etc/apache2/mods-available/evasive.conf /etc/apache2/mods-available/backup.evasive.conf

echo "/etc/apache2/mods-available/qos.conf"
cp /etc/apache2/mods-available/qos.conf /etc/apache2/mods-available/backup.qos.conf

echo "/etc/vsftpd.conf"
cp /etc/vsftpd.conf /etc/backup.vsftpd.conf

echo "/etc/redis/redis.conf"
cp /etc/redis/redis.conf /etc/redis/backup.redis.conf

echo "/etc/varnish/default.vcl"
cp /etc/varnish/default.vcl /etc/varnish/backup.default.vcl

echo "/etc/ssh/sshd_config"
cp /etc/ssh/sshd_config /etc/ssh/backup.sshd_config

echo "/etc/fail2ban/jail.conf"
cp /etc/fail2ban/jail.conf /etc/fail2ban/backup.jail.conf
echo "Create jail.local"
cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local
cp /etc/fail2ban/jail.local /etc/fail2ban/backup.jail.local

# create_copy "/etc/hosts"
# create_copy "/etc/hostname"
# create_copy "/etc/bash.bashrc"
# create_copy "/etc/profile"
# create_copy "/home/$USER/.bashrc"
# create_copy "/etc/login.defs"
# create_copy "/etc/pam.d/login"
# create_copy "/etc/pam.d/common-password"
# create_copy ""