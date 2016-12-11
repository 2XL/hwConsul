#!/usr/bin/env bash




## Sending signals
killall -s <signal-code> consul





## consul template
#consul push based service health check with consul template
#<service.name>.ctpml
#https://github.com/hashicorp/consul-template

compile a template
consul-template -template /path/to/template.ctmpl -dry
consul exec -node <nodename> docker start web
consul exec -node <nodename> docker stop web    # we will live refresh of ctmpl


## Handy queries

# retrieve ip
iface="br-9b7915c87753"
ip=$(ifconfig $iface | grep 'inet addr' | awk '{print substr($2,6) }')
./consul agent -advertise $ip -config-file consul.agent.json -config-file consul.service.json

# if service falls we can restart them manually
consul exec -node <service_name_node_id> [command]
consul exec -node web1 docker start web

# check config file is valid
consul configtest -h
consul configtest -config-file "</config/file/path>"


# maintenance
consul maint -h
consul maint -enable -reason Because  "<reason why a node is put into maintenance>"
consul maint -disable

# setup local machine as a consule node
consul agent -config-file consul.json.js


## DNS queries

# query node
dig @localhost -p "<dns-port>" "<node-name>.node.consul"

# query service
dig @localhost -p "<dns-port>" "<service-name>.service.consul"

# query service record
dig @localhost -p "<dns-port>" "<service-name>.service.consul" SRV


## K/V queries

# retrieve value
curl http://localhost:8500/v1/kv/
curl http://localhost:8500/v1/kv/?recurse'&'pretty'&'raw

# ALTER values
curl -X [POST OR DELETE] -d "<VALUE>" http://SERVER:PORT/v1/kv/PATH/TO/KEY/


## Refresh template with signals

killall -HUP consul-template


## Blocking Queries


curl -v http://localhost:8500/v1/kv/PATH/TOKEY/stats?index=INDEX'&'wait=Xs