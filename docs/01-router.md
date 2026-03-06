## Teil I: Installation Router-VM

### 1. VM-Setup

**Soll:** 
- Gen 2 VM
- Name "Router"
-  1024 MB RAM (dynamisch, mind. 512 MB)
-  1 vCPU
-  Erste NIC: an externem vSwitch (WAN/Internet)

**Ist:**
Identisch umgesetzt

### 2. OS-Installation

**Soll:** Debian 12.6.0-amd64-netinst
> aus lokalem Verzeichnis

**Ist:** Debian 13.2.0-amd64-netinst 
> `https://cdimage.debian.org/mirror/cdimage/archive/13.2.0/amd64/iso-cd/debian-13.2.0-amd64-netinst.iso`

**Grund:**
Aktuellere Software-Repos in Debian 13

### 3. Hardware & Sicherheit (Hyper-V)

**Soll:**

- Erste NIC: an externem vSwitch (WAN) – bereits aus VM-Setup vorhanden
- Zweite NIC an vSwitch „Firmennetz"
- Secure Boot aus
- RAM-Limits manuell nachjustieren (512–1024 MB)

**Ist:**
Identisch umgesetzt

### 4. Netzwerkkonfiguration (OS-Ebene)

**Soll:**
```
# /etc/network/interfaces
# eth0 = WAN (per DHCP vom Host/Internet)
allow-hotplug eth0
iface eth0 inet dhcp

# eth1 = LAN (Firmennetz, statisch)
allow-hotplug eth1
iface eth1 inet static
    address 192.168.10.1
    netmask 255.255.255.0
```
```bash
systemctl restart networking
```

**Ist:**
Identisch umgesetzt

### 5. IP-Forwarding (Kernel)

**Soll:**
```bash
echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf
sysctl -p
```

**Ist:**
```bash
echo "net.ipv4.ip_forward=1" >> /etc/sysctl.d/99-router.conf
sysctl -p /etc/sysctl.d/99-router.conf
```

**Grund:**
Arbeit mit Unterverzeichnis /etc/sysctl.d ist sauberer → eigene Einstellungen getrennt von Systemdefaults, bessere Fehlersuche, Schutz vor Update-Überschreibungen

### 6. Paketfilter-Vorbereitung

**Soll:**
```bash
apt install iptables -y
```

**Ist:**
Identisch umgesetzt

### 7. Firewall-Konfiguration (Paketfilter)

**Soll:**
Nur eine Zeile Masquerading:
```bash
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
```

**Ist:**
Implementierung eines Stateful-Firewall-Skripts 

`/scripts/fw_policy.sh`

**Grund:**

Es handelt sich um eine klassische Gateway-Firewall, die ausschließlich den externen (gerouteten) Verkehr kontrolliert und den internen Netzwerkverkehr nicht beeinflusst. Bei aktuell wenigen Diensten bleibt das Regelwerk überschaubar und nachvollziehbar.

### 8. Persistenz & Abschluss

**Soll:**
```bash
apt install iptables-persistent -y
netfilter-persistent save
reboot
```

**Ist:**
Identisch umgesetzt

### 9. Installation Client (Linux Mint)

**Soll:**
Client (Linux Mint) an vSwitch „Firmennetz" anschließen, IP manuell konfigurieren:
- IP: 192.168.10.50/24
- Gateway: 192.168.10.1
- DNS: 1.1.1.1

**Ist:**
Identisch umgesetzt

### 10. Konfiguration Virtualisierungshost (Hyper-V Support)

**Soll:**
```powershell
Set-VM -VMName CL01 -EnhancedSessionTransportType HvSocket
```

**Ist:**
Identisch umgesetzt

---
