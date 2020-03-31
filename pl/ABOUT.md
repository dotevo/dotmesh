# DotMesh

**Zanim zaczniesz czytać dalej!**

Musisz wiedzieć, że nie jestem z wykształcenia osobą zajmującą się sieciami, ani bezpieczeństwem. Projekt zaś jest w bardzo wczesnej fazie i nie biorę odpowiedzialności za ew. problemy lub uszkodzenia sprzętu.

Chętnie przyjmę pomoc i usłyszę krytykę.

## Początek

Sieć mesh (kratowa/siatkowa) nie jest pojęciem ani nowym, ani innowacyjnym. Zaś na świecie powstało wiele projektów, które skupiają całe społeczności na tworzeniu sieci typu mesh aby zapewnić sobie np. alternatywne połączenia z interenetem:

Przykładowe społeczności:

- https://freifunk.net/
- https://guifi.net/

DotMesh jest jednak projektem w innej warstwie i nie zapewnia połącznia z interenetem ale oczywiście może pozwolić zrealizować takie połączenia o czym później.

Wpadłem na pomysł DotMesh gdy zakupiłem drugie mieszkanie. Są oddalone od siebie o 100m więc można bez problemu spiąć je w jedną sieć używając technologii wifi lecz nie jest to takie proste gdyż nie da się złapać kontaktu wzrokowego. Pomyślałem wtedy, że można stworzyć infrastrukturę typu mesh, która mogłaby pomóc rozwiązać tego typu problemy.

## Założenia

1. Chcę stworzyć sieć MESH dostępną dla wszystkich
2. Chcę mieć możliwość wykorzystania internetu z innego posiadanego węzła
3. Nie chcę udostępniać swojego internetu innym użytkownikom sieci gdyż mogłoby się to wiązać z problemami prawnymi w razie dokonania przestępstwa

![Image](../img/network_1.png)

## Technologie

Podczas powstawania projektu musiałem się zdecydować na pewne technologie i niektóre z nich (ale nie wszystkie) są obowiązkowe aby połączyć się z siecią DotMesh.

### Urządzenie

Cały projekt powstaje na: TP-LINK WDR4300 lecz na innych urządzeniach wspieranych przez OpenWRT powinien również działać. Konfiguracja takiego urządznia może wyglądać nieco inaczej.

### OpenWrt

Użyłem oprogramowania OpenWRT dla urządenia jednak dla ułatwienia nie jest to standardowa kompilacja lecz ze strony https://dl.eko.one.pl Dzięki temu oprogramowanie od razu zawiera kilka przydatnych pakietów. Mam nadzieję, że projekt będzie posiadał swoją kompilację w przyszłości.

### Batman-adv

_Node: Dopisać opis_

Batman-adv to projekt, który zapewnia tworzenie sieci mesh w warstwie 2. Oznacza to tyle, że działa jak duży switch.

### BMX7

_Node: Dopisać opis_

BMX7 w odróżnieniu od Batman-adv działa na warstwie 3.

### OpenVPN

_Node: Dopisać opis_

### Tinc

_Node: Dopisać opis_

### MWAN3

_Node: Dopisać opis_

## Konfiguracja krok po kroku

[Konfiguracja](CONFIGURATION.md)

TODO: Skrypty konfiguracyjne
