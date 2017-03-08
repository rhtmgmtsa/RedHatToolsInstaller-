#!/bin/bash
#POC/Demo

#Project git link
# https://github.com/ShaddGallegos/RedHatToolsInstaller
# https://gitlab.sat.lab.tlv.redhat.com/sgallego/Red_Hat_Tools_Installer/tree/master
# https://mojo.redhat.com/people/sgallego/blog/2017/02/22/simple-red-hat-tools-installer


# Based off the document written by Rich Jerrido https://mojo.redhat.com/docs/DOC-1030365

# Hammer referance to assist in modifing the script can be found at 
# https://www.gitbook.com/book/abradshaw/getting-started-with-satellite-6-command-line/details








clear

#--------------------------required packages for script to run----------------------------

echo " "
echo " "
echo " "
echo " "
echo " "
echo " "
echo " "
echo " "
echo " "
echo "
                                     P.O.C Satellite 6.X RHEL 7.X KVM or RHEL 7 Physical Host 
                                         THIS SCRIPT CONTAINS NO CONFIDENTIAL INFORMATION

                           This script is designed to set up a basic standalone Satellite 6.X system

                         Disclaimer: This script was written for education, evaluation, and/or testing 
                                     purposes and is not officially supported by anyone.
                                 
                        ...SHOULD NOT BE USED ON A CURRENT PRODUCTION SYSTEM - USE AT YOUR OWN RISK...

	 However the if you have an issue with the products installed and have a valid License please contact Red Hat at:
		
		RED HAT Inc..
		1-888-REDHAT-1 or 1-919-754-3700, then select the Menu Prompt for Customer Service
		Spanish: 1-888-REDHAT-1 Option 5 or 1-919-754-3700 Option 5
		Fax: 919-754-3701 (General Corporate Fax)
		Email address: customerservice@redhat.com "

echo " "
echo " "
echo " "
echo " "
echo " "
echo " "
echo " "
echo " "
echo " "
echo " "
echo " "
echo " "
echo " "
echo " "
echo " "
read -p "Press [Enter] to continue"
clear
if [ "$(whoami)" != "root" ]
then
    #sudo su -s "$0"
    echo "This script must be run as root - if you do not have the credentials please contact your administrator"
    exit
fi
#--------------------------required packages for script to run----------------------------
clear

echo "*************************************************************"
echo " Script configuration requirements installing for this server"
echo "*************************************************************"
    setenforce 0
    HNAME=$(hostname)
    domainname $(hostname -d)
    subscription-manager register --auto-attach

	#subscription-manager attach --pool=`subscription-manager list --available --matches 'Red Hat Enterprise Linux Server' --pool-only`
	
   	yum upgrade subscription-manager -y
   	yum -q list installed yum-utils &>/dev/null && echo "yum-utils  is installed" || yum install -y yum-util*  --skip-broken
    	yum-config-manager --disable "*"
	rm -fr /var/cache/yum/*
	yum clean all 
    	subscription-manager repos --enable=rhel-7-server-rpms 
    	subscription-manager repos --enable=rhel-7-server-extras-rpms  
    	subscription-manager repos --enable=rhel-7-server-optional-rpms  
    	subscription-manager repos --enable=rhel-7-server-rpms
    	sed -i 's/SELINUX=enforcing/SELINUX=permissive/g' /etc/sysconfig/selinux
    	echo 'inet.ipv4.ip_forward=1' >> /etc/sysctl.conf
    	yum -q list installed epel-release-latest-7 &>/dev/null && echo "epel-release-latest-7  is installed" || yum install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm  --skip-broken
    	yum-config-manager --enable epel
	sleep 10
    	rm -fr /var/cache/yum/*
    	yum clean all
    	yum-config-manager --save --setopt=*.skip_if_unavailable=true
	yum -q list installed gtk2-devel &>/dev/null && echo "gtk2-devel  is installed" || yum install -y gtk2-devel  --skip-broken
    	yum -q list installed wget &>/dev/null && echo "wget  is installed" || yum install -y wget  --skip-broken
    	yum -q list installed firewalld &>/dev/null && echo "firewalld  is installed" || yum install -y firewalld  --skip-broken
    	yum -q list installed ansible &>/dev/null && echo "ansible is installed" || yum install -y ansible --skip-broken 
    	yum -q list installed gnome-terminal &>/dev/null && echo "gnome-terminal is installed" || yum install -y gnome-terminal --skip-broken
    	yum -q list installed yum &>/dev/null && echo "yum is installed" || yum install -y yum --skip-broken
    	yum -q list installed lynx &>/dev/null && echo "lynx is installed" || yum install -y lynx --skip-broken
    	yum -q list installed perl &>/dev/null && echo "perl is installed" || yum install -y perl --skip-broken
    	yum -q list installed dialog &>/dev/null && echo "dialog is installed" || yum install -y *dialog* --skip-broken
    	yum -q list installed xdialog &>/dev/null && echo "xdialog is installed" || yum install -y http://rpmfind.net/linux/sourceforge/k/ke/kenzy/special/C7/x86_64/xdialog-2.3.1-13.el7.centos.x86_64.rpm --skip-broken
    	#sed -i 's/notify_only=1/notify_only=0/g'  /etc/yum/pluginconf.d/search-disabled-repos.conf 
    	yum-config-manager --disable *epel*
	yum -y upgrade --skip-broken 
	clear


#--------------------------Define Env----------------------------


#configures dialog command for proper environment

if [[ -n $DISPLAY ]]
	then
	# Assume script running under X:windows
	DIALOG=`which Xdialog`
	RC=$?
        if [[ $RC != 0 ]]
		then
		DIALOG=`which dialog`
		RC=$?
		if [[ $RC != 0 ]]
			then
			echo "Error::  Could not locate suitable dialog command: Please install dialog or if running in a desktop install Xdialog."
			exit 1
		fi
	fi
	else
	# If Display is  no set assume ok to use dialog
	DIALOG=`which dialog`
	RC=$?
	if [[ $RC != 0 ]]
		then
		echo "Error::  Could not locate suitable dialog command: Please install dialog or if running in a desktop install Xdialog."
		exit 1
	fi
fi

#------------------------------Functions---------------------------------

#-----------------------------------------------------------------------------------------------------------------------
#-----------------------------------------Stage 1 - Install Satellite 6.2-----------------------------------------------
#-----------------------------------------------------------------------------------------------------------------------

#-----------------
function baseenv {
#-----------------

echo -ne "\e[8;33;120t"
sleep 5
clear

HNAME=$(hostname)
clear
echo " "
echo " "
echo " "
echo " "
echo "
	SATELLITE BASE REQUIREMENTS:

		1. ISO media should be downloaded to /var/lib/libvirt/images of the host machine if it is to be KVM 
  	  	   or /root/Downloads/ of host machine if it is a physical install

		2. Hardware requirements may vary per your org needs, however whether 
  		   it is a  KVM or physical environment the Satellite will require 1 node with:

			Min Storage 220 GB
				Directory		Recommended
				/			Rest of drive
				/boot			1024MB
				/swap			16384MB

			Min RAM 			16384
			Min CPU				2 (4 Recommended)"
echo " "
echo " "
echo " "
echo " "
echo " "
read -p "Press [Enter] to continue"
clear
echo "
	REQUIREMENTS CONTINUED
		3. Network
			eth0 internal for nodes	
			eth1 Connection to the internet
		
		4. For this POC you must have a RHN User ID and password with entitlements
   		   to channels below. (item 6)
		
		5. Install ISO must be in /var/lib/libvirt/images/ of the host machine so they will 
   		   be scp'ed to the Satellite KVM to the /root/Downloads directory

			* RHEL 7.3 media can be downloaded from   https://access.redhat.com/downloads/content/69/ver=/rhel---7/7.3/x86_64/product-software
			* Sat 6.2.2 media can be downloaded from  https://access.redhat.com/downloads/content/250/ver=6.2/rhel---7/6.2.6/x86_64/product-software
			* The manifest for Satellite can be downloaded from https://access.redhat.com/management/distributors

		6. This install was tested with:
         	   * RHEL_7.3 using the Software Server with the build from the 7.3 install DVD in a KVM environment.
        	   * Red Hat subscriber channels:
                    		rhel-7-server-rpms
				rhel-server-rhscl-7-rpms
				rhel-7-server-satellite-6.2-rpms
				rhel-7-server-satellite-capsule-6.2-rpms
				rhel-7-server-satellite-tools-6.2-rpms
				rhel-7-server-rh-common-rpms
				rhel-7-server-extras-rpms
				rhel-7-server-rhn-tools-rpms

		7. Additional resources, packages, and documentation may be found at 
                    		http://www.redhat.com
                    		https://access.redhat.com/documentation/en/red-hat-satellite
                    		https://access.redhat.com/products/red-hat-satellite/get-started
				https://access.redhat.com/support/policy/updates/satellite"
echo " "
echo " "
read -p "If you have met the minimum requirement from above please Press [Enter] to continue"
clear
echo " "
echo " "
echo " "
echo " "
echo " "
echo "		Please set the system hostname $HNAME as specified at Subscription Management Applications under the 
      		Satellite tab from 
				https://access.redhat.com/management/distributors"

echo " "
echo " "
echo " "
echo " "
echo " "
echo "Please enter Satellite FQDN"
read HNAME
hostnamectl set-hostname $HNAME

echo "*********************************************************"
echo "Add Satellite subscription"
echo "*********************************************************"
	subscription-manager unregister
	sleep 5
	subscription-manager clean
	sleep 5
	subscription-manager register
	sleep 5
	subscription-manager list --available --matches 'Red Hat Satellite'
	sleep 5
	echo "Attaching pool id from above"
	subscription-manager attach --pool=`subscription-manager list --available --matches 'Red Hat Satellite' --pool-only`

mkdir -p /usr/share/foreman/.ssh
ssh-keygen -f /usr/share/foreman/.ssh/id_rsa -t rsa -N ''
ssh-keyscan -t ecdsa $(hostname) >/usr/share/foreman/.ssh/known_hosts
chown -R foreman.foreman /usr/share/foreman/.ssh
ssh-keygen -f /root/.ssh/id_rsa -t rsa -N  ""
echo 'inet.ipv4.ip_forward=1' >> /etc/sysctl.conf
sed -i 's/SELINUX=enforcing/SELINUX=permissive/g' /etc/sysconfig/selinux

#echo "Creating the admin user please type an initial password"
#read PASWD
#useradd -p $PASWD -c 'Administrative user for administration' admin
#useradd -G 

#adduser --group sudo admin
echo 'admin   ALL = NOPASSWD: ALL' >> /etc/sudoers

echo "*********************************************************"
echo "Add required Directories"
echo "*********************************************************"

mkdir -p /root/Downloads
mkdir -p /media/rhel73
mkdir -p /media/sat6
mkdir -p /root/.hammer

echo "*********************************************************"
echo "If ISOs are local copy to /root/Downloads"
echo "*********************************************************"
cp *.iso /root/Downloads


echo "*********************************************************"
echo "Making sure network is up"
echo "*********************************************************"
service network restart
ifup $(ip -o link | head -n 2 | tail -n 1 | awk '{print $2;}' | sed s/:$//)
ifup $(ip route show | sed -e 's/^default via [0-9.]* dev \(\w\+\).*/\1/' | head -1)

sleep 5


#yum -q list installed https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm &>/dev/null && echo "Installed" || yum install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm --skip-broken

#yum-config-manager --enable epel
#yum -q list installed dialog &>/dev/null && echo "dialog is installed" || yum install -y dialog --skip-broken
#yum -q list installed ftp://rpmfind.net/linux/sourceforge/k/ke/kenzy/special/C7/x86_64/xdialog-2.3.1-13.el7.centos.x86_64.rpm &>/dev/null && echo "xdialog is installed" || yum install -y ftp://rpmfind.net/linux/sourceforge/k/ke/kenzy/special/C7/x86_64/xdialog-2.3.1-13.el7.centos.x86_64.rpm --skip-broken
#yum -q list installed  python-urwid &>/dev/null && echo "python-urwid is installed" || yum install -y python-urwid --skip-broken
#yum -q list installed  wmctrl &>/dev/null && echo "wmctrl is installed" || yum install -y wmctrl --skip-broken
#sleep 10
yum-config-manager --disable *epel*

echo " "
echo "***********************************************************************************************************"
echo "
	If the ISOS were not provided we can SCP the ISOs and manifest to this Satellite. 
	If the ISOs and Manifest are already in /root/Downloads on this machine, this step will be skipped

	What is the host ip for the system the ISOs and Manifest were downloaded to?" 
echo " "
echo "***********************************************************************************************************"
echo "#:" ; read SCP

echo " "
echo "******************************************************************************************************************"
echo "What is the full path to the ISOs for RHEL, Sat6, and Manifest on the remote machine? eg.. /var/lib/libvirt/images :"
echo "******************************************************************************************************************"
echo "#:" ; read PATH_TO_ISO
echo " "

if [ ! -f /root/Downloads/rhel-server-7.*.iso ]; then
    scp root@$SCP:$PATH_TO_ISO/rhel-server-7.*.iso /root/Downloads/
fi

if [ ! -f /root/Downloads/satellite-*.iso ]; then
    scp root@$SCP:$PATH_TO_ISO/satellite-*.iso /root/Downloads/
fi

if [ ! -f /root/Downloads/manifest*.zip ]; then
    scp root@$SCP:$PATH_TO_ISO/manifest*.zip /root/Downloads/
fi

#scp root@$SCP:$PATH_TO_ISO*.iso /root/Downloads/
#scp root@$SCP:$PATH_TO_ISO*manifest* /root/Downloads/
sleep 5

echo " "
echo "*********************************************************"
echo 'Mounting ISOs'
echo "*********************************************************"
echo " "
mount -o loop /root/Downloads/rhel-server-7.*.iso /media/rhel73
mount -o loop /root/Downloads/satellite-*.iso /media/sat6
sleep 10

echo " "
echo "*********************************************************"
echo 'Set up local repos /etc/yum.repos.d/local.repo'
echo "*********************************************************"
cat > /etc/yum.repos.d/local.repo <<EOF
[sat62_local]
name=Satellite 6.2
baseurl=file:///media/sat6/
enabled=1
gpgcheck=0

[RHEL73_local]
name=Red Hat Enterprise Linux
baseurl=file:///media/rhel73/
enabled=1
gpgcheck=0

[RHSCL_local]
name=RHSCL
baseurl=file:///media/sat6/RHSCL/
enabled=1
gpgcheck=0
EOF

sleep 5

}

#----------------------------------
function rhel7_firewall {
#----------------------------------
echo ""
echo "*********************************************************"
echo 'Set up firewalld for Satellite'
echo "*********************************************************"
systemctl start firewalld.service
systemctl enable firewalld.service
echo "16509/tcp"
firewall-cmd --permanent --add-port="16509/tcp"
echo "16514/tcp"
firewall-cmd --permanent --add-port=16514/tcp
echo "22/tc"
firewall-cmd --permanent --add-port=22/tcp
echo "27017/tcp"
firewall-cmd --permanent --add-port=27017/tcp
echo "389/tcp"
firewall-cmd --permanent --add-port=389/tcp
echo "443/tcp"
firewall-cmd --permanent --add-port=443/tcp
echo "5000/tcp"
firewall-cmd --permanent --add-port=5000/tcp
echo "53/tcp"
firewall-cmd --permanent --add-port=53/tcp
echo "53/udp"
firewall-cmd --permanent --add-port=53/udp
echo "5646/tcp"
firewall-cmd --permanent --add-port=5646/tcp
echo "=5647/tcp"
firewall-cmd --permanent --add-port=5647/tcp
echo "5671/tcp"
firewall-cmd --permanent --add-port=5671/tcp
echo "5672/tcp"
firewall-cmd --permanent --add-port=5672/tcp
echo "5900/tcp"
firewall-cmd --permanent --add-port=5900/tcp
echo "5910-5930/tcp"
firewall-cmd --permanent --add-port=5910-5930/tcp
echo "5930/tcp"
firewall-cmd --permanent --add-port=5930/tcp
echo "636/tcp"
firewall-cmd --permanent --add-port=636/tcp
echo "67/udp"
firewall-cmd --permanent --add-port=67/udp
echo "68/udp"
firewall-cmd --permanent --add-port=68/udp
echo "69/udp"
firewall-cmd --permanent --add-port=69/udp
echo "7911/tcp"
firewall-cmd --permanent --add-port=7911/tcp
echo "80/tcp"
firewall-cmd --permanent --add-port=80/tcp
echo "8000/tcp"
firewall-cmd --permanent --add-port=8000/tcp
echo "8080/tcp"
firewall-cmd --permanent --add-port=8080/tcp
echo "8140/tcp"
firewall-cmd --permanent --add-port=8140/tcp
echo "8443/tcp"
firewall-cmd --permanent --add-port=8443/tcp
echo "9090/tcp"
firewall-cmd --permanent --add-port=9090/tcp

echo "Firewall services for tftp, RH-Satellite-6, https, http, dns, and dhcp"
firewall-cmd --zone public --add-service mountd
firewall-cmd --zone public --add-service rpc-bind
firewall-cmd --zone public --add-service nfs 
firewall-cmd --permanent --zone public --add-service mountd
firewall-cmd --permanent --zone public --add-service rpc-bind
firewall-cmd --permanent --zone public --add-service nfs
firewall-cmd --permanent --add-service=tftp
firewall-cmd --permanent --add-service=RH-Satellite-6
firewall-cmd --permanent --add-service=https
firewall-cmd --permanent --add-service=http
firewall-cmd --permanent --add-service=dns
firewall-cmd --permanent --add-service=dhcp
sleep 2
echo "Restarting firewall"
systemctl restart firewalld.service

sleep 10
}

#----------------------------------
function configure_repos {
#----------------------------------
echo ""
echo "*********************************************************"
echo 'Enable/Disable repos for Satellite'
echo "*********************************************************"
#sed -i 's/notify_only=0/notify_only=1/g'  /etc/yum/pluginconf.d/search-disabled-repos.conf

yum-config-manager --disable "*"

time subscription-manager repos --enable=rhel-7-server-extras-rpms 
time subscription-manager repos --enable=rhel-7-server-optional-rpms
time subscription-manager repos --enable=rhel-7-server-rh-common-rpms
time subscription-manager repos --enable=rhel-7-server-rhn-tools-rpms 
time subscription-manager repos --enable=rhel-7-server-rpms
time subscription-manager repos --enable=rhel-server-rhscl-7-rpms
time subscription-manager repos --enable=rhel-7-server-satellite-6.2-rpms
time subscription-manager repos --enable=rhel-7-server-satellite-capsule-6.2-rpms 
time subscription-manager repos --enable=rhel-7-server-satellite-tools-6.2-rpms 
sleep 20


rm -fr /var/cache/yum/*
yum clean all
sleep 20
yum-config-manager --save --setopt=*.skip_if_unavailable=true
sleep 10
}

#----------------------------------
function install_packages  {
#----------------------------------
echo ""
echo "*********************************************************"
echo 'Install packages for Satellite (can take upto 30 min)'
echo "*********************************************************"
echo 'if $programname == "systemd" and ($msg contains "Starting Session" or $msg contains "Started Session" or $msg contains "slice" or $msg contains "Starting user-" or $msg contains clipboard" ) then stop' > /etc/rsyslog.d/ignore-systemd-session-slice.conf
systemctl restart rsyslog
gnome-terminal -e "tail -f /var/log/messages"
yum -q list installed tftp-server &>/dev/null && echo "tftp-server installed" || yum install -y tftp-server --skip-broken
yum -q list installed syslinux &>/dev/null && echo "syslinux installed" || yum install -y syslinux --skip-broken
yum -q list installed bind-utils &>/dev/null && echo "bind-utils installed" || yum install -y bind-utils --skip-broken
yum -q list installed nfs-utils &>/dev/null && echo "nfs-utils installed" || yum install -y nfs-utils --skip-broken

subscription-manager repos --enable=rhel-7-server-satellite-6.1-rpms 
subscription-manager repos --enable=rhel-7-server-satellite-6.0-rpms

yum install -y elasticsearch
yum -q list installed ruby193-rubygem-tire &>/dev/null && echo "ruby193-rubygem-tire installed" || yum install -y ruby193-rubygem-tire --skip-broken
yum -q list installed tfm-rubygem-tire &>/dev/null && echo "tfm-rubygem-tire installed" || yum install -y tfm-rubygem-tire --skip-broken

subscription-manager repos --disable=rhel-7-server-satellite-6.1-rpms
subscription-manager repos  --disable=rhel-7-server-satellite-6.0-rpms

yum -q list installed acpid &>/dev/null && echo "acpid installed" || yum install -y acpid --skip-broken
yum -q list installed chrony &>/dev/null && echo "chrony installed" || yum install -y chrony --skip-broken
yum -q list installed kexec-tools &>/dev/null && echo "kexec-tools installed" || yum install -y kexec-tools --skip-broken
yum install -y scap-security-guide openscap-scanner openscap-utils openscap openscap-scanner openscap-utils openscap.i686 openscap-devel.i686 openscap-devel openscap-engine-sce.i686 openscap-engine-sce openscap-engine-sce-devel.i686 openscap-engine-sce-devel openscap-extra-probes openscap-python openscap-selinux.noarch  --skip-broken
yum-complete-transaction --cleanup-only

echo ""
echo "******************************************************************************************************************"
echo 'Stand by while some additional packages for Satellite are installed and the system base is prepaired'
echo "******************************************************************************************************************"
cd /media/sat6/ ; ./install_packages
sleep 10
}

#Stage 2 - Configure Satellite 
#-------------------------------
function satellite_environment {
#-------------------------------
echo ""
echo "*********************************************************"
echo 'Set up environment for Satellite in /root/.bashrc'
echo "*********************************************************"
cp /root/.bashrc /root/.bashrc.bak
export INTERNAL=$(ip -o link | head -n 2 | tail -n 1 | awk '{print $2;}' | sed s/:$//)
export EXTERNAL=$(ip route show | sed -e 's/^default via [0-9.]* dev \(\w\+\).*/\1/' | head -1)
echo "INTERNAL=$(ip -o link | head -n 2 | tail -n 1 | awk '{print $2;}' | sed s/:$//)" >> /root/.bashrc
echo "EXTERNAL=$(ip route show | sed -e 's/^default via [0-9.]* dev \(\w\+\).*/\1/' | head -1)" >> /root/.bashrc
echo "DHCPDNS=$(ifconfig $INTERNAL | grep "inet" | awk -F ' ' '{print $2}' |grep -v f |awk -F . '{print $1"."$2"."$3"."$4}')" >> /root/.bashrc
echo "GATEWAY=$(ifconfig $INTERNAL | grep "inet" | awk -F ' ' '{print $2}' |grep -v f |awk -F . '{print $1"."$2"."0"."1}')" >> /root/.bashrc
echo "DNSFWD=$(ifconfig $INTERNAL | grep "inet" | awk -F ' ' '{print $2}' |grep -v f |awk -F . '{print $1"."$2"."0"."1}')" >> /root/.bashrc
echo "DNSRVS=$(ifconfig $INTERNAL | grep "inet" | awk -F ' ' '{print $2}' |grep -v f |awk -F . '{print $3"."$2"."$1".""in-addr.arpa"}')" >> /root/.bashrc
echo "DHCPGW=$(ifconfig $INTERNAL | grep "inet" | awk -F ' ' '{print $2}' |grep -v f |awk -F . '{print $1"."$2"."0"."1}')" >> /root/.bashrc
echo "DHCPSTART=$(ifconfig $INTERNAL | grep "inet" | awk -F ' ' '{print $2}' |grep -v f |awk -F . '{print $1"."$2"."100"."1}')" >> /root/.bashrc
echo "DHCPEND=$(ifconfig $INTERNAL | grep "inet" | awk -F ' ' '{print $2}' |grep -v f |awk -F . '{print $1"."$2"."100"."250}')" >> /root/.bashrc
echo "ORG=$(hostname -s)" >> /root/.bashrc
echo 'What is the company or customer name, spaces should be _ (eg.. Custy_Customer)'
read COMPANY
echo 'What is the location of the Satellite? (eg.. DENVER)'
read SATLOCATION
echo "LOCATION=$SATLOCATION" >> /root/.bashrc
echo "DOMAIN=$(hostname -d)" >> /root/.bashrc
echo "SATELLITE=$(hostname)" >> /root/.bashrc
echo "HNAME=$(hostname)" >> /root/.bashrc
echo "EXTERNALIP=$(ifconfig $EXTERNAL |grep -v inet6 |grep inet |awk {'print $2'})" >> /root/.bashrc
echo "INTERNALIP=$(ifconfig $INTERNAL |grep -v inet6 |grep inet |awk {'print $2'})" >> /root/.bashrc
echo "REALM=$(hostname -d)" >> /root/.bashrc
echo "ADMIN=admin" >> /root/.bashrc
echo "ADMIN_PASSWORD=redhat" >> /root/.bashrc
echo "HOST_PREFIX=$COMPANY" >> /root/.bashrc
echo "HOST_PASSWORD=redhat" >> /root/.bashrc
source /root/.bashrc
echo $(ifconfig $INTERNAL | grep "inet" | awk -F ' ' '{print $2}' |grep -v f |awk -F . '{print $1"."$2"."$3"."$4}') $(hostname -f) $(hostname -s) >>/etc/hosts
}

#------------------------------
function satellite_configure {
#------------------------------
echo ""
echo "******************************************************************"
echo 'Base configuration of Satellite (This can take up to 30 to 40 min)'
echo "******************************************************************"
source /root/.bashrc
cat > /root/satellite_configure.sh << EOF
satellite-installer -v --scenario satellite --capsule-puppet=true --enable-foreman-plugin-openscap --foreman-admin-password=redhat --foreman-admin-username=admin --foreman-initial-location=$LOCATION --foreman-initial-organization=$ORG --foreman-proxy-dhcp=true --foreman-proxy-dhcp-gateway=$DHCPGW --foreman-proxy-dhcp-interface=$INTERNAL --foreman-proxy-dhcp-nameservers=$DHCPDNS --foreman-proxy-dhcp-range="$DHCPSTART $DHCPEND" --foreman-proxy-dns=true --foreman-proxy-dns-forwarders=$DNSFWD --foreman-proxy-dns-interface=$INTERNAL --foreman-proxy-dns-reverse=$DNSRVS --foreman-proxy-dns-zone=$DOMAIN --foreman-proxy-dns=true --foreman-proxy-plugin-discovery-install-images=true --foreman-proxy-plugin-discovery-tftp-root /var/lib/tftpboot --foreman-proxy-puppetca=true --foreman-proxy-templates=true --foreman-proxy-tftp=true --foreman-proxy-tftp-servername=$SATELLITE 
EOF

chmod 777 /root/satellite_configure.sh
sh /root/satellite_configure.sh
mkdir -p /etc/puppet/environments/production/modules
sleep 10

yum -q list installed tfm-rubygem-foreman_discovery &>/dev/null && echo "tfm-rubygem-foreman_discovery installed" || yum install -y *rubygem-foreman_discovery --skip-broken
yum -q list installed foreman-discovery-image  &>/dev/null && echo "foreman-discovery-image installed"  || yum install -y foreman-discovery-image --skip-broken
yum -q list installed rubygem-smart_proxy_discovery_image  &>/dev/null && echo "rubygem-smart_proxy_discovery_image installed"  || yum install -y rubygem-smart_proxy_discovery* --skip-broken
yum -q list installed puppet-foreman_scap_client &>/dev/null && echo "puppet-foreman_scap_client installed" || yum install -y puppet-foreman_scap_client --skip-broken
yum -q list installed rubygem-foreman_api &>/dev/null && echo "rubygem-foreman_api installed" || yum install -y rubygem-foreman_api --skip-broken
yum -q list installed rubygem-foreman_scap_client &>/dev/null && echo "rubygem-foreman_scap_client installed" || yum install -y rubygem-foreman_scap_client --skip-broken
yum -q list installed satellite-capsule &>/dev/null && echo "satellite-capsule installed" || yum install -y satellite-capsule --skip-broken
yum -q list installed katello-agent &>/dev/null && echo "katello-agent installed" || yum install -y katello-agent --skip-broken
yum -q list installed puppet-foreman_scap_client &>/dev/null && echo "puppet-foreman_scap_client installed" || yum install -y puppet-foreman_scap_client --skip-broken
yum -q list installed ruby193-rubygem-tire &>/dev/null && echo "ruby193-rubygem-tire installed" || yum install -y ruby193-rubygem-tire --skip-broken
yum -q list installed tfm-rubygem-tire &>/dev/null && echo "tfm-rubygem-tire installed" || yum install -y tfm-rubygem-tire --skip-broken

systemctl stop goferd
systemctl disable goferd
service foreman-proxy restart
hammer capsule refresh-features --id=1
foreman-rake foreman_openscap:bulk_upload:default


}

#-----------------------------------------------------------------------------------------------------------------------
#-------------------------------Stage 2 - Configure and enable and sync repositories------------------------------------
#-----------------------------------------------------------------------------------------------------------------------
function stage2 {
echo -ne "\e[8;33;120t"
source /root/.bashrc
sleep 2

clear
echo "***********************************************************************************************************"
echo "Enabling Hammer for Satellite configuration tasks"

echo "
	Setting up hammer will list the Satellite username and password in the /root/.hammer/cli_config.yml file 
	with default permissions set to -rw-r--r--, if this is a security concern it is reccomended the file is 
	deleted once the setup is complete"
echo " "
echo "***********************************************************************************************************"

cat > /root/.hammer/cli_config.yml<< EOF
:foreman:
    :host: 'https://$(hostname)'
    :username: 'admin'
    :password: 'redhat'

:log_dir: '/var/log/foreman'
:log_level: 'error'

EOF
sed -i 's/example/redhat/g'  /etc/hammer/cli.modules.d/foreman.yml
sed -i 's/#:password/:password/g'  /etc/hammer/cli.modules.d/foreman.yml

#echo " "
#echo "*********************************************************"
#echo "Create a new organization and user admin into it:"
#echo "*********************************************************"
#hammer organization create --name $ORG --label $ORG
hammer organization add-user --user=admin --name $ORG

#echo " "
#echo "*********************************************************"
#echo "New location:"
#echo "*********************************************************"
#read NEWLOCATION
#hammer location create --name=$NEWLOCATION

#echo " "
#echo "*********************************************************"
#echo "New user:"
#echo "*********************************************************"
#read NEWUSER
hammer location add-user --name=$LOCATION --user=admin

#echo " "
#echo "*********************************************************"
#echo "New organization:"
#echo "*********************************************************"
#read NEWORG
#hammer location add-organization --name=RDU --organization $NEWORG

echo " "
echo "*********************************************************"
echo "Create a domain:"
echo "*********************************************************"
hammer domain create --name $DOMAIN
hammer domain list

echo " "
echo "*****************************************************************"
echo "Create a subnet for the Satellite to communicate with its clients:"
echo "*****************************************************************"
echo 'please specify the gateway for the subnet. (eg.. 10.168.0.1)'
read SUBGATEWAY
echo 'please specify the mask for the subnet. (eg.. 255.255.0.0)'
read SUBMASK
echo 'please specify the name for the subnet. (eg.. 10.168.0.0_16)'
read SUBNAME
echo 'please specify the network for the subnet. (eg.. 10.168.0.0)'
read SUBNETWORK
echo 'please specify the dns for the subnet. (eg.. 10.168.0.1)'
read SUBDNS

hammer subnet create --domain-ids=1 --gateway=$SUBGATEWAY --mask=$SUBMASK --name=$SUBNAME  --tftp-id=1 --network=$SUBNETWORK --dns-primary=$SUBDNS --dhcp-id 1 --dns-id 1 --organizations $ORG --locations $LOC

echo " "
echo "****************************************************************************"
echo "Associate domain/subnet to our organization/location through the web portal:"
echo "****************************************************************************"
hammer organization add-subnet --id=1 --name $ORG
hammer organization add-domain --id=1 --name $ORG 
hammer subnet list

echo " "
echo "********************************************************************************"
echo "Upload our manifest.zip (created in RH Portal) to our org and list our products:"
echo "********************************************************************************"
hammer subscription upload --organization $ORG --file /root/Downloads/manifest_*.zip
hammer subscription list --organization $ORG

echo " "
echo "*********************************************************"
echo "List all product repositories:"
echo "*********************************************************"
hammer repository-set list --organization $ORG --product 'Red Hat Enterprise Linux Server'

echo " "
echo "Set sync to on_demand rather than immediate:"
hammer settings set --name default_download_policy --value on_demand

echo " "
echo "*******************************************************************************************************"
echo "
Syncing repos this can take hours or days depending what all has been added So kick your feet up, and/or have some coffee and cheack back 
Please goto your system with a browser and connect to https://"$EXTERNALIP"/katello/sync_management to view progress"
echo " "
echo "*******************************************************************************************************"

echo " "
echo "*********************************************************"
echo "Red Hat Enterprise Linux 6 Server (Kickstart):"
echo "*********************************************************"
hammer repository-set enable --organization $ORG --product 'Red Hat Enterprise Linux Server' --basearch='x86_64' --releasever='6.8' --name 'Red Hat Enterprise Linux 6 Server (Kickstart)' 
time hammer repository synchronize --organization $ORG --product 'Red Hat Enterprise Linux Server'  --name  'Red Hat Enterprise Linux 6 Server Kickstart x86_64 6.8' 2>/dev/null
echo " "
echo "*********************************************************"
echo "Red Hat Enterprise Linux 6 Server (RPMs):"
echo "*********************************************************"
hammer repository-set enable --organization $ORG --product 'Red Hat Enterprise Linux Server' --basearch='x86_64' --releasever='6Server' --name 'Red Hat Enterprise Linux 6 Server (RPMs)'
time hammer repository synchronize --organization $ORG --product 'Red Hat Enterprise Linux Server'  --name  'Red Hat Enterprise Linux 6 Server RPMs x86_64 6Server' 2>/dev/null
echo " "
echo "*********************************************************"
echo "Red Hat Satellite Tools 6.2 (for RHEL 6 Server) (RPMs):"
echo "*********************************************************"
hammer repository-set enable --organization $ORG --product 'Red Hat Enterprise Linux Server' --basearch='x86_64' --name 'Red Hat Satellite Tools 6.2 (for RHEL 6 Server) (RPMs)'
time hammer repository synchronize --organization $ORG --product 'Red Hat Enterprise Linux Server'  --name  'Red Hat Satellite Tools 6.2 for RHEL 6 Server RPMs x86_64' 2>/dev/null
echo " "
echo "*********************************************************"
echo "Red Hat Software Collections RPMs for Red Hat Enterprise Linux 6 Server:"
echo "*********************************************************"
hammer repository-set enable --organization $ORG --product 'Red Hat Software Collections for RHEL Server' --basearch='x86_64' --releasever='6Server' --name 'Red Hat Software Collections RPMs for Red Hat Enterprise Linux 6 Server'
time hammer repository synchronize --organization $ORG --product 'Red Hat Software Collections for RHEL Server'  --name  'Red Hat Software Collections RPMs for Red Hat Enterprise Linux 6 Server x86_64 6Server' 2>/dev/null 
echo " "
echo "*********************************************************"
echo "Red Hat Enterprise Linux 6 Server - Extras (RPMs):"
echo "*********************************************************"
hammer repository-set enable --organization $ORG --product 'Red Hat Enterprise Linux Server' --basearch='x86_64' --name 'Red Hat Enterprise Linux 6 Server - Extras (RPMs)'
time hammer repository synchronize --organization $ORG --product 'Red Hat Enterprise Linux Server'  --name  'Red Hat Enterprise Linux 6 Server - Extras RPMs x86_64 6Server' 2>/dev/null
echo " "
echo "*********************************************************"
echo "Red Hat Enterprise Linux 6 Server - Optional (RPMs):"
echo "*********************************************************"
hammer repository-set enable --organization $ORG --product 'Red Hat Enterprise Linux Server' --basearch='x86_64' --releasever='6Server' --name 'Red Hat Enterprise Linux 6 Server - Optional (RPMs)'
time hammer repository synchronize --organization $ORG --product 'Red Hat Enterprise Linux Server'  --name  'Red Hat Enterprise Linux 6 Server - Optional RPMs x86_64 6Server' 2>/dev/null
echo " "
echo "*********************************************************"
echo "Red Hat Enterprise Linux 6 Server - Supplementary (RPMs):"
echo "*********************************************************"
hammer repository-set enable --organization $ORG --product 'Red Hat Enterprise Linux Server' --basearch='x86_64' --releasever='6Server' --name 'Red Hat Enterprise Linux 6 Server - Supplementary (RPMs)'
time hammer repository synchronize --organization $ORG --product 'Red Hat Enterprise Linux Server'  --name  'Red Hat Enterprise Linux 6 Server - Supplementary RPMs x86_64 6Server' 2>/dev/null
echo " "
echo "*********************************************************"
echo "Red Hat Enterprise Linux 6 Server - RH Common (RPMs):"
echo "*********************************************************"
hammer repository-set enable --organization $ORG --product 'Red Hat Enterprise Linux Server' --basearch='x86_64' --releasever='6Server' --name 'Red Hat Enterprise Linux 6 Server - RH Common (RPMs)'
time hammer repository synchronize --organization $ORG --product 'Red Hat Enterprise Linux Server'  --name  'Red Hat Enterprise Linux 6 Server - RH Common RPMs x86_64 6Server' 2>/dev/null

echo " "
echo "*********************************************************"
echo "EPEL 6 packages:"
echo "*********************************************************"
wget -q https://dl.fedoraproject.org/pub/epel/RPM-GPG-KEY-EPEL-6 -O /root/RPM-GPG-KEY-EPEL-6
hammer gpg create --key /root/RPM-GPG-KEY-EPEL-6  --name 'GPG-EPEL-6' --organization $ORG
hammer product create --name='Extra Packages for Enterprise Linux 6' --organization $ORG
hammer repository create --name='Extra Packages for Enterprise Linux 6' --organization $ORG --product='Extra Packages for Enterprise Linux 6' --content-type=yum --publish-via-http=true --url=http://dl.fedoraproject.org/pub/epel/6/x86_64/  --checksum-type=sha256 --gpg-key=GPG-EPEL-6
time hammer repository synchronize --organization $ORG --product 'Extra Packages for Enterprise Linux 6'  --name  'Extra Packages for Enterprise Linux 6' 2>/dev/null

echo " "
echo "*********************************************************"
echo "Red Hat Enterprise Linux 7 Server (Kickstart):"
echo "*********************************************************"
hammer repository-set enable --organization $ORG --product 'Red Hat Enterprise Linux Server' --basearch='x86_64' --releasever='7.3' --name 'Red Hat Enterprise Linux 7 Server (Kickstart)' 
hammer repository update --organization $ORG --product 'Red Hat Enterprise Linux Server' --name 'Red Hat Enterprise Linux 7 Server Kickstart x86_64 7.3' --download-policy immediate
time hammer repository synchronize --organization $ORG --product 'Red Hat Enterprise Linux Server'  --name  'Red Hat Enterprise Linux 7 Server Kickstart x86_64 7.3' 2>/dev/null
echo " "
echo "*********************************************************"
echo "Red Hat Enterprise Linux 7 Server (RPMs):"
echo "*********************************************************"
hammer repository-set enable --organization $ORG --product 'Red Hat Enterprise Linux Server' --basearch='x86_64' --releasever='7Server' --name 'Red Hat Enterprise Linux 7 Server (RPMs)'
time hammer repository synchronize --organization $ORG --product 'Red Hat Enterprise Linux Server'  --name  'Red Hat Enterprise Linux 7 Server RPMs x86_64 7Server' 2>/dev/null
echo " "
echo "*********************************************************"
echo "Red Hat Satellite Tools 6.2 (for RHEL 7 Server) (RPMs):"
echo "*********************************************************"
hammer repository-set enable --organization $ORG --product 'Red Hat Enterprise Linux Server' --basearch='x86_64' --name 'Red Hat Satellite Tools 6.2 (for RHEL 7 Server) (RPMs)'
time hammer repository synchronize --organization $ORG --product 'Red Hat Enterprise Linux Server'  --name  'Red Hat Satellite Tools 6.2 for RHEL 7 Server RPMs x86_64'
echo " "
echo "*********************************************************"
echo "Red Hat Software Collections RPMs for Red Hat Enterprise Linux 7 Server:"
echo "*********************************************************"
hammer repository-set enable --organization $ORG --product 'Red Hat Software Collections for RHEL Server' --basearch='x86_64' --releasever='7Server' --name 'Red Hat Software Collections RPMs for Red Hat Enterprise Linux 7 Server'
time hammer repository synchronize --organization $ORG --product 'Red Hat Software Collections for RHEL Server'  --name  'Red Hat Software Collections RPMs for Red Hat Enterprise Linux 7 Server x86_64 7Server' 2>/dev/null
echo " "
echo "*********************************************************"
echo "Red Hat Enterprise Linux 7 Server - Extras (RPMs):"
echo "*********************************************************"
hammer repository-set enable --organization $ORG --product 'Red Hat Enterprise Linux Server' --basearch='x86_64' --name 'Red Hat Enterprise Linux 7 Server - Extras (RPMs)'
time hammer repository synchronize --organization $ORG --product 'Red Hat Enterprise Linux Server'  --name  'Red Hat Enterprise Linux 7 Server - Extras RPMs x86_64' 2>/dev/null
echo " "
echo "*********************************************************"
echo "Red Hat Enterprise Linux 7 Server - Optional (RPMs):"
echo "*********************************************************"
hammer repository-set enable --organization $ORG --product 'Red Hat Enterprise Linux Server' --basearch='x86_64' --releasever='7Server' --name 'Red Hat Enterprise Linux 7 Server - Optional (RPMs)'
time hammer repository synchronize --organization $ORG --product 'Red Hat Enterprise Linux Server'  --name  'Red Hat Enterprise Linux 7 Server - Optional RPMs x86_64 7Server' 2>/dev/null
echo " "
echo "*********************************************************"
echo "Red Hat Enterprise Linux 7 Server - RH Common (RPMs):"
echo "*********************************************************"
hammer repository-set enable --organization $ORG --product 'Red Hat Enterprise Linux Server' --basearch='x86_64' --releasever='7Server' --name 'Red Hat Enterprise Linux 7 Server - RH Common (RPMs)'
time hammer repository synchronize --organization $ORG --product 'Red Hat Enterprise Linux Server'  --name  'Red Hat Enterprise Linux 7 Server - RH Common RPMs x86_64 7Server' 2>/dev/null
echo " "
echo "*********************************************************"
echo "Red Hat Enterprise Linux 7 Server - Supplementary (RPMs):"
echo "*********************************************************"
hammer repository-set enable --organization $ORG --product 'Red Hat Enterprise Linux Server' --basearch='x86_64' --releasever='7Server' --name 'Red Hat Enterprise Linux 7 Server - Supplementary (RPMs)'
time hammer repository synchronize --organization $ORG --product 'Red Hat Enterprise Linux Server'  --name  'Red Hat Enterprise Linux 7 Server - Supplementary RPMs x86_64 7Server' 2>/dev/null
echo " "
echo "*********************************************************"
echo "Red Hat Ceph Storage Tools 1.3 for Red Hat Enterprise Linux 7 Server (RPMs):"
echo "*********************************************************"
hammer repository-set enable --organization $ORG --product 'Red Hat Enterprise Linux Server' --basearch='x86_64' --releasever='7Server' --name 'Red Hat Ceph Storage Tools 1.3 for Red Hat Enterprise Linux 7 Server (RPMs)'
time hammer repository synchronize --organization $ORG --product 'Red Hat Enterprise Linux Server'  --name  'Red Hat Ceph Storage Tools 1.3 for Red Hat Enterprise Linux 7 Server RPMs x86_64 7Server' 2>/dev/null
echo " "
echo "*********************************************************"
echo "Red Hat Enterprise Linux 7 Server - Oracle Java:"
echo "*********************************************************"
echo " "
hammer repository-set enable --organization $ORG --product 'Oracle Java for RHEL Server' --basearch='x86_64' --releasever='7Server' --name 'Red Hat Enterprise Linux 7 Server - Oracle Java (RPMs)'
time hammer repository synchronize --organization $ORG --product 'Oracle Java for RHEL Server'  --name  'Red Hat Enterprise Linux 7 Server - Oracle Java (RPMs)' 2>/dev/null

echo " "
echo "*********************************************************"
echo "Extra Packages for Enterprise Linux 7 - x86_64:"
echo "*********************************************************"
wget -q https://dl.fedoraproject.org/pub/epel/RPM-GPG-KEY-EPEL-7 -O /root/RPM-GPG-KEY-EPEL-7
hammer gpg create --key /root/RPM-GPG-KEY-EPEL-7  --name 'GPG-EPEL-7' --organization $ORG
hammer product create --name='Extra Packages for Enterprise Linux 7' --organization $ORG
hammer repository create --name='Extra Packages for Enterprise Linux 7' --organization $ORG --product='Extra Packages for Enterprise Linux 7' --content-type yum --publish-via-http=true --url=http://dl.fedoraproject.org/pub/epel/7/x86_64/
time hammer repository synchronize --organization $ORG --product 'Extra Packages for Enterprise Linux 7'  --name  'Extra Packages for Enterprise Linux 7' 2>/dev/null

echo " "
echo "*********************************************************"
echo "Create a new product for Ansible-Tower:"
echo "*********************************************************"
hammer product create --name='Ansible-Tower' --organization $ORG
hammer repository create --name='Ansible-Tower' --organization $ORG --product='Ansible-Tower' --content-type yum --publish-via-http=true --url=http://releases.ansible.com/ansible-tower/rpm/epel-7-x86_64/
time hammer repository synchronize --organization $ORG --product 'Ansible-Tower'  --name  'Ansible-Tower' 2>/dev/null

echo " "
echo "*********************************************************"
echo "Create a new product for Puppet modules in Puppet Forge:"
echo "*********************************************************"
hammer product create --name='Puppet Forge' --organization $ORG
hammer repository create --name='Puppet Forge' --organization $ORG --product='Puppet Forge' --content-type puppet --publish-via-http=true --url=https://forge.puppetlabs.com
time hammer repository synchronize --organization $ORG --product 'Puppet Forge'  --name  'Puppet Forge' 2>/dev/null



katello-service restart
foreman-rake katello:reindex

#echo " "
#echo "*********************************************************"
#echo "Sync all repositories:"
#echo "*********************************************************"

#for i in $(hammer --csv repository list --organization $ORG  | awk -F, {'print $1'} | grep -vi '^ID'); do hammer repository synchronize --id ${i} --organization $ORG --async; done



}

#-----------------------------------------------------------------------------------------------------------------------
#-------------------------------------------Stage 3 - Configure Satellite-----------------------------------------------
#-----------------------------------------------------------------------------------------------------------------------
function stage3 {
echo -ne "\e[8;33;120t"
sleep 2
source /root/.bashrc
SUBNAME=$(hammer subnet list |awk -F "|" {'print $2'} |grep -v "-"|grep -v NAME |sed 's/ //g')
MEDID1=$(hammer --csv medium list | grep 'Red_Hat_Enterprise_Linux_7_Server_Kickstart_x86_64_7_3' | awk -F, {'print $1'})
MEDID2=$(hammer --csv medium list | grep 'Red_Hat_Enterprise_Linux_6_Server_Kickstart_x86_64_6_8' | awk -F, {'print $1'})

echo "if $programname == "systemd" and ($msg contains "Starting Session" or $msg contains "Started Session" or $msg contains "Created slice" or $msg contains "Starting user-") then stop" >> /etc/rsyslog.d/ignore-systemd-session-slice.conf
ausearch -c 'celery' --raw | audit2allow -M my-celery
semodule -i my-celery.pp
clear

echo " "
echo "*********************************************************"
echo "Associate subnet to location:"
echo "*********************************************************"
hammer subnet update --name $SUBNAME --locations $LOCATION --organizations  $ORG

echo " "
echo "*********************************************************"
echo "Associate media to location:"
echo "*********************************************************"
hammer location add-medium --medium-id $MEDID1 --name $LOCATION
hammer location add-medium --medium-id $MEDID2 --name $LOCATION

echo " "
echo "*********************************************************"
echo "Associate organization to location:"
echo "*********************************************************"
hammer location add-organization --organization $ORG --name $LOCATION

echo " "
echo "*********************************************************"
echo "Associate domain to location:"
echo "*********************************************************"
hammer location add-domain --domain  $DOMAIN --name $LOCATION

echo " "
echo "*********************************************************"
echo "Create puppet environments:"
echo "*********************************************************"
time hammer environment create --locations $LOCATION --organizations $ORG --name puppet

echo " "
echo "*********************************************************"
echo "Create 3 environments DEV_RHEL->TEST_RHEL->PROD_RHEL:"
echo "*********************************************************"
echo "DEVLOPMENT"
time hammer lifecycle-environment create --name='DEV_RHEL' --prior='Library' --organization $ORG
sleep 10
echo "TEST"
time hammer lifecycle-environment create --name='TEST_RHEL' --prior='DEV_RHEL' --organization $ORG
sleep 10
echo "PRODUCTION"
time hammer lifecycle-environment create --name='PROD_RHEL' --prior='TEST_RHEL' --organization $ORG
sleep 10

echo " "
hammer lifecycle-environment list --organization $ORG
echo " "
echo "*********************************************************"
echo "Create a daily sync plan:"
echo "*********************************************************"
time hammer sync-plan create --name 'Daily Sync' --description 'Daily Synchronization Plan' --organization $ORG --interval daily --sync-date $(date +"%Y-%m-%d")" 00:00:00" --enabled yes
sleep 10
hammer sync-plan list --organization $ORG


echo " "
echo "Daily Sync Plan - Red Hat Enterprise Linux Server"
hammer product set-sync-plan --name 'Red Hat Enterprise Linux Server' --organization $ORG --sync-plan 'Daily Sync'
sleep 10
echo "Daily Sync Plan - Extra Packages for Enterprise Linux 6"
hammer product set-sync-plan --name 'Extra Packages for Enterprise Linux 6' --organization $ORG --sync-plan 'Daily Sync'
sleep 10
echo "Daily Sync Plan - Extra Packages for Enterprise Linux 7"
hammer product set-sync-plan --name 'Extra Packages for Enterprise Linux 7' --organization $ORG --sync-plan 'Daily Sync'
sleep 10
echo "Daily Sync Plan - Puppet Forge"
hammer product set-sync-plan --name 'Puppet Forge' --organization $ORG --sync-plan 'Daily Sync'
sleep 10
echo "Daily Sync Plan - Oracle Java for RHEL Server"
hammer product set-sync-plan --name 'Oracle Java for RHEL Server' --organization $ORG --sync-plan 'Daily Sync'
sleep 10

echo " "
echo "*********************************************************"
echo "Associate plan to products:"
echo "*********************************************************"
hammer product set-sync-plan --sync-plan-id=1 --organization $ORG --name='Oracle Java for RHEL Server'
hammer product set-sync-plan --sync-plan-id=1 --organization $ORG --name='Red Hat Enterprise Linux Server'
hammer product set-sync-plan --sync-plan-id=1 --organization $ORG --name='Puppet Forge'
hammer product set-sync-plan --sync-plan-id=1 --organization $ORG --name='Extra Packages for Enterprise Linux 6'
hammer product set-sync-plan --sync-plan-id=1 --organization $ORG --name='Extra Packages for Enterprise Linux 7'
sleep 10

echo " "
echo "***********************************************"
echo "Create a content view for RHEL server x86_64:"
echo "***********************************************"
time hammer content-view create --name='rhel-server-x86_64' --organization $ORG
sleep 10
for i in $(hammer --csv repository list --organization $ORG | awk -F, {'print $1'} | grep -vi '^ID'); do time hammer content-view add-repository --name rhel-server-x86_64 --organization $ORG --repository-id=${i}; done 
sleep 10

echo " "
echo "***********************************************"
echo "add individual puppet modules:"
echo "***********************************************"
echo "stdlib"
hammer content-view puppet-module add --organization $ORG --content-view 'rhel-server-x86_64' --author puppetlabs --name stdlib  
echo "ntp"
hammer content-view puppet-module add --organization $ORG --content-view 'rhel-server-x86_64' --author puppetlabs --name ntp  
echo "motd"
hammer content-view puppet-module add --organization $ORG --content-view 'rhel-server-x86_64' --author jeffmccune --name motd  
echo "rsyslog"
hammer content-view puppet-module add --organization $ORG --content-view 'rhel-server-x86_64' --author saz --name rsyslog 
echo "foreman_scap_client"
hammer content-view puppet-module add --organization $ORG --content-view 'rhel-server-x86_64' --author theforeman --name foreman_scap_client
echo "archive"
hammer content-view puppet-module add --organization $ORG --content-view 'rhel-server-x86_64' --author camptocamp --name archive
echo "firewalld"
hammer content-view puppet-module add --organization $ORG --content-view 'rhel-server-x86_64' --author crayfishx --name firewalld
echo "docker"
hammer content-view puppet-module add --organization $ORG --content-view 'rhel-server-x86_64' --author cristifalcas --name docker
echo "etcd"
hammer content-view puppet-module add --organization $ORG --content-view 'rhel-server-x86_64' --author cristifalcas --name etcd
echo "kubernetes"
hammer content-view puppet-module add --organization $ORG --content-view 'rhel-server-x86_64' --author cristifalcas --name kubernetes
echo "monitor"
hammer content-view puppet-module add --organization $ORG --content-view 'rhel-server-x86_64' --author example42 --name monitor
echo "puppi"
hammer content-view puppet-module add --organization $ORG --content-view 'rhel-server-x86_64' --author example42 --name puppi
echo "buildhost"
hammer content-view puppet-module add --organization $ORG --content-view 'rhel-server-x86_64' --author LunetIX --name buildhost
echo "docker"
hammer content-view puppet-module add --organization $ORG --content-view 'rhel-server-x86_64' --author LunetIX --name docker
echo "dockerhost"
hammer content-view puppet-module add --organization $ORG --content-view 'rhel-server-x86_64' --author LunetIX --name dockerhost
echo "git"
hammer content-view puppet-module add --organization $ORG --content-view 'rhel-server-x86_64' --author LunetIX --name git
echo "oscp"
hammer content-view puppet-module add --organization $ORG --content-view 'rhel-server-x86_64' --author LunetIX --name oscp
echo "fail2ban"
hammer content-view puppet-module add --organization $ORG --content-view 'rhel-server-x86_64' --author netmanagers --name fail2ban
echo "concat"
hammer content-view puppet-module add --organization $ORG --content-view 'rhel-server-x86_64' --author puppetlabs --name concat
echo "java"
hammer content-view puppet-module add --organization $ORG --content-view 'rhel-server-x86_64' --author puppetlabs --name java
echo "postgresql"
hammer content-view puppet-module add --organization $ORG --content-view 'rhel-server-x86_64' --author puppetlabs --name postgresql
echo "jenkins"
hammer content-view puppet-module add --organization $ORG --content-view 'rhel-server-x86_64' --author rtyler --name jenkins
echo "ssh"
hammer content-view puppet-module add --organization $ORG --content-view 'rhel-server-x86_64' --author saz --name ssh

echo " "
echo " "
echo "********************************"
echo "Publish content view to Library:"
echo "********************************"
echo " "
echo " "
hammer content-view list --organization $ORG
hammer lifecycle-environment list --organization $ORG
echo " "
echo "********************************************************************************************************************************"
echo " 
	There may be an error that the (content-view publish) task has failed however the process takes longer to complete than the command timeout.
                           Please see https://"$EXTERNALIP"/content_views/2/versions to watch the task complete.
 "
echo "********************************************************************************************************************************"
echo " "
sleep 10
time hammer content-view publish --name 'rhel-server-x86_64' --organization $ORG --async
sleep 1500

echo " "
echo "*********************************************************"
echo "Promote content views to DEV_RHEL,TEST_RHEL,PROD_RHEL:"
echo "*********************************************************"
time hammer content-view version promote --organization $ORG --from-lifecycle-environment ='Library' --to-lifecycle-environment 'DEV_RHEL' --id 2 --async
sleep 500
time hammer content-view version promote --organization $ORG --from-lifecycle-environment ='DEV_RHEL' --to-lifecycle-environment 'TEST_RHEL' --id 2 --async
sleep 500
time hammer content-view version promote --organization $ORG --from-lifecycle-environment ='TEST_RHEL' --to-lifecycle-environment 'PROD_RHEL' --id 2 --async
sleep 500

echo " "
echo "***********************************"
echo "Create a host collection for RHEL:"
echo "***********************************"
time hammer host-collection create --name='RHEL x86_64' --organization $ORG
hammer host-collection list --organization $ORG

echo " "
echo "*********************************************************"
echo "Create an activation keys for environments:"
echo "*********************************************************"
hammer activation-key create --name 'rhel-server-x86_64'-DEV_RHEL --organization $ORG --content-view='rhel-server-x86_64' --lifecycle-environment 'DEV_RHEL'
sleep 5
hammer activation-key create --name 'rhel-server-x86_64'-TEST_RHEL --organization $ORG --content-view='rhel-server-x86_64' --lifecycle-environment 'TEST_RHEL'
sleep 5
hammer activation-key create --name 'rhel-server-x86_64'-PROD_RHEL --organization $ORG --content-view='rhel-server-x86_64' --lifecycle-environment 'PROD_RHEL'
sleep 5
hammer activation-key list --organization $ORG

echo " "
echo "*********************************************************"
echo "Associate each activation key to host collection:"
echo "*********************************************************"
hammer activation-key add-host-collection --name 'rhel-server-x86_64'-DEV_RHEL --host-collection='RHEL x86_64' --organization $ORG
sleep 5
hammer activation-key add-host-collection --name 'rhel-server-x86_64'-TEST_RHEL --host-collection='RHEL x86_64' --organization $ORG
sleep 5
hammer activation-key add-host-collection --name 'rhel-server-x86_64'-PROD_RHEL --host-collection='RHEL x86_64' --organization $ORG
sleep 5

echo " "
echo "********************************************************************************************************************************"
echo "
	There may be errors in the next step (Could not add subscription to activation key) Please ignore these as 
	long as your primary keys for your enabled subscriptions have been added"
echo " "
echo  "********************************************************************************************************************************"
echo " "
echo "*********************************************************"
echo "Add all subscriptions available to keys:"
echo "*********************************************************"
for i in $(hammer --csv activation-key list --organization $ORG | awk -F, {'print $1'} | grep -vi '^ID'); do for j in $(hammer --csv subscription list --organization $ORG  | awk -F, {'print $8'} | grep -vi '^ID'); do hammer activation-key add-subscription --id ${i} --subscription-id ${j}; done; done

hammer subscription list --organization $ORG

}
#-----------------------------------------------------------------------------------------------------------------------
#---------------Stage 4 - Associate Partition table, PXE template, and create a RHEL7 hostgroups-------------------------
#-----------------------------------------------------------------------------------------------------------------------
#function default {
#cat > /var/lib/tftpboot/pxelinux.cfg/default << EOF

#DEFAULT menu
#PROMPT 0
#MENU TITLE PXE Menu
#TIMEOUT 200
#TOTALTIMEOUT 6000
#ONTIMEOUT local

#LABEL local
#     MENU LABEL (local)
#     MENU DEFAULT
#     LOCALBOOT 0

#LABEL discovery
#     MENU LABEL Satellite 6 Discovery
#    KERNEL boot/fdi-image-rhel_7-vmlinuz
#     APPEND initrd=boot/fdi-image-rhel_7-img rootflags=loop root=live:/fdi.iso rootfstype=auto ro rd.live.image acpi=force rd.luks=0 rd.md=0 rd.dm=0 rd.lvm=0 rd.bootif=0 rd.neednet=0 nomodeset proxy.url=https://SATELLITE_CAPSULE_URL:9090 proxy.type=proxy
#     IPAPPEND 2

#EOF
#}

function Kickstart {
cat > /root/Kickstart_Metro << EOF
<%#
kind: ptable
name: Kickstart Metro
oses:

- RedHat 6
- RedHat 7
%>
zerombr
clearpart --all --initlabel
part  /boot     --asprimary  --size=1024
part  swap                   --size=1024
part  pv.01     --asprimary  --size=12000 --grow
volgroup Metrohost pv.01
logvol / --vgname=Metrohost --size=9000 --name=rootvol
EOF
    hammer partition-table create  --file=/root/Kickstart_Metro --name='Kickstart Metro' --os-family='Redhat' --organizations=$ORG --locations="$LOC"
    hammer os update --title 'RedHat 7.3' --partition-tables='Kickstart default','Kickstart Metro'
    hammer os update --title 'RedHat 6.8' --partition-tables='Kickstart default','Kickstart Metro'
}


function stage4 {
source /root/.bashrc
echo -ne "\e[8;33;120t"
CAID=1
ENVIROMENT=$(hammer environment list |awk -F "|"  {'print $2'}|grep -v -|grep -v NAME |sed 's/ //g')
MEDID=$(hammer --csv medium list | grep 'Red_Hat_Enterprise_Linux_7_Server_Kickstart_x86_64_7_3' | awk -F, {'print $1'})
OSID=$(hammer --csv os list | grep -vi '^ID' | awk -F, {'print $1'})
PROXYNAME=$(hammer proxy list |awk -F "|" {'print $2'}| grep -v NAME |grep -v - |sed 's/ //g')
PROXYID=$(hammer proxy list |awk -F "|" {'print $1'} |grep -v - |grep -v ID)
OS=$(hammer --csv os list | awk -F, {'print $2'} | grep -vi '^ID'|grep -vi '^Title'| awk {'print $1 " "  $2'})
NETNAME=$(hammer subnet list  | awk -F "|" {'print $2'}|grep -iv name |grep -iv - |sed 's/ //g')
PARTID=$(hammer --csv partition-table list | grep "Kickstart default" | cut -d, -f1)
##PXEID=$(hammer --csv template list --per-page=1000 | grep "PXELinux global default" | cut -d, -f1)
PXEID=$(hammer --csv template list --per-page=1000 | grep "Kickstart default PXELinux" | cut -d, -f1)
SATID=$(hammer --csv template list --per-page=1000 | grep "provision" | grep "Satellite Kickstart Default" | cut -d, -f1)
PARTTABLE=$(hammer --csv partition-table list |grep "Kickstart default" |awk -F ","  {'print $2'})
ORGID=$(hammer organization list|awk -F "|"  {'print $1'}|grep -v -|grep -v ID)
LOCID=$(hammer location list|awk -F "|"  {'print $1'}|grep -v -|grep -v ID)
ARCH=$(uname -i)
LEL=$(hammer lifecycle-environment list --organization $ORG |awk -F "|" {'print $2'}|grep -v - |grep -v NAME)


echo " "
echo "*************************************************************************"
echo "Associate a partition table to OS, Associate kickstart PXE template to OS"
echo "*************************************************************************"
for i in $OSID 
	do 
   hammer partition-table add-operatingsystem --id="${PARTID}" --operatingsystem-id="${i}"
   hammer template add-operatingsystem --id="${PXEID}" --operatingsystem-id="${i}"
   hammer os set-default-template --id="${i}" --config-template-id="${PXEID}"
   hammer os add-config-template --id="${i}" --config-template-id="${SATID}"
   hammer os set-default-template --id="${i}" --config-template-id="${SATID}"
done

echo " "
echo "*********************************************************"
echo "Create a RHEL hostgroup:"
echo "*********************************************************"

#hammer hostgroup create --name "hostgroup_name"   --environment "environment_name"   --architecture "architecture_name"   --domain domain_name   --subnet subnet_name   --puppet-proxy proxy_name   --puppet-ca-proxy ca-proxy_name   --operatingsystem "os_name"  --partition-table "table_name"  --medium "medium_name"  --organization-ids org_ID1,org_ID2...   --location-ids loc_ID1,loc_ID2...
for i in $ENVIROMENT ; do hammer hostgroup create --name "rhel-7-server" --environment $i --architecture "$ARCH" --domain "$DOMAIN" --subnet "$NETNAME"  --puppet-proxy-id "$PROXYID" --puppet-ca-proxy-id "$CAID" --operatingsystem "$OS" --partition-table "$PARTTABLE" --medium-id "$MEDID" --organization-ids "$ORGID" --location-ids "$LOCID"; done


hammer settings set --name ignore_puppet_facts_for_provisioning --value true
hammer settings set --name default_puppet_environment --value KT_sat_DEV_RHEL7_rhel_7_server_x86_64_2
hammer settings set --name discovery_auto --value true
}


function satsum {
echo " "
echo "*********************************************************"
echo "Satellite Summary"
echo "*********************************************************"

echo "*********************************************************"
echo "Regestered To"
echo "*********************************************************"
subscription-manager list --installed |grep "Product Name:" |awk -F : {'print $2'}
echo " "
hammer domain list
echo " "
hammer subnet list
echo " "
hammer subscription list --organization $ORG
echo " "
hammer repository-set list --organization $ORG --product 'Red Hat Enterprise Linux Server' |awk -F "|" {'print $3'} |grep -v -i debug |grep -v -i source |grep -v -i beta |grep -v -i Fastrack|sort |grep -v -i "RHEL 6" |grep -v -i "RHEL 5"|grep -v -i " Red Hat Enterprise Linux 6 Server" |grep -v -i " Red Hat Enterprise Linux 5 Server" |grep -v -i " Red Hat Enterprise Linux 4"  |grep -v -i "OpenStack Platform 8 Tools for RHEL 7 Server"  |grep -v -i "OpenStack Platform 7" |grep -v -i "OpenStack Platform 8 Tools" |grep -v -i "OpenStack Platform 9 Tools"  |grep -v -i "Ceph Storage Tools 1.3" |grep -v -i "Satellite Tools 6.1"
echo " "
hammer lifecycle-environment list --organization $ORG
echo " "
hammer sync-plan list --organization $ORG
echo " "
hammer content-view list --organization $ORG
echo " "
hammer host-collection list --organization $ORG
echo " "
hammer activation-key list --organization $ORG
echo " "
hammer capsule list
}

function  satupdate {
echo " "
echo "*********************************************************"
echo "Updating Satellite"
echo "*********************************************************"
echo " "
echo " "
katello-service stop
yum update -y --skip-broken
satellite-installer --scenario satellite --upgrade


}


#-----------------------------------------------------------------------------------------------------------------------
#----------------------------------------------Install OpenSCAP---------------------------------------------------------
#-----------------------------------------------------------------------------------------------------------------------
function openscap {
cat > openscap << EOF
 

systemctl restart httpd & amp;amp;amp;amp;&amp;amp;amp;amp; systemctl restart foreman-proxy
EOF

}
#-----------------------------------------------------------------------------------------------------------------------
#----------------------------------------------Install Insights---------------------------------------------------------
#-----------------------------------------------------------------------------------------------------------------------


#-----------------------------------------------------------------------------------------------------------------------
#-------------------------------------------------Cloud Forms-----------------------------------------------------------
#-----------------------------------------------------------------------------------------------------------------------
function cloudforms {
echo -ne "\e[8;33;120t"
sleep 5
clear
HNAME=$(hostname)
}

#-----------------------------------------------------------------------------------------------------------------------
#-------------------------------------------------Ansible Tower---------------------------------------------------------
#-----------------------------------------------------------------------------------------------------------------------
function ansibletower {
echo -ne "\e[8;33;120t"
sleep 5
clear

HNAME=$(hostname)
clear
echo " "
echo " "
echo " "
echo " "
echo "
	ANSIBLE-TOWER BASE REQUIREMENTS:

		1. Ansible-Tower must be installed on a SECONDARY server other than the Satellite server and will require a license.
			Please register and download the license from https://www.ansible.com/tower-trial

		2. Hardware requirements may vary per your org needs, however whether 
  		   it is a  KVM or physical environment the Ansible-Tower will require 1 node with:

			Min Storage 50 GB
				Directory		Recommended
				/			Rest of drive
				/boot			1024MB
				/swap			8192MB

			Min RAM 			8192
			Min CPU				2 (4 Reccomended)"
echo " "
echo " "
echo " "
echo " "
echo " "
read -p "Press [Enter] to continue"
clear
echo "
	REQUIREMENTS CONTINUED
		3. Network
			Connection to the internet so the instller can download the required packages
		
		4. For this POC you must have a RHN User ID and password with entitlements
   		   to channels below. (item 6)
		
		5. Install ansible tgz will be downloaded and placed into the FILES directory created by the sript on the host machine:

			* Ansible-Tower download will be pulled from https://releases.ansible.com/awx/setup/ansible-tower-setup-latest.tar.gz
			
		6. This install was tested with:
         	   * RHEL_7.3 and RHEL_6.8 using the Software Server with the build from the install DVD in a KVM environment.
        	   * Red Hat subscriber channels:
                    		
				rhel-7-server-rpms
				rhel-7-server-rh-common-rpms
				rhel-7-server-extras-rpms
				rhel-7-server-rhn-tools-rpms
				EPEL

		7. Additional resources, packages, and documentation may be found at 
                    		http://www.ansible.com
				https://www.ansible.com/tower-trial
                    		http://docs.ansible.com/ansible-tower/latest/html/quickinstall/index.html"
echo " "
echo " "
read -p "If you have met the minimum requirement from above please Press [Enter] to continue"
clear

#!/bin/bash
echo '************************************'
echo 'installing prereq'
echo '************************************'
#yum --noplugins -q list installed kernel-uek-devel &>/dev/null && echo "kernel-uek-devel  is installed" || yum install -y kernel-uek-devel --skip-broken --noplugins

if grep -q -i "release 6" /etc/redhat-release ; then
  rhel6only=1
	echo "RHEL 6"
	yum --noplugins -q list installed epel-release-latest-6 &>/dev/null && echo "epel-release-latest-6  is installed" || yum install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-6.noarch.rpm  --skip-broken --noplugins

elif grep -q -i "release 7" /etc/redhat-release ; then
  rhel7only=1
	echo "RHEL 7"
	yum --noplugins -q list installed epel-release-latest-7 &>/dev/null && echo "epel-release-latest-7  is installed" || yum install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm  --skip-broken --noplugins
else
  echo "Running neither RHEL6.x nor RHEL 7.x !"
fi
echo 
yum --noplugins -q list installed mongodb-server  &>/dev/null && echo "mongodb-server  is installed" || yum install -y mongodb-server   --skip-broken --noplugins
yum --noplugins -q list installed yum-utils &>/dev/null && echo "yum-utils  is installed" || yum install -y yum-utils  --skip-broken --noplugins
yum --noplugins -q list installed ansible &>/dev/null && echo "ansible is installed" || yum install -y ansible --skip-broken --noplugins
yum --noplugins -q list installed wget &>/dev/null && echo "wget is installed" || yum install -y wget --skip-broken --noplugins
yum --noplugins -q list installed bash-completion-extras  &>/dev/null && echo "bash-completion-extras" || yum install -y bash-completion-extras --skip-broken --noplugins
yum --noplugins -q list installed openssh-clients  &>/dev/null && echo "openssh-clients" || yum install -y openssh-clients --skip-broken --noplugins
sleep 10

echo " "
echo '************************************'
echo 'removing epel'
echo '************************************'
yum remove -y epel*
yum clean all
sleep 10

#echo " "
#echo '************************************'
#echo 'updating the system'
#echo '************************************'
#yum update -y
#sleep 10

echo " "
echo '************************************'
echo 'Creating FILES dir here'
echo '************************************'
mkdir -p FILES
cd FILES
pwd
sleep 10

echo " "
echo '************************************'
echo 'Wget Ansible Tower'
echo '************************************'
if grep -q -i "release 6" /etc/redhat-release ; then
  rhel6only=1
	echo "RHEL 6 supporting tower 3.0"
	wget https://releases.ansible.com/awx/setup/ansible-tower-setup-3.0.0.tar.gz

elif grep -q -i "release 7" /etc/redhat-release ; then
  rhel7only=1
	echo "RHEL 7 supporting latest release"
	wget https://releases.ansible.com/awx/setup/ansible-tower-setup-latest.tar.gz
else
  echo "Running neither RHEL6.x nor RHEL 7.x !"
fi
echo " "
sleep 10

echo " "
echo '************************************'
echo 'Expanding Ansible Tower and installing '
echo '************************************'

cd FILES
tar -zxvf ansible-tower-*.tar.gz
cd ansible-tower*
sed -i s/admin_password="''"/admin_password="'redhat'"/g inventory
sed -i s/redis_password="''"/redis_password="'redhat'"/g inventory
sed -i s/pg_password="''"/pg_password="'redhat'"/g inventory
sh setup.sh
}

#--------------------------End Primary Functions--------------------------

#-----------------------
function dMainMenu {
#-----------------------
$DIALOG --stdout --title "Red Hat P.O.C. - RHEL 7.3" --menu "********** Main Menu ********* \n Please choose [1 -> 3]?" 30 90 10 \
1 "Satellite - Install, Sync Repositories RHEL6 RHEL7, and Configure Satellite"  \
2 "Install - Ansible Tower"  \
3 "Exit Installer" 
}

#----------------------
function dYesNo {
#-----------------------
$DIALOG --title " Prompt " --yesno "$1" 10 80
}

#-----------------------
function dMsgBx {
#-----------------------
$DIALOG --infobox "$1" 10 80
sleep 10
}

#----------------------
function dInptBx {
#----------------------
#Requires 2 mandatory options and 3rd is preset variable 
$DIALOG --title "$1" --inputbox "$2" 20 80 "$3" 
}




#----------------------------------End-Functions-------------------------------


######################
####  MAIN LOGIC  ####
######################

#set -o xtrace
clear
# Sets a time value for Xdialog
[[ -z $DISPLAY ]] || TV=3000
$DIALOG --infobox "

**************************
**** Red Hat  - Config Tools****
**************************

`hostname`" 20 80 $TV
[[ -z $DISPLAY ]] && sleep 2 

#---------------------------------Menu----------------------------------------
HNAME=$(hostname)
TMPd=FILES/TMP
while true		
	do
	[[ -e "$TMPd" ]] || mkdir -p $TMPd
	TmpFi=$(mktemp $TMPd/xcei.XXXXXXX )

	dMainMenu > $TmpFi
	RC=$?
	[[ $RC -ne 0 ]] && break

	Flag=$(cat $TmpFi)

	case $Flag in
	  1)
		dMsgBx "Satellite - Install, Sync Repositories RHEL6 RHEL7, and Configure Satellite"

			baseenv
			rhel7_firewall
			configure_repos
			install_packages
			satellite_environment
			satellite_configure
			satupdate
			configure_repos
			stage2
			configure_repos
			stage3
			Kickstart
			stage4
			satsum
			

		exit
		;;
	
	  2)	
		dMsgBx "Install - Ansible Tower"
		echo ""
			ansibletower
		exit
		;;

	  3)	dMsgBx "*** Thank you for installing Red Hat tools  ***"
		break 
		;;
esac

done
# cleanup tempfile
clear
rm FILES/$TmpFi

exit 0
