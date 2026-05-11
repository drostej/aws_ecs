# Erforderliche Tools für infrastructure/docs

Diese Tools werden benötigt, um die Beispiele und Anleitungen in den Dokumentationen auszuführen.

## 0. AWS Sandbox

https://sandbox-service.shared.services.aws.de.pri.o2.com/home




## 1. Terraform / OpenTofu

Infrastructure as Code Tool für AWS-Ressourcen.

***Wichtig:*** Bitte ***NUR** OpenTofu verwenden,es ist ein Fork von Terraform der
noch ohne Lizenzabhängeiten verwendet wird. Die terraform Aufrufe stehen hier zum ganzheitlichen Verständnis, da
in Karriereportalen und Umgangssprachich immer von Terraform gesprochen wird.

### macOS
```bash
brew install terraform
# oder
brew install opentofu
```

### Arch Linux
```bash
# Terraform
sudo pacman -S terraform

# OpenTofu
yay -S opentofu-bin
# oder
sudo pacman -S opentofu
```

### Debian/Ubuntu
```bash

***Achtun

# Terraform
wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install terraform

# OpenTofu
curl --proto '=https' --tlsv1.2 -fsSL https://get.opentofu.org/install-opentofu.sh -o install-opentofu.sh
chmod +x install-opentofu.sh
./install-opentofu.sh --install-method deb
```

---

## 2. AWS CLI

Command-Line Interface für AWS Services.

### macOS
```bash
brew install awscli
```

### Arch Linux
```bash
sudo pacman -S aws-cli
```

### Debian/Ubuntu
```bash
sudo apt update
sudo apt install awscli
```

---

## 3. Docker

Container-Runtime für Image-Management und Registry-Push.

### macOS
```bash
brew install --cask docker
```

### Arch Linux
```bash
sudo pacman -S docker
sudo systemctl enable docker
sudo systemctl start docker
sudo usermod -aG docker $USER
```

### Debian/Ubuntu
```bash
# Docker Repository hinzufügen
sudo apt update
sudo apt install ca-certificates curl gnupg
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Docker installieren
sudo apt update
sudo apt install docker-ce docker-ce-cli containerd.io

# User zu docker Gruppe hinzufügen
sudo usermod -aG docker $USER
```

---

## Übersicht: Welches Tool wird wo benötigt?

| Tool | Verwendet in | Zweck |
|------|-------------|-------|
| **terraform/tofu** | 10state, 20ecr, 30ecs_log-group_role | Infrastructure as Code |
| **aws cli** | 10state, 40app_zu_docker_push | AWS API Zugriff, ECR Login |
| **docker** | 40app_zu_docker_push | Image Management & Push zu ECR |

---

## Konfiguration nach Installation

### AWS Credentials einrichten

Siehe `10state/readme.md` für Details zur Konfiguration von:
- `~/.aws/credentials`
- `~/.aws/config`
- AWS Profile Setup
