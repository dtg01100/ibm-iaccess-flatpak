#!/bin/bash
# Script to select and save default IBM i system
# Usage: select-default-system.sh [plugin] [title]

PLUGIN="$1"
TITLE="$2"

# Configuration directory for storing default system preference
CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/ibm-iaccess-flatpak"
DEFAULT_SYSTEM_FILE="$CONFIG_DIR/default-system"

# Ensure config directory exists
mkdir -p "$CONFIG_DIR"

# Get list of configured systems using cfg plugin
SYSTEMS_OUTPUT=$(/app/launch-ibmiaccess.sh /plugin=cfg /LIST 2>&1)

# Parse system names from output
# System names appear indented after "System Configurations:" and don't have colons
SYSTEMS=$(echo "$SYSTEMS_OUTPUT" | grep -A 1000 "System Configurations:" | grep "^  [^ ]" | grep -v ":" | sed 's/^  //' | sort -u)

# Show current default if set
CURRENT_DEFAULT=""
if [ -f "$DEFAULT_SYSTEM_FILE" ]; then
    CURRENT_DEFAULT=$(cat "$DEFAULT_SYSTEM_FILE")
fi

# Build dialog text
if [ -n "$SYSTEMS" ]; then
    DIALOG_TEXT="Select an IBM i system for quick launch:"
    if [ -n "$CURRENT_DEFAULT" ]; then
        DIALOG_TEXT="Select an IBM i system for quick launch:\n\n(Current: $CURRENT_DEFAULT)"
    fi
    
    # Show system selection dialog
    SELECTED=$(echo "$SYSTEMS" | zenity --list --title="Set Quick Launch System" --text="$DIALOG_TEXT" --column="System" --height=350 --width=450 2>/dev/null)
    
    if [ -z "$SELECTED" ]; then
        # User cancelled
        exit 0
    fi
else
    # No systems configured
    zenity --info --text="No systems configured.\n\nPlease configure systems first using:\nSystem Configurations" --width=400 2>/dev/null
    /app/launch-ibmiaccess.sh /plugin=cfg /GUI
    exit 0
fi

# Save selected system as default
echo "$SELECTED" > "$DEFAULT_SYSTEM_FILE"

# Show confirmation
zenity --info --text="Default system for quick launch set to:\n\n$SELECTED\n\nThis will be used when launching modules from the right-click menu." --width=400 2>/dev/null

# If called with plugin and title, launch it now
if [ -n "$PLUGIN" ] && [ -n "$TITLE" ]; then
    /app/launch-ibmiaccess.sh "/plugin=$PLUGIN" "/SYSTEM=$SELECTED"
fi
