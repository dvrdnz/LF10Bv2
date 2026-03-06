## Teil III: Installation SRV 1

### 1. ISO-Vorbereitung

**Soll:**

- Im Proxmox-Webinterface → Storage „local" (ISO-Images) → „Von URL herunterladen"
 Browser öffnen → https://www.debian.org/distrib/ aufrufen
- Zum passenden netinst-Link navigieren (amd64, netinst) → Rechtsklick → „Adresse des Links kopieren"
- Link in Proxmox-Dialog einfügen → „URL abfragen" → „Herunterladen"
- Vorgabe ist Debian 12.6.0-amd64-netinst

**Ist:**
Da auf dem Router die Default-Drop-Policy aktiv ist und es keine DNS-Weiterleitung (UDP/TCP Port 53) vom LAN ins WAN gibt, kann Proxmox keine Namensauflösungen durchführen. Daher wurde ein alternativer Weg gewählt: 

nslookup auf der Router-VM und temporärer Eintrag in /etc/hosts auf Proxmox für den direkten Download.

Auf dem **Debian-Router** (192.168.10.1) die IP des Mirrors ermitteln:
```bash
nslookup ftp-stud.hs-esslingen.de
```

Ergebnis:
```text
ftp-stud.hs-esslingen.de canonical name = rhlx01.hs-esslingen.de.
Name: rhlx01.hs-esslingen.de
Address: <ipv4>
```

Auf **Proxmox** (192.168.10.10) temporär Host-Eintrag ergänzen:
```bash
echo "<ipv4> ftp-stud.hs-esslingen.de" >> /etc/hosts
```

ISO (nicht netinst) direkt herunterladen und im ISO-Verzeichnis ablegen:
```bash
curl -L -# -o /var/lib/vz/template/iso/debian-13.3.0-amd64-DVD-1.iso \
  https://ftp-stud.hs-esslingen.de/Mirrors/debian-cd/13.3.0/amd64/iso-dvd/debian-13.3.0-amd64-DVD-1.iso
```

**Grund für Abweichung:**
Die restriktive Default-Drop-Policy des Routers erlaubt keine DNS-Weiterleitung vom LAN ins WAN. Der Download über das Webinterface war daher nicht möglich. Der manuelle Weg stellt eine funktionale und kontrollierte Alternative dar. Der Mirror `ftp-stud.hs-esslingen.de` ist offiziell.

### 2. Erstellen der VM „SRV1"

**Soll:**
Neue VM auf Proxmox erstellen:
- Name: `SRV1`
- ISO: `debian-12.6.0-amd64-netinst.iso`
- CPU: 2 Kerne, Typ: `host`
- RAM: 2048 MB (dynamisch, Min. 1024 MB)
- Speicher: Standardwert (dynamische Verwaltung)
- Option „Beim Booten starten": aktivieren (VM-Optionen → Booteigenschaften)

**Ist:**
Identisch umgesetzt, bis auf:
- ISO: `debian-13.3.0-amd64-DVD-1.iso` – wie oben heruntergeladen

### 3. Installation Debian Server

**Soll:**
Debian über den grafischen Installer installieren. Einstellungen unverändert lassen, solange nicht anders angegeben. Netzwerkkonfiguration manuell vornehmen:

| IP-Adresse | Gateway | DNS | Rechnername | Domain |
|---|---|---|---|---|
| 192.168.10.11/24 | 192.168.10.1 | 8.8.8.8 | srv1 | example.internal |

Softwareauswahl – nur folgendes aktivieren:
- SSH server
- Standard-Systemwerkzeuge
- Grafische Umgebung (abwählen!)

**Ist:**
Identisch umgesetzt

### 4. Rechteverwaltung / Post-Install

**Soll:**
Als Benutzer `root` anmelden und folgende Nacharbeiten vornehmen:
```bash
apt update && apt install sudo   # ermöglicht erhöhte Rechte für Benutzer
usermod -aG sudo student         # berechtigt den Benutzer, sudo zu nutzen
```

**Ist:**

1. APT-Sources konfigurieren (für aktuelle Paketquellen):
```bash
su -
cat > /etc/apt/sources.list <<EOF
deb http://ftp.debian.org/debian trixie main
EOF
```

Ebenfalls Host-Eintrag ergänzen (vorher nslookup von debian-router):
```bash
echo "<ipv4> ftp.de.debian.org" >> /etc/hosts
```

2. sudo Installation:
```bash
su
apt update && apt install sudo
/usr/sbin/usermod -aG sudo student
```
