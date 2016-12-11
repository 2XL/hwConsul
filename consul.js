// this is the local configuration file
// load with
 
/*
 consul rest api
 */


var get_services = "http://localhost:8500/v1/catalog/services?pretty";
var services_response = {
    "admin": [
        "admin",
        "protected"
    ],
    "anonymous": [
        "anonymous",
        "profile-service",
        "api"
    ],
    "authorized": [
        "profile-service",
        "api",
        "authorized"
    ],
    "cassandra": [],
    "consul": [],
    "consul-ui": [
        "infra",
        "discovery",
        "http-protected-sysops"
    ],
    "kong": [
        "udp"
    ],
    "nginx-443": [],
    "nginx-80": []
}
var get_service_catalog = "http://localhost:8500/v1/catalog/service/admin?pretty";
var service_catalog_response = [
    {
        "Node": "consul-server",
        "Address": "172.24.0.5",
        "TaggedAddresses": {
            "lan": "172.24.0.5",
            "wan": "172.24.0.5"
        },
        "ServiceID": "62132325663a:app:7000",
        "ServiceName": "admin",
        "ServiceTags": [
            "admin",
            "protected"
        ],
        "ServiceAddress": "172.24.0.4",
        "ServicePort": 7000,
        "ServiceEnableTagOverride": false,
        "CreateIndex": 8,
        "ModifyIndex": 8
    }
]
var get_service_health = "http://localhost:8500/v1/catalog/service/admin?pretty";
var service_health_response = [
    {
        "Node": {
            "Node": "consul-server",
            "Address": "172.24.0.5",
            "TaggedAddresses": {
                "lan": "172.24.0.5",
                "wan": "172.24.0.5"
            },
            "CreateIndex": 4,
            "ModifyIndex": 931
        },
        "Service": {
            "ID": "62132325663a:app:7000",
            "Service": "admin",
            "Tags": [
                "admin",
                "protected"
            ],
            "Address": "172.24.0.4",
            "Port": 7000,
            "EnableTagOverride": false,
            "CreateIndex": 8,
            "ModifyIndex": 8
        },
        "Checks": [
            {
                "Node": "consul-server",
                "CheckID": "serfHealth",
                "Name": "Serf Health Status",
                "Status": "passing",
                "Notes": "",
                "Output": "Agent alive and reachable",
                "ServiceID": "",
                "ServiceName": "",
                "CreateIndex": 4,
                "ModifyIndex": 4
            }
        ]
    }
]


 
// config server

var agent_config = {
    "ui": true,
    "retry_join": [
        "172.24.0.5" // docker inspect <consul-machine> # search of his ip
    ], // list of bootstap node, atleast one for server discovery - list of cluster nodes, can be server/client
    "advertise_addr": "", // the local IP address where I the current node listens
    "client_addr": "",
    "data_dir": "",
}

// config service
var service_config = {
    "service": {
        "name": "noname",
        "tags": [
            "dummy_node"
        ],
        "retry_join": [
            "172.24.0.5"
        ],
        "advertise_addr": "172.24.0.1",
        "port": 7788,
        "enableTagOverride": false,
        "checks": [ //  alist of health checks
            {
                "script": "consul.py", // running a script
                "interval": "10s"
            },
            {
                "http": "http://localhost:8080",
                "interval": "10s"

            }
        ]
    },
    "data_dir": "/tmp/consul"
}


