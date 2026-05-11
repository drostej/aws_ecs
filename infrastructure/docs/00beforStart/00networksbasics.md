Udemy AWS network basics
https://www.udemy.com/course/awsnetworking/learn/lecture/16266676#overview

#### Subnet Calculator
https://www.davidc.net/sites/default/subnets/subnets.html



## begriffe


![[Pasted image 20250215173613.png]]


### AWS Availability Zones

- In einer Region
### VPC
- Zur Umsetzung von Zonenkonzepten web --> backend -->DB
- Eigenständiges Netzwerk wie in einem "on premise" Stack
- Ist region spezifisch - z.B. eu-central-1
- Verbindung von AWS resourcen zu on prem resourcen
- 5 VPCs pro Region sind möglich


### AWS region

- Geografisch getrennt
- 5 VPCs möglich
- 5 Elastic IPs möglcih



### Verstehen von Subnetting 


Um das **Netzwerk 10.1.0.0/16** in **zwei gleich große Subnetze** zu unterteilen, müssen wir die **Subnetzmaske um 1 Bit erweitern**.

### **Schritt 1: Subnetzmaske erhöhen**

- Das ursprüngliche Netz ist **10.1.0.0/16** (**255.255.0.0**), also hat es **16 Bit für das Netzwerk** und **16 Bit für Hosts**.
- Um es zu **halbieren**, nehmen wir **ein weiteres Bit für das Netzwerk** → neue Subnetzmaske: **/17** (**255.255.128.0**).

### **Schritt 2: Die beiden neuen Subnetze bestimmen**

Ein zusätzliches Bit verdoppelt die Anzahl der Netze und halbiert die Anzahl der Hosts.

|Subnetz|Netzwerkadresse|Host-Bereich|Broadcast-Adresse|
|---|---|---|---|
|**Subnetz 1**|`10.1.0.0/17`|`10.1.0.1 - 10.1.127.254`|`10.1.127.255`|
|**Subnetz 2**|`10.1.128.0/17`|`10.1.128.1 - 10.1.255.254`|`10.1.255.255`|

### **Erklärung:**

- **Subnetz 1** deckt die **erste Hälfte** ab (`10.1.0.0` bis `10.1.127.255`).
- **Subnetz 2** deckt die **zweite Hälfte** ab (`10.1.128.0` bis `10.1.255.255`).
- Beide Subnetze haben **jeweils 32.766 nutzbare Hosts** (`2^15 - 2`, weil die erste und letzte Adresse reserviert sind).


### Reservierte Host IPs
- 0 - Adressierung des Subnetzes
- 255 - Adressierung der Broadcast adresse 


### Erkennen von Netzwerk IPs und Host IPs
Falls eine IP-Adresse **explizit mit einer Netzmaske angegeben ist**, kannst du sofort erkennen, ob sie eine Netzwerkadresse ist:

- `10.0.0.0/16` → Das ist eine Netzwerkadresse (weil alle Host-Bits `0` sind).
- `10.0.0.1/16` → Das ist ein Host innerhalb des Netzwerks.

### Reservierte IP Adressen

|Typ|Bereich|Zweck|
|---|---|---|
|**Loopback**|`127.0.0.0/8`|Kommunikation mit sich selbst (localhost).|
|**Private Netzwerke**|`10.0.0.0/8`, `172.16.0.0/12`, `192.168.0.0/16`|Interne Netzwerke (nicht im Internet).|
|**Link-Local**|`169.254.0.0/16`|Automatische Vergabe ohne DHCP.|
|**Multicast**|`224.0.0.0/4`|Pakete an mehrere Empfänger senden.|
|**CGNAT**|`100.64.0.0/10`|NAT für große Provider-Netze.|
|**Dokumentation**|`192.0.2.0/24`, `198.51.100.0/24`, `203.0.113.0/24`|Beispiel-IP-Bereiche für Tests.|
