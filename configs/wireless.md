```
config wifi-device 'radio0'
	option type 'mac80211'
	option channel '11'
	option hwmode '11g'
	option path 'platform/ahb/18100000.wmac'
	option htmode 'HT20'
	option country 'PL'

config wifi-device 'radio1'
	option type 'mac80211'
	option channel '36'
	option hwmode '11a'
	option path 'pci0000:00/0000:00:00.0'
	option htmode 'HT20'
	option country 'PL'

# MESH
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
