#!/bin/bash
didsmth=0
while read p; do
   if nc -z 192.168.1.34 80; then
      if [ -f "/etc/unbound/unbound.conf.d/$p" ]; then
         echo "$p exists"
      else
        echo "$p does not exist"
        mv -v "/etc/unbound/local.d/$p" "/etc/unbound/unbound.conf.d/"
	didsmth=1
      fi
      if [ -f "/etc/dnsmasq.d/$p" ]; then
         echo "$p exists"
      else
        mv -v "/etc/dnsmasq.local/$p" "/etc/dnsmasq.d/"
        didsmth=1
      fi
   else
      if [ -f "/etc/unbound/unbound.conf.d/$p" ]; then
         echo "$p exists"
         mv -v "/etc/unbound/unbound.conf.d/$p" "/etc/unbound/local.d/$p"
         didsmth=1
      else
        echo "$p does not exist"
      fi
      if [ -f "/etc/dnsmasq.d/$p" ]; then
        mv -v "/etc/dnsmasq.d/$p" "/etc/dnsmasq.local/"
        didsmth=1
      else
        echo "$p does not exist"
      fi
   fi
done < $(realpath "$(dirname "$0")")/list.lst

if [ ! $didsmth -eq 0 ];then
   echo "did something"
   #unbound-control flush *
   #/usr/sbin/service unbound restart
   unbound-control reload
   pihole restartdns
   dig lancache.steamcontent.com
fi
