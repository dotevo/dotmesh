```
config interface 'loopback'
	option ifname 'lo'
	option proto 'static'
	option ipaddr '127.0.0.1'
	option netmask '255.0.0.0'

config globals 'globals'
	option ula_prefix 'fde9:323c:2fd6::/48'

# SWITCH
config switch
	option name 'switch0'
	option reset '1'
	option enable_vlan '1'

config switch_vlan
	option device 'switch0'
	option vlan '1'
	option ports '1 0t'
	option vid '1'

config switch_vlan
	option device 'switch0'
	option vlan '2'
	option ports '3 2 0t'
	option vid '2'

config switch_vlan
	option device 'switch0'
	option vlan '3'
	option ports '5 4 0'
	option vid '3'

# LAN
config interface 'lan'
	option type 'bridge'
	option proto 'static'
	option ipaddr '10.10.1.1'
	option netmask '255.255.255.0'
	option ip6assign '60'
	option ifname 'eth0.2'

# WAN
config interface 'wan'
	option ifname 'eth0.1'
	option proto 'dhcp'

config interface 'wan6'
	option proto 'dhcpv6'
	option ifname 'eth0.1'
	option reqaddress 'try'
	option reqprefix 'auto'

config interface 'wwan'
	option proto 'dhcp'

# MESH
config interface 'bat0'
	option proto 'batadv'
	option routing_algo 'BATMAN_IV'
	option aggregated_ogms '1'
	option ap_isolation '0'
	option bonding '0'
	option fragmentation '1'
	option gw_mode 'off'
	option log_level '0'
	option orig_interval '1000'
	option bridge_loop_avoidance '1'
	option distributed_arp_table '1'
	option multicast_mode '1'
	option network_coding '0'
	option hop_penalty '30'
	option isolation_mark '0x00000000/0x00000000'

config interface 'nwi_mesh0'
	option mtu '2304'
	option proto 'batadv_hardif'
	option master 'bat0'

config interface 'nwi_mesh0_eth0_3'
	option proto 'batadv_hardif'
	option master 'bat0'
	option mtu '2304'
	option ifname 'eth0.3'
	option elp_interval '500'
```
