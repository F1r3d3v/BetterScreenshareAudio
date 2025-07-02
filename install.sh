#!/usr/bin/env bash

# BetterDiscord Installation Script
# Author: F1r3d3v
# Description: Automated installer for BetterDiscord with Discord version selection

set -e  # Exit on any error

readonly SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

# Colors for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly PURPLE='\033[0;35m'
readonly CYAN='\033[0;36m'
readonly WHITE='\033[1;37m'
readonly NC='\033[0m' # No Color

# ASCII Art
display_ascii_art() {
    echo -e "${CYAN}"
    cat << "EOF"
______      _   _           ______ _                       _ 
| ___ \    | | | |          |  _  (_)                     | |
| |_/ / ___| |_| |_ ___ _ __| | | |_ ___  ___ ___  _ __ __| |
| ___ \/ _ \ __| __/ _ \ '__| | | | / __|/ __/ _ \| '__/ _` |
| |_/ /  __/ |_| ||  __/ |  | |/ /| \__ \ (_| (_) | | | (_| |
\____/ \___|\__|\__\___|_|  |___/ |_|___/\___\___/|_|  \__,_|                                                    
  ___        _       _____          _        _ _             
 / _ \      | |     |_   _|        | |      | | |            
/ /_\ \_   _| |_ ___  | | _ __  ___| |_ __ _| | | ___ _ __   
|  _  | | | | __/ _ \ | || '_ \/ __| __/ _` | | |/ _ \ '__|  
| | | | |_| | || (_) || || | | \__ \ || (_| | | |  __/ |     
\_| |_/\__,_|\__\___/\___/_| |_|___/\__\__,_|_|_|\___|_|     
                                                                                                                       
EOF
    echo -e "${NC}"
    echo -e "${WHITE}🎮 BetterDiscord Automated Installer 🎮${NC}"
    echo -e "${PURPLE}═══════════════════════════════════════════════════════════════${NC}"
    echo ""
}

# Function to display what the script will do
display_actions() {
    echo -e "${YELLOW}📋 This script will perform the following actions:${NC}"
    echo -e "${WHITE}  1. ${BLUE}Check if pnpm is installed${NC}"
    echo -e "${WHITE}  2. ${BLUE}Clone BetterDiscord repository from GitHub${NC}"
    echo -e "${WHITE}  3. ${BLUE}Install dependencies${NC}"
    echo -e "${WHITE}  4. ${BLUE}Let you choose Discord version (Normal/Canary/PTB)${NC}"
    echo -e "${WHITE}  5. ${BLUE}Install BetterDiscord for your chosen version${NC}"
    echo -e "${WHITE}  6. ${BLUE}Copy BetterScreenshareAudio plugin to BetterDiscord${NC}"
    echo ""
    echo -e "${PURPLE}═══════════════════════════════════════════════════════════════${NC}"
    echo ""
}

# Function to check if pnpm is installed
check_pnpm() {
    echo -e "${CYAN}🔍 Checking for pnpm installation...${NC}"
    if ! command -v pnpm &> /dev/null; then
        echo -e "${RED}❌ pnpm is not installed!${NC}"
        echo -e "${YELLOW}📦 Please install pnpm first using one of these methods:${NC}"
        echo -e "${WHITE}  • npm install -g pnpm${NC}"
        echo -e "${WHITE}  • curl -fsSL https://get.pnpm.io/install.sh | sh -${NC}"
        echo -e "${WHITE}  • Visit: https://pnpm.io/installation${NC}"
        echo ""
        echo -e "${RED}Please install pnpm and run this script again.${NC}"
        exit 1
    else
        echo -e "${GREEN}✅ pnpm is installed ($(pnpm --version))${NC}"
    fi
}

# Function to clone repository
clone_repository() {
    local repo_url="https://github.com/F1r3d3v/BetterDiscord"
    local repo_dir="BetterDiscord"
    
    if [ -d "$repo_dir" ]; then
        echo -e "${YELLOW}📁 Directory '$repo_dir' already exists.${NC}"
        echo -e "${CYAN}� Pulling latest changes...${NC}"
        cd "$repo_dir"
        
        if git pull origin main 2>/dev/null; then
            echo -e "${GREEN}✅ Repository updated successfully${NC}"
        else
            echo -e "${RED}❌ Failed to pull latest changes${NC}"
            echo -e "${YELLOW}🔄 The repository directory may be corrupted or not a valid git repository.${NC}"
            echo -e "${YELLOW}⚠️  To fix this, the existing directory needs to be removed and re-cloned.${NC}"
            echo ""
            read -p "$(echo -e ${CYAN}Do you want to remove the existing directory and re-clone? [y/N]: ${NC})" remove_confirm
            case $remove_confirm in
                [Yy]*)
                    echo -e "${CYAN}🗑️  Removing existing directory...${NC}"
                    cd ..
                    rm -rf "$repo_dir"
                    
                    if git clone --depth 1 --branch main --single-branch --recurse-submodules "$repo_url"; then
                        echo -e "${GREEN}✅ Repository cloned successfully${NC}"
                        cd "$repo_dir"
                    else
                        echo -e "${RED}❌ Failed to clone repository${NC}"
                        exit 1
                    fi
                    ;;
                *)
                    echo -e "${RED}❌ Cannot proceed without a clean repository${NC}"
                    echo -e "${YELLOW}Please manually fix the repository or remove the directory and run the script again.${NC}"
                    exit 1
                    ;;
            esac
        fi
    else
        echo -e "${CYAN}📥 Cloning BetterDiscord repository...${NC}"
        echo -e "${WHITE}Repository: ${repo_url}${NC}"
        
        if git clone --depth 1 --branch main --single-branch --recurse-submodules "$repo_url"; then
            echo -e "${GREEN}✅ Repository cloned successfully${NC}"
            cd "$repo_dir"
        else
            echo -e "${RED}❌ Failed to clone repository${NC}"
            exit 1
        fi
    fi
}

# Function to install dependencies
install_dependencies() {
    echo -e "${CYAN}📦 Installing dependencies...${NC}"
    echo -e "${WHITE}Command: pnpm install${NC}"
    
    if pnpm install; then
        echo -e "${GREEN}✅ Dependencies installed successfully${NC}"
    else
        echo -e "${RED}❌ Failed to install dependencies${NC}"
        exit 1
    fi
}

# Function to choose Discord version
choose_discord_version() {
    echo ""
    echo -e "${PURPLE}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${YELLOW}🎯 Choose your Discord version:${NC}"
    echo -e "${WHITE}  1) ${GREEN}Normal Discord${NC} ${WHITE}(Stable release)${NC}"
    echo -e "${WHITE}  2) ${YELLOW}Discord Canary${NC} ${WHITE}(Alpha/Testing)${NC}"
    echo -e "${WHITE}  3) ${BLUE}Discord PTB${NC} ${WHITE}(Public Test Build/Beta)${NC}"
    echo ""
    
    while true; do
        read -p "$(echo -e ${CYAN}Enter your choice [1-3]: ${NC})" choice
        case $choice in
            1)
                DISCORD_VERSION="stable"
                INSTALL_COMMAND="pnpm run install-stable"
                VERSION_NAME="Normal Discord"
                break
                ;;
            2)
                DISCORD_VERSION="canary"
                INSTALL_COMMAND="pnpm run install-canary"
                VERSION_NAME="Discord Canary"
                break
                ;;
            3)
                DISCORD_VERSION="ptb"
                INSTALL_COMMAND="pnpm run install-ptb"
                VERSION_NAME="Discord PTB"
                break
                ;;
            *)
                echo -e "${RED}❌ Invalid choice. Please enter 1, 2, or 3.${NC}"
                ;;
        esac
    done
    
    echo -e "${GREEN}✅ Selected: ${VERSION_NAME}${NC}"
}

# Function to install BetterDiscord
install_betterdiscord() {
    echo ""
    echo -e "${CYAN}🚀 Installing BetterDiscord for ${VERSION_NAME}...${NC}"
    echo -e "${WHITE}Command: ${INSTALL_COMMAND}${NC}"
    
    if eval "$INSTALL_COMMAND"; then
        echo -e "${GREEN}✅ BetterDiscord installed successfully for ${VERSION_NAME}${NC}"
    else
        echo -e "${RED}❌ Failed to install BetterDiscord${NC}"
        exit 1
    fi
}

# Function to copy BetterScreenshareAudio plugin
copy_plugin() {
    local plugin_filename="BetterScreenshareAudio.plugin.js"
    local plugin_path="${SCRIPT_DIR}/${plugin_filename}"
    local config_dir="${XDG_CONFIG_HOME:-$HOME/.config}"
    local bd_plugins_dir="$config_dir/BetterDiscord/plugins"
    
    echo ""
    echo -e "${CYAN}📁 Copying BetterScreenshareAudio plugin...${NC}"
    
    # Check if plugin file exists in current directory
    if [ ! -f "$plugin_path" ]; then
        echo -e "${YELLOW}⚠️  Plugin file '$plugin_filename' not found in current directory.${NC}"
        echo -e "${WHITE}Please make sure '$plugin_filename' is in the same directory as this script.${NC}"
        
        read -p "$(echo -e ${CYAN}Do you want to continue without copying the plugin? [y/N]: ${NC})" skip_plugin
        case $skip_plugin in
            [Yy]*)
                echo -e "${YELLOW}⏭️  Skipping plugin installation...${NC}"
                return 0
                ;;
            *)
                echo -e "${RED}❌ Cannot proceed without the plugin file${NC}"
                echo -e "${YELLOW}Please place '$plugin_filename' in the same directory as this script and run again.${NC}"
                exit 1
                ;;
        esac
    fi
    
    # Copy the plugin file
    echo -e "${CYAN}📋 Copying plugin to BetterDiscord...${NC}"
    echo -e "${WHITE}Source: $plugin_path${NC}"
    echo -e "${WHITE}Destination: $bd_plugins_dir/$plugin_filename${NC}"
    
    if cp "$plugin_path" "$bd_plugins_dir/"; then
        echo -e "${GREEN}✅ Plugin copied successfully${NC}"
    else
        echo -e "${RED}❌ Failed to copy plugin${NC}"
        echo -e "${YELLOW}You may need to copy it manually to: $bd_plugins_dir${NC}"
    fi
}

# Function to prompt Discord restart
prompt_discord_restart() {
    # Check if Discord processes are running
    if pgrep -f "discord" > /dev/null; then
        echo ""
        echo -e "${PURPLE}═══════════════════════════════════════════════════════════════${NC}"
        echo -e "${YELLOW}🔄 Discord Restart Required${NC}"
        echo -e "${WHITE}To complete the installation, please restart Discord.${NC}"
        echo ""
        
        read -p "$(echo -e ${CYAN}Would you like to close Discord now? [y/N]: ${NC})" close_discord
        case $close_discord in
            [Yy]*)
                echo -e "${CYAN}🔄 Closing Discord...${NC}"
                pkill -f "discord" 2>/dev/null || true
                sleep 2
                echo -e "${GREEN}✅ Discord closed${NC}"
                echo -e "${WHITE}You can now start Discord to use BetterDiscord.${NC}"
                ;;
            *)
                echo -e "${YELLOW}👍 Please manually restart Discord when you're ready.${NC}"
                ;;
        esac
    fi
}

# Function to display completion message
display_completion() {
    echo ""
    echo -e "${PURPLE}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${GREEN}🎉 Installation Complete! 🎉${NC}"
    echo ""
    echo -e "${WHITE}BetterDiscord has been successfully installed for ${VERSION_NAME}.${NC}"
    echo -e "${WHITE}BetterScreenshareAudio plugin has been installed.${NC}"
    echo ""
    echo -e "${YELLOW}📝 Next steps:${NC}"
    echo -e "${WHITE}  • Look for the BetterDiscord settings in Discord${NC}"
    echo -e "${WHITE}  • Enable the BetterScreenshareAudio plugin in BetterDiscord settings${NC}"
    echo -e "${WHITE}  • Enjoy your enhanced Discord experience!${NC}"
    echo ""
    echo -e "${CYAN}💡 Tip: You can find more themes and plugins at https://betterdiscord.app/${NC}"
    echo -e "${PURPLE}═══════════════════════════════════════════════════════════════${NC}"
}

# Main execution
main() {
    # Clear screen and display ASCII art
    clear
    display_ascii_art
    display_actions
    
    # Confirm before proceeding
    read -p "$(echo -e ${CYAN}Do you want to proceed with the installation? [Y/n]: ${NC})" confirm
    case $confirm in
        [Nn]*)
            echo -e "${YELLOW}Installation cancelled.${NC}"
            exit 0
            ;;
    esac
    
    echo ""
    echo -e "${PURPLE}═══════════════════════════════════════════════════════════════${NC}"
    
    # Execute installation steps
    check_pnpm
    echo ""
    clone_repository
    echo ""
    install_dependencies
    echo ""
    choose_discord_version
    echo ""
    install_betterdiscord
    echo ""
    copy_plugin
    echo ""
    prompt_discord_restart
    echo ""
    display_completion
}

# Run main function
main "$@"
