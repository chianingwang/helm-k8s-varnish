#!/bin/bash

# Start supervisord
echo "chown -R swift:swift /srv/node"
chown -R swift:swift /srv/node
echo "chown -R swift:swift /etc/swift"
chown -R swift:swift /etc/swift
echo "start rsyslog"
/etc/init.d/rsyslog start
echo "Starting supervisord..."
/usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf
#echo "swift-init all restart"
#swift-init all restart
