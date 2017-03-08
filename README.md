# RedHatToolsInstaller-
Installing Red Hat Tools - Satellite and Ansible 

Who said you cant install, sync, and configure Satellite with one push of a button ?

This is RED HAT we can do anything
https://gitlab.sat.lab.tlv.redhat.com/sgallego/Red_Hat_Tools_Installer.git

Time savings can be measured in days if not weeks

README
LICENSED UNDER - GPL 
Script to install Satellite or Ansible Tower POC for demos or  for customer use

Opensource rules apply: 
	-If you can improve it share your improvements 
	-Feel free to share with anyone that might need it 
	-If you try it out please give me some feedback!

The script now has automated 
	Satellite one button installer
	Ansible Tower one buttoninstaller

The idea(s) behind the tool are:

    1. One button Red Hat Installer
    2. Guide customers to success!
    3. Increase margin by reducing time on site for non paid POC 
    4. Standardize a base deployment between consultants/architects
    5. Setup in a known state to reduce support instance/time
    6. Reduce TtP (Time to Productivity) for customers
    7. Reduce recreate support times in the lab for customer troubleshooting
    8. Reduce support instances related to instalation and configuration of products 


CREDITS
This is based off of Mojo doc https://mojo.redhat.com/docs/DOC-1030365 by Rich Jerrido
This script was written by Shadd Gallegos Shadd@RedHat.com of Dave 
Johnson's SA Team with contributions from Red Hatters (In no particular order) 
 Jimmy Conner
 Orcun Atakan
 Eric McLeroy
 Kevin Holmes
 Sebastian Hetze
 Uzoma Nwosu
 James Mills


WHAT IT IS -- This is just an idea and A work in progress
WHAT IT DOES -- Automated menu written in bash using dialog and/or xdialog display menu

Self Documenting menuized script that prompts users to success For Satellite and Ansible things

#-------------------------------------------------------------------------------------------------------------
 P.O.C Satellite 6.X Ansible Tower RHEL 7.X KVM or RHEL 7 Physical Host 
 THIS SCRIPT CONTAINS NO CONFIDENTIAL INFORMATION 
 Licensed under GPL

 This script is designed to set up a basic standalone Satellite 6.X system

 Disclaimer: This script was written for education, evaluation, and/or testing 
 purposes and is not officially supported by anyone.
 
 ...SHOULD NOT BE USED ON A CURRENT PRODUCTION SYSTEM - USE AT YOUR OWN RISK...

  However the if you have an issue with the products installed and have a valid License please contact Red Hat at:
  
  RED HAT Inc..
  1-888-REDHAT-1 or 1-919-754-3700, then select the Menu Prompt for Customer Service
  Spanish: 1-888-REDHAT-1 Option 5 or 1-919-754-3700 Option 5
  Fax: 919-754-3701 (General Corporate Fax)
  Email address: customerservice@redhat.com
#-------------------------------------------------------------------------------------------------------------

SCRIPT REQUIREMENTS:

packages that will to be installed by the installer script to run properly

https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
GUI environment -> xdialog ftp://rpmfind.net/linux/sourceforge/k/ke/kenzy/special/C7/x86_64/xdialog-2.3.1-13.el7.centos.x86_64.rpm
Headless -> dialog
 ansible

#-------------------------------------------------------------------------------------------------------------

 SATELLITE BASE REQUIREMENTS:

  1. ISO media should be downloaded to /var/lib/libvirt/images of the host machine if it is to be KVM 
     or /root/Downloads/ of host machine if it is a physical install

  2. Hardware requirements may vary per your org needs, however whether 
    it is a KVM or physical environment the Satellite will require 1 node with:

   Min Storage 220 GB
    Directory  Recommended
    /   Rest of drive
    /boot   1024MB
    /swap   16384MB

   Min RAM    16384
   Min CPU    2 (4 Reccomended)"

  3. Network
   eth0 internal for nodes 
   eth1 Connection to the internet
  
  4. For this POC you must have a RHN User ID and password with entitlements
    to channels below. (item 6)
  
  5. Install ISO must be in /var/lib/libvirt/images/ of the host machine so they will 
    be scp'ed to the Satellite KVM to the /root/Downloads directory

   * RHEL 7.3 media can be downloaded from https://access.redhat.com/downloads/content/69/ver=/rhel---7/7.3/x86_64/product-software
   * Sat 6.2.2 media can be downloaded from https://access.redhat.com/downloads/content/250/ver=6.2/rhel---7/6.2.6/x86_64/product-software
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
    https://access.redhat.com/support/policy/updates/satellite

#-------------------------------------------------------------------------------------------------------------



 ANSIBLE-TOWER BASE REQUIREMENTS:

  1. Ansible-Tower must be installed on a SECONDARY server other than the Satellite server and will require a license.
   Please register and download the license from https://www.ansible.com/tower-trial

  2. Hardware requirements may vary per your org needs, however whether 
    it is a KVM or physical environment the Ansible-Tower will require 1 node with:

   Min Storage 50 GB
    Directory  Recommended
    /   Rest of drive
    /boot   1024MB
    /swap   8192MB

   Min RAM    8192
   Min CPU    2 (4 Reccomended)"


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

# RedHatToolsInstaller
