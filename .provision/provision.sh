#!/bin/bash
set -u -e -o pipefail # fail on all errors and in pipes

# vars we will want
LOC=/usr/local
APACHEDIR=/var/www
CGIS=$APACHEDIR/cgi-bin
HTDOCS=$APACHEDIR/html

echo "installing vim, wget, rsync, apache"
sudo yum install -y vim wget rsync httpd git

echo "setting up python"
sudo yum groupinstall -y Development tools
sudo yum install -y zlib-devel bzip2-devel openssl-devel ncurses-devel sqlite-devel readline-devel tk-devel gdbm-devel db4-devel libpcap-devel xz-devel

# Check if fresh install or just re-provisioning
if [ ! -e $LOC/bin/python3.5]; then
   if [ ! -d Python-3.5.2 ]; then # don't redownload unless we need to
      if [ ! -e Python-3.5.2.tgz ]; then
         wget https://www.python.org/ftp/python/3.5.2/Python-3.5.2.tgz
      fi
      tar -xvzf Python-3.5.2.tgz
   fi
   cd Python-3.5.2
   ./configure --prefix=$LOC # allow multiple versions of python
   make altinstall
else # otherwise just download what we need
   pip3.5 install requests pandas bs4
fi

echo "starting apache and enabling on vm boot"
if [ ! $(service httpd status) =~ "running" ]; then 
   sudo systemctl enable httpd
   sudo systemctl start httpd
   sudo systemctl status httpd
fi

# Now we need to to configure /var/www directories to serve our app
# Clean directories first
# This will always be necessary, even if we are just running vagrant reload
# as it is assumed there are changes in the shared directory and symlinks may
# need to be updated.
sudo rm -rf /var/www 
sudo mkdir -p $APACHEDIR/{cgi-bin,html}
sudo ln -s /vagrant/src $CGIS
sudo ln -s /vagrant/htdocs $HTDOCS
sudo ln -s /vagrant/css $HTDOCS/css
sudo ln -s /vagrant/js $HTDOCS/js
sudo chown -R apache $APACHEDIR $CGIS $HTDOCS

# TODO: Allow args to this script so we can specify whether we need full setup, just 
#      update to existing files, or new files that need new symlinks.

echo "VM finished setup. Please check that you can load the home page at http://127.0.0.1:8080"
