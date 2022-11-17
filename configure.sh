#!/bin/bash

main_message "Edit /etc/issue"

echo -e "
###############################################################
#                  This is a private server!                  #
#       All connections are monitored and recorded.           #
#  Disconnect IMMEDIATELY if you are not an authorized user!  #
###############################################################
" > /etc/issue

main_message "Edit /etc/issue.net"
echo -e "
###############################################################
#                  This is a private server!                  #
#       All connections are monitored and recorded.           #
#  Disconnect IMMEDIATELY if you are not an authorized user!  #
###############################################################
" > /etc/issue.net

echo "Content: " && cat /etc/issue

load_spinner

main_message "Set permissions /etc/issue /etc/issue.net"

sub_message "/etc/issue"
sub_message "/etc/issue.net"
chown root:root /etc/issue
chmod 644 /etc/issue
chown root:root /etc/issue.net
chmod 644 /etc/issue.net

load_spinner

main_message "Set UMASK to 027"

sub_message "/etc/login.defs"
sed -i "s/UMASK           022/UMASK           027/g" /etc/login.defs

sub_message "~/.bashrc"

load_spinner