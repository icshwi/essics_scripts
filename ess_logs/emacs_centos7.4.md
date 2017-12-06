

wget http://mirrors.ibiblio.org/gnu/ftp/gnu/emacs/emacs-25.1.tar.xz

tar xJvfp emacs-25.1.tar.xz

cd emacs-25.1/

sudo yum -y install libXpm-devel libjpeg-turbo-devel openjpeg-devel openjpeg2-devel turbojpeg-devel giflib-devel libtiff-devel gnutls-devel libxml2-devel GConf2-devel dbus-devel wxGTK-devel gtk3-devel libselinux-devel gpm-devel librsvg2-devel ImageMagick-devel

./configure

make

sudo make install 
