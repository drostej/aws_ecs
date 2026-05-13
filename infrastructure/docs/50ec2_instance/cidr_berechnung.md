# CIDR-Block Berechnung für Subnets

## Wie wird der CIDR-Block ermittelt?

Der CIDR-Block wird basierend auf **verfügbarem IP-Adressraum in der VPC** ermittelt.

### Beispiel VPC: `172.31.0.0/16`

**VPC-Größe:** 65.536 IPs

**Bestehende Subnets:**
- `172.31.0.0/20` (4.096 IPs) - Public Subnet
- `172.31.16.0/20` (4.096 IPs)
- `172.31.32.0/20` (4.096 IPs)

**Nächster freier Block:** `172.31.48.0/20`

---

## CIDR-Rechnung für /20

```
/20 = 32 - 20 = 12 Bits für Hosts
2^12 = 4.096 IPs pro Subnet
```

**Block-Grenzen in /20 Schritten:**
- 0, 16, 32, 48, 64, 80, 96, 112, 128, 144, 160, 176, 192, 208, 224, 240

---

## Automatisch ermitteln

```bash
# Zeige verfügbare CIDR-Blöcke
aws ec2 describe-subnets \
  --filters "Name=vpc-id,Values=vpc-0f3b8e31600886d09" \
  --query 'Subnets[*].CidrBlock' \
  --output text \
  --profile tefde-sandbox \
  --region eu-central-1 | sort
```

**Formel für nächsten Block:**
```
Nächster Block = (Letzter Block + Block-Größe)
172.31.32.0 + 16 = 172.31.48.0
```

---

## Woher kommt die Blockgröße?

Die Blockgröße hängt von der **Subnet-Maske** ab, nicht von der Zahl nach dem `/`.

### Formel:

**Blockgröße = 2^(32 - CIDR-Suffix)**

### Beispiele:

| CIDR | Rechnung | Blockgröße im 3. Oktett | Hosts | Verwendung |
|------|----------|-------------------------|-------|------------|
| /20  | 2^(32-20) = 2^12 | **16** | 4.096 | Große Subnets |
| /24  | 2^(32-24) = 2^8  | **1** | 256 | Standard |
| /28  | 2^(32-28) = 2^4  | **0.0625** | 16 | Klein |

### Für /20 Subnet:

```
2^12 = 4.096 IPs
4.096 / 256 = 16

→ Blockgröße im 3. Oktett: 16
```

**Daher:**
```
172.31.0.0/20   → nächster Block bei 0 + 16 = 16
172.31.16.0/20  → nächster Block bei 16 + 16 = 32
172.31.32.0/20  → nächster Block bei 32 + 16 = 48
172.31.48.0/20  → nächster Block bei 48 + 16 = 64
```

### Quick Reference:

- **/16** → Blockgröße = 256 im 2. Oktett
- **/20** → Blockgröße = **16** im 3. Oktett
- **/24** → Blockgröße = 1 im 3. Oktett
- **/28** → Blockgröße = 16 im 4. Oktett

**Merke:** Je größer die Zahl nach `/`, desto kleiner das Subnet!

---

## Wo fängt der Host-Teil an?

Bei einem `/20` CIDR fängt der Host-Teil nach **20 Bits** an.

### Visualisierung für `172.31.48.0/20`:

```
172     .     31      .     48      .      0
01010100   00011111   00110000   00000000

|←──────── 20 Bits Netzwerk ──────→|←─ 12 Bits Host ─→|
```

**Aufschlüsselung:**
- **Oktett 1 (172):** 8 Bits → Netzwerk
- **Oktett 2 (31):** 8 Bits → Netzwerk
- **Oktett 3 (48):** 4 Bits Netzwerk + 4 Bits Host
- **Oktett 4 (0):** 8 Bits → Host

**Summe:** 8 + 8 + 4 = 20 Bits Netzwerk

### Der Host-Teil umfasst:

**12 Bits** = 4 Bits (aus Oktett 3) + 8 Bits (Oktett 4)

### Subnet-Maske:

```
/20 = 255.255.240.0

11111111.11111111.11110000.00000000
                  ↑
                  Hier beginnt Host-Teil
```

**Praktisch bedeutet das:**

- **Netzwerk-Adresse:** `172.31.48.0`
- **Erste nutzbare IP:** `172.31.48.1`
- **Letzte nutzbare IP:** `172.31.63.254`
- **Broadcast:** `172.31.63.255`
- **Gültige IPs:** `172.31.48.0` bis `172.31.63.255` (4.096 IPs)

**Der Host-Teil beginnt also mitten im 3. Oktett!**

---

## Wie viele Subnets sind möglich?

### Berechnung der möglichen /20 Subnets in einer /16 VPC:

**VPC:** `172.31.0.0/16`

### Formel:

**Anzahl Subnets = 2^(Subnet-Bits - VPC-Bits)**

```
2^(20 - 16) = 2^4 = 16 Subnets
```

### Die 16 möglichen /20 Subnets:

```
1.  172.31.0.0/20    (172.31.0.0   - 172.31.15.255)
2.  172.31.16.0/20   (172.31.16.0  - 172.31.31.255)
3.  172.31.32.0/20   (172.31.32.0  - 172.31.47.255)
4.  172.31.48.0/20   (172.31.48.0  - 172.31.63.255)  ← neu angelegt
5.  172.31.64.0/20
6.  172.31.80.0/20
7.  172.31.96.0/20
8.  172.31.112.0/20
9.  172.31.128.0/20
10. 172.31.144.0/20
11. 172.31.160.0/20
12. 172.31.176.0/20
13. 172.31.192.0/20
14. 172.31.208.0/20
15. 172.31.224.0/20
16. 172.31.240.0/20  (172.31.240.0 - 172.31.255.255)
```

### Warum Blockgröße 16?

Bei `/20` variiert nur das **3. Oktett** in 16er-Schritten:

```
/20 bedeutet: 12 Host-Bits = 4.096 IPs
4.096 IPs / 256 (IPs pro /24) = 16

→ Das 3. Oktett springt in 16er-Schritten
```

**Zusammenfassung:**
- **16 Subnets** á 4.096 IPs = 65.536 IPs gesamt
- **Schrittweite im 3. Oktett:** 16
- **Belegt:** 3 Subnets (0, 16, 32)
- **Frei:** 13 Subnets

---

## Warum max. 256 Werte pro Oktett?

Weil **ein Oktett maximal 256 verschiedene Werte** darstellen kann!

### Warum 256?

**1 Oktett = 8 Bits**

```
2^8 = 256 Werte (0 bis 255)
```

### Binär-Darstellung eines Oktetts:

```
00000000 = 0
00000001 = 1
00000010 = 2
...
11111111 = 255

→ Insgesamt 256 verschiedene Werte
```

### In IP-Adressen:

```
172.31.48.0
 ↑   ↑  ↑  ↑
 |   |  |  └─ 4. Oktett: 0-255 (256 Werte)
 |   |  └──── 3. Oktett: 0-255 (256 Werte)
 |   └─────── 2. Oktett: 0-255 (256 Werte)
 └─────────── 1. Oktett: 0-255 (256 Werte)
```

### Beim /20 CIDR:

```
4.096 IPs / 256 IPs pro /24 = 16

Das bedeutet:
- Ein /20 Subnet umfasst 16 × /24 Blöcke
- Im 3. Oktett: Sprünge von 16 (0, 16, 32, 48...)
- Im 4. Oktett: Alle 256 Werte (0-255)
```

### Beispiel `172.31.48.0/20`:

```
172.31.48.0     ← Start
172.31.48.1
...
172.31.48.255   ← 256 IPs im ersten /24
172.31.49.0     ← Nächster /24 Block
...
172.31.63.255   ← Ende (16 × 256 = 4.096 IPs)
```

**Kurz:** 256 ist die "natürliche Größe" eines Oktetts (8 Bits = 2^8 = 256).

---

## Online-Tools zur Berechnung

- https://www.ipaddressguide.com/cidr
- https://cidr.xyz/
- https://www.subnet-calculator.com/
