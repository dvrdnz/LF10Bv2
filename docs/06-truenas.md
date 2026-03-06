## Teil VI: Installation TrueNAS als Storagegerät

### 1. VM-Setup (TrueNAS)

**Soll:**
| Eigenschaft | Wert |
|---|---|
| Name | Storage |
| Generation | Gen 2 |
| Arbeitsspeicher | 3600 MB |
| Netzwerk | Firmennetz |
| Festplatte | 250 GB (VHDX, dynamisch erweiterbar) |
| Betriebssystem | TrueNAS-13.0-U6.2.iso |

**Ist:**
Identisch umgesetzt. Aber 

| Arbeitsspeicher | 4096 MB |

erhöht.

**Grund:** In Anbetracht der verfügbaren Systemressourcen wurde der Arbeitsspeicher leicht erhöht, um einen stabileren Betrieb von TrueNAS zu gewährleisten.

### 2. Hardware-Anpassung

**Soll:**
Einen weiteren Prozessorkern hinzufügen und Secure Boot deaktivieren.

**Ist:**
Identisch umgesetzt

### 3. Zusätzliche Festplatten (Storage-Pools)

**Soll:**
Drei neue Festplatten vom Typ „Dynamisch erweiterbar" mit jeweils 1024 GB hinzufügen:
- Pool01
- Pool02
- Pool03

Ablageort: Ordner „Virtual Hard Disks" der VM. Bootmodus: UEFI.

**Ist:**
Identisch umgesetzt

### 4. OS-Installation

**Soll:**
VM starten und Installationsanweisungen folgen. Zielfestplatte: `da0`. Bootmodus: UEFI.
Bei fehlendem Bootvorgang nach Installation: erste Systemfestplatte auf Bootreihenfolge Position 1 setzen.

**Ist:**
Identisch umgesetzt

### 5. Netzwerkkonfiguration (TrueNAS Webinterface)

**Soll:**
Im Browser des Clients TrueNAS-Weboberfläche aufrufen (angezeigte IP nach Installation).
Login: `root`, Passwort: selbst festgelegt während Installation.
Navigieren zu: Network → Interfaces → Schnittstelle expandieren → Edit
- DHCP deaktivieren
- IP-Adresse: `192.168.10.12/24`
- „APPLY" → „TEST CHANGES" → „Save Configuration"

**Ist:**
Identisch umgesetzt. TrueNAS ist nach Konfiguration unter `https://192.168.10.12` erreichbar.

### 6. Netzwerkkonfiguration prüfen

**Soll:**
Unter Network → Interfaces prüfen ob sowohl alte als auch neue IP-Adresse vorhanden. Falls beide vorhanden: Schritt 5 wiederholen.

**Ist:**
Identisch umgesetzt

### 7. DNS-Eintrag für Storage (SRV1)

**Soll:**
Per SSH mit SRV1 verbinden, Zonendatei öffnen:
```bash
sudo nano /etc/bind/db.example.internal
```
Folgenden Eintrag am Dateiende hinzufügen:
```
storage    IN    A    192.168.10.12
```
bind9 neu laden:
```bash
sudo systemctl reload named
```

**Ist:**
Eintrag korrekt gesetzt. `https://storage.example.internal` war jedoch zunächst nicht erreichbar.

Im Zuge der Fehlersuche wurde die Serial auf das in RFC 1912 empfohlene Format umgestellt:

> "The recommended syntax is YYYYMMDDnn (YYYY=year, MM=month, DD=day, nn=revision number."
>
> — Barr, D. (1996). *Common DNS Operational and Configuration Errors*. RFC 1912, Abschnitt 2.2. Internet Engineering Task Force (IETF). https://www.ietf.org/rfc/rfc1912.txt (Zugriff: 05. März 2026)

Diese Änderung wurde dann vorgenommen bevor erkannt wurde, dass RFC 1912 Abschnitt 3.1 die Serial ausschließlich im Kontext von Zonentransfers zwischen Primary und Secondary definiert – ein Secondary war in diesem Setup nicht vorhanden. Eventuell war die Unerreichbarkeit von https://storage.example.internal nur eine Verzögerung. Trotzdem wurde dieses Format für Serial beibehalten:
```
$TTL 2D
@   IN  SOA srv1.example.internal. administrator.example.internal. (
        2026030501 ; Serial (YYYYMMDDNN) - Stand: 05. März 2026, Revision 01
        8H         ; Refresh
        2H         ; Retry
        4W         ; Expire
        3H )       ; Minimum TTL

@       IN  NS  srv1.example.internal.
@       IN  A   192.168.10.11
srv1    IN  A   192.168.10.11
router  IN  A   192.168.10.1
proxmox IN  A   192.168.10.10
storage IN  A   192.168.10.12
```

```bash
sudo named-checkzone example.internal /etc/bind/db.example.internal
# zone example.internal/IN: loaded serial 2026030501
# OK
sudo systemctl reload named
```

### 8. Validierung

**Soll:**
Im Browser des Clients TrueNAS unter `https://storage.example.internal` aufrufen.

**Ist:**
Identisch umgesetzt.
