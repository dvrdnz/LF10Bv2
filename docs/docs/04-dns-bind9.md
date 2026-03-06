## Teil IV: Installation und Konfiguration DNS-Server

### 1. Zwingende Voraussetzung: DNS-Forward-Regel freischalten

**Soll:**
(nicht vorgegeben)

**Ist:**
Auf der debian-router-vm in fw_policy.sh ergänzen:
```bash
cat << 'EOF' >> fw_policy.sh
### DNS-Forward-Regel
/usr/sbin/iptables -A FORWARD -i $LAN_IF -o $WAN_IF -p udp --dport 53 -m conntrack --ctstate NEW -j ACCEPT
/usr/sbin/iptables -A FORWARD -i $LAN_IF -o $WAN_IF -p tcp --dport 53 -m conntrack --ctstate NEW -j ACCEPT
EOF

./fw_policy.sh
```

**Grund:**
Durch die Default-DROP-Policy der Firewall werden DNS-Anfragen aus dem LAN standardmäßig blockiert. Diese Regeln erlauben DNS-Verkehr (UDP und TCP Port 53) vom gesamten LAN ins WAN. TCP wird zusätzlich erlaubt, da große DNS-Antworten oder DNSSEC TCP verwenden können.

### 2. Installation bind9

**Soll:**
```bash
sudo apt install bind9 bind9-utils -y
```

**Ist:**
Identisch umgesetzt

### 3. named.conf – Include ergänzen

**Soll:**
```bash
sudo nano /etc/bind/named.conf
```
Zeile am Ende der Datei hinzufügen:
```
include "/etc/bind/named.conf.internal-zones";
```

**Ist:**
Identisch umgesetzt

### 4. named.conf.options – ACL, Forwarders, Optionen

**Soll:**
```bash
sudo nano /etc/bind/named.conf.options
```
```
acl internal-network {
    192.168.10.0/24;
};

options {
    directory "/var/cache/bind";

    forwarders {
        1.1.1.1;
        8.8.8.8;
    };

    allow-query { localhost; internal-network; };
    allow-transfer { none; };
    recursion yes;
    dnssec-validation no;
    listen-on-v6 { none; };
};
```

**Ist:**
Identisch umgesetzt

### 5. IPv6 für bind9 deaktivieren

**Soll:**
```bash
sudo nano /etc/default/named
```
Startup-Option `-4` hinzufügen:
```
OPTIONS="-u bind -4"
```

**Ist:**
Identisch umgesetzt

### 6. Zonen definieren (named.conf.internal-zones)

**Soll:**
```bash
sudo nano /etc/bind/named.conf.internal-zones
```
```
zone "example.internal" IN {
    type master;
    file "/etc/bind/db.example.internal";
    allow-update { none; };
};

zone "10.168.192.in-addr.arpa" IN {
    type master;
    file "/etc/bind/db.10.168.192";
    allow-update { none; };
};
```

**Ist:**
Identisch umgesetzt

### 7. Forward-Lookup-Zone anlegen (db.example.internal)

**Soll:**
```bash
sudo nano /etc/bind/db.example.internal
```
```
$TTL 2D
@       IN      SOA     srv1.example.internal. administrator.example.internal. (
                        1       ;Serial
                        8H      ;Refresh
                        2H      ;Retry
                        4W      ;Expire
                        3H )    ;MinimumTTL

@                       IN      NS      srv1.example.internal.
srv1                    IN      A       192.168.10.11
router                  IN      A       192.168.10.1
proxmox                 IN      A       192.168.10.10
```

**Ist:**
Identisch umgesetzt
```

### 8. Reverse-Lookup-Zone anlegen (db.10.168.192)

**Soll:**
```bash
sudo nano /etc/bind/db.10.168.192
```
```
$TTL 2D
@       IN      SOA     srv1.example.internal. administrator.example.internal. (
                        1       ;Serial
                        8H      ;Refresh
                        2H      ;Retry
                        4W      ;Expire
                        3H )    ;MinimumTTL

@                       IN      NS      srv1.example.internal.

1                       IN      PTR     router.example.internal.
10                      IN      PTR     proxmox.example.internal.
11                      IN      PTR     srv1.example.internal.
```

**Ist:**
Identisch umgesetzt

### 9. Service starten und testen

**Soll:**
```bash
sudo systemctl restart named
sudo systemctl status named
dig proxmox.example.internal @192.168.10.11
```

**Ist:**
Identisch umgesetzt

### 10. Netzwerkkonfiguration SRV1 anpassen

**Soll:**
```bash
sudo nano /etc/network/interfaces
```
`dns-nameservers` auf `127.0.0.1` ändern. Gleiche Änderung in:
```bash
sudo nano /etc/resolv.conf
```
```
search example.internal
nameserver 127.0.0.1
```
```bash
sudo systemctl restart networking
```

**Ist:**
Identisch umgesetzt

Validierung:
```bash
dig router.example.internal
# status: NOERROR
# ANSWER SECTION: router.example.internal. 172800 IN A 192.168.10.1
# SERVER: 127.0.0.1#53(127.0.0.1)
```

---
