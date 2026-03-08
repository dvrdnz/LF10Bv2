## Teil IX: Apache2 Webserver auf SRV2

### 1. Installation Apache2

**Soll:**
```bash
sudo apt install apache2 -y
sudo systemctl status apache2
ss -tapn
```
Apache2 ist unter der IP des Servers an Port 80 erreichbar.

**Ist:**
Identisch umgesetzt.

---

### 2. Verzeichnis und index.html anlegen

**Soll:**
```bash
sudo mkdir /var/www/lf10b
```
Datei `/var/www/lf10b/index.html` mit folgendem Inhalt anlegen:
```html
<!DOCTYPE html>
<html lang="de">
    <head>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Kursseite LF10b</title>
    </head>
    <body>
        <h1>Herzlich Willkommen im Lernfeld 10b!</h1>
        <p>Dies ist eine Dummyseite, um die Funktion des Apache Webservers zu demonstrieren.</p>
    </body>
</html>
```

**Ist:**
Identisch umgesetzt.

---

### 3. vHost-Konfigurationsdatei anlegen

**Soll:**
```bash
cd /etc/apache2/sites-available/
sudo nano lf10b.example.internal.conf
```
Inhalt der Datei:
```apacheconf
<VirtualHost *:80>
    ServerName lf10b.example.internal
    DocumentRoot /var/www/lf10b/

    # log files
    ErrorLog /var/log/apache2/lf10b-error.log
    CustomLog /var/log/apache2/lf10b-access.log combined
</VirtualHost>
```
Site aktivieren und Apache neu laden:
```bash
sudo a2ensite lf10b.example.internal.conf
sudo systemctl reload apache2
```

**Ist:**
Identisch umgesetzt.

---

### 4. DNS-Eintrag für lf10b (auf SRV1)

**Soll:**
Per SSH mit SRV1 verbinden, Zonendatei öffnen:
```bash
sudo nano /etc/bind/db.example.internal
```
Eintrag am Dateiende hinzufügen:
```
lf10b    IN    A    192.168.10.13
```

**Ist:**
Identisch umgesetzt. Zusätzlich nach jedem DNS-Eintrag ausgeführt:
```bash
sudo systemctl reload named
```

**Grund:**
In der Anleitung fehlte der Reload-Schritt nach dem Hinzufügen von DNS-Einträgen. Ohne `systemctl reload named` übernimmt bind9 neue Einträge nicht und die Namensauflösung schlägt fehl. Dieser Schritt wurde daher konsequent nach jedem Zonenfiledit ergänzt.

---

### 5. Validierung

**Soll:**
`http://lf10b.example.internal` im Browser des CL01 aufrufen.
Der Browser löst den Namen über den DNS-Server auf, erhält die IP von SRV2, sendet eine HTTP-Anfrage auf Port 80. Apache ordnet die Anfrage anhand des FQDN dem korrekten vHost zu und liefert die Dummyseite aus.

**Ist:**
Identisch umgesetzt.
