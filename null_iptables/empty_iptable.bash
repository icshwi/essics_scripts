

SUDO=sudo

${SUDO} iptables -P INPUT ACCEPT
${SUDO} iptables -P FORWARD ACCEPT
${SUDO} iptables -P OUTPUT ACCEPT
${SUDO} iptables -t nat -F
${SUDO} iptables -t mangle -F
${SUDO} iptables -F
${SUDO} iptables -X

