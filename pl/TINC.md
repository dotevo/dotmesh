# Tinc

Tinc to Mesh VPN czyli zdecentralizowany VPN, który nie posiada jednego głównego serwera.

## Instalacja

```
opkg install tinc
```

## Konfiguracja pierwszego węzła

### Plik konfiguracyjny

```
config tinc-net net
	option enabled 1

	## Daemon Configuration	(cmd arguments)
	option generate_keys 0
	option key_size 2048
	option logfile /tmp/log/tinc.net.log
	option debug 3

	## Server Configuration (tinc.conf)
	option AddressFamily any
	option BindToAddress fe80::3cb6:ebff:fe73:359f
	option BindToInterface bat0

	#option Forwarding internal
	option GraphDumpFile /tmp/log/tinc.net.dot
	option Hostnames 1

	option Interface tun0
	option KeyExpire 3600
	option MACExpire 600
	option MaxTimeout 900
	option Mode router
	option Name master

	option PrivateKeyFile /etc/tinc/net/rsa_key.priv
	option ProcessPriority normal
	option ReplayWindow 16

config tinc-host master
	option enabled 1
	option net net
	option Cipher blowfish
	option ClampMSS yes
	option Compression 0
	option Digest sha1
	option IndirectData 0
	option MACLength 4
	option PMTU 1514
	option PMTUDiscovery yes
	option Port 655
	option Subnet 10.10.0.0/24
```

### Generowanie

## Konfiguracja kolejnego węzła
