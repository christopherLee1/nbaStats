#!/usr/bin/env bash

echo "installing vim, wget, rsync, apache"
sudo yum install -y vim wget rsync httpd git

echo "setting up python"
sudo yum groupinstall -y Development tools
sudo yum install -y zlib-devel bzip2-devel openssl-devel ncurses-devel sqlite-devel readline-devel tk-devel gdbm-devel db4-devel libpcap-devel xz-devel

# check if fresh install or just re-provisioning
if [ ! -e /usr/local/bin/python3.5]; then
   if [ ! -d Python-3.5.2 ]; then # don't redownload unless we need to
      if [ ! -e Python-3.5.2.tgz ]; then
         wget https://www.python.org/ftp/python/3.5.2/Python-3.5.2.tgz
      fi
      tar -xvzf Python-3.5.2.tgz
   fi
   cd Python-3.5.2
   ./configure --prefix=/usr/local # allow multiple versions of python
   make altinstall
else # check for required python dependencies as well
   # download python packages
   pip3.5 install requests pandas bs4
fi

echo "starting apache and enabling on vm boot"
sudo systemctl stop httpd
sudo systemctl enable httpd
sudo systemctl start httpd
sudo systemctl status httpd

# now we need to to configure /var/www directories to serve our app
rm -rf /var/www # clean directories first
sudo mkdir -p /var/www/{cgi-bin,html}
ln -s /vagrant/src /var/www/cgi-bin/
ln -s /vagrant/htdocs /var/www/html
ln -s /vagrant/css /var/www/html/css
ln -s /vagrant/js /var/www/html/js
