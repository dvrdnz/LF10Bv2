## Teil XII: Chrony & Portainer auf SRV2

### 1. Chrony-Container starten

**Soll:**
```bash
docker run --name=ntp \
  --restart=always \
  --detach \
  --publish=123:123/udp \
  cturra/ntp
```
Prüfen:
```bash
docker ps
ss -tulpen
```

**Ist:**
Identisch umgesetzt.

---

### 2. Zeitserver vom Client testen

**Soll:**
```bash
sudo apt install ntpdate
ntpdate -q 192.168.10.13
```

**Ist:**
`ntpdate` auf Trixie nicht verfügbar – ersetzt durch `ntpsec-ntpdate`:
```bash
sudo apt install ntpsec-ntpdate -y
sudo ntpdate -q 192.168.10.13
```

**Grund:**
`ntpdate` wurde in Debian Trixie durch `ntpsec-ntpdate` ersetzt.

---

### 3. NTP-Adresse im DHCP-Server hinterlegen (SRV1)

**Soll:**
Option `ntp-servers` in `/etc/kea/kea-dhcp4.conf` ergänzen.
Referenz: https://kea.readthedocs.io/en/latest/arm/dhcp4-srv.html

**Ist:**
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

---

### 4. Chrony via docker-compose

**Soll:**
```bash
docker stop ntp
mkdir -p ~/docker/chrony && cd ~/docker/chrony
nano docker-compose.yml
```
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
```bash
docker compose up -d
docker ps
```

**Ist:**
Identisch umgesetzt.

---

### 5. Portainer installieren

**Soll:**
```bash
mkdir ~/docker/portainer && cd ~/docker/portainer
nano docker-compose.yml
```
```yaml
services:
  portainer:
    image: portainer/portainer-ce:latest
    container_name: portainer
    restart: unless-stopped
    security_opt:
      - no-new-privileges:true
    volumes:
      - /etc/localtime:/etc/localtime:ro
      - /var/run/docker.sock:/var/run/docker.sock:ro
      - ./portainer-data:/data
    ports:
      - 9000:9000
      - 9443:9443
```
```bash
docker compose up -d
```
Aufruf: `https://192.168.10.13:9443`

**Ist:**
Identisch umgesetzt. App-Template-URL geändert auf:
```
https://raw.githubusercontent.com/technorabilia/portainer-templates/main/lsio/templates/templates.json
```

**Grund:**
Umfangreichere Auswahl an linuxserver.io-basierten Templates.

---

### 6. FreshRSS via Portainer

**Soll:**
*(optionale Erweiterung)*

**Ist:**
FreshRSS über Portainer App-Template deployed:
- Template: `Freshrss` (linuxserver/freshrss:latest)
- TZ: `Europe/Berlin`, PUID/PGID: `1000`
- Port-Mapping: Host `8099` → Container `80`
- Volume: `/srv/lsio/freshrss/config` → `/config`
https://github.com/dvrdnz/LF10Bv2/blob/main/images/fresh_rss.png
Erreichbar unter `http://192.168.10.13:8099`. Test-Feed `https://gnulinux.ch/` erfolgreich hinzugefügt.
![FreshRSS Screenshot](https://github.com/dvrdnz/LF10Bv2/blob/main/images/fresh_rss.png)
