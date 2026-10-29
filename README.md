# Facehugger

Minimal bash toolkit for setting up SSHd on a chosen inbound port, configuring GitHub SSH over port 443, and cloning private repos on fresh/repaved Ubuntu images.

I find this useful when provisioning a fresh node or performing node repaving, where I need to establish SSH access and clone a private bootstrap repo without relying on SSH port 22.

Note: This is intended only for fresh Ubuntu instances. Existing SSH configuration may be changed, and existing SSH keys may trigger overwrite prompts.

Run the scripts in order -

### 01-setup-sshd.sh

Sets up SSHd on the Ubuntu node.

- Installs OpenSSH-Server
- Configures SSH to listen on a chosen port
- Disables root SSH login
- Validates the SSH config before applying it
- Enables and restarts the SSH service

Configure inbound SSH access (run as root or using sudo):

```bash
chmod +x 01-setup-sshd.sh
sudo ./01-setup-sshd.sh
```

Connect to the node over the chosen SSH port and verify access before closing your console session.

### 02-setup-github.sh

Sets up outbound GitHub SSH access and clones a repo.

- Installs Git and OpenSSH-Client
- Configures SSH to connect to GitHub over port 443
- Generates an Ed25519 SSH key and provides instructions for adding it to GitHub
- Tests SSH auth before proceeding
- Prompts for a GitHub repository in OWNER/REPO.git format and clones it locally
- Usage

Configure GitHub access (run as your normal sudo-capable administrator, not as root):

```bash
chmod +x 02-setup-github.sh
./02-setup-github.sh
```

Follow the prompts to add your public SSH key to GitHub, verify auth, and clone your repo.
