#!/bin/bash

# create lab.conf if doesn't exist
touch lab.conf

# clean lab.conf
echo > lab.conf

# adding lab env variables
echo "LAB_DESCRIPTION=\"Exam lab\"" >> lab.conf
echo "LAB_VERSION=1.0" >> lab.conf
echo "LAB_AUTHOR=\"Marte Valerio Falcone\"" >> lab.conf
echo "" >> lab.conf

### EXAMPLES of devices creation 
bash device-generator.bash -rip ripfrouter 2					# RIP router with two interfaces
bash device-generator.bash -ospf 0.0.0.0 ospfrouter 3			# OSPF router with three interfaces, and AREA_ID 0.0.0.0 (backbone)
bash device-generator.bash -bgp 10 2 1 bgprouter 3				# BGP router with three interfaces, BGP AS (Autonomous System) id 10, two neighbors and one announcement to do
bash device-generator.bash client 1								# client
bash device-generator.bash -s server 1							# server
bash device-generator.bash -z root dnsr 1						# authority nameserver for root zone called dnsr
bash device-generator.bash -z uniroma3.it dnsrm3 1				# authority nameserver for uniroma3.it zone called dnsrm3
bash device-generator.bash -z it dnsit 1						# authority nameserver for it zone called dnsit