#!/bin/sh
# Configure shared temporary directory for printer output/uploads
# ACS writes temp files here before asking xdg-open to handle them.
# We use a path in XDG_CACHE_HOME so it's accessible by the host.
CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}"
APP_TEMP_DIR="$CACHE_DIR/tmp"
mkdir -p "$APP_TEMP_DIR"

# Use Java from the OpenJDK extension
if [ -f "/usr/lib/sdk/openjdk/bin/java" ]; then
	export JAVA_HOME="/usr/lib/sdk/openjdk"
	JAVA_BIN="/usr/lib/sdk/openjdk/bin/java"
elif [ -f "/app/jre/bin/java" ]; then
	JAVA_BIN="/app/jre/bin/java"
else
	JAVA_BIN="java"
fi

# Ensure X11 display is available
if [ -z "$DISPLAY" ]; then
	export DISPLAY=:0
fi

# Set GTK theme to match KDE (Breeze or Breeze-Dark)
# Check if user prefers dark theme
if [ -f "$HOME/.config/gtk-3.0/settings.ini" ] && grep -q "gtk-application-prefer-dark-theme=true" "$HOME/.config/gtk-3.0/settings.ini" 2>/dev/null; then
	GTK_THEME="Breeze-Dark"
else
	GTK_THEME="Breeze"
fi

export GTK_THEME="$GTK_THEME"

# Trick Java into thinking it's on GNOME for better GTK integration
# Many Java apps check XDG_CURRENT_DESKTOP to decide look-and-feel
export XDG_CURRENT_DESKTOP=GNOME
export DESKTOP_SESSION=gnome

# Debug: show environment
echo "=== IBM i Access Environment ===" >&2
echo "JAVA_BIN: $JAVA_BIN" >&2
echo "DISPLAY: $DISPLAY" >&2
echo "GTK_THEME: $GTK_THEME" >&2
echo "XDG_CURRENT_DESKTOP: $XDG_CURRENT_DESKTOP" >&2
echo "=================================" >&2

exec "$JAVA_BIN" \
	-Djava.awt.headless=false \
	-Djava.awt.x11.display="$DISPLAY" \
	-Djava.io.tmpdir="$APP_TEMP_DIR" \
	-Dawt.useSystemAAFontSettings=lcd \
	-Dswing.aatext=true \
	-Dswing.defaultlaf=com.sun.java.swing.plaf.gtk.GTKLookAndFeel \
	-Dgtk.theme.name="$GTK_THEME" \
	-Dgtk.icon.theme.name="$GTK_THEME" \
	-Djdk.gtk.version=3 \
	-jar /app/IBMiAccess_v1r1/acsbundle.jar "$@"
