#!/usr/bin/env bash
#|---/ /+--------------------------------------+---/ /|#
#|--/ /-| Script to apply post install configs |--/ /-|#
#|-/ /--| Prasanth Rangan                      |-/ /--|#
#|/ /---+--------------------------------------+/ /---|#

scrDir=$(dirname "$(realpath "$0")")
# shellcheck disable=SC1091
if ! source "${scrDir}/global_fn.sh"; then
    echo "Error: unable to source global_fn.sh..."
    exit 1
fi

cloneDir="${cloneDir:-$CLONE_DIR}"
flg_DryRun=${flg_DryRun:-0}
# sddm
if pkg_installed sddm; then
    print_log -c "[DISPLAYMANAGER] " -b "detected :: " "sddm"
    if [ ! -d /etc/sddm.conf.d ]; then
        [ ${flg_DryRun} -eq 1 ] || sudo mkdir -p /etc/sddm.conf.d
    fi
    if [ ! -f /etc/sddm.conf.d/backup_the_hyde_project.conf ] || [ "${HYDE_INSTALL_SDDM}" = true ]; then
        print_log -g "[DISPLAYMANAGER] " -b " :: " "configuring sddm..."
        print_log -g "[DISPLAYMANAGER] " -b " :: " "Select sddm theme:" -r "\n[1]" -b " Candy" -r "\n[2]" -b " Corners"
        read -p " :: Enter option number : " -r sddmopt

        case $sddmopt in
        1) sddmtheme="Candy" ;;
        *) sddmtheme="Corners" ;;
        esac

        if [[ ${flg_DryRun} -ne 1 ]]; then
            sudo tar -xzf "${cloneDir}/Source/arcs/Sddm_${sddmtheme}.tar.gz" -C /usr/share/sddm/themes/
            sudo touch /etc/sddm.conf.d/the_hyde_project.conf
            sudo cp /etc/sddm.conf.d/the_hyde_project.conf /etc/sddm.conf.d/backup_the_hyde_project.conf
            sudo cp /usr/share/sddm/themes/${sddmtheme}/the_hyde_project.conf /etc/sddm.conf.d/
            
            # Configure auto-login
            print_log -g "[DISPLAYMANAGER] " -b " :: " "configuring auto-login..."
            sudo tee -a /etc/sddm.conf.d/the_hyde_project.conf > /dev/null <<EOF

[Autologin]
User=${USER}
Session=hyprland
EOF
            print_log -g "[DISPLAYMANAGER] " -b " :: " "auto-login enabled for ${USER}"
        fi

        print_log -g "[DISPLAYMANAGER] " -b " :: " "sddm configured with ${sddmtheme} theme..."
    else
        print_log -y "[DISPLAYMANAGER] " -b " :: " "sddm is already configured..."
    fi

    if [ ! -f "/usr/share/sddm/faces/${USER}.face.icon" ] && [ -f "${cloneDir}/Source/misc/${USER}.face.icon" ]; then
        sudo cp "${cloneDir}/Source/misc/${USER}.face.icon" /usr/share/sddm/faces/
        print_log -g "[DISPLAYMANAGER] " -b " :: " "avatar set for ${USER}..."
    fi

else
    print_log -y "[DISPLAYMANAGER] " -b " :: " "sddm is not installed..."
fi

# dolphin
if pkg_installed dolphin && pkg_installed xdg-utils; then
    print_log -c "[FILEMANAGER] " -b "detected :: " "dolphin"
    xdg-mime default org.kde.dolphin.desktop inode/directory
    print_log -g "[FILEMANAGER] " -b " :: " "setting $(xdg-mime query default "inode/directory") as default file explorer..."

else
    print_log -y "[FILEMANAGER]" -b " :: " "dolphin is not installed..."
    print_log -y "[FILEMANAGER]" -b " :: " "Setting $(xdg-mime query default "inode/directory") as default file explorer..."
fi

# shell
"${scrDir}/restore_shl.sh"

# flatpak
if ! pkg_installed flatpak; then
    echo ""
    print_log -g "[FLATPAK]" -b " list :: " "flatpak application"
    awk -F '#' '$1 != "" {print "["++count"]", $1}' "${scrDir}/extra/custom_flat.lst"
    prompt_timer 60 "Install these flatpaks? [Y/n]"
    fpkopt=${PROMPT_INPUT,,}

    if [ "${fpkopt}" = "y" ]; then
        print_log -g "[FLATPAK]" -b " install :: " "flatpaks"
        [ ${flg_DryRun} -eq 1 ] || "${scrDir}/extra/install_fpk.sh"
    else
        print_log -y "[FLATPAK]" -b " skip :: " "flatpak installation"
    fi

else
    print_log -y "[FLATPAK]" -b " :: " "flatpak is already installed"
fi


# ddcutil - configure i2c for monitor brightness control
if pkg_installed ddcutil; then
    print_log -c "[DDCUTIL] " -b "detected :: " "ddcutil"
    
    # Load i2c-dev kernel module
    if ! lsmod | grep -q i2c_dev; then
        print_log -g "[DDCUTIL] " -b " :: " "loading i2c-dev kernel module..."
        if [ ${flg_DryRun} -eq 1 ]; then
            print_log -g "[DDCUTIL] " -b " :: " "would load i2c-dev module..."
        else
            sudo modprobe i2c-dev
        fi
    fi
    
    # Make i2c-dev load on boot
    if [ ! -f /etc/modules-load.d/i2c-dev.conf ]; then
        print_log -g "[DDCUTIL] " -b " :: " "configuring i2c-dev to load on boot..."
        if [ ${flg_DryRun} -eq 1 ]; then
            print_log -g "[DDCUTIL] " -b " :: " "would create /etc/modules-load.d/i2c-dev.conf..."
        else
            echo "i2c-dev" | sudo tee /etc/modules-load.d/i2c-dev.conf > /dev/null
        fi
    else
        print_log -y "[DDCUTIL] " -b " :: " "i2c-dev already configured"
    fi
    
    # Add user to i2c group
    if ! groups ${USER} | grep -q i2c; then
        print_log -g "[DDCUTIL] " -b " :: " "adding ${USER} to i2c group..."
        if [ ${flg_DryRun} -eq 1 ]; then
            print_log -g "[DDCUTIL] " -b " :: " "would add user to i2c group..."
        else
            sudo usermod -aG i2c ${USER}
            print_log -y "[DDCUTIL] " -b " :: " "You need to log out and back in for group changes to take effect"
        fi
    else
        print_log -y "[DDCUTIL] " -b " :: " "${USER} already in i2c group"
    fi
    
        print_log -g "[DDCUTIL] " -b " :: " "ddcutil configured. Test with: ddcutil detect"
    else
        print_log -y "[DDCUTIL] " -b " :: " "ddcutil is not installed..."
    fi

    
# mpv - install uosc, playlistmanager, and thumbfast scripts
if pkg_installed mpv; then
    print_log -c "[MPV] " -b "detected :: " "mpv"
    
    mpv_scripts_dir="${HOME}/.config/mpv/scripts"
    mpv_playlists_dir="${HOME}/.config/mpv/playlists"
    
    if [ ${flg_DryRun} -eq 1 ]; then
        print_log -g "[MPV] " -b " :: " "would install mpv scripts..."
    else
        # Create scripts and playlists directories if they don't exist
        mkdir -p "${mpv_scripts_dir}"
        mkdir -p "${mpv_playlists_dir}"
        print_log -g "[MPV] " -b " :: " "playlists directory created"
        
        print_log -g "[MPV] " -b " :: " "installing uosc..."
        if [ ! -f "${mpv_scripts_dir}/uosc.lua" ]; then
            curl -sL "https://github.com/tomasklaen/uosc/releases/latest/download/uosc.zip" -o /tmp/uosc.zip
            unzip -q /tmp/uosc.zip -d "${mpv_scripts_dir}"
            rm /tmp/uosc.zip
            print_log -g "[MPV] " -b " :: " "uosc installed"
        else
            print_log -y "[MPV] " -b " :: " "uosc already installed"
        fi
        
        print_log -g "[MPV] " -b " :: " "installing playlistmanager..."
        if [ ! -f "${mpv_scripts_dir}/playlistmanager.lua" ]; then
            curl -sL "https://raw.githubusercontent.com/jonniek/mpv-playlistmanager/master/playlistmanager.lua" \
                -o "${mpv_scripts_dir}/playlistmanager.lua"
            print_log -g "[MPV] " -b " :: " "playlistmanager installed"
        else
            print_log -y "[MPV] " -b " :: " "playlistmanager already installed"
        fi
        
        print_log -g "[MPV] " -b " :: " "installing thumbfast..."
        if [ ! -f "${mpv_scripts_dir}/thumbfast.lua" ]; then
            curl -sL "https://raw.githubusercontent.com/po5/thumbfast/master/thumbfast.lua" \
                -o "${mpv_scripts_dir}/thumbfast.lua"
            print_log -g "[MPV] " -b " :: " "thumbfast installed"
        else
            print_log -y "[MPV] " -b " :: " "thumbfast already installed"
        fi
        
        print_log -g "[MPV] " -b " :: " "mpv scripts installation complete"
    fi
else
    print_log -y "[MPV] " -b " :: " "mpv is not installed..."
fi

# neovim - install LazyVim and apply custom configs
if pkg_installed neovim; then
    print_log -c "[NEOVIM] " -b "detected :: " "neovim"
    
    nvim_config_dir="${HOME}/.config/nvim"
    # shellcheck disable=SC2154
    nvim_custom_dir="${cloneDir}/Configs/.config/nvim"
    
    if [ ${flg_DryRun} -eq 1 ]; then
        print_log -g "[NEOVIM] " -b " :: " "would install LazyVim..."
    else
        if [ ! -d "${nvim_config_dir}" ]; then
            print_log -g "[NEOVIM] " -b " :: " "installing LazyVim starter..."
            git clone https://github.com/LazyVim/starter "${nvim_config_dir}"
            rm -rf "${nvim_config_dir}/.git"
            print_log -g "[NEOVIM] " -b " :: " "LazyVim installed"
        else
            print_log -y "[NEOVIM] " -b " :: " "LazyVim already exists"
        fi
        
        # Overlay custom configs if they exist
        if [ -d "${nvim_custom_dir}" ]; then
            print_log -g "[NEOVIM] " -b " :: " "applying custom configs..."
            cp -r "${nvim_custom_dir}"/* "${nvim_config_dir}/"
            print_log -g "[NEOVIM] " -b " :: " "custom configs applied"
        fi
        
        print_log -y "[NEOVIM] " -b " :: " "Run 'nvim' to complete setup"
    fi
    else
        print_log -y "[NEOVIM] " -b " :: " "neovim is not installed..."
fi

# hyprland scripts - ensure proper permissions
if pkg_installed hyprland; then
    hypr_scripts_dir="${HOME}/.config/hypr/scripts"
    
    if [ -d "${hypr_scripts_dir}" ]; then
        print_log -c "[HYPRLAND] " -b "detected :: " "hyprland scripts"
        
        if [ ${flg_DryRun} -eq 1 ]; then
            print_log -g "[HYPRLAND] " -b " :: " "would make scripts executable..."
        else
            print_log -g "[HYPRLAND] " -b " :: " "making scripts executable..."
            chmod +x "${hypr_scripts_dir}"/*.sh 2>/dev/null
            print_log -g "[HYPRLAND] " -b " :: " "scripts permissions set"
        fi
    else
        print_log -y "[HYPRLAND] " -b " :: " "scripts directory not found"
    fi
else
    print_log -y "[HYPRLAND] " -b " :: " "hyprland is not installed..."
fi
