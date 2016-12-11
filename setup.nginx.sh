#!/usr/bin/env bash


iface="enp4s0f2"
ip=$(ifconfig $iface | grep 'inet addr' | awk '{print substr($2,6) }')
echo $ip > /tmp/index.html
#./consul agent -advertise $ip -config-file consul.agent.json -config-file consul.service.json


docker run -d \
        --name web \
        -p 8080:80 \
        --restart unless-stopped \
        -v /tmp/index.html:/usr/share/nginx/html/index.html:ro \
        nginx

