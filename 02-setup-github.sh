#!/bin/bash
set -Eeuo pipefail
echo
echo
if [[ "$EUID" -eq 0 ]]; then
    echo "ERROR: Run this script as your normal sudo-capable administrator, not as root or using sudo."
    exit 1
fi
echo
echo "This script is intended ONLY for fresh Ubuntu images."
echo "It installs Git and OpenSSH-Client, and configures ssh/config git over port 443."
echo
echo "Existing ~/.ssh/config will be overwritten."
echo "An existing ~/.ssh/id_ed25519 key may also trigger an overwrite prompt."
echo
echo "If you wish to continue, press ENTER. Otherwise CTRL+C"
echo
read -e
echo
echo "Installing Git and OpenSSH-Client..."
echo
sudo apt-get update
sudo apt-get install -y git openssh-client
echo
echo "Installation complete."
echo
echo
echo "Git version: "
git --version
echo
echo
echo "OpenSSH-Client version: "
ssh -V
echo
echo
echo
echo "Configuring SSH-Client for GitHub..."
echo
mkdir -p ~/.ssh
chmod 700 ~/.ssh
cat > ~/.ssh/config <<'EOF'
Host github.com
    HostName ssh.github.com
    Port 443
    User git
EOF
chmod 600 ~/.ssh/config
echo
echo "Generating SSH Key..."
echo
ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519
echo
echo "Please copy this SSH Key to GitHub:  "
echo
echo "https://github.com/settings/ssh/new"
echo
cat ~/.ssh/id_ed25519.pub
echo
echo
read -r -p "Press ENTER once you have added the public key to GitHub: "
echo
echo
echo "Testing authentication..."
echo
SSH_OUTPUT=$(ssh -T git@github.com 2>&1) || true
echo "$SSH_OUTPUT"
if [[ "$SSH_OUTPUT" == *"successfully authenticated"* ]]; then
    echo "GitHub authentication successful."
else
    echo "ERROR: GitHub authentication failed."
    echo "Check that your public key has been added to GitHub."
    exit 1
fi
echo
echo
read -r -p "Enter repository [OWNER/REPO.git]: " REPO
if [[ ! "$REPO" =~ ^[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+\.git$ ]]; then
    echo "Invalid repository format."
    exit 1
fi
echo
REPO_DIR="${REPO##*/}"
REPO_DIR="${REPO_DIR%.git}"

if [[ -e "$REPO_DIR" ]]; then
    echo "ERROR: Destination already exists: $REPO_DIR"
    exit 1
fi
git clone "git@github.com:$REPO"
echo
echo "Cloned Repo $REPO"
echo
ls -ld -- "$REPO_DIR"
echo
