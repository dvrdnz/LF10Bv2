## Teil X: Nextcloud auf SRV2

### 1. PHP 8.x installieren

**Soll:**
```bash
sudo apt install -y php php-curl php-cli php-mysql php-gd php-common php-xml php-json \
php-intl php-pear php-imagick php-dev php-common php-mbstring php-zip php-soap \
php-bz2 php-bcmath php-gmp php-apcu libmagickcore-dev
```
Überprüfen:
```bash
php --version
php -m
```
Erwartete Ausgabe: PHP 8.2.x mit aktivierten Erweiterungen (GD, MySQL, Imagick, xml, zip, ...).

**Ist:**
PHP 8.4 installiert (Trixie liefert 8.4 statt 8.2). 

---

### 2. PHP-Konfiguration anpassen

**Soll:**
```bash
sudo nano /etc/php/8.2/apache2/php.ini
```
Folgende Parameter anpassen:
```ini
date.timezone = Europe/Berlin

memory_limit = 512M
upload_max_filesize = 500M
post_max_size = 600M
max_execution_time = 300

file_uploads = On
allow_url_fopen = On

display_errors = Off
output_buffering = Off

zend_extension=opcache

; [opcache]
opcache.enable = 1
opcache.interned_strings_buffer = 8
opcache.max_accelerated_files = 10000
opcache.memory_consumption = 128
opcache.save_comments = 1
opcache.revalidate_freq = 1
```
```bash
sudo systemctl restart apache2
```

**Ist:**
Identisch umgesetzt.

---

### 3. MariaDB-Server installieren

**Soll:**
```bash
sudo apt install -y mariadb-server
sudo systemctl status mariadb
```

**Ist:**
Identisch umgesetzt.

---

### 4. MariaDB absichern

**Soll:**
```bash
sudo mariadb-secure-installation
```
- Enter current password: Enter (leer)
- Switch to unix_socket authentication: n
- Change the root password: y
- Remove anonymous users: y
- Disallow root login remotely: y
- Remove test database: y
- Reload privilege tables: y

**Ist:**
Identisch umgesetzt.

---

### 5. Datenbank und Benutzer anlegen

**Soll:**
```bash
mariadb -u root -p
```
```sql
CREATE DATABASE nextcloud_db;
CREATE USER nextclouduser@localhost IDENTIFIED BY 'StrongPassword';
GRANT ALL PRIVILEGES ON nextcloud_db.* TO nextclouduser@localhost;
FLUSH PRIVILEGES;
SHOW GRANTS FOR nextclouduser@localhost;
quit
```

**Ist:**
Identisch umgesetzt. Grants korrekt gesetzt:
```
GRANT USAGE ON *.* TO `nextclouduser`@`localhost`
GRANT ALL PRIVILEGES ON `nextcloud_db`.* TO `nextclouduser`@`localhost`
```

---

### 6. curl und unzip installieren

**Soll:**
```bash
sudo apt install curl unzip -y
```

**Ist:**
Identisch umgesetzt.

---

### 7. Nextcloud herunterladen und entpacken

**Soll:**
```bash
cd /var/www/
sudo curl -o nextcloud.zip https://download.nextcloud.com/server/releases/latest.zip
sudo unzip nextcloud.zip
sudo chown -R www-data:www-data nextcloud
```

**Ist:**
Identisch umgesetzt.

---

### 8. Apache2 vHost konfigurieren

**Soll:**
```bash
sudo nano /etc/apache2/sites-available/nextcloud.example.internal.conf
```
Inhalt:
```apacheconf
<VirtualHost *:80>
    ServerName nextcloud.example.internal
    DocumentRoot /var/www/nextcloud/

    # log files
    ErrorLog /var/log/apache2/nextcloud-error.log
    CustomLog /var/log/apache2/nextcloud-access.log combined

    <Directory /var/www/nextcloud/>
        Options +FollowSymlinks
        AllowOverride All
        <IfModule mod_dav.c>
            Dav off
        </IfModule>
        SetEnv HOME /var/www/nextcloud
        SetEnv HTTP_HOME /var/www/nextcloud
    </Directory>
</VirtualHost>
```
Syntax prüfen, aktivieren und Apache neu laden:
```bash
sudo apachectl configtest
sudo a2ensite nextcloud.example.internal.conf
sudo systemctl reload apache2
```

**Ist:**
Identisch umgesetzt. `apachectl configtest` lieferte `Syntax OK`.

---

### 9. DNS-Eintrag für Nextcloud (auf SRV1)

**Soll:**
```bash
sudo nano /etc/bind/db.example.internal
```
Eintrag am Dateiende hinzufügen:
```
nextcloud    IN    CNAME    srv2
```
bind9 neu laden:
```bash
sudo systemctl reload named
```

**Ist:**
Identisch umgesetzt.

---

### 10. Nextcloud Webinstaller

**Soll:**
`http://nextcloud.example.internal` im Browser des CL01 aufrufen und den Webinstaller ausfüllen:
- Admin-Benutzername: frei wählbar
- Admin-Passwort: sicheres Passwort
- Datenverzeichnis: `/var/www/nextcloud/data` (Standardvorgabe)
- Datenbank: MySQL/MariaDB
- Datenbankbenutzer: `nextclouduser`
- Datenbankpasswort: *(vergeben in Schritt 5)*
- Datenbankname: `nextcloud_db`
- Datenbankhost: `localhost`

„Installieren" klicken. Nach Abschluss Empfehlung zur Installation von Apps bestätigen. Anschließend Weiterleitung auf das Dashboard.

**Ist:**
Identisch umgesetzt. Nextcloud-Installation erfolgreich abgeschlossen. Dashboard erreichbar unter `http://nextcloud.example.internal`.
