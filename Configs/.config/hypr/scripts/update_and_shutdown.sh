#!/bin/bash
# Interactive Update and Shutdown script
clear
echo "========================================"
echo "    SYSTEM UPDATE AND SHUTDOWN"
echo "========================================"
echo ""
echo "This will:"
echo "1. Update system packages"
echo "2. Update AUR packages (if paru is available)"
echo "3. Update Flatpak packages (if available)"
echo "4. Clean package cache"
echo "5. Remove orphaned packages"
echo "6. Clean journal logs"
echo "7. Shutdown the system"
echo ""
echo "========================================"
echo ""
# Ask for confirmation
read -p "Do you want to continue? (y/N): " -n 1 -r
echo ""
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
	echo "Operation cancelled."
	exit 1
fi
# Pre-authenticate sudo
sudo -v || {
	echo "Authentication failed. Exiting."
	exit 1
}
# Update system packages
sudo pacman -Sy archlinux-keyring --noconfirm && sudo pacman -Syu --noconfirm || {
	echo "System update failed!"
	exit 1
}
# Update AUR packages
if command -v paru >/dev/null; then
	paru -Sua --noconfirm --skipreview --cleanafter --removemake --needed --sudoloop
fi
# Update Flatpak packages
if command -v flatpak >/dev/null; then
	flatpak update -y --noninteractive
fi
# Update Snap packages
if command -v snap >/dev/null; then
	sudo snap refresh
fi
# Clean package cache
sudo paccache -rk1 -ruk0
# Clean AUR cache
if command -v paru >/dev/null; then
	paru -Sc --noconfirm
fi
# Remove orphaned packages
orphans=$(pacman -Qtdq 2>/dev/null)
if [[ -n $orphans ]]; then
	sudo pacman -Rns $orphans --noconfirm 2>/dev/null
fi
# Clean journal logs
sudo journalctl --vacuum-time=2weeks --quiet
# Update file database
sudo updatedb
# Refresh font cache
fc-cache -fv >/dev/null
# Clean temporary files
sudo find /tmp /var/tmp -type f -atime +7 -delete 2>/dev/null
# Sync filesystems
sync
# Shutdown immediately
sudo shutdown -h now
