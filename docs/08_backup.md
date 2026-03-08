## Teil VIII: iSCSI-Backup auf SRV2

### 1. iSCSI Target02 auf TrueNAS erstellen

**Soll:**
Auf dem Storage-Server ein weiteres iSCSI Target mit dem Namen `target02` und einer Größe von 200 GB erstellen. Zugriff für SRV2 autorisieren, auf CHAP-Authentifizierung verzichten.

**Ist:**
Identisch umgesetzt (analog zu target01, siehe Teil VI Abschnitt 10).

---

### 2. iSCSI-Tools installieren und Target ermitteln (SRV2)

**Soll:**
Als root auf SRV2:
```bash
su -
apt update && apt install open-iscsi -y
```
Verfügbare iSCSI Targets auf dem Storage-Server ermitteln:
```bash
iscsiadm -m discovery -t sendtargets -p 192.168.10.12
```
Erwartete Ausgabe:
```
192.168.10.12:3260,-1 iqn.2005-10.org.freenas.ctl:target01
192.168.10.12:3260,-1 iqn.2005-10.org.freenas.ctl:target02
```

**Ist:**
`iscsid`-Dienst war initial inaktiv und nicht aktiviert. Nach manuellem Start funktionierte die Discovery:
```bash
systemctl enable --now iscsid
iscsiadm -m discovery -t sendtargets -p 192.168.10.12
```

**Grund:**
In der Anleitung fehlt der Hinweis, dass `iscsid` explizit gestartet und aktiviert werden muss. Der Dienst ist nach der Installation nicht automatisch aktiv.

---

### 3. Verbindung mit target02 herstellen

**Soll:**
```bash
iscsiadm -m node -T iqn.2005-10.org.freenas.ctl:target02 -p 192.168.10.12 -l
```
Anschließend prüfen ob das neue Block Device `sdb` verfügbar ist:
```bash
lsblk
```

**Ist:**
Identisch umgesetzt. `sdb` mit 200G erscheint als neues Block Device.

---

### 4. Partition anlegen

**Soll:**
```bash
fdisk /dev/sdb
```
Innerhalb von fdisk:
- `n` – neue Partition erstellen
- `p` – primäre Partition
- Eingabetaste – Standardwerte für Start- und Endsektor akzeptieren
- `w` – Änderungen schreiben und fdisk beenden

**Ist:**
Identisch umgesetzt.

---

### 5. Partition formatieren

**Soll:**
```bash
mkfs.ext4 /dev/sdb1
```

**Ist:**
Identisch umgesetzt.

---

### 6. Partition einbinden und prüfen

**Soll:**
```bash
mkdir /mnt/backup
mount /dev/sdb1 /mnt/backup
df -h /mnt/backup
```
Erwartete Ausgabe:
```
Dateisystem    Größe Benutzt Verf. Verw% Eingehängt auf
/dev/sdb1       246G     28K  233G    1% /mnt/backup
```

**Ist:**
Identisch umgesetzt.

---

### 7. Gerät wieder trennen

**Soll:**
```bash
umount /mnt/backup
iscsiadm -m node -T iqn.2005-10.org.freenas.ctl:target02 -p 192.168.10.12 -u
```

**Ist:**
Identisch umgesetzt.

---

### 8. rsync installieren

**Soll:**
```bash
apt install rsync -y
```

**Ist:**
Identisch umgesetzt.

---

### 9. Backup-Skript anlegen

**Soll:**
```bash
nano /usr/local/bin/backup.sh
```
Skript-Inhalt: siehe `scripts/backup.sh`

**Ist:**
Identisch umgesetzt.

---

### 10. Skript ausführbar machen

**Soll:**
```bash
chmod +x /usr/local/bin/backup.sh
```

**Ist:**
Identisch umgesetzt.

---

### 11. Skript testen

**Soll:**
```bash
/usr/local/bin/backup.sh
```
Hinweis: `/var/www` existiert zu diesem Zeitpunkt noch nicht – der rsync-Fehler dafür ist erwartet und kann ignoriert werden. Das Verzeichnis wird im weiteren Verlauf des Lernfeldes angelegt.

**Ist:**
Identisch umgesetzt. rsync-Fehler für `/var/www` wie erwartet aufgetreten und ignoriert.

---

### 12. Backup-Inhalt verifizieren

**Soll:**
Manuell einbinden und prüfen:
```bash
iscsiadm -m node -T iqn.2005-10.org.freenas.ctl:target02 -p 192.168.10.12 -l
mount /dev/sdb1 /mnt/backup
ls -lha /mnt/backup
```
Anschließend wieder sauber aushängen:
```bash
umount /mnt/backup
iscsiadm -m node -T iqn.2005-10.org.freenas.ctl:target02 -p 192.168.10.12 -u
```

**Ist:**
Identisch umgesetzt. Datumsstempel-Verzeichnis mit `/etc`-Backup auf dem Target sichtbar.

---

### 13. Cron-Job einrichten

**Soll:**
```bash
crontab -e
```
Folgende Zeile am Ende der Datei einfügen (Editor: nano):
```
0 1 * * * /usr/local/bin/backup.sh >> /var/log/backup.log 2>&1
```
Das Skript wird täglich um 01:00 Uhr ausgeführt. Ausgaben (inkl. Fehler) werden in `/var/log/backup.log` protokolliert.

**Ist:**
Identisch umgesetzt.
