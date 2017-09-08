define(`MUNIN_NODE',`
log_level 4	
log_file /var/log/munin-node/munin-node.log
pid_file /var/run/munin/munin-node.pid

background 1
setsid 1

user root
group root

ignore_file [\#~]$
ignore_file DEADJOE$
ignore_file \.bak$
ignore_file %$
ignore_file \.dpkg-(tmp|new|old|dist)$
ignore_file \.rpm(save|new)$
ignore_file \.pod$


host_name $1

cidr_allow 127.0.0.1/32
#cidr_allow 10.4.0.0/16
cidr_allow $2/32

host *

port $3
')
