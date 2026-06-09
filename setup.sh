#!/usr/bin/env bash
# setup.sh — macOS bootstrapper
# Run this on a fresh machine to restore your environment.
# Usage: ./setup.sh [--no-macos-defaults]

set -euo pipefail

DOTFILES_REPO="https://github.com/dbriones/dotfiles"
DOTFILES_DIR="$HOME/.dotfiles"

# ── Colour helpers ────────────────────────────────────────────────────────────
info()    { printf "\r  [ \033[00;34m..\033[0m ] %s\n" "$1"; }
success() { printf "\r\033[2K  [ \033[00;32mOK\033[0m ] %s\n" "$1"; }
fail()    { printf "\r\033[2K  [\033[0;31mFAIL\033[0m] %s\n" "$1"; exit 1; }

# ── Helpers ───────────────────────────────────────────────────────────────────
command_exists() { command -v "$1" &>/dev/null; }

# ── 1. Xcode Command Line Tools ───────────────────────────────────────────────
install_xcode_clt() {
  if xcode-select -p &>/dev/null; then
    success "Xcode Command Line Tools already installed"
    return
  fi

  info "Installing Xcode Command Line Tools..."
  # Trigger the GUI installer, then poll until it finishes.
  xcode-select --install 2>/dev/null || true
  until xcode-select -p &>/dev/null; do
    sleep 5
  done
  success "Xcode Command Line Tools installed"
}

# ── 2. Homebrew ───────────────────────────────────────────────────────────────
install_homebrew() {
  if command_exists brew; then
    success "Homebrew already installed"
  else
    info "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    success "Homebrew installed"
  fi

  # Make sure brew is on PATH immediately (Apple Silicon path differs)
  if [[ -f /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [[ -f /usr/local/bin/brew ]]; then
    eval "$(/usr/local/bin/brew shellenv)"
  fi

  info "Updating Homebrew..."
  brew update --quiet
  success "Homebrew up to date"
}

# ── 3. Packages & Apps (Brewfile) ─────────────────────────────────────────────
install_packages() {
  local brewfile="${DOTFILES_DIR}/homebrew/Brewfile"

  if [[ ! -f "$brewfile" ]]; then
    info "No Brewfile found at $brewfile — skipping package install"
    return
  fi

  info "Installing packages from Brewfile..."
  brew bundle -v install --file="$brewfile"
  success "Packages installed"
}

# ── 4. Dotfiles ───────────────────────────────────────────────────────────────
clone_dotfiles() {
  if [[ -d "$DOTFILES_DIR" ]]; then
      if [[ "${1:-}" == "--no-pull" ]]; then
        info "Skipping pull of latest dotfiles"
      else
        info "Dotfiles repo already cloned; pulling latest..."
        git -C "$DOTFILES_DIR" pull --rebase --quiet
      fi
  else
    info "Cloning dotfiles repo..."
    git clone "$DOTFILES_REPO" "$DOTFILES_DIR"
  fi
  success "Dotfiles repo ready at $DOTFILES_DIR"
}

setup_dotfiles() {
  # Symlink files using GNU Stow.
  # Assumes DOTFILES_DIR contains subdirectories mirroring $HOME structure,
  # e.g. dotfiles/zsh/.zshrc → $HOME/.zshrc
  if command_exists stow; then
    info "Symlinking dotfiles with stow..."
    for pkg in "$DOTFILES_DIR"/*/; do
      pkg_name=$(basename "$pkg")
      # Skip non-package directories
      [[ "$pkg_name" == ".git" ]] && continue
      stow --dir="$DOTFILES_DIR" --target="$HOME" --restow "$pkg_name"
    done
    success "Dotfiles symlinked"
  else
    info "GNU Stow not found; skipping symlinks (add 'brew stow' to your Brewfile)"
  fi
}

# ── 5. macOS System Defaults ──────────────────────────────────────────────────
set_macos_defaults() {
  info "Applying macOS defaults..."

  # --- Finder ---
  # Show hidden files
  defaults write com.apple.finder AppleShowAllFiles -bool true
  # Show all file extensions
  defaults write NSGlobalDomain AppleShowAllExtensions -bool true
  # Show path bar at the bottom of Finder windows
  defaults write com.apple.finder ShowPathbar -bool true
  # Show status bar
  defaults write com.apple.finder ShowStatusBar -bool true
  # Default to list view in Finder
  defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"
  # Search the current folder by default (instead of whole Mac)
  defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"
  # Disable the warning when changing a file extension
  defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false
  # Avoid creating .DS_Store files on network or USB volumes
  defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
  defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true

  # --- Keyboard ---
  # Fast key repeat (lower = faster; default is 6)
  defaults write NSGlobalDomain KeyRepeat -int 2
  # Short delay before key repeat kicks in (default is 25)
  defaults write NSGlobalDomain InitialKeyRepeat -int 15
  # Disable auto-correct
  defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false
  # Disable automatic capitalisation
  defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled -bool false
  # Disable smart dashes and smart quotes (they break code snippets)
  defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false
  defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false

  # --- Dock ---
  # Auto-hide the Dock
  defaults write com.apple.dock autohide -bool true
  # Remove the auto-hide delay
  defaults write com.apple.dock autohide-delay -float 0
  # Faster animation when showing/hiding
  defaults write com.apple.dock autohide-time-modifier -float 0.25
  # Show only open apps in the Dock (no pinned apps)
  # Remove this if you want to keep your pinned apps:
  # defaults write com.apple.dock static-only -bool true
  # Don't show recent apps in Dock
  defaults write com.apple.dock show-recents -bool false
  # Set Dock icon size
  defaults write com.apple.dock tilesize -int 48

  # --- Screenshots ---
  # Save screenshots to ~/Screenshots instead of Desktop
  mkdir -p "$HOME/Screenshots"
  defaults write com.apple.screencapture location -string "$HOME/Screenshots"
  # Save as PNG by default
  defaults write com.apple.screencapture type -string "png"
  # Disable drop shadow on screenshots
  defaults write com.apple.screencapture disable-shadow -bool true

  # --- Trackpad ---
  # Enable tap to click
  defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
  defaults write com.apple.AppleMultitouchTrackpad Clicking -bool true
  defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
  # Enable three-finger drag
  defaults write com.apple.AppleMultitouchTrackpad TrackpadThreeFingerDrag -bool true

  # --- Safari ---
  # Show the full URL in the address bar
  defaults write com.apple.Safari ShowFullURLInSmartSearchField -bool true
  # Enable the Develop menu
  defaults write com.apple.Safari IncludeDevelopMenu -bool true

  # --- Miscellaneous ---
  # Expand save panel by default
  defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
  defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode2 -bool true
  # Expand print panel by default
  defaults write NSGlobalDomain PMPrintingExpandedStateForPrint -bool true
  defaults write NSGlobalDomain PMPrintingExpandedStateForPrint2 -bool true
  # Quit the printer app once all jobs have completed
  defaults write com.apple.print.PrintingPrefs "Quit When Finished" -bool true
  # Disable the "Are you sure you want to open this application?" quarantine dialog
  #defaults write com.apple.LaunchServices LSQuarantine -bool false

  # Restart affected apps so changes take effect in this session
  for app in "Finder" "Dock" "SystemUIServer" "Safari"; do
    killall "$app" &>/dev/null || true
  done

  success "macOS defaults applied"
}

# ── 6. Shell ──────────────────────────────────────────────────────────────────
setup_shell() {
  # Change default shell to zsh if it isn't already (it's the default on modern macOS)
  local zsh_path
  zsh_path=$(command -v zsh)
  if [[ "$SHELL" != "$zsh_path" ]]; then
    info "Changing default shell to zsh..."
    # Ensure Homebrew zsh is in /etc/shells (it may not be on a fresh machine)
    if ! grep -qF "$zsh_path" /etc/shells; then
      echo "$zsh_path" | sudo tee -a /etc/shells
    fi
    chsh -s "$zsh_path"
    success "Default shell set to $zsh_path"
  else
    success "Shell is already zsh"
  fi
}

# ── Main ──────────────────────────────────────────────────────────────────────
main() {
  echo ""
  echo "  macOS Setup"
  echo "  ────────────────────────────────"
  echo ""

  install_xcode_clt
  install_homebrew
  clone_dotfiles "$@"
  install_packages
  # install_mac_apps
  # install magnet
  setup_dotfiles
  setup_shell

  if [[ "${1:-}" == "--no-macos-defaults" ]]; then
    info "Skipping macOS defaults (--no-macos-defaults passed)"
  else
    set_macos_defaults
  fi

  echo ""
  success "All done! Open a new terminal for changes to take effect."
  echo ""
}

main "$@"