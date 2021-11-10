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
# bash device-generator.bash -r rip ripfrouter 2		# rip router
# bash device-generator.bash -r ospf ospfrouter 3		# ospf router
# bash device-generator.bash client 1					# client
# bash device-generator.bash -s server 1				# server
# bash device-generator.bash -z root dnsr 1				# authority nameserver for root zone called dnsr
# bash device-generator.bash -z uniroma3.it dnsrm3 1	# authority nameserver for uniroma3.it zone called dnsrm3
# bash device-generator.bash -z it dnsit 1				# authority nameserver for it zone called dnsit