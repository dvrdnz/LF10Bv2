# LF10Bv2
Dieses Repository dokumentiert ein Infrastruktur-Lab aus dem Lernfeld **LF10Bv2 – Serverdienste bereitstellen und Administrationsaufgaben automatisieren**.

Das Setup bildet eine kleine Unternehmensumgebung nach.

## Komponenten

* Debian Router (NAT Gateway + Firewall)
* Virtualisierungshost (Proxmox VE)
* Debian Server (DNS + DHCP)
* Storage-System (TrueNAS)
* Linux Client (Linux Mint)

Ziel des Labs ist die praktische Umsetzung grundlegender Server- und Netzwerkdienste.

---

# Architektur

Netzwerk: `192.168.10.0/24`

| Host    | Funktion             | IP            |
| ------- | -------------------- | ------------- |
| router  | Gateway / Firewall   | 192.168.10.1  |
| proxmox | Virtualisierungshost | 192.168.10.10 |
| srv1    | DNS + DHCP Server    | 192.168.10.11 |
| storage | TrueNAS Storage      | 192.168.10.12 |
| client  | Linux Mint Client    | 192.168.10.50 |

---

# Technologien

* Debian Linux
* Proxmox VE
* Hyper-V (Nested Virtualization)
* bind9 (DNS Server)
* Kea DHCPv4
* TrueNAS
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

# DNS Server

* bind9
* interne Domain: `gfn.internal`
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

# Netzwerkdiagramm

```
Internet
   │
┌───────────┐
│  Router   │
│ Debian    │
│ 192.168.10.1
└─────┬─────┘
      │
      │ Firmennetz (192.168.10.0/24)
      │
 ┌────┼───────────────┬─────────────┐
 │    │               │             │
 │ ┌───────┐     ┌────────┐     ┌─────────┐
 │ │Proxmox│     │ SRV1   │     │ TrueNAS │
 │ │.10    │     │ DNS    │     │ Storage │
 │ │       │     │ .11    │     │ .12     │
 │ └───────┘     └────────┘     └─────────┘
 │
 └──── Admin-Client (Linux Mint)
       .50
```

---

# Lizenz

Dieses Repository dient ausschließlich Lern- und Demonstrationszwecken.
