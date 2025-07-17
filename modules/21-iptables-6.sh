#!/bin/bash
set -euo pipefail

source helpers.sh
source ./config/env.sh

info "Setting up ip6tables rules for IPv6..."

if [ ! -d "${HOME_DIR}/Documents" ]; then
    mkdir -p "${HOME_DIR}/Documents"
    cd "${HOME_DIR}/Documents"
else
    cd "${HOME_DIR}/Documents"
fi

curl -s https://www.cloudflare.com/ips-v6 -o "$CLOUDFLARE_IP_LIST"


ip6tables-save > ip6tables_default_ipv6_${TODAY}.rules


ip6tables -P INPUT ACCEPT
ip6tables -P OUTPUT ACCEPT

# Flush chains
ip6tables -F
# Delete chains
ip6tables -X
# Zero packet and byte counters
ip6tables -Z

# set default policy to drop
ip6tables -P INPUT DROP
ip6tables -P OUTPUT DROP
ip6tables -P FORWARD DROP

# Logging
# For PSAD
# Suspicious packet logging for PSAD and diagnostics
ip6tables -N LOGGING

# Drop and log invalid packets (helpful for PSAD)
ip6tables -A INPUT -m state --state INVALID -j LOG --log-prefix "INVALID_PKT: " --log-level 4
ip6tables -A INPUT -m state --state INVALID -j DROP

# Log potential scans (non-SYN new packets, XMAS, NULL, etc.)
ip6tables -A INPUT -p tcp ! --syn -m state --state NEW -j LOG --log-prefix "NON_SYN_NEW: " --log-level 4
ip6tables -A INPUT -p tcp --tcp-flags ALL NONE -j LOG --log-prefix "NULL_PKT: " --log-level 4
ip6tables -A INPUT -p tcp --tcp-flags ALL ALL -j LOG --log-prefix "XMAS_PKT: " --log-level 4


# Whitelist ip addresses and network interfaces
ip6tables -A INPUT -s $EXTERNAL_IP -j ACCEPT -m comment --comment "Allow external ip address"
ip6tables -A INPUT -i $MAIN_NETWORK_INTERFACE -j ACCEPT -m comment --comment "Allow incoming network interface"
ip6tables -A INPUT -i $LOOPBACK -j ACCEPT -m comment --comment "Allow incoming loopback"
ip6tables -A OUTPUT -o $LOOPBACK -j ACCEPT -m comment --comment "Allow outgoing loopback"
ip6tables -A OUTPUT -o $MAIN_NETWORK_INTERFACE -j ACCEPT -m comment --comment "Allow outgoing network interface"

# Check if server is used as router
if [ "true" == "${IS_ROUTER}" ]; then
    if grep -Fxq "net.ipv4.ip_forward" /etc/sysctl.conf; then
        sed -i '/net.ipv4.ip_forward/s/^#//' /etc/sysctl.conf
    else
        echo 'net.ipv4.ip_forward=1' >>/etc/sysctl.conf
    fi

    ip6tables -t nat -A POSTROUTING -j MASQUERADE
    ip6tables -A FORWARD -i $SECOND_NETWORK_INTERFACE -o $MAIN_NETWORK_INTERFACE -j ACCEPT -m comment --comment "Allow internal network to access external"
fi

ip6tables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT -m comment --comment "Allowing established and related incoming connections"
ip6tables -A OUTPUT -m conntrack --ctstate ESTABLISHED -j ACCEPT -m comment --comment "Allowing established outgoing connections"
# drop invalid packets
ip6tables -A INPUT -m state --state INVALID -j DROP -m comment --comment "Drop invalid INPUT packets"
ip6tables -A OUTPUT -m state --state INVALID -j DROP -m comment --comment "Drop invalid OUTPUT packets"
ip6tables -A FORWARD -m state --state INVALID -j DROP -m comment --comment "Drop invalid FORWARD packets"

ip6tables -A INPUT -p tcp --dport $HTTP -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT -m comment --comment "Allow incoming HTTP"
ip6tables -A INPUT -p tcp --dport $HTTPS -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT -m comment --comment "Allow incoming HTTPS"

# Stop Masked Attacks
ip6tables -A INPUT -p icmp --icmp-type 13 -j DROP -m comment --comment "Drop Timestamp"
ip6tables -A INPUT -p icmp --icmp-type 17 -j DROP -m comment --comment "Drop Address mask request"
ip6tables -A INPUT -p icmp --icmp-type 14 -j DROP -m comment --comment "Drop Timestamp reply"
ip6tables -A INPUT -p icmp -m limit --limit 1/second -j ACCEPT

ip6tables -A INPUT -p tcp --syn -m multiport --dports $HTTP,$HTTPS -m connlimit --connlimit-above 20 -j REJECT --reject-with tcp-reset

ip6tables -A OUTPUT -p tcp --sport $HTTP -m conntrack --ctstate ESTABLISHED -j ACCEPT -m comment --comment "Allow outgoing HTTP"
ip6tables -A OUTPUT -p tcp --sport $HTTPS -m conntrack --ctstate ESTABLISHED -j ACCEPT -m comment --comment "Allow outgoing HTTPS"

if [ -f "${CLOUDFLARE_IP_LIST}" ]; then
    while read -r ip; do
        ip6tables -A INPUT -p tcp -m multiport --dports $HTTP,$HTTPS -s "$ip" -j ACCEPT -m comment --comment "Allow Cloudflare IP $ip"
    done < $CLOUDFLARE_IP_LIST
fi

ip6tables -A INPUT -p tcp ! --syn -m state --state NEW -j DROP -m comment --comment "Force SYN packets check"
ip6tables -A INPUT -f -j DROP -m comment --comment "Force Fragments packets check"
ip6tables -A INPUT -p tcp --tcp-flags ALL ALL -j DROP -m comment --comment "XMAS packets"
ip6tables -A INPUT -p tcp --tcp-flags ALL NONE -j DROP -m comment --comment "Drop all NULL packets"
ip6tables -I INPUT -p tcp --dport $HTTP -m connlimit --connlimit-above 50 --connlimit-mask 20 -j DROP -m comment --comment "Prevent Slowloris"
ip6tables -A INPUT -p tcp --dport $SSH -m conntrack --ctstate NEW -m recent --set -m comment --comment "SSH brute-force protection"
ip6tables -A INPUT -p tcp --dport $SSH -m conntrack --ctstate NEW -m recent --update --seconds 60 --hitcount 10 -j DROP -m comment --comment "SSH brute-force protection"
# Prevent port scanning
ip6tables -N port-scanning
ip6tables -A port-scanning -p tcp --tcp-flags SYN,ACK,FIN,RST RST -m limit --limit 1/s --limit-burst 2 -j RETURN
ip6tables -A port-scanning -j DROP

ip6tables -A INPUT -s 10.0.0.0/8 -j DROP -m comment --comment "Prevent spoofing"
ip6tables -A INPUT -s 169.254.0.0/16 -j DROP -m comment --comment "Prevent spoofing"
ip6tables -A INPUT -s 172.16.0.0/12 -j DROP -m comment --comment "Prevent spoofing"
ip6tables -A INPUT -s 127.0.0.0/8 -j DROP -m comment --comment "Prevent spoofing"
ip6tables -A INPUT -s 192.0.2.0/24 -j DROP -m comment --comment "Prevent spoofing"
ip6tables -A INPUT -s 192.168.0.0/16 -j DROP -m comment --comment "Prevent spoofing"
ip6tables -A INPUT -s 224.0.0.0/4 -j DROP -m comment --comment "Prevent spoofing"
ip6tables -A INPUT -d 224.0.0.0/4 -j DROP -m comment --comment "Prevent spoofing"
ip6tables -A INPUT -s 240.0.0.0/5 -j DROP -m comment --comment "Prevent spoofing"
ip6tables -A INPUT -d 240.0.0.0/5 -j DROP -m comment --comment "Prevent spoofing"
ip6tables -A INPUT -s 0.0.0.0/8 -j DROP -m comment --comment "Prevent spoofing"
ip6tables -A INPUT -d 0.0.0.0/8 -j DROP -m comment --comment "Prevent spoofing"
ip6tables -A INPUT -d 239.255.255.0/24 -j DROP -m comment --comment "Prevent spoofing"
ip6tables -A INPUT -d 255.255.255.255 -j DROP -m comment --comment "Prevent spoofing"

ip6tables -A INPUT -p icmp -m icmp --icmp-type 8 -j ACCEPT -m comment --comment "Allow ping"

# Time sync
ip6tables -A OUTPUT -o $MAIN_NETWORK_INTERFACE -p udp -s $SERVER_IP -d 0/0 --sport 32768:65535 --dport 123 -m state --state NEW -j ACCEPT -m comment --comment "Allow time sync"
ip6tables -A INPUT -i $MAIN_NETWORK_INTERFACE -p udp -d $SERVER_IP -s 0/0 --sport 123 --dport 32768:65535 -m state --state RELATED,ESTABLISHED -j ACCEPT -m comment --comment "Allow time sync"

# === Begin Generalized Portscan Detection ===

# Port scanning
ip6tables -N PORTSCAN
ip6tables -A PORTSCAN -m recent --name portscan --set
ip6tables -A PORTSCAN -j LOG --log-prefix "PORTSCAN: " --log-level 4
ip6tables -A PORTSCAN -j DROP

ip6tables -A INPUT -m recent --name portscan --rcheck --seconds 86400 -j DROP
ip6tables -A INPUT -m recent --name portscan --remove

ip6tables -A INPUT -p tcp --tcp-flags ALL NONE -j PORTSCAN         # NULL scan
ip6tables -A INPUT -p tcp --tcp-flags ALL ALL -j PORTSCAN          # XMAS scan
ip6tables -A INPUT -p tcp --tcp-flags SYN,RST SYN,RST -j PORTSCAN  # SYN/RST
ip6tables -A INPUT -p tcp --tcp-flags SYN,FIN SYN,FIN -j PORTSCAN  # SYN/FIN
ip6tables -A INPUT -p tcp --tcp-flags FIN FIN -j PORTSCAN
ip6tables -A INPUT -p tcp --tcp-flags ACK,FIN FIN -j PORTSCAN
ip6tables -A INPUT -p tcp --tcp-flags ACK,PSH PSH -j PORTSCAN
ip6tables -A INPUT -p tcp --tcp-flags ACK,URG URG -j PORTSCAN


ip6tables -A INPUT -j LOGGING
ip6tables -A LOGGING -m limit --limit 3/min -j LOG --log-prefix "DROP: " --log-level 4
ip6tables -A LOGGING -j DROP

# === End Generalized Portscan Detection ===

ip6tables -A INPUT -j DROP
ip6tables -A OUTPUT -j DROP

ip6tables-save > /etc/ip6tables/rules.v4
