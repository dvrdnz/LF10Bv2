## Teil II: Installation Virtualisierungshost

### 1. VM-Setup (Proxmox)

**Soll:**

- Gen 2 VM
- Name: „Proxmox"
- 4096 MB RAM (fest)
- 4 vCPUs
- vSwitch: „Firmennetz"
- HDD: 250 GB (VHDX, dynamisch erweiterbar)


**Ist:**
Identisch umgesetzt

### 2. OS-Installation (Proxmox)

**Soll:**
- ISO: proxmox-ve_8.2-1.iso 
> aus lokalem ISO-Ordner

**Ist:**
- ISO: proxmox-ve_9.1-1.iso
> `https://enterprise.proxmox.com/iso/proxmox-ve_9.1-1.iso`

**Grund:**
Aktuellste stabile Version

### 3. Hardware-Optimierung (Verschachtelte Virtualisierung)

**Soll:**

Secure Boot deaktivieren
4 vCPUs
MAC-Spoofing für Netzwerkkarte aktivieren

**Ist:**
Identisch umgesetzt


### 4. Aktivierung Virtualisierungserweiterungen (Host)

**Soll:**
```powershell
Set-VMProcessor -VMName Proxmox -ExposeVirtualizationExtensions $true
```

**Ist:**
Identisch umgesetzt

### 5. Netzwerkkonfiguration (Proxmox-Installer)

**Soll:**

- Management Interface: `eth0`
- Hostname (FQDN): `pve.example.internal`
- IP: 192.168.10.10/24
- GW: 192.168.10.1
- DNS: 1.1.1.1

**Ist:**
Identisch umgesetzt

### 6. Management-Zugriff

**Soll:**
Nach Abschluss der Installation Proxmox-Weboberfläche im Browser des Clients aufrufen:
`https://192.168.10.10:8006`
Hyper-V-Session anschließend schließen.

**Ist:**
Ergänzung in fw_policy.sh auf Router-VM – Portweiterleitung für externen RDP-Zugriff auf den Admin-Client:
```bash
cat << 'EOF' >> ./scripts/fw_policy.sh
### RDP-Zugriff aus dem VPN-Netz auf den Admin-Client
/usr/sbin/iptables -t nat -A PREROUTING -i $WAN_IF -p tcp --dport 3389 -j DNAT --to-destination 192.168.10.50:3389
/usr/sbin/iptables -A FORWARD -p tcp -d 192.168.10.50 --dport 3389 -m conntrack --ctstate NEW -j ACCEPT
EOF
# Skript erneut ausführen
./scripts/fw_policy.sh
```
`https://192.168.10.10:8006` ist erreichbar.

**Grund:**
So kann ohne Umweg über das RemoteLab direkt auf den Admin-Client zugegriffen werden.

---
