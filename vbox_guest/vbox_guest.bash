yum -y install kernel-devel kernel-headers dkms make perl bzip2

sudo 

export KERN_DIR=/usr/src/kernels/`uname -r`

bash /run/media/opcuser/VBOXADDITIONS_5.1.30_118389/VBoxLinuxAdditions.run 
