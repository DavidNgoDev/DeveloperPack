#!/bin/bash
sudo mkdir ~/.local/share/fonts

sudo pacman -S alsa-utils pulseaudio cups pulseaudio-alsa unzip wget maim feh xclip chromium flatpak imagemagick blueman redshift xfce4-power-manager upower noto-fonts-emoji xdg-user-dirs iproute2 iw ffmpeg kitty neovim termite ncmpcpp mpd mpc lollypop vlc qutebrowser neofetch htop atom neovim kubectl gimp inkscape clamav clamtk net-tools arch-audit firewalld krita tmux virtualbox latte-dock plank awesome-git rofi pulseeffects
sudo mkdir ~/Pictures/Wallpapers
sudo wget https://i.redd.it/587a3w75p1b51.png -P ~/Pictures/Wallpapers
sudo wget https://i.redd.it/cm2l9qq30yz41.png -P ~/Pictures/Wallpapers
sudo wget https://i.redd.it/rhu9xgqq9i351.jpg -P ~/Pictures/Wallpapers
sudo wget https://i.redd.it/nvsf29d135051.jpg -P ~/Pictures/Wallpapers
sudo wget https://i.redd.it/fiyjtl1rtoi51.jpg -P ~/Pictures/Wallpapers
sudo wget https://i.redd.it/3iwpgz1c9hh41.jpg -P ~/Pictures/Wallpapers
sudo wget https://i.redd.it/btqplv4tonv31.png -P ~/Pictures/Wallpapers
sudo wget https://i.redd.it/nvy8b1m6ii751.png -P ~/Pictures/Wallpapers
sudo wget https://i.redd.it/tizoc0t311c51.png -P ~/Pictures/Wallpapers
sudo wget https://i.redd.it/73mt4aji81831.png -P ~/Pictures/Wallpapers
sudo wget https://i.redd.it/qqjhrf0io4c51.png -P ~/Pictures/Wallpapers
sudo wget https://github.com/google/fonts/archive/master.zip -P ~/.local/share/fonts/
cd ~/.local/share/fonts/
sudo unzip master.zip
cp -r /fonts-master/ofl* ~/.local/share/fonts/
sudo rm master.zip
sudo rm -r fonts-master

flatpak install flathub com.spotify.Client

yay -S spicetify-cli
yay -S polybar
yay -S nerd-fonts-complete

sudo fc-cache -v

sudo chmod a+wr /opt/spotify
sudo chmod a+wr /opt/spotify/Apps -R

sudo pacman -Rs unzip

git clone --depth=1 https://github.com/amix/vimrc.git ~/.vim_runtime
sh ~/.vim_runtime/install_awesome_vimrc.sh

sudo snap install spt
sudo snap install code --classic
sudo snap install notepadqq
sudo snap install audacity
sudo snap install sublime-text --classic
sudo snap install postman
sudo snap install android-studio --classic
sudo snap install powershell --classic
sudo snap install brackets --classic
sudo snap install jupyter
sudo snap install librepcb
sudo snap install freecad
sudo snap install skype --classic
sudo snap install drawio
sudo snap install teams-for-linux
sudo snap install slack --classic
sudo snap install discord
sudo snap install shotcut --classic
sudo snap install beekeeper-studio

sudo freshclam
sudo systemctl start clamav-freshclam.service
sudo systemctl enable clamav-freshclam.service
sudo systemctl start clamav-daemon.service
sudo systemctl enable clamav-daemon.service
sudo systemctl start firewalld
sudo systemctl enable firewalld
sudo systemctl stop	sshd
sudo systemctl disable sshd
arch-audit