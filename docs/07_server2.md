## Teil VII: Installation SRV2

### 1. VM-Erstellung auf Proxmox

**Soll:**
- Name: `SRV2`
- ISO: Debian 12
- CPU: 2 Kerne
- RAM: 2048 MB dynamisch, Minimalwert 1024 MB
- Festplatte: 50 GB, lokalisiert auf `local-lvm`

**Ist:**
Identisch umgesetzt. ISO: `debian-13.3.0-amd64-DVD-1.iso` (bereits auf Proxmox vorhanden aus Teil III).

**Grund:**
Bereits vorhandenes ISO auf dem Proxmox-Host genutzt.

---

### 2. OS-Installation

**Soll:**
Installationsassistent folgen bis zum Punkt Netzwerk.
- Rechnername: `srv2`
- Domäne: `example.internal`
- Konten: `root` und Benutzer `student` (analog zu SRV1)
- Defaultwerte beibehalten
- Softwareauswahl: nur `SSH server` und `Standard-Systemwerkzeuge`

**Ist:**
Identisch umgesetzt.

---

### 3. Post-Install (sudo)

**Soll:**
```bash
apt update && apt install sudo
usermod -aG sudo student
```

**Ist:**
```bash
cat << EOF > /etc/apt/sources.list
deb http://deb.debian.org/debian trixie main non-free-firmware
deb http://deb.debian.org/debian trixie-updates main non-free-firmware
deb-src http://deb.debian.org/debian trixie main non-free-firmware
deb-src http://deb.debian.org/debian trixie-updates main non-free-firmware
EOF

apt update && apt install sudo
usermod -aG sudo student
```

**Grund:**
Das DVD-ISO von Debian 13 (Trixie) enthält keine verwertbaren Netzwerk-Paketquellen. Die `/etc/apt/sources.list` wurde daher manuell auf die offiziellen `trixie`-Repos gesetzt, bevor `apt update` ausgeführt werden konnte.

---

### 4. Statische IP-Konfiguration

**Soll:**
```bash
nano /etc/network/interfaces
```
```
# The primary network device
allow-hotplug ens18
iface ens18 inet static
        address 192.168.10.13/24
        gateway 192.168.10.1
        dns-nameservers 192.168.10.11
        dns-search example.internal
```
```bash
systemctl restart networking
ip a
```
Erwartete Ausgabe: `inet 192.168.10.13/24`

**Ist:**
Identisch umgesetzt.

---

### 5. DNS-Eintrag für SRV2 (auf SRV1)

**Soll:**
```bash
sudo nano /etc/bind/db.example.internal
```
Eintrag am Dateiende hinzufügen:
```
srv2    IN    A    192.168.10.13
```

**Ist:**
Identisch umgesetzt.

---

