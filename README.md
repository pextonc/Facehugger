# Facehugger

A minimal bash script for quickly setting up GitHub SSH access over port 443 and cloning private repos on fresh/repaved Ubuntu images.

I find this useful when provisioning a fresh node or performing node repaving, where I need to clone a private bootstrap repository without relying on SSH port 22.

Note: This is intended only for fresh Ubuntu instances. Existing SSH keys/config may be changed.

- Installs Git and OpenSSH-Client
- Configures SSH to connect to GitHub over port 443
- Generates an Ed25519 SSH key and provides instructions for adding it to GitHub
- Tests SSH authentication before proceeding
- Prompts for a GitHub repository in OWNER/REPO.git format and clones it locally

## Usage

```bash
./facehugger.sh
```
