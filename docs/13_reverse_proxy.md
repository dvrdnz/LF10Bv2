## Teil XIII: Reverse Proxy & Portfreigabe

### 1. DNS-Eintrag für Portainer (SRV1)

**Soll:**
```bash
sudo nano /etc/bind/db.example.internal
```
```
portainer    IN    CNAME    srv2
```
```bash
sudo systemctl reload named
```

**Ist:**
Identisch umgesetzt.

---

### 2. Apache vHost als Reverse Proxy

**Soll:**
```bash
sudo nano /etc/apache2/sites-available/portainer.example.internal.conf
```
```apacheconf
<VirtualHost *:80>
    ServerName portainer.example.internal

    ProxyPreserveHost On
    ProxyPass / http://localhost:9000/
    ProxyPassReverse / http://localhost:9000/
</VirtualHost>
```
```bash
sudo a2ensite portainer.example.internal.conf
sudo a2enmod proxy proxy_http
sudo systemctl restart apache2
```

**Ist:**
Identisch umgesetzt. Portainer unter `http://portainer.example.internal` erreichbar.

---

### 3. Portfreigabe am Router

**Soll:**
```bash
iptables -t nat -A PREROUTING -p tcp -d <externe IP> --dport 80 -j DNAT --to-destination 192.168.10.13:80
```
Auf dem Remote-Lab in `C:\Windows\System32\drivers\etc\hosts` eintragen:
```
<externe IP des Routers>    portainer.example.internal
```

**Ist:**
Identisch umgesetzt. Portainer vom Remote-Lab aus unter `http://portainer.example.internal` erreichbar.
