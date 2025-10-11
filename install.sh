#!/usr/bin/env bash

# BetterDiscord Installation Script
# Author: F1r3d3v
# Description: Automated installer for BetterDiscord with Discord version selection and silent install support

set -e  # Exit on any error

readonly SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

# Global variables for silent mode
SILENT_MODE=false
DEFAULT_DISCORD_VERSION="stable"
AUTO_CLOSE_DISCORD=false
SKIP_PLUGIN_ON_MISSING=false

# Colors for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly PURPLE='\033[0;35m'
readonly CYAN='\033[0;36m'
readonly WHITE='\033[1;37m'
readonly NC='\033[0m' # No Color

# Function to display help
display_help() {
    echo "BetterDiscord Installation Script"
    echo ""
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -s, --silent              Run in silent mode (no prompts)"
    echo "  -v, --version VERSION     Discord version to install (stable, canary, ptb)"
    echo "                           Default: stable"
    echo "  -c, --close-discord       Automatically close Discord after installation"
    echo "  -p, --skip-plugin         Skip plugin installation if not found"
    echo "  -h, --help               Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0                       Interactive installation"
    echo "  $0 --silent              Silent installation with stable Discord"
    echo "  $0 -s -v canary -c       Silent install Canary version and close Discord"
    echo "  $0 --silent --version ptb --skip-plugin"
    echo "                           Silent install PTB, skip plugin if missing"
    echo ""
}

# Function to parse command line arguments
parse_arguments() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            -s|--silent)
                SILENT_MODE=true
                shift
                ;;
            -v|--version)
                if [[ -n $2 && $2 != -* ]]; then
                    case $2 in
                        stable|canary|ptb)
                            DEFAULT_DISCORD_VERSION="$2"
                            shift 2
                            ;;
                        *)
                            echo "Error: Invalid Discord version '$2'. Valid options: stable, canary, ptb"
                            exit 1
                            ;;
                    esac
                else
                    echo "Error: --version requires a value (stable, canary, ptb)"
                    exit 1
                fi
                ;;
            -c|--close-discord)
                AUTO_CLOSE_DISCORD=true
                shift
                ;;
            -p|--skip-plugin)
                SKIP_PLUGIN_ON_MISSING=true
                shift
                ;;
            -h|--help)
                display_help
                exit 0
                ;;
            *)
                echo "Error: Unknown option '$1'"
                echo "Use --help for usage information"
                exit 1
                ;;
        esac
    done
}

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
    echo -e "${CYAN}💡 Tip: Use --silent flag for automated installation${NC}"
    echo -e "${CYAN}   Use --help to see all available options${NC}"
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
    local repo_dir="$HOME/.cache/BetterDiscord"
    
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
            
            if [ "$SILENT_MODE" = true ]; then
                echo -e "${CYAN}🗑️  Removing existing directory (silent mode)...${NC}"
                cd ..
                rm -rf "$repo_dir"
                
                if git clone --depth 1 --branch main --single-branch --recurse-submodules "$repo_url" "$repo_dir"; then
                    echo -e "${GREEN}✅ Repository cloned successfully${NC}"
                    cd "$repo_dir"
                else
                    echo -e "${RED}❌ Failed to clone repository${NC}"
                    exit 1
                fi
            else
                read -p "$(echo -e ${CYAN}Do you want to remove the existing directory and re-clone? [y/N]: ${NC})" remove_confirm
                case $remove_confirm in
                    [Yy]*)
                        echo -e "${CYAN}🗑️  Removing existing directory...${NC}"
                        cd ..
                        rm -rf "$repo_dir"
                        
                        if git clone --depth 1 --branch main --single-branch --recurse-submodules "$repo_url" "$repo_dir"; then
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
        fi
    else
        echo -e "${CYAN}📥 Cloning BetterDiscord repository...${NC}"
        echo -e "${WHITE}Repository: ${repo_url}${NC}"
        
        if git clone --depth 1 --branch main --single-branch --recurse-submodules "$repo_url" "$repo_dir"; then
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
    if [ "$SILENT_MODE" = true ]; then
        # Set version based on DEFAULT_DISCORD_VERSION
        case $DEFAULT_DISCORD_VERSION in
            stable)
                DISCORD_VERSION="stable"
                INSTALL_COMMAND="pnpm run install-stable"
                VERSION_NAME="Normal Discord"
                ;;
            canary)
                DISCORD_VERSION="canary"
                INSTALL_COMMAND="pnpm run install-canary"
                VERSION_NAME="Discord Canary"
                ;;
            ptb)
                DISCORD_VERSION="ptb"
                INSTALL_COMMAND="pnpm run install-ptb"
                VERSION_NAME="Discord PTB"
                ;;
        esac
        echo -e "${GREEN}✅ Selected: ${VERSION_NAME} (silent mode)${NC}"
        return
    fi
    
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

# Function to download BetterScreenshareAudio plugin
copy_plugin() {
    local plugin_filename="BetterScreenshareAudio.plugin.js"
    local plugin_url="https://raw.githubusercontent.com/F1r3d3v/BetterScreenshareAudio/master/${plugin_filename}"
    local config_dir="${XDG_CONFIG_HOME:-$HOME/.config}"
    local bd_plugins_dir="$config_dir/BetterDiscord/plugins"
    
    echo ""
    echo -e "${CYAN}📁 Downloading BetterScreenshareAudio plugin...${NC}"
    
    # Create plugins directory if it doesn't exist
    if [ ! -d "$bd_plugins_dir" ]; then
        echo -e "${CYAN}📁 Creating BetterDiscord plugins directory...${NC}"
        mkdir -p "$bd_plugins_dir"
    fi
    
    # Download the plugin file
    echo -e "${CYAN}📋 Downloading plugin from remote repository...${NC}"
    echo -e "${WHITE}Source: $plugin_url${NC}"
    echo -e "${WHITE}Destination: $bd_plugins_dir/$plugin_filename${NC}"
    
    if curl -fs "$plugin_url" -o "$bd_plugins_dir/$plugin_filename"; then
        echo -e "${GREEN}✅ Plugin downloaded successfully${NC}"
    else
        echo -e "${RED}❌ Failed to download plugin${NC}"
        
        if [ "$SILENT_MODE" = true ]; then
            if [ "$SKIP_PLUGIN_ON_MISSING" = true ]; then
                echo -e "${YELLOW}⏭️  Skipping plugin installation (silent mode)...${NC}"
                return 0
            else
                echo -e "${RED}❌ Cannot proceed without the plugin file (silent mode)${NC}"
                exit 1
            fi
        else
            read -p "$(echo -e ${CYAN}Do you want to continue without the plugin? [y/N]: ${NC})" skip_plugin
            case $skip_plugin in
                [Yy]*)
                    echo -e "${YELLOW}⏭️  Skipping plugin installation...${NC}"
                    return 0
                    ;;
                *)
                    echo -e "${RED}❌ Installation failed${NC}"
                    echo -e "${YELLOW}Please check your internet connection and try again.${NC}"
                    exit 1
                    ;;
            esac
        fi
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
        
        if [ "$SILENT_MODE" = true ]; then
            if [ "$AUTO_CLOSE_DISCORD" = true ]; then
                echo -e "${CYAN}🔄 Closing Discord (silent mode)...${NC}"
                pkill -f "discord" 2>/dev/null || true
                sleep 2
                echo -e "${GREEN}✅ Discord closed${NC}"
                echo -e "${WHITE}You can now start Discord to use BetterDiscord.${NC}"
            else
                echo -e "${YELLOW}👍 Please manually restart Discord when you're ready (silent mode).${NC}"
            fi
        else
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
    # Parse command line arguments
    parse_arguments "$@"
    
    # In silent mode, skip ASCII art and interactive prompts
    if [ "$SILENT_MODE" = true ]; then
        echo -e "${WHITE}🎮 BetterDiscord Automated Installer (Silent Mode) 🎮${NC}"
        echo -e "${PURPLE}═══════════════════════════════════════════════════════════════${NC}"
        echo -e "${CYAN}Running in silent mode with Discord version: ${DEFAULT_DISCORD_VERSION}${NC}"
        echo ""
    else
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
    fi
    
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
