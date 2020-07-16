#!/bin/bash
echo "+-----------------------------+"
echo "|                             |"
echo "|        D O T M E S H        |"
echo "|                   by dotevo |"
echo "+-----------------------------+"
echo "Konfiguracja routera tak aby dołączył do lokalnej sieci."


#TODO:
# Opóźnienie startu tinc
# tinc-up /down :
# host master up/down
# route del default gw 10.10.1.1 dev br-local
# route add default gw 10.10.1.1 dev br-local

#

ret_val=""
IFS=
question_yn()
{
    while true; do
    read -p "$1 [Tak/Nie]" yn
    case $yn in
        [Tt]* ) return 0; break;;
        [Nn]* ) return 1;;
        * ) echo "Odpowiedz tak lub nie.";;
    esac
    done
}
command() {
    echo "Execuing... : $1";
    if [[ "$TESTING" != 'true' ]]; then
        ret_val=$(eval "$1")
    fi;
}

echo 'Instalacja wymaganych pakietów...'
command 'opkg update'
command 'opkg install tinc'

# TODO!
#cat /etc/init.d/reloader 
#!/bin/sh /etc/rc.common
#START=91
#USE_PROCD=1
#start_service() {
#
#	while ! ifconfig bat0 | grep Global; do
#   	 sleep 3
#	done
#        sleep 5
#	/etc/init.d/tinc restart

echo "========================================================="
echo "Pobieranie host name..."
command 'uci get system.@system[0].hostname'
HOST=$ret_val

echo "========================================================="
echo "Konfigurowanie TINC..."

if [ -d "/etc/tinc/local" ] 
then
    echo "Używanie istniejącej konfiguracji..."
else
    command "ip -o -6 addr show bat0 | grep global | sed -e 's/^.*inet6 \([^/]\+\).*/\1/'"
    IP=$ret_val
    echo "BAT0 IP: $IP"

    command "uci set network.tap0=interface"
    command "uci set network.tap0.proto='none'"
    command "uci set network.bridge.ifname='eth0.4 tap0'"

    command "cat /dev/null > /etc/config/tinc"
    command "mkdir /etc/tinc"
    command "mkdir /etc/tinc/local"
    command "mkdir /etc/tinc/local/hosts"

    command "uci set tinc.local=tinc-net"
    command "uci set tinc.local.enabled=1"
    command "uci set tinc.local.generate_keys=0"
    command "uci set tinc.local.key_size=2048"
    command "uci set tinc.local.logfile='/tmp/log/tinc.log'"
    command "uci set tinc.local.debug=3"

    command "uci set tinc.local.AddressFamily=any"
    command "uci set tinc.local.BindToAddress='$IP'"
    command "uci set tinc.local.BindToInterface='bat0'"

    command "uci set tinc.local.Forwarding='internal'"
    command "uci set tinc.local.GraphDumpFile='/tmp/log/tinc.dot'"
    command "uci set tinc.local.Hostnames='1'"

    command "uci set tinc.local.Interface='tap0'"
    command "uci set tinc.local.KeyExpire='3600'"
    command "uci set tinc.local.MACExpire='600'"
    command "uci set tinc.local.MaxTimeout='900'"
    command "uci set tinc.local.Mode='switch'"
    command "uci set tinc.local.Name='$HOST'"
    command "uci set tinc.local.PrivateKeyFile='/etc/tinc/local/rsa_key.priv'"
    command "uci set tinc.local.ProcessPriority='normal'"
    command "uci set tinc.local.ReplayWindow='16'"

    command "uci set tinc.$HOST=tinc-host"
    command "uci set tinc.$HOST.enabled=1"
    command "uci set tinc.$HOST.net=local"
    command "uci set tinc.$HOST.Port=655"
    command "uci set tinc.$HOST.Subnet='10.10.2.0/24'" 
    command "uci commit"

    command "echo 'Name = $HOST' > /etc/tinc/local/tinc.conf"
    command "echo 'Device = /dev/net/tun' >> /etc/tinc/local/tinc.conf"
    command "tincd -n local -K"
fi



echo "========================================================="
echo "Znalezione węzły w sieci:"
command "bmx7 -c show=originators | grep :....: | awk '{print \$2, \$13}'"
NODES=$ret_val
echo $ret_val

read -p "Nazwę hosta do dodania: " host
command "echo '$ret_val' | grep $host | awk '{print \$2}'"
IP=$ret_val

echo "========================================================="
#read -p "Podaj hasło dla $host: " password
echo "Poieranie podpisu..."

command "rm -rf /tmp/tincTMP"
command "scp -r root@[$IP]:/etc/tinc/ /tmp/tincTMP"
echo "Kopiowanie klucza..."
command "cp /tmp/tincTMP/local/hosts/jordMaster /etc/tinc/local/hosts/"


echo "Dodawanie hosta"
command "uci set tinc.$host=tinc-host"
command "uci set tinc.$host.enabled=1"
command "uci set tinc.$host.net=local"
command "uci add_list tinc.$host.Address=$IP"
command "uci add_list tinc.local.ConnectTo='$host'"
command "uci commit"

echo "Wysyłanie podpisu..."
command "scp -r /etc/tinc/local/hosts/$HOST root@[$IP]:/etc/tinc/local/hosts/"

echo "uci set tinc.$HOST=tinc-host" > /tmp/tincTMP/scr.sh
echo "uci set tinc.$HOST.enabled=1" > /tmp/tincTMP/scr.sh
echo "uci set tinc.$HOST.net=local" > /tmp/tincTMP/scr.sh
echo "uci commit" > /tmp/tincTMP/scr.sh

ssh root@$IP '$(< /tmp/tincTMP/scr.sh)'

#config tinc-host ajmaster    
#        option enabled 1                                    
#        option net jordanek                                 
#        list Address fd70:3ac8:4d33:5fcd:b7e1:3e5a:d5f2:6f4
#        option Subnet 10.10.10.0/24

    #command "uci set tinc.local.@ConnectTo[-1] $host"

    #command "uci set tinc.$host=tinc-host"
    #command "uci set tinc.$host.enabled=1"
    #command "uci set tinc.$host.net=local"
    #command "uci set tinc.$host.Port=655"
    #command "uci set tinc.$host.Subnet='10.10.1.0/24'" # FIXME:

#ssh user@remote_server "$(< localfile)"

echo "========================================================="

echo "Konfigurowanie WIFI-BRIDGE..."
echo "Aby roaming (przełączani między węzłami) działał poprawnie, wszystkie węzły powinny mieć to samo ssid i hasło."
read -p "SSID:" ssid
echo -n "Hasło (min. 8 znaków):" 
read -s password

command "uci set wireless.full_radio0=wifi-iface"
command "uci set wireless.full_radio0.device='radio0'"
command "uci set wireless.full_radio0.network='bridge'"
command "uci set wireless.full_radio0.mode='ap'"
command "uci set wireless.full_radio0.key='$password'"
command "uci set wireless.full_radio0.ssid='$ssid'"
command "uci set wireless.full_radio0.encryption='psk2'"
command "uci set wireless.full_radio0.ieee80211r='1'"

command "uci set wireless.local_radio0=wifi-iface"
command "uci set wireless.local_radio0.device='radio0'"
command "uci set wireless.local_radio0.network='bridge'"
command "uci set wireless.local_radio0.mode='ap'"
command "uci set wireless.local_radio0.key='$password'"
command "uci set wireless.local_radio0.ssid='$ssid-$HOST'"
command "uci set wireless.local_radio0.encryption='psk2'"
command "uci commit"


command "service network reload"