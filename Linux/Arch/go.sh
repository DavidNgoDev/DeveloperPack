#!/bin/bash
sudo pacman -Syu
sudo pacman -Syyy
sudo pacman -S xf86-video-fbdev xorg xorg-xinit nitrogen picom alacritty firefox base-devel wpa_supplicant wireless_tools netctl
git clone https://aur.archlinux.org/yay-git.git
cd yay-git/
makepkg -si
sudo pacman -S plasma plasma-wayland-session kde-applications
sudo systemctl enable sddm.service
git clone https://aur.archlinux.org/snapd.git
cd snapd
makepkg -si
sudo systemctl enable --now snapd.socket
sudo ln -s /var/lib/snapd/snap /snap

echo "Done. You may want to reboot for everything to take affect."
reboot