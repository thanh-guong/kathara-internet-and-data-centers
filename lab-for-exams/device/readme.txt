If this is not a DNS nameserver, DELETE:
- directory	./etc/bind/

If this device doesn't need to resolve DNS names, DELETE:
- file		./etc/resolv.conf

If there's no need to activate routing protocols, DELETE:
- directory	./etc/frr/

If this device is not a server, DELETE:
- directory	./var/