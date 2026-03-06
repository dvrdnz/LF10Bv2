## Teil V: Installation und Konfiguration DHCP-Server

### 1. Installation auf SRV1

**Soll:**
```bash
sudo apt install kea -y
```

**Ist:**
```bash
apt install --no-install-recommends --no-install-suggests kea-dhcp4-server -y
```

**Grund:**
- Reduziert Speicherverbrauch ( kea-dhcp6-server wird beispielsweise nicht automatisch mitinstalliert durch dieses Vorgehen)


### 2. Konfiguration

**Soll:**
```bash
sudo mv /etc/kea/kea-dhcp4.conf /etc/kea/kea-dhcp4.conf.example
sudo nano /etc/kea/kea-dhcp4.conf
```

**Ist:**
```bash
sudo mv /etc/kea/kea-dhcp4.conf /etc/kea/kea-dhcp4.conf.example
sudo nano /etc/kea/kea-dhcp4.conf
kea-dhcp4 -t /etc/kea/kea-dhcp4.conf
```

Folgende Zeilen einfügen und speichern:
```json
{
  "Dhcp4": {
    "interfaces-config": {
      "interfaces": [ "ens18" ]
    },
    "control-socket": {
      "socket-type": "unix",
      "socket-name": "/run/kea-kea4-ctrl-socket"
    },
    "lease-database": {
      "type": "memfile",
      "lfc-interval": 3600
    },
    "valid-lifetime": 600,
    "max-valid-lifetime": 7200,
    "subnet4": [
      {
        "id": 1,
        "subnet": "192.168.10.0/24",
        "pools": [
          {
            "pool": "192.168.10.100 - 192.168.10.200"
          }
        ],
        "option-data": [
          {
            "name": "routers",
            "data": "192.168.10.1"
          },
          {
            "name": "domain-name-servers",
            "data": "192.168.10.11"
          },
          {
            "name": "domain-name",
            "data": "example.internal"
          }
        ]
      }
    ]
  }
}
```

**Grund:**
- Identisch mit Vorgabe für Konfigurationsinhalt
- Zusätzlich: `kea-dhcp4 -t /etc/kea/kea-dhcp4.conf` validiert die JSON-Syntax BEVOR der Service gestartet wird

### 3. Service starten und Status prüfen

**Soll:**
```bash
sudo systemctl restart kea-dhcp4-server
sudo systemctl status kea-dhcp4-server
```

**Ist:**
Identisch umgesetzt. Service läuft:
```
● kea-dhcp4-server.service - Kea IPv4 DHCP daemon
     Loaded: loaded (/usr/lib/systemd/system/kea-dhcp4-server.service; enabled; preset: enabled)
     Active: active (running) since Wed 2026-03-04 15:00:11 CET; 8s ago
   Main PID: 4747 (kea-dhcp4)
      Tasks: 7 (limit: 2300)
     Memory: 2.7M (peak: 3.1M)
        CPU: 31ms
     CGroup: /system.slice/kea-dhcp4-server.service
             └─4747 /usr/sbin/kea-dhcp4 -c /etc/kea/kea-dhcp4.conf
```

### 4. Funktionstest mit Client (CL01)

**Soll:**
Client von statischer IP-Konfiguration auf DHCP umstellen. Wenn der Client eine Konfiguration per DHCP bezieht, ist der Dienst betriebsbereit.

**Ist:**
Client auf DHCP umgestellt und Lease erneuert:
```bash
sudo dhclient -r eth1
sudo dhclient eth1
resolvectl status
# Current DNS Server: 192.168.10.11
# DNS Domain: example.internal
```

Client hat automatisch `192.168.10.11` als DNS und `example.internal` als Suchdomäne erhalten – DHCP-Server funktioniert korrekt.
