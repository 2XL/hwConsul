#!/usr/bin/env bash


iface="enp4s0f2"
ip=$(ifconfig $iface | grep 'inet addr' | awk '{print substr($2,6) }')



cp haproxy.cfg /tmp/haproxy.cfg

docker run  -d \
            --name haproxy \
            -p 80:80 \
            --restart unless-stopped \
            -v /tmp/haproxy.cfg:/usr/local/etc/haproxy/haproxy.cfg:ro \
            haproxy:1.6.5-alpine
