# Tinc

Tinc to Mesh VPN czyli zdecentralizowany VPN, który nie posiada jednego głównego serwera.

## Instalacja

```
opkg install tinc
```

## Konfiguracja pierwszego węzła

### Plik konfiguracyjny

1. Wyciągnij adres ipv6 dla bat0

```
ifconfig bat0 | grep inet6
          inet6 addr: fd70:5b64:4f67:a52a:ff34:f1ab:e51:19a5/16 Scope:Global
          inet6 addr: fe80::f443:31ff:fece:f9c9/64 Scope:Link
```

2. Stwórz plik konfiguracyjny


/etc/config/tinc.conf
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
	option BindToAddress XXXX      # TUTAJ WSTAW ADRES IPV6
	option BindToInterface bat0

	#option Forwarding internal
	option GraphDumpFile /tmp/log/tinc.net.dot

	option Interface tun0

	option KeyExpire 3600
	option MACExpire 600
	option MaxTimeout 900
	option Mode switch

	option Name master             # TUTUJ WPISZ NAZWĘ WĘZŁA

	option PrivateKeyFile /etc/tinc/net/rsa_key.priv
	option ProcessPriority normal
	option ReplayWindow 16

config tinc-host master            # TUTUJ WPISZ NAZWĘ WĘZŁA
	option enabled 1
	option net net
	option Port 655
	option Subnet 10.10.0.0/24
```

3. Plik konfiguracyjny sieci

```
mkdir /etc/tinc/net
mkdir /etc/tinc/net/hosts
```

/etc/tinc/net/tinc.conf
```
Name = master
Device = /dev/net/tun
```


### Generowanie klucza

```
tincd -n net -K
```

### Skrypty startowe
TODO: Wymaga dodatkowej pracy

```
$ cat /etc/tinc/jordanek/tinc-up 
#!/bin/sh
ifconfig tun0 10.10.0.1 netmask 255.255.0.0
```

```
$ cat /etc/tinc/jordanek/tinc-down
#!/bin/sh
ifconfig $INTERFACE down
```

```
$ cat /etc/tinc/jordanek/subnet-up
#!/bin/sh
NODE=`uci get tinc.$NETNAME.Name`

NEW_NODE=`uci show tinc | grep $SUBNET | awk -F '\.' '{print $2}'`

if [[ "$NODE" !=  "$NEW_NODE" ]]
then
  route add -net $SUBNET dev $INTERFACE;
fi
```

```
# cat /etc/tinc/jordanek/subnet-down 
#!/bin/sh
[ $NODE = `uci get tinc.$NETNAME.Name` ] && exit
case $SUBNET in
	*/32) targetType=-host ;;
	*) targetType=-net ;;
esac
route del $targetType $SUBNET dev $INTERFACE
```

## Konfiguracja kolejnego węzła

Konfiguracja kolejnego węzła odbywa się w identyczny sposób jak pierwszego. Z tą różnicą, że powinien posiadać inną nazwę oraz inną podsieć.
Po wygenerowaniu klucza należy przesłać klucz publiczny do innego węzła i dodać wpis połączenia do pliku tinc