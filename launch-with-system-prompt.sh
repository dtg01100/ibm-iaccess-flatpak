#!/bin/bash
# Wrapper script to launch IBM i Access plugins with default system preference
# Usage: launch-with-system-prompt.sh <plugin> <title>

PLUGIN="$1"
TITLE="$2"

# Configuration directory for storing default system preference
CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/ibm-iaccess-flatpak"
DEFAULT_SYSTEM_FILE="$CONFIG_DIR/default-system"

# Ensure config directory exists
mkdir -p "$CONFIG_DIR"

# Check if default system is set
if [ -f "$DEFAULT_SYSTEM_FILE" ]; then
    DEFAULT_SYSTEM=$(cat "$DEFAULT_SYSTEM_FILE")
    if [ -n "$DEFAULT_SYSTEM" ]; then
        # Use default system transparently
        /app/launch-ibmiaccess.sh "/plugin=$PLUGIN" "/SYSTEM=$DEFAULT_SYSTEM"
        exit 0
    fi
fi

# No default system set - prompt user to configure one
zenity --question --text="No default system configured for quick launch.\n\nWould you like to set a default system now?\n\n(You can change this later via 'Set Quick Launch System')" --width=450 2>/dev/null

if [ $? -eq 0 ]; then
    # User wants to set default - launch system selector
    exec /app/select-default-system.sh "$PLUGIN" "$TITLE"
else
    # User declined - launch System Configurations
    /app/launch-ibmiaccess.sh /plugin=cfg /GUI
fi
