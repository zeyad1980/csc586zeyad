#!/bin/bash
sudo apt update

echo -e "ldap_auth_config        ldap_auth_config/ldapns/ldap-server     string  ldap://192.168.1.1" |sudo debconf-set-selections

sudo apt install -y libnss-ldap libpam-ldap ldap-utils

cat<<EOF >/local/repository/etc/nsswitch.conf
#/etc/nsswitch.conf
#
# Example configuration of GNU Name Service Switch functionality.
# If you have the `glibc-doc-reference' and `info' packages installed, try:
# `info libc "Name Service Switch"' for information about this file.
                                                                                                                                                                                                                         
passwd:         compat systemd ldap
group:          compat systemd ldap                                                                                                                                                                                      
shadow:         compat                                                                                                                                                                                                   
gshadow:        files                                                                                                                                                                                                    
                                                                                                                                                                                                                         
hosts:          files dns                                                                                                                                                                                                
networks:       files 

group:          compat systemd                                                                                                                                                                                           
shadow:         compat                                                                                                                                                                                                   
gshadow:        files                                                                                                                                                                                                    
                                                                                                                                                                                                                         
hosts:          files dns                                                                                                                                                                                                
networks:       files                                                                                                                                                                                                    
                                                                                                                                                                                                                         
protocols:      db files                                                                                                                                                                                                 
services:       db files                                                                                                                                                                                                 
ethers:         db files                                                                                                                                                                                                 
rpc:            db files                                                                                                                                                                                                 
                                                                                                                                                                                                                         
netgroup:       nis 

EOF

cat<<EOF >/local/repository/etc/pam.d/common-password
## here are the per-package modules (the "Primary" block)
password        [success=2 default=ignore]      pam_unix.so obscure sha512                                                                                                                                               
password        [success=1 user_unknown=ignore default=die]     pam_ldap.so use_authtok                                                                                                                   
# here's the fallback if no module succeeds
password        requisite                       pam_deny.so                                                                                                                                                              
# prime the stack with a positive return value if there isn't one already;
# this avoids us returning an error just because nothing sets a success code
# since the modules above will each just jump around
password        required                        pam_permit.so                                                                                                                                                            
# and here are more per-package modules (the "Additional" block)
# end of pam-auth-update config

EOF

cat<<EOF >/local/repository/etc/pam.d/common-session  

# here are the per-package modules (the "Primary" block)
session [default=1]                     pam_permit.so                                                                                                                                                                    
# here's the fallback if no module succeeds
session requisite                       pam_deny.so
# prime the stack with a positive return value if there isn't one already;
# this avoids us returning an error just because nothing sets a success code
# since the modules above will each just jump around
session required                        pam_permit.so                                                                                                                                                                    
# The pam_umask module will set the umask according to the system default in
# /etc/login.defs and user settings, solving the problem of different
# umask settings with different shells, display managers, remote sessions etc.
# See "man pam_umask".
session optional                        pam_umask.so 
# and here are more per-package modules (the "Additional" block)
session required        pam_unix.so                                                                                                                                                                                      
session optional                        pam_ldap.so                                                                                                                                                                      
session optional        pam_systemd.so  
session optional pam_mkhomedir.so skel=/etc/skel umask=077
# end of pam-auth-update config
                                    

EOF

sudo getent passwd student
sudo su - student





