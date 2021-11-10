#!/bin/sh

usage()
{
	echo "Usage: $0 <DEVICE_NAME> <INTERFACES_NUMBER> [-r rip|ospf] [-z <ZONE>] [-s]"
	echo ""
	echo "Args:"
	echo -e "\t<DEVICE_NAME>:the name for this device."
	echo -e "\t<INTERFACES_NUMBER>: number of interfaces for this device."
	echo ""
	echo "Options:"
	echo -e "\t-r rip|ospf: if this device is a router, you can configure here the routing protocol. RIP or OSPF protocols supported."
	echo ""
	echo -e "\t-z <ZONE>: if this device is a nameserver, you can configura here the zone. If it's root nameserver, use root as <ZONE> value."
	echo ""
	echo -e "\t-s: if this device is a web server, just flag this option."
	echo ""
	exit 1
}

# first argument is the device name
while [ $# -gt 0 ]; do
    case "$1" in
        -r) routing_protocol=$2; shift 2 ;;
		-z) zone=$2; shift 2 ;;
        -s) is_server='true'; shift ;;
		*) break;;
    esac
done

# if there aren't at least 2 arguments
if [  $# -le 1 ]; then 
	usage
	exit 1
fi

device_name="$1"
interfaces_count=$2

mkdir $device_name
touch $device_name.startup

# clean if exists
echo > $device_name.startup

echo $interfaces_count
echo $routing_protocol
echo $zone
echo $is_server

# if interfaces_count not null
if [ -n "$interfaces_count" ]; then
	echo "$interfaces_count interfaces required, configuring them..."
	
	echo "# INTERFACES" >> $device_name.startup
	
	for i in $(seq 0 $(($interfaces_count-1)))
	do
		echo "/sbin/ifconfig eth$i <IP_ADDRESS>/<PREFIX_BITS> up" >> $device_name.startup
	done
fi

configureRIP()
{
	echo "Configuring $device_name/etc/frr/daemons"
	
	echo "ripd=yes" >> $device_name/etc/frr/daemons
	
	echo "! RIP CONFIGURATION" >> $device_name/etc/frr/frr.conf
	echo "router rip" >> $device_name/etc/frr/frr.conf
}

configureOSPF()
{
	echo "ospfd=yes" >> $device_name/etc/frr/daemons
	
	echo "! OSPF CONFIGURATION" >> $device_name/etc/frr/frr.conf
	echo "router ospf" >> $device_name/etc/frr/frr.conf
}

# if routing_protocol not null
if [ -n "$routing_protocol" ]; then
	echo "FRR Routing daemon required, configuring it..."
	
	echo "# start FRR routing daemon" >> $device_name.startup
	echo "/etc/init.d/frr start" >> $device_name.startup
	
	# create FRR directories
	mkdir $device_name/etc/
	mkdir $device_name/etc/frr/
	
	# create FRR configuration files
	touch $device_name/etc/frr/daemons
	touch $device_name/etc/frr/frr.conf
	touch $device_name/etc/frr/vtysh.conf
	
	# configurations default values
	echo "zebra=yes" > $device_name/etc/frr/daemons
	
	echo "! ZEBRA" > $device_name/etc/frr/frr.conf
	echo "password zebra" > $device_name/etc/frr/frr.conf
	echo "enable password zebra" >> $device_name/etc/frr/frr.conf
	
	echo "service integrated-vtysh-config" > $device_name/etc/frr/vtysh.conf
	echo "hostname $device_name-frr" >> $device_name/etc/frr/vtysh.conf
	
	case "${routing_protocol}" in
		rip) configureRIP $device_name;;
		ospf) configureOSPF $device_name;;
		*) echo "supported routing protocols: rip|ospf";;
	esac
	
	echo "! LOGGING" >> $device_name/etc/frr/frr.conf
	echo "log file /var/log/frr/frr.log" >> $device_name/etc/frr/frr.conf
fi

configureRootZone()
{
	# db.root
	echo -e "\$TTL\t60000" >> $device_name/etc/bind/db.root
	echo -e "@\t\t\t\tIN\t\tSOA\t\tROOT-SERVER.\t\troot.ROOT-SERVER. (" >> $device_name/etc/bind/db.root
	echo -e "\t\t\t\t\t\t2006031201 ; serial" >> $device_name/etc/bind/db.root
	echo -e "\t\t\t\t\t\t28800 ; refresh" >> $device_name/etc/bind/db.root
	echo -e "\t\t\t\t\t\t14400 ; retry" >> $device_name/etc/bind/db.root
	echo -e "\t\t\t\t\t\t3600000 ; expire" >> $device_name/etc/bind/db.root
	echo -e "\t\t\t\t\t\t0 ; negative cache ttl" >> $device_name/etc/bind/db.root
	echo -e "\t\t\t\t\t\t)\n" >> $device_name/etc/bind/db.root
	echo -e "@\t\t\t\tIN\t\tNS\t\tROOT-SERVER." >> $device_name/etc/bind/db.root
	echo -e "ROOT-SERVER.\tIN\t\tA\t\t<THIS-DEVICE-IP-ADDRESS>\n" >> $device_name/etc/bind/db.root
	echo -e ";; <DOMAIN_NAME_LOWER_LEVEL>.		IN 	NS	<DEVICE_NAMESERVER_LOWER_LEVEL>.<DOMAIN_NAME_LOWER_LEVEL>." >> $device_name/etc/bind/db.root
	echo -e ";; <DEVICE_NAMESERVER_LOWER_LEVEL>.<DOMAIN_NAME_LOWER_LEVEL>.	IN 	A	<NAMESERVER_IP_ADDRESS>" >> $device_name/etc/bind/db.root
	
	# named.conf
	echo  -e "zone \".\" {" >> $device_name/etc/bind/named.conf
	echo  -e "\ttype master;" >> $device_name/etc/bind/named.conf
	echo  -e "\tfile \"/etc/bind/db.root\";" >> $device_name/etc/bind/named.conf
	echo  -e "};" >> $device_name/etc/bind/named.conf
}

configureZone()
{
	# db.root
	echo -e ".\t\t\t\tIN\tNS\tROOT-SERVER." >> $device_name/etc/bind/db.root
	echo -e "ROOT-SERVER.\tIN\tA\t<ROOT-AUTHORITY-NAMESERVER-IP-ADDRESS>" >> $device_name/etc/bind/db.root
	
	# named.conf
	echo -e "zone \".\" {" >> $device_name/etc/bind/named.conf
	echo -e "\ttype hint;" >> $device_name/etc/bind/named.conf
	echo -e "\tfile \"/etc/bind/db.root\";" >> $device_name/etc/bind/named.conf
	echo -e "};" >> $device_name/etc/bind/named.conf
	
	echo -e "zone \"$zone\" {" >> $device_name/etc/bind/named.conf
	echo -e "\ttype master;" >> $device_name/etc/bind/named.conf
	echo -e "\tfile \"/etc/bind/db.REVERSED_ZONE_NAME_GOES_HERE\";" >> $device_name/etc/bind/named.conf
	echo -e "};" >> $device_name/etc/bind/named.conf
	
	# create db.REVERSED_ZONE_NAME_GOES_HERE
	touch $device_name/etc/bind/db.REVERSED_ZONE_NAME_GOES_HERE
	
	# clean db.REVERSED_ZONE_NAME_GOES_HERE
	echo > $device_name/etc/bind/db.REVERSED_ZONE_NAME_GOES_HERE
	
	# db.REVERSED_ZONE_NAME_GOES_HERE
	echo -e "\$TTL\t60000" >> $device_name/etc/bind/db.REVERSED_ZONE_NAME_GOES_HERE
	echo -e "@\t\t\t\tIN\t\tSOA\t\t$device_name.$zone.\t\troot.$device_name$zone. (" >> $device_name/etc/bind/db.REVERSED_ZONE_NAME_GOES_HERE
	echo -e "\t\t\t\t\t\t2006031201 ; serial" >> $device_name/etc/bind/db.REVERSED_ZONE_NAME_GOES_HERE
	echo -e "\t\t\t\t\t\t28800 ; refresh" >> $device_name/etc/bind/db.REVERSED_ZONE_NAME_GOES_HERE
	echo -e "\t\t\t\t\t\t14400 ; retry" >> $device_name/etc/bind/db.REVERSED_ZONE_NAME_GOES_HERE
	echo -e "\t\t\t\t\t\t3600000 ; expire" >> $device_name/etc/bind/db.REVERSED_ZONE_NAME_GOES_HERE
	echo -e "\t\t\t\t\t\t0 ; negative cache ttl" >> $device_name/etc/bind/db.REVERSED_ZONE_NAME_GOES_HERE
	echo -e "\t\t\t\t\t\t)\n" >> $device_name/etc/bind/db.REVERSED_ZONE_NAME_GOES_HERE
	echo -e "@\t\t\t\tIN\t\tNS\t\t$device_name.$zone." >> $device_name/etc/bind/db.REVERSED_ZONE_NAME_GOES_HERE
	echo -e "$device_name.\tIN\t\tA\t\t<THIS-DEVICE-IP-ADDRESS>\n" >> $device_name/etc/bind/db.REVERSED_ZONE_NAME_GOES_HERE
	echo -e ";; <ANOTHER_DEVICE_NAME>.\tIN\t\tA\t\t<THAT-DEVICE-IP-ADDRESS>" >> $device_name/etc/bind/db.REVERSED_ZONE_NAME_GOES_HERE
	echo -e ";; ..." >> $device_name/etc/bind/db.REVERSED_ZONE_NAME_GOES_HERE
}

# if is_nameserver not null
if [ -n "$zone" ]; then
	echo "bind daemon required, configuring it..."
	
	echo "# start bind daemon" >> $device_name.startup
	echo "/etc/init.d/bind start" >> $device_name.startup
	
	# create bind directories
	mkdir $device_name/etc/
	mkdir $device_name/etc/bind/
	
	# create FRR configuration files
	touch $device_name/etc/bind/db.root
	touch $device_name/etc/bind/named.conf
	
	# clean
	echo > $device_name/etc/bind/db.root
	echo > $device_name/etc/bind/named.conf
	
	case "${zone}" in
		root) configureRootZone;;
		*) configureZone;;
	esac
fi

# if is_server not null
if [ -n "$is_server" ]; then
	echo "apache2 daemon required, launching it"
	
	# create directories
	mkdir $device_name/var/
	mkdir $device_name/var/www/
	mkdir $device_name/var/www/html/
	
	# create index.html
	touch $device_name/var/www/html/index.html
	
	# write (overwriting) something into index.html
	echo $device_name > $device_name/var/www/html/index.html
	
	echo "# start apache2 daemon" >> $device_name.startup
	echo "/etc/init.d/apache2 start" >> $device_name.startup
fi
