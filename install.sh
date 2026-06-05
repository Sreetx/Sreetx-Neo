#!/bin/bash

# Sreetx-Neo-Dots Installer Script
# Target: Arch Linux / CachyOS

set -e

# Efek warna terminal
GREEN="\e[32m"
YELLOW="\e[33m"
CYAN="\e[36m"
ENDCOLOR="\e[0m"

echo -e "${CYAN}===========================================${ENDCOLOR}"
echo -e "${GREEN}    Sreetx-Neo Hyprland Dots Installer     ${ENDCOLOR}"
echo -e "${CYAN}===========================================${ENDCOLOR}"

# 1. Deteksi AUR Helper (yay/paru)
if command -v yay &> /dev/null; then
    AUR_HELPER="yay"
elif command -v paru &> /dev/null; then
    AUR_HELPER="paru"
else
    echo -e "${YELLOW}[!] AUR helper (yay/paru) tidak ditemukan.${ENDCOLOR}"
    read -p "Install yay otomatis? (y/n): " temp_aur
    if [[ $temp_aur =~ ^[Yy]$ ]]; then
        sudo pacman -S --needed base-devel git
        git clone https://aur.archlinux.org/yay.git /tmp/yay
        cd /tmp/yay && makepkg -si --noconfirm && cd -
        AUR_HELPER="yay"
    else
        echo -e "${YELLOW}[-] Membatalkan installer. Butuh AUR helper untuk paket GIT.${ENDCOLOR}"
        exit 1
    fi
fi

# 2. Daftar Paket Repo Resmi (Pacman)
DEPENDENCIES=(
    "python" 
    "blueman" 
    "pavucontrol" 
    "jq" 
    "hyprland" 
    "rofi" 
    "rofimoji"
    "fish" 
    "cliphist" 
    "grim" 
    "wtype" 
    "wl-clipboard"
    "swww" 
    "slurp"
)

# Daftar Paket dari AUR
AUR_DEPENDENCIES=(
    "quickshell-git"
    "grimblast-git"
)

echo -e "\n${CYAN}[*] Menginstall dependensi dari repositori resmi...${ENDCOLOR}"
$AUR_HELPER -S --needed --noconfirm "${DEPENDENCIES[@]}"

echo -e "\n${CYAN}[*] Menginstall komponen dari AUR...${ENDCOLOR}"
$AUR_HELPER -S --needed --noconfirm "${AUR_DEPENDENCIES[@]}"

# 3. Proses Deployment / Penyalinan Config ke ~/.config
CONFIG_DIR="$HOME/.config"
mkdir -p "$CONFIG_DIR"

# List folder yang tertera pada repo Sreetx-Neo
FOLDERS=("Sreetx-Neo" "fish" "hypr" "rofi")

echo -e "\n${CYAN}[*] Menyalin konfigurasi ke $CONFIG_DIR...${ENDCOLOR}"

for folder in "${FOLDERS[@]}"; do
    if [ -d "$folder" ]; then
        # Jika folder target sudah ada di ~/.config, buat backup biar aman
        if [ -d "$CONFIG_DIR/$folder" ]; then
            echo -e "${YELLOW}[!] Menemukan config $folder lama. Membuat backup...${ENDCOLOR}"
            mv "$CONFIG_DIR/$folder" "$CONFIG_DIR/${folder}_backup_$(date +%F_%T)"
        fi
        
        echo -e "${GREEN}[+] Menyalin folder $folder -> $CONFIG_DIR/$folder${ENDCOLOR}"
        cp -r "$folder" "$CONFIG_DIR/"
    else
        echo -e "${YELLOW}[!] Peringatan: Folder $folder tidak ditemukan di direktori saat ini.${ENDCOLOR}"
    fi
done

# 4. Finishing Touch
echo -e "\n${GREEN}===========================================${ENDCOLOR}"
echo -e "${GREEN}    Instalasi Sreetx-Neo Dots Selesai!     ${ENDCOLOR}"
echo -e "${CYAN}    Silakan log out dan masuk ke Hyprland.   ${ENDCOLOR}"
echo -e "${GREEN}===========================================${ENDCOLOR}"
