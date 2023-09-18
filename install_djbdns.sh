#!/bin/bash
# $1 is this server's IP address
# $2 is slave server's IP address to which you want to allow AXFR
# $3 is the domain for which you want to allow AXFR

# Installs daemontools
mkdir -p /package
chmod 1755 /package
cd /package
echo " Getting daemontools-0.76 from cr.yp.to "
wget http://cr.yp.to/daemontools/daemontools-0.76.tar.gz
gunzip daemontools-0.76.tar
tar -xpf daemontools-0.76.tar
rm -f daemontools-0.76.tar
cd admin/daemontools-0.76
echo gcc -O2 -include /usr/include/errno.h > src/conf-cc
echo " Starting compilation and installation "
package/install
#Install make
dnf install make -y
# Installs ucspi-tcp-0.88
mkdir -p /package
chmod 1755 /package
cd /package
echo " Getting ucspi-tcp-0.88 from cr.yp.to "
wget http://cr.yp.to/ucspi-tcp/ucspi-tcp-0.88.tar.gz
gunzip ucspi-tcp-0.88.tar
tar -xf ucspi-tcp-0.88.tar
rm -f ucspi-tcp-0.88.tar
cd ucspi-tcp-0.88
echo gcc -O2 -include /usr/include/errno.h > conf-cc
echo " Starting compilation and installation "
make
make setup check
# Installs djbdns
mkdir -p /package
chmod 1755 /package
cd /package
echo " Getting djbdns-1.05 from cr.yp.to "
wget http://cr.yp.to/djbdns/djbdns-1.05.tar.gz
gunzip djbdns-1.05.tar
tar -xf djbdns-1.05.tar
rm -f djbdns-1.05.tar
cd djbdns-1.05
echo gcc -O2 -include /usr/include/errno.h > conf-cc
echo " Starting compilation and installation "
make
make setup check
echo " Installations Done!"
echo " Configuring tinydns "
useradd -r -s /sbin/nologin -l -M Gtinydns
useradd -r -s /sbin/nologin -l -M Gdnslog
tinydns-conf Gtinydns Gdnslog /etc/tinydns $1
ln -s /etc/tinydns /service; sleep 5; svstat /service/tinydns
echo " Configuring axfrdns"
useradd -r -s /sbin/nologin -M -l Gaxfrdns
axfrdns-conf Gaxfrdns Gdnslog /etc/axfrdns /etc/tinydns $1
ln -s /etc/axfrdns /service; sleep 5; svstat /service/axfrdns
echo ':allow,AXFR=""' > /etc/axfrdns/tcp
echo $2':allow,AXFR="'$3'"' >> /etc/axfrdns/tcp
echo " Checking process "
ps fo pid,ppid,rss,bsdstart,etime,euser,args p `pgrep "svscan|multilog|tinydns|readproc|supervise|tcpserver" `
echo " Checking listening ports "
netstat -natunee  grep 53
echo " Completed! "