#!/bin/bash

echo " ____________________________________________________________________________ " 
echo "|                                                                            |"
echo "| [+]                   Installing Tools | Please Wait                  [+] |"
echo "|____________________________________________________________________________|" 

sudo apt-get install git

sudo mkdir ~/Desktop/Tools
cd ~/Desktop/Tools
git clone https://github.com/v1s1t0r1sh3r3/airgeddon.git
git clone https://github.com/Screetsec/TheFatRat.git
git clone https://github.com/LionSec/xerosploit
cd xerosploit && sudo python install.py

sudo wget https://github.com/google/fonts/archive/master.zip -P ~/.local/share/fonts/
cd ~/.local/share/fonts/
sudo unzip master.zip
cp -r /fonts-master/ofl* ~/.local/share/fonts/
sudo rm master.zip
sudo rm -r fonts-master

cd ~

git clone --depth=1 https://github.com/amix/vimrc.git ~/.vim_runtime
sh ~/.vim_runtime/install_awesome_vimrc.sh

echo " ____________________________________________________________________________ " 
echo "|                                                                            |"
echo "| [+]                 Installing Packages | Please Wait!                 [+] |"
echo "|____________________________________________________________________________|" 

sudo add-apt-repository ppa:alexlarsson/flatpak
sudo apt update
sudo apt install flatpak
sudo apt install gnome-software-plugin-flatpak
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
sudo apt install plank
sudo apt-get install vim
sudo snap install telegram-desktop
sudo add-apt-repository ppa:dawidd0811/neofetch
sudo apt-get update
sudo apt-get update install neofetch
sudo apt-get install terminator
sudo apt-get install vlc

sudo snap install sublime-text --classic
sudo snap install postman
sudo snap install atom --classic
sudo snap install android-studio --classic
sudo snap install intellij-idea-community --classic
sudo snap install powershell --classic
sudo snap install brackets --classic
sudo snap install go --classic
sudo snap install code --classic
sudo snap install ruby --classic
sudo snap install deno
sudo snap install mysql-workbench-community
sudo snap install arduino
sudo snap install slack --classic
sudo snap install skype --classic
sudo snap install chromium
sudo snap install brave
sudo snap install firefox
sudo snap install opera
sudo snap install htop
sudo snap install ghex-udt
sudo snap install handbrake-jz
sudo snap install obs-studio
sudo snap install audacity
sudo snap install inkscape
sudo snap install figma-linux
sudo snap install zeplin-lukewh
sudo snap install mockuuups
sudo snap install discord
sudo snap install beekeeper-studio
sudo snap install drawio