# Katharà Internet and Data Centers

This repository is a stash of data I need for Internet and Data Centers exam in Roma Tre University.

I developed a config generator system for Katharà, contained in this repository.

## Prerequisites

- Latest [Docker](https://www.docker.com/) version.
- [Katharà](https://www.kathara.org/)

## Devices generator

`device-generator.bash` is a bash script which generates kathara configurations. Those configurations are prepared to work on them (often you just have to insert IP addresses).

### RIP

`bash device-generator.bash -rip <ROUTER_NAME> <INTERFACES_COUNT>` generates configuration files for a RIP router named ROUTER_NAME with INTERFACES_COUNT interfaces.

Example: `bash device-generator.bash -rip ripfrouter 2` generates a router running RIP protocol, and with two interfaces.

### OSPF

`bash device-generator.bash -ospf <AREA_ID> <ROUTER_NAME> <INTERFACES_COUNT>` generates configuration files for a OSPF router with AREA_ID as OSPF area identificator, named ROUTER_NAME with INTERFACES_COUNT interfaces.

Example: `bash device-generator.bash -ospf 0.0.0.0 ospfrouter 3` generates a router running OSPF protocol on backbone area (0.0.0.0 is the backbone area identificator), and having three interfaces.

### BGP

`bash device-generator.bash -bgp <BGP_AS_ID> <NEIGHBORS_COUNT> <ANNOUNCEMENTS_COUNT> <ROUTER_NAME> <INTERFACES_COUNT>` generates configuration files for a BGP router with BGP_AS_ID as BGP AS (Autonomous System) identificator, with NEIGHBORS_COUNT BGP neighbors, ANNOUNCEMENTS_COUNT announcements to execute, named ROUTER_NAME with INTERFACES_COUNT interfaces.

Example: `bash device-generator.bash -bgp 10 2 1 bgprouter 3` generates a BGP router with three interfaces, BGP AS (Autonomous System) id 10, two neighbors and one announcement to do.

### Client

`bash device-generator.bash <CLIENT_NAME> <INTERFACES_COUNT>` generates configuration files for a client named CLIENT_NAME with INTERFACES_COUNT interfaces.

Example: `bash device-generator.bash client 1` generates a client with one interface.

### Server

`bash device-generator.bash -s <SERVER_NAME> <INTERFACES_COUNT>` generates configuration files for a server (apache2) named SERVER_NAME with INTERFACES_COUNT interfaces.

Example: `bash device-generator.bash -s server 1`  generates a server with one interface.

### Root DNS Authority  Name Server

`bash device-generator.bash -z root <DEVICE_NAME> <INTERFACES_COUNT>` generates configuration files for a root DNS Authority Name Server named DEVICE_NAME with INTERFACES_COUNT interfaces.

Example: `bash device-generator.bash -z root dnsr 2`  generates a root DNS Authority Name Server named dnsr with two interfaces.

### DNS Authority  Name Server

`bash device-generator.bash -z <ZONE> <DEVICE_NAME> <INTERFACES_COUNT>` generates configuration files for a DNS Authority Name Server for the zone named ZONE, with device name DEVICE_NAME and INTERFACES_COUNT interfaces.

Example: `bash device-generator.bash -z uniroma3.it dnsrm3 1`  generates a DNS Authority Name Server called dnsrm3, authority for uniroma3.it zone.
Example: `bash device-generator.bash -z it dnsit 1`  generates a DNS Authority Name Server called dnsit, authority for it zone.

## Lab generator

You can run the `device-generator.bash` for each configuration you want to generate, or you can write a script which runs the commands for you, so you only have to call that script and it does the trick.

`example.generate-this-lab.bash` is a file in this repository containing an example of how you can organize the script which generates your katharà lab.

