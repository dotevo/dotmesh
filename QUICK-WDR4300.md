# WDR-4300

**TODO**

```
opkg update
opkg install ....
```

/etc/config/network

```
config globals 'globals'
    option ula_prefix 'fdc6:3a70:ea96::/48'

config interface 'loopback'
    option ifname 'lo'
    option proto 'static'
    option ipaddr '127.0.0.1'
    option netmask '255.0.0.0'

# SWITCHES
config switch
    option name 'switch0'
    option reset '1'
    option enable_vlan '1'

config switch_vlan
    option device 'switch0'
    option vlan '1'
    option vid '1'
    option ports '0t 2'

config switch_vlan
    option device 'switch0'
    option vlan '2'
    option vid '2'
    option ports '0t 3'

config switch_vlan
    option device 'switch0'
    option vlan '3'
    option vid '3'
    option ports '0t 4'

config switch_vlan
    option device 'switch0'
    option vlan '4'
    option vid '4'
    option ports '0t 5'

config switch_vlan
    option device 'switch0'
    option vlan '5'
    option ports '0t 1'
    option vid '5'

# LAN  WIFI + eth0.1
config interface 'lan'
    option type 'bridge'
    option proto 'static'
    option ip6assign '60'
    list ipaddr '192.168.100.1/24'
    list dns '8.8.8.8'
    option ifname 'eth0.1'

# WAN

config interface 'wan'
    option proto 'dhcp'
    option ifname 'eth0.5'

config interface 'wan6'
    option proto 'dhcpv6'
    option ifname 'eth0.5'
    option reqaddress 'try'
    option reqprefix 'auto'

config interface 'wwan'
    option proto 'dhcp'

config interface 'wan_master'
    option ifname 'tun1'
    option proto 'none'

config route 'default'
    option interface 'wan_master'
    option gateway '10.10.10.1'
    option target '0.0.0.0'
    option netmask '0.0.0.0'

# MESH WIFI + eth0.2

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

config interface 'nwi_mesh0_eth0_2'
    option proto 'batadv_hardif'
    option master 'bat0'
    option mtu '2304'
    option ifname 'eth0.2'
    option elp_interval '500'

# VPN (SHARE NETWORK)

config interface 'vpn'
    option ifname 'tun0'
    option proto 'none'
```

Plik cat /etc/config/wireless

```
config wifi-device 'radio0'
	option type 'mac80211'
	option channel '11'
	option hwmode '11g'
	option path 'platform/ahb/18100000.wmac'
	option htmode 'HT20'
	option country 'PL'

config wifi-iface 'default_radio0'
	option device 'radio0'
	option network 'lan'
	option mode 'ap'
	option key 'TESTOWETESTOWE'
	option ssid 'DotMesh'
	option encryption 'psk2'

config wifi-device 'radio1'
	option type 'mac80211'
	option channel '36'
	option hwmode '11a'
	option path 'pci0000:00/0000:00:00.0'
	option htmode 'HT20'
	option country 'PL'

config wifi-iface 'mesh0'
	option device 'radio1'
	option ifname 'mesh0'
	option network 'nwi_mesh0'
	option mode 'mesh'
	option mesh_fwding '0'
	option mesh_id 'dotevo.github.io/dotmesh'
	option encryption 'psk2+ccmp'
	option key 'meshmesh'
```

```
cat /etc/config/bmx7

# for more information:
# http://bmx6.net/projects/bmx6/wiki
# options execute: bmx7 --help

config 'bmx7' 'general'
#       option 'runtimeDir' '/var/run/bmx7'
#	option 'trustedNodesDir' '/etc/bmx7/trustedNodes'

#config 'plugin'
#        option 'plugin' 'bmx7_config.so'

config 'plugin'
        option 'plugin' 'bmx7_json.so'

config 'plugin'
        option 'plugin' 'bmx7_sms.so'

config 'plugin'
        option 'plugin' 'bmx7_iwinfo.so'


config 'dev' 'mesh_1'
        option 'dev' 'bat0'


config 'plugin'
        option 'plugin' 'bmx7_tun.so'

config 'plugin'
        option 'plugin' 'bmx7_table.so'


config 'tunDev' default
        option 'tunDev' 'default'
        option 'tun6Address' '2012:0:0:6666::1/64'
        option 'tun4Address' '10.66.66.101/24'


#config 'tunOut'
#        option 'tunOut' 'ip6'
#        option 'network' '2012::/16'
#        option 'exportDistance' '0'

#config 'tunOut'
#        option 'tunOut' 'ip4'
#        option 'network' '10.0.0.0/9'
#        option 'minPrefixLen' '27'

```

```
cat /etc/config/openvpn
config openvpn 'server'
	option dev 'tun0'
        option proto 'udp6'
	option comp_lzo 'yes'
	option mssfix '1420'
	option keepalive '10 60'
	option verb '3'
        # ZMIANA: USTAW IP
	option server '10.10.11.0 255.255.255.0'
	option ca '/etc/openvpn/ca.crt'
	option dh '/etc/openvpn/dh.pem'
	option cert '/etc/openvpn/master.crt'
	option key '/etc/openvpn/master.key'
	option enabled '1'
        option status '/tmp/openvpn_server.status'
        option log '/tmp/openvpn_server.log'
        option redirect-gateway 'def1'

config openvpn 'clientToMaster'
	option client '1'
	option dev 'tun1'
	option proto 'udp6'
        # ZMIANA: USTAW IPv6
	list remote 'fd70:9b50:9900:8d6b:1581:20c9:f9f6:76c8 1194'
        #list remote '192.168.90.1 1194'
        option route '0.0.0.0 0.0.0.0'
        option link-mtu '1558'
	option compress 'lzo'
	option resolv_retry 'infinite'
	option nobind '1'
	option persist_key '1'
	option persist_tun '1'
	option user 'nobody'
	option ca '/etc/openvpn/ca.crt'
	option verb '3'
	option cert '/etc/openvpn/slave1.crt'
	option key '/etc/openvpn/slave1.key'
	option enabled '1'
        option log '/tmp/openvpn_clientToMaster.log'
        option status '/tmp/openvpn_clientToMaster.status'

```

```
cat /etc/config/firewall

config defaults
	option syn_flood '1'
	option input 'ACCEPT'
	option output 'ACCEPT'
	option forward 'REJECT'

config zone
	option name 'lan'
	option input 'ACCEPT'
	option output 'ACCEPT'
	option forward 'ACCEPT'
	option network 'lan'

config zone
	option name 'wan'
	option input 'REJECT'
	option output 'ACCEPT'
	option forward 'REJECT'
	option masq '1'
	option mtu_fix '1'
	option network 'wan wan6 wan_master'

config forwarding
	option src 'lan'
	option dest 'wan'

config rule
	option name 'Allow-DHCP-Renew'
	option src 'wan'
	option proto 'udp'
	option dest_port '68'
	option target 'ACCEPT'
	option family 'ipv4'

config rule
	option name 'Allow-Ping'
	option src 'wan'
	option proto 'icmp'
	option icmp_type 'echo-request'
	option family 'ipv4'
	option target 'ACCEPT'

config rule
	option name 'Allow-IGMP'
	option src 'wan'
	option proto 'igmp'
	option family 'ipv4'
	option target 'ACCEPT'

config rule
	option name 'Allow-DHCPv6'
	option src 'wan'
	option proto 'udp'
	option src_ip 'fc00::/6'
	option dest_ip 'fc00::/6'
	option dest_port '546'
	option family 'ipv6'
	option target 'ACCEPT'

config rule
	option name 'Allow-MLD'
	option src 'wan'
	option proto 'icmp'
	option src_ip 'fe80::/10'
	list icmp_type '130/0'
	list icmp_type '131/0'
	list icmp_type '132/0'
	list icmp_type '143/0'
	option family 'ipv6'
	option target 'ACCEPT'

config rule
	option name 'Allow-ICMPv6-Input'
	option src 'wan'
	option proto 'icmp'
	list icmp_type 'echo-request'
	list icmp_type 'echo-reply'
	list icmp_type 'destination-unreachable'
	list icmp_type 'packet-too-big'
	list icmp_type 'time-exceeded'
	list icmp_type 'bad-header'
	list icmp_type 'unknown-header-type'
	list icmp_type 'router-solicitation'
	list icmp_type 'neighbour-solicitation'
	list icmp_type 'router-advertisement'
	list icmp_type 'neighbour-advertisement'
	option limit '1000/sec'
	option family 'ipv6'
	option target 'ACCEPT'

config rule
	option name 'Allow-ICMPv6-Forward'
	option src 'wan'
	option dest '*'
	option proto 'icmp'
	list icmp_type 'echo-request'
	list icmp_type 'echo-reply'
	list icmp_type 'destination-unreachable'
	list icmp_type 'packet-too-big'
	list icmp_type 'time-exceeded'
	list icmp_type 'bad-header'
	list icmp_type 'unknown-header-type'
	option limit '1000/sec'
	option family 'ipv6'
	option target 'ACCEPT'

config rule
	option name 'Allow-IPSec-ESP'
	option src 'wan'
	option dest 'lan'
	option proto 'esp'
	option target 'ACCEPT'

config rule
	option name 'Allow-ISAKMP'
	option src 'wan'
	option dest 'lan'
	option dest_port '500'
	option proto 'udp'
	option target 'ACCEPT'

config include
	option path '/etc/firewall.user'

config forwarding
	option dest 'wan'
	option src 'mesh'

config zone
	option input 'ACCEPT'
	option name 'vpn'
	option output 'ACCEPT'
	option forward 'ACCEPT'
	option network 'VPN vpn'

config forwarding
	option dest 'wan'
	option src 'vpn'

```
