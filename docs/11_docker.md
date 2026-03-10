## Teil XI: Docker & Chrony auf SRV2

### 1. Docker-Repository einrichten

**Soll:**
```bash
# Add Docker's official GPG key:
sudo apt update
sudo apt install ca-certificates curl -y
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] \
  https://download.docker.com/linux/debian \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update
```

**Ist:**
Identisch umgesetzt.

---

### 2. Docker installieren

**Soll:**
```bash
sudo apt install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y
```

**Ist:**
Identisch umgesetzt.

---

### 3. Installation prüfen

**Soll:**
```bash
sudo docker run hello-world
```

**Ist:**
Identisch umgesetzt.

---

### 4. Benutzer zur Docker-Gruppe hinzufügen

**Soll:**
```bash
sudo usermod -aG docker <benutzername>
```
Anschließend ab- und wieder anmelden, damit die Gruppenmitgliedschaft aktiv wird.

**Ist:**
Identisch umgesetzt.

---

### 5. Chrony-Container starten

**Soll:**
```bash
docker run --name=ntp \
  --restart=always \
  --detach \
  --publish=123:123/udp \
  cturra/ntp
```

**Ist:**
Identisch umgesetzt.

---

### 6. Container-Status prüfen

**Soll:**
```bash
docker ps
```
Container `ntp` läuft mit Port `0.0.0.0:123->123/udp`.

**Ist:**
Identisch umgesetzt.

---

### 7. Dienst auf Host-Ebene prüfen

**Soll:**
```bash
ss -tulpen
```
UDP Port 123 auf `0.0.0.0` sichtbar.

**Ist:**
Identisch umgesetzt.

---

### 8. Zeitserver vom Client testen

**Soll:**
Auf dem Mint-Client:
```bash
sudo apt install ntpdate
ntpdate -q 192.168.10.13
```
Wenn der Server antwortet, ist der Dienst funktionstüchtig.

**Ist:**
`ntpdate` auf Trixie nicht verfügbar – ersetzt durch `ntpsec-ntpdate`:
```bash
sudo apt install ntpsec-ntpdate -y
sudo ntpdate -q 192.168.10.13
```
Ausgabe: `ntpdig: Response dropped: stratum 0, probable KOD packet` – Dienst antwortet, Client-seitig kein weiterer Test erforderlich laut Anleitung.

**Grund:**
`ntpdate` wurde in Debian Trixie durch `ntpsec-ntpdate` ersetzt.

---

### 9. NTP-Adresse im DHCP-Server hinterlegen

**Soll:**
NTP-Server-Adresse in der Kea-DHCP-Konfiguration auf SRV1 eintragen.
Referenz: `https://linux.die.net/man/5/dhcpd-options)`

**Ist:**
Option `ntp-servers` in `/etc/kea/kea-dhcp4.conf` ergänzt:
```json
{
    "name": "ntp-servers",
    "data": "192.168.10.13"
}
```
```bash
kea-dhcp4 -t /etc/kea/kea-dhcp4.conf
sudo systemctl restart kea-dhcp4-server
```
Zusätzliche Quelle: `https://kea.readthedocs.io/en/latest/arm/dhcp4-srv.html`

---

### 10. Chrony via docker-compose

**Soll:**

1. Laufenden Container stoppen:
```bash
docker stop ntp
```

2. Verzeichnisstruktur anlegen:
```bash
mkdir -p ~/docker/chrony
cd ~/docker/chrony
```

3. `docker-compose.yml` anlegen:
```bash
nano docker-compose.yml
```
Inhalt:
```yaml
services:
  ntp:
    image: cturra/ntp:latest
    container_name: chrony
    restart: always
    ports:
      - 123:123/udp
    environment:
      - NTP_SERVERS=time.cloudflare.com
      - LOG_LEVEL=0
      - TZ=Europe/Berlin
```

4. Stack starten:
```bash
docker compose up -d
```

5. Ergebnis prüfen:
```bash
docker ps
```

**Ist:**
*(noch nicht durchgeführt)*
