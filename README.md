# LF10Bv2
Dieses Repository dokumentiert ein Infrastruktur-Lab aus dem Lernfeld **LF10Bv2 – Serverdienste bereitstellen und Administrationsaufgaben automatisieren**.
Der Aufbau orientiert sich grundsätzlich an der vorgegebenen Aufgabenstellung.  
Mehrere Komponenten wurden jedoch bewusst abweichend implementiert, um aktuelle
Softwareversionen sowie praxisnahe Administrationskonzepte anzuwenden.

Das begleitende Logbuch in `docs/` dokumentiert diese Abweichungen systematisch nach dem
Schema **Soll – Ist – Begründung**. Dadurch wird transparent, welche Teile der
Umgebung direkt der Aufgabenstellung entsprechen und an welchen Stellen
technische Anpassungen oder Erweiterungen vorgenommen wurden.


## Komponenten

* Debian Router (NAT Gateway + Firewall)
* Virtualisierungshost (Proxmox VE)
* Debian Server 1 (DNS + DHCP)
* Debian Server 2 (Webserver, Nextcloud, Docker, iSCSI-Backup)
* Storage-System (TrueNAS)
* Linux Client (Linux Mint)
  
Das Setup bildet eine kleine Unternehmensumgebung nach.
Ziel des Labs ist die praktische Umsetzung grundlegender Server- und Netzwerkdienste.

---

# Architektur

Netzwerk: `192.168.10.0/24`

| Host    | Funktion                              | IP            |
| ------- | ------------------------------------- | ------------- |
| router  | Gateway / Firewall                    | 192.168.10.1  |
| proxmox | Virtualisierungshost                  | 192.168.10.10 |
| srv1    | DNS + DHCP Server                     | 192.168.10.11 |
| srv2    | Webserver, Nextcloud, iSCSI-Backup    | 192.168.10.13 |
| storage | TrueNAS Storage                       | 192.168.10.12 |
| client  | Linux Mint Client                     | 192.168.10.50 |

---

# Technologien

* Debian Linux
* Proxmox VE
* Hyper-V (Nested Virtualization)
* bind9 (DNS Server)
* Kea DHCPv4
* TrueNAS
* Apache2
* PHP 8.4
* MariaDB
* Nextcloud
* Docker & docker-compose
* Chrony (NTP)
* Portainer
* iptables / netfilter

---

# Router

* Debian Router
* NAT Gateway (LAN → WAN)
* iptables Firewall
* conntrack für stateful packet filtering

Dokumentation:

`docs/01-router.md`

---

# Virtualisierung

**Proxmox VE**

* Nested Virtualization
* Management Interface
* VM Hosting

Dokumentation:

`docs/02-proxmox.md`

---

# Server 1 (SRV1) 


* Debian VM in Proxmox

Dokumentation:

`docs/03-server1.md`

---

# DNS Server

* bind9
* interne Domain: `example.internal`
* Forwarding DNS

Dokumentation:

`docs/04-dns-bind9.md`

---

# DHCP Server

* Kea DHCPv4
* dynamischer Adresspool
* DNS Integration

Dokumentation:

`docs/05-dhcp-kea.md`

---

# Storage

* TrueNAS
* ZFS Storage Pools
* Netzwerkstorage

Dokumentation:

`docs/06-truenas.md`

---

# Server 2 (SRV2)

* Debian VM in Proxmox
* Apache2 Webserver & Virtual Hosts
* Nextcloud (PHP 8.4, MariaDB, SSL)
* iSCSI-Backup (rsync, cron)
* Docker & docker-compose
* Chrony NTP-Server
* Portainer (inkl. FreshRSS)
* Reverse Proxy & Portfreigabe

Dokumentation:

`docs/07-server2.md` – Basisinstallation

`docs/08-backup.md` – iSCSI-Backup & Automatisierung

`docs/09-apache.md` – Apache2 & vHosts

`docs/10-nextcloud.md` – Nextcloud Installation & HTTPS

`docs/11-docker.md` – Docker Installation

`docs/12-chrony-portainer.md` – Chrony, Portainer & FreshRSS

`docs/13-reverse-proxy.md` – Reverse Proxy & Portfreigabe

---

# Firewall Script

Stateful Firewall Policy:

```
scripts/fw_policy.sh
```

Features:

* Default-DROP Policy
* NAT Gateway
* HTTP/HTTPS Forward
* DNS Allow
* ICMP Diagnostics

---

# Backup Script

Automatisiertes iSCSI-Backup:

```
scripts/backup.sh
```

Features:

* iSCSI-Target einbinden (target02)
* rsync-Backup von `/var/www` und `/etc`
* Datumsstempel-Verzeichnis
* Target nach Backup sauber aushängen

---

# Netzwerkdiagramm

```
Internet
   │
┌─────────────┐
│ Router VM   │
│             │
│ 192.168.10.1│
└─────┬───────┘
      │
      │ Firmennetz (192.168.10.0/24)
      │
 ┌────┼───────────────┬─────────────┬─────────────┐
 │    │               │             │             │
 │ ┌─────────┐     ┌────────┐     ┌────────┐   ┌─────────┐
 │ │ Proxmox │     │ SRV1   │     │ SRV2   │   │ Storage │
 │ │   .10   │     │   .11  │     │   .13  │   │    .12  │
 │ └─────────┘     └────────┘     └────────┘   └─────────┘
 │
 └──── Admin-Client (Linux Mint)
       .50
```

---

# Architekturdiagramm

```
Physical Host (Remote Lab – Windows Server 2019 Datacenter)
│
└── Hyper-V
    │
    ├── Router VM
    │      → minimal Debian + iptables (NAT / Firewall)
    │
    ├── Proxmox VM
    │      → Hypervisor (Nested Virtualization)
    │      │
    │      ├── srv1 (pve100)
    │      │      → DNS + DHCP
    │      │
    │      └── srv2 (pve101)
    │             → Apache2, Nextcloud, Docker, Chrony, Portainer, iSCSI-Backup
    │
    ├── TrueNAS VM
    │      → File Server (Storage)
    │
    └── Linux Mint VM
           → Admin Client
```

# Lizenz

Dieses Repository dient ausschließlich Lern- und Demonstrationszwecken.
