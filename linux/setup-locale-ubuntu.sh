# before setting up locale, you need to install
apt-get install apt-transport-https
apt-get install gnupg

# if you manually added repos into sources.list in docker, import GPG Public keys to solve installation errors such as:
# W: GPG error: https://download.docker.com/linux/ubuntu bionic InRelease: The following signatures couldn't be verified because the public key is not available: NO_PUBKEY 7EA0A9C3F273FCD8
#
# Then add the public key to be imported
# sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 7EA0A9C3F273FCD8

# install locales on docker container
apt-get update
apt-get install -y locales

#generate a locale
locale-gen es_CO.UTF-8

# check if your new locale was added
locale -a

# setup locale using > to replace or >> to append as needed
#echo "LANG=es_CO.UTF-8" > /etc/default/locale
update-locale LC_ALL=es_CO.UTF-8 LANG=es_CO.UTF-8

#reboot or stop docker container

#configure timezone
dpkg-reconfigure tzdata
