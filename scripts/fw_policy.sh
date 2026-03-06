#!/bin/bash

################################ Firewall Policy Script (iptables) ###############################
#
# Rolle:
#   Debian Router / Gateway zwischen LAN und WAN
#
# Netzwerkschnittstellen:
#   WAN_IF = Internet / externes Netz
#   LAN_IF = internes Netzwerk
#
# Sicherheitskonzept:
#   - Default-Deny Prinzip
#   - Stateful Packet Inspection mit conntrack
#   - NAT (Masquerading) für private LAN-Adressen
#   - Minimale erlaubte Dienste (HTTP, HTTPS, DNS, ICMP)
##################################################################################################

################################ INTERFACE-DEFINITIONEN ###############################

WAN_IF="eth0"
LAN_IF="eth1"


################################ RESET ###############################

# Alle bestehenden Regeln der Filter-Tabelle löschen
/usr/sbin/iptables -F

# Alle benutzerdefinierten Chains löschen
/usr/sbin/iptables -X

# Paket- und Byte-Zähler zurücksetzen
/usr/sbin/iptables -Z

# NAT-Tabelle zurücksetzen
/usr/sbin/iptables -t nat -F
/usr/sbin/iptables -t nat -X


################################ DEFAULT POLICIES ###############################

# Eingehender Verkehr zum Router wird standardmäßig blockiert
/usr/sbin/iptables -P INPUT DROP

# Weitergeleiteter Verkehr wird ebenfalls blockiert
/usr/sbin/iptables -P FORWARD DROP

# Ausgehender Verkehr vom Router selbst ist erlaubt
/usr/sbin/iptables -P OUTPUT ACCEPT


################################ LOOPBACK INTERFACE ###############################

# Lokale Kommunikation innerhalb des Systems erlauben
/usr/sbin/iptables -A INPUT -i lo -j ACCEPT


################################ STATEFUL PACKET INSPECTION ###############################

# Bereits etablierte oder zugehörige Verbindungen erlauben
/usr/sbin/iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT


################################ ICMP KOMMUNIKATION IM LAN ###############################

# ICMP (z.B. Ping) vom LAN zum Router erlauben
/usr/sbin/iptables -A INPUT -i $LAN_IF -p icmp -j ACCEPT

# ICMP vom LAN ins Internet weiterleiten
/usr/sbin/iptables -A FORWARD -i $LAN_IF -o $WAN_IF -p icmp -j ACCEPT


################################ NETWORK ADDRESS TRANSLATION ###############################

# Masquerading: Private LAN-Adressen werden beim Verlassen über das WAN-Interface durch die öffentliche Router-IP ersetzt.
/usr/sbin/iptables -t nat -A POSTROUTING -o $WAN_IF -j MASQUERADE


################################ RÜCKVERKEHR ERLAUBEN ###############################

# Antwortpakete bestehender Verbindungen dürfen zurück ins LAN 
/usr/sbin/iptables -A FORWARD -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT


################################ LAN → INTERNET (WEBZUGRIFF) ###############################

# HTTP-Verbindungen erlauben
/usr/sbin/iptables -A FORWARD -i $LAN_IF -o $WAN_IF -p tcp --dport 80 -m conntrack --ctstate NEW -j ACCEPT

# HTTPS-Verbindungen erlauben
/usr/sbin/iptables -A FORWARD -i $LAN_IF -o $WAN_IF -p tcp --dport 443 -m conntrack --ctstate NEW -j ACCEPT


############################### ICMP LAN → WAN ###############################

# Neue ICMP-Verbindungen vom LAN ins Internet erlauben
/usr/sbin/iptables -A FORWARD -i $LAN_IF -o $WAN_IF -p icmp -m conntrack --ctstate NEW -j ACCEPT

############################### # DNS VERKEHR (LAN → INTERNET) ###############################
# DNS-Weiterleitung wird zunächst nicht erlaubt, da das Einrichten eines eigenen DNS-Servers Teil der Aufgabenstellung ist.
# Die Freigabe von Port 53 erfolgt erst zu Beginn der Konfiguration von SRV1, um die Funktionsweise und Abhängigkeit
# des Netzwerks von einem korrekt eingerichteten DNS-Dienst demonstrieren zu können.
