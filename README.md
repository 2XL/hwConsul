
[Reference](view-source:https://gist.githubusercontent.com/g0t4/10c82f7ffd8a3f0cbd3980593259b7a8/raw/4c4f5d595c869b9d3bda045dc8c7884e81b61ceb/glossary.md)


[consul-templates](https://github.com/hashicorp/consul-template)


## My favorite consul architecture reference: 

Architectural image from https://www.consul.io/docs/internals/architecture.html:
![Architectural image from https://www.consul.io/docs/internals/architecture.html](https://www.consul.io/assets/images/consul-arch-420ce04a.png)

- **Node** - a physical or virtual machine that hosts services
  - Nodes also referred to as members.
  - Examples
    - Your computer
    - An AWS EC2 instance
    - A bare metal machine in your private data center
- **Service** - executing software that provides utility via an interface
  - Typically long-lived process listening on a port(s)
  - Examples
    - A web server (nginx, apache, iis)
    - A database server (mysql, mongo, mssql)
    - DNS, DHCP, consul agent
- **Client Address** - The default address to bind local client services
  - (HTTP: 8500, HTTPS, DNS: 8600, Client RPC: 8400)
  - By default this is 127.0.0.1 for local consumption only
- **Cluster Address** - The default address to bind node to node services   
  - (LAN gossip: 8301, WAN gossip: 8302, Server RPC: 8300)
  - By default this is 0.0.0.0
  - If you have multiple IPs on a node, then you need to specify the one to advertise with the `-advertise` flag
- **Service Registration** - Telling consul about services on a node.
  - Often independent of service
  - Configure health checks
  - Many methods: service definition config file, HTTP API, consul aware apps, registrator (sniff docker containers), scheduler integrated (marathon/mesos, nomad, docker swarm).
- **Consul Agent** – a daemon meant to be run on every node in your infrastructure.
  - Intended as a system service (**one agent per node**)
  - Characteristics
    - Provides consul services to other local services:
      - DNS: `dig @localhost -p 8600 web.service.consul`
      - HTTP: `curl http://localhost:8500/v1/catalog/service/web`
      - RPC (port 8400) used for consul CLI commands: `consul members`
      - Avoids chicken and egg problem
    - Registers local services
    - Health checks the host node & local services
    - Partakes in LAN gossip pool
  - Two modes
    - **Consul Client**
      - Basically just the above agent characteristics
      - Forwards RPC to servers
      - Relatively stateless
    - **Consul Server**
      - Usually 3 to 5 dedicated server nodes per DC for HA
        - Each server peer set is canonical for its local DC
        - One elected leader per DC, rest of servers are followers
        - See [deployment table](https://www.consul.io/docs/internals/consensus.html#deployment_table)
      - Additional responsibilities
        - store and replicate cluster state
        - participate in Raft quorum
        - partake in WAN gossip with other DCs
        - followers forward RPC to leader
        - leaders respond to RPC, coordinate transactions
        - remote DC queries are forwarded to random, remote DC server
- **Atlas join** - Join nodes together by leveraging [Atlas](https://atlas.hashicorp.com/) so you don't have to configure any IP or hostnames. Leverages environment names that can be created on the fly. 
- **Gossip pool via Serf**
  - Analogy: think of a crowd of people chatting. Imagine a fight breaks out, the people nearby will begin gossiping about it and the message will likely spread like wildfire across the crowd.
    - Gossip is an **eventually consistent** means of distributing information
    - Massive scalability
    - Random P2P node communication
    - Uses Serf https://www.serfdom.io/
    - LAN Gossip (port 8301) - one pool per DC, with all nodes in the DC, hence LAN
        - Optimized for low latency
    - WAN Gossip (port 8302) - one global pool with all servers in all DCs, hence WAN
      - Optimized for high latency
    - Information disseminated:
      - Membership (discovery, joining) - joining the cluster entails only knowing the address of one other node (not required to be a server)
      - Failure detection - affords distributed health checks, no need for centralized health checking
      - Event broadcast - i.e. leader elected, custom events
    - Details: https://www.consul.io/docs/internals/gossip.html
- *Edge triggered updates*
    - Only send updates when something changes
    - Combined with serf membership detection to make sure node didn't just disappear
    - Highly efficient and scalable
- **Leave** versus **Fail**
  - Leave - like when a friend moves out of town, no longer part of the group
    - No longer need to gossip with the node to make sure it's ok
  - Fail - power outage, agent process killed/dies, network partition
    - Node doesn't tell us that it left
    - Still part of group, so something must be wrong
  - Signals and what they simulate
    - SIGKILL - Simulates Failure 
      - server will remain in peers list, unhealthy state
      - no log output, process doesn't get to handle this signal
    - SIGTERM - Simulates Graceful Failure in version 0.6.4
      - server will remains in peers list, unhealthy state
      - log output with graceful shutdown (NOT LEAVING)
      - Override behavior with `leave_on_terminate` https://www.consul.io/docs/agent/options.html#leave_on_terminate
        - Defaults to false (0.6.4)
        - Set to true if you want to leave on SIGTERM
        - Likely to be defaulted to true in 0.7, per docker image README https://hub.docker.com/_/consul/
    - SIGINT - Simulates Leave (Graceful Shutdown) in version 0.6.4
      - server removed from peers list
      - not a part of quorum anymore
      - log Graceful Shutdown with Leave
      - Override behavior with `skip_leave_on_interrupt`
        - Defaults to false (0.6.4)
        - **in 0.7 server will be true, client will be false**
        - false = leave on interrupt
        - true = not leave on interrupt
- **Datacenter** (in consul parlance) - a logical grouping of nodes that reside within close proximity
  - Close proximity meaning low latency, high bandwidth
  - A datacenter becomes a logical grouping to ensure responsiveness, design accordingly.
  - A datacenter in consul doesn't have to tie to a physical datacenter.
  - Each DC can support tens of thousands of nodes.
  - Configurable per agent via `-dc` flag, no need for central DB!
  - Examples
    - AWS, Azure, DigitalOcean regions
    - Private datacenter
    - Corporate offices
  - Cluster state is unique per Datacenter (key value store, service catalog, node catalog, etc)
- **Custom Events**
  - Coolest use case: rolling, real-time autonomous deployments (see my Pluralsight course)
  - No guarantee of delivery but still works in a server outage
  - Consul Exec uses events, but data stored in K/V store, so doesn't work in a server outage.
  - Optional, small payload
  - Serf provides peer to peer event transmission
- **Watches**
  - "view" types: services, nodes, individual service, health checks, custom events, individual key, entire key/value prefix
  - Logging, debug/troubleshoot, notifications
  - Persistent watches via consul configuration
  - Keep in mind consul-template is an advanced version of `consul watch` with integrated templating



## Attribution ##

This information was collected from my own usage of consul and the following doc links:
- Architecture glossary: https://www.consul.io/docs/internals/architecture.html
- Agent basics & glossary: https://www.consul.io/docs/agent/basics.html
- This glossary was put together in my Consul courses created for Pluralsight: https://www.pluralsight.com/authors/wes-mcclure

