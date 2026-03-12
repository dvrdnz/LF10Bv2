## Teil XI: Docker auf SRV2

### 1. Docker-Repository einrichten

**Soll:**
```bash
sudo apt update
sudo apt install ca-certificates curl -y
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] \
  https://download.docker.com/linux/debian \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update
```

**Ist:**
Identisch umgesetzt.

---

### 2. Docker installieren

**Soll:**
```bash
sudo apt install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y
```

**Ist:**
Identisch umgesetzt.

---

### 3. Installation prüfen

**Soll:**
```bash
sudo docker run hello-world
```

**Ist:**
Identisch umgesetzt.

---

### 4. Benutzer zur Docker-Gruppe hinzufügen

**Soll:**
```bash
sudo usermod -aG docker <benutzername>
```
Anschließend ab- und wieder anmelden.

**Ist:**
Identisch umgesetzt.
