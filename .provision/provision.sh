#!/bin/bash
set -u -e -o pipefail # fail on all errors and in pipes

# vars we will want
LOC=/usr/local
APACHEDIR=/var/www
CGIS=$APACHEDIR/cgi-bin
HTDOCS=$APACHEDIR/html

initialSetup () 
{
echo "installing vim, wget, rsync, git, selinux tools, and apache"
sudo yum install -y vim wget rsync httpd git setroubleshoot

echo "setting up python"
sudo yum groupinstall -y Development tools
sudo yum install -y zlib-devel bzip2-devel openssl-devel ncurses-devel sqlite-devel readline-devel tk-devel gdbm-devel db4-devel libpcap-devel xz-devel

# Check if fresh install or just re-provisioning
if [ ! -e $LOC/bin/python3.5 ]; then
   if [ ! -d Python-3.5.2 ]; then # don't redownload unless we need to
      if [ ! -e Python-3.5.2.tgz ]; then
         wget https://www.python.org/ftp/python/3.5.2/Python-3.5.2.tgz
      fi
      tar -xvzf Python-3.5.2.tgz
   fi
   cd Python-3.5.2
   ./configure --prefix=$LOC # allow multiple versions of python
   make altinstall
   sudo $LOC/bin/pip3.5 install requests pandas bs4
else # otherwise just download what we need
   sudo $LOC/bin/pip3.5 install requests pandas bs4
fi
}

# there should be a better way to check if apache is running :(
setupApache ()
{
echo "starting apache and enabling on vm boot"
pgrep httpd > /dev/null && echo running > /dev/null
if [ $? -ne 0 ]; then 
   sudo systemctl enable httpd
   sudo systemctl start httpd
   sudo systemctl status httpd
else
   echo "apache already running"
fi
}

# get rid of selinux issues
fixSELinux ()
{
sudo chcon  --user system_u --type httpd_sys_content_t -RvL $HTDOCS
sudo chcon  --user system_u --type httpd_sys_script_exec_t -RvL $CGIS
# python urlib can run fine from command line but not by apache, fix with the following
sudo setsebool -P httpd_can_network_connect 1
}

# Now we need to to configure /var/www directories to serve our app
# This will always be necessary, even if we are just running vagrant reload
# as it is assumed there are changes in the shared directory and symlinks may
# need to be updated.
syncFiles () 
{
#cd /vagrant
#git init
#git clone https://github.com/christopherLee1/nbaStats.git
sudo rm -rf /var/www 
sudo mkdir -p $APACHEDIR/{cgi-bin,html}
sudo ln -s /vagrant/src $CGIS
sudo ln -s /vagrant/htdocs $HTDOCS
sudo ln -s /vagrant/css $HTDOCS/css
sudo ln -s /vagrant/js $HTDOCS/js
sudo chown -R apache:apache $APACHEDIR $CGIS $HTDOCS
}

# main
trap errorHandler ERR

# I think this fixes 
if [ -e completeFlag ]; then
   # vm already provision, just syncing new files
   syncFiles
   fixSELinux
   exit 0
fi

if [ $# -eq 0 ]; then
   echo "running full install"
   initialSetup
   setupApache
   syncFiles
   fixSELinux
   touch completeFlag
   exit 0
fi

# pretty sure this is unnecessary now
while getopts "s" opt; do
   case $opt in
      s)
         echo "Only syncing new files, hopefully apache and python are already installed!"
         syncFiles
         exit 0
      \?)
         echo "invalid opton: -$OPTARG"
         ;;
   esac
done
#TODO: Add flag to detect if full install has been ran yet, don't allow s option if so
echo "If when importing pandas there is some Apache MemoryError, comment out 
the CFUNCTYPE(c_int)(lambda ... line."
echo "VM finished setup. Please check that you can load the home page at http://127.0.0.1:8080"
