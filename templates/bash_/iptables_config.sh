#!/bin/bash

TODAY=$(date +"%Y_%m_%d")
# network
IS_ROUTER="false"
SERVER_IP="1.1.1.1"
EXTERNAL_IP="1.1.1.1"
INTERNAL_NETWORK="1.1.1.1/24"
MAIN_NETWORK_INTERFACE=$(route | grep '^default' | grep -o '[^ ]*$')
SECOND_NETWORK_INTERFACE="enp0s2"
LOOPBACK="lo"

# ports
SSH=22
VSFTP=21
HTTP=80
HTTPS=443
SMTP=25
IMAP=143
IMAPS=993
POP3=110
POP3S=995
DNS=53
VIRTUALMIN=10000
USERMIN=20000

cd /home/${USER}/Documents
iptables-save > iptables_default_${TODAY}.rules

iptables -P INPUT ACCEPT
iptables -P OUTPUT ACCEPT

# Flush chains
iptables -F
# Delete chains
iptables -X
# Zero packet and byte counters
iptables -Z

# set default policy to drop
iptables -P INPUT DROP
iptables -P OUTPUT DROP
iptables -P FORWARD DROP

# Whitelist ip addresses and network interfaces
iptables -A INPUT -s $EXTERNAL_IP -j ACCEPT -m comment --comment "Allow external ip address"
iptables -A INPUT -i $MAIN_NETWORK_INTERFACE -j ACCEPT -m comment --comment "Allow incoming network interface"
iptables -A INPUT -i $LOOPBACK -j ACCEPT -m comment --comment "Allow incoming loopback"
iptables -A OUTPUT -o $LOOPBACK -j ACCEPT -m comment --comment "Allow outgoing loopback"
iptables -A OUTPUT -o $MAIN_NETWORK_INTERFACE -j ACCEPT -m comment --comment "Allow outgoing network interface"



if [ "true" == "${IS_ROUTER}" ]; then
    if grep -Fxq "net.ipv4.ip_forward" /etc/sysctl.conf; then
        sed -i '/net.ipv4.ip_forward/s/^#//' /etc/sysctl.conf
    else
        echo 'net.ipv4.ip_forward=1' >> /etc/sysctl.conf
    fi

    iptables -t nat -A POSTROUTING -j MASQUERADE
    iptables -A FORWARD -i $SECOND_NETWORK_INTERFACE -o $MAIN_NETWORK_INTERFACE -j ACCEPT -m comment --comment "Allow internal network to access external"
fi

iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT -m comment --comment "Allowing established and related incoming connections"
iptables -A OUTPUT -m conntrack --ctstate ESTABLISHED -j ACCEPT -m comment --comment "Allowing established outgoing connections"
# drop invalid packets
iptables -A INPUT  -m state --state INVALID -j DROP -m comment --comment "Drop invalid INPUT packets"
iptables -A OUTPUT -m state --state INVALID -j DROP -m comment --comment "Drop invalid OUTPUT packets"
iptables -A FORWARD -m state --state INVALID -j DROP -m comment --comment "Drop invalid FORWARD packets"

iptables -A INPUT -p tcp --dport $HTTP -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT -m comment --comment "Allow incoming HTTP"
iptables -A INPUT -p tcp --dport $HTTPS -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT -m comment --comment "Allow incoming HTTPS"

iptables –A INPUT –p tcp –syn -m multiport -–dport $HTTP,$HTTPS –m connlimit -–connlimit-above 20 –j REJECT -–reject-with-tcp-reset

iptables -A OUTPUT -p tcp --sport $HTTP -m conntrack --ctstate ESTABLISHED -j ACCEPT -m comment --comment "Allow outgoing HTTP"
iptables -A OUTPUT -p tcp --sport $HTTPS -m conntrack --ctstate ESTABLISHED -j ACCEPT -m comment --comment "Allow outgoing HTTPS"

for ip in `curl https://www.cloudflare.com/ips-v4`; do 
    iptables -I INPUT -p tcp -m multiport --dports $HTTP,$HTTPS -s $ip -j ACCEPT -m comment --comment "Allow Cloudflare network ip ${ip}";
done

iptables -A INPUT -p tcp ! --syn -m state --state NEW -j DROP -m comment --comment "Force SYN packets check"
iptables -A INPUT -f -j DROP -m comment --comment "Force Fragments packets check"
iptables -A INPUT -p tcp --tcp-flags ALL ALL -j DROP -m comment --comment "XMAS packets"
iptables -A INPUT -p tcp --tcp-flags ALL NONE -j DROP -m comment --comment "Drop all NULL packets"
iptables -I INPUT -p tcp --dport $HTTP -m connlimit --connlimit-above 50 --connlimit-mask 20 -j DROP -m comment --comment "Prevent Slowloris"
iptables -A INPUT -p tcp --dport $SSH -m conntrack --ctstate NEW -m recent --set -m comment --comment "SSH brute-force protection"
iptables -A INPUT -p tcp --dport $SSH -m conntrack --ctstate NEW -m recent --update --seconds 60 --hitcount 10 -j DROP -m comment --comment "SSH brute-force protection"
# Prevent port scanning
iptables -N port-scanning
iptables -A port-scanning -p tcp --tcp-flags SYN,ACK,FIN,RST RST -m limit --limit 1/s --limit-burst 2 -j RETURN
iptables -A port-scanning -j DROP
iptables -A INPUT -s 10.0.0.0/8 -j DROP -m comment --comment "Prevent spoofing"
iptables -A INPUT -s 169.254.0.0/16 -j DROP -m comment --comment "Prevent spoofing"
iptables -A INPUT -s 172.16.0.0/12 -j DROP -m comment --comment "Prevent spoofing"
iptables -A INPUT -s 127.0.0.0/8 -j DROP -m comment --comment "Prevent spoofing"
iptables -A INPUT -s 192.0.2.0/24 -j DROP -m comment --comment "Prevent spoofing"
iptables -A INPUT -s 192.168.0.0/16 -j DROP -m comment --comment "Prevent spoofing"
iptables -A INPUT -s 224.0.0.0/4 -j DROP -m comment --comment "Prevent spoofing"
iptables -A INPUT -d 224.0.0.0/4 -j DROP -m comment --comment "Prevent spoofing"
iptables -A INPUT -s 240.0.0.0/5 -j DROP -m comment --comment "Prevent spoofing"
iptables -A INPUT -d 240.0.0.0/5 -j DROP -m comment --comment "Prevent spoofing"
iptables -A INPUT -s 0.0.0.0/8 -j DROP -m comment --comment "Prevent spoofing"
iptables -A INPUT -d 0.0.0.0/8 -j DROP -m comment --comment "Prevent spoofing"
iptables -A INPUT -d 239.255.255.0/24 -j DROP -m comment --comment "Prevent spoofing"
iptables -A INPUT -d 255.255.255.255 -j DROP -m comment --comment "Prevent spoofing"

iptables -A INPUT -p icmp -m icmp --icmp-type 8 -j ACCEPT -m comment --comment "Allow ping"

iptables -A OUTPUT -o $MAIN_NETWORK_INTERFACE -p udp -s $SERVER_IP -d 0/0 --sport 32768:65535 --dport 123 -m state --state NEW -j ACCEPT -m comment --comment "Allow time sync"
iptables -A INPUT -i $MAIN_NETWORK_INTERFACE -p udp -d $SERVER_IP -s 0/0 --sport 123 --dport 32768:65535 -m state --state RELATED,ESTABLISHED -j ACCEPT -m comment --comment "Allow time sync"

iptables -A INPUT -j DROP
iptables -A OUTPUT -j DROP
