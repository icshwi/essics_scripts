

user_name=${USER}
host_name=${HOSTNAME}

ssh-keygen -t rsa -b 4096 -C "${user_name}@${host_name}"

