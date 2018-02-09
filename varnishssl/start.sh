#!/bin/bash

/etc/init.d/nginx start

# /usr/bin/stunnel

/usr/sbin/varnishd -j unix,user=vcache -F -a :80 -T localhost:6082 -f /etc/varnish/default.vcl -S /etc/varnish/secret -s malloc,256m
#/usr/sbin/varnishd -j unix,user=varnish,ccgroup=varnish -P /var/run/varnish.pid -f /etc/varnish/default.vcl -a :80,PROXY -T 127.0.0.1:6082 -t 120 -S /etc/varnish/secret -s malloc,256MB -F
# run forever
tail -f /dev/null
