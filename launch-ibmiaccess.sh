#!/bin/sh
# Set environment variables for better font rendering
# Rely on Flatpak to mount host fonts at /run/host/fonts or /run/host/usr/share/fonts
export FONTCONFIG_PATH="/etc/fonts"
export GDK_BACKEND=x11

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

# Force X11 by unsetting Wayland
export WAYLAND_DISPLAY=""
export GDK_BACKEND=x11

# Generate a custom fonts.conf to include bundled fonts and host fonts
# Use XDG_CACHE_HOME if set, otherwise default to ~/.cache
CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}"
export FONTCONFIG_FILE="$CACHE_DIR/fontconfig/fonts.conf"
mkdir -p "$(dirname "$FONTCONFIG_FILE")"

cat > "$FONTCONFIG_FILE" << 'EOF'
<?xml version="1.0"?>
<!DOCTYPE fontconfig SYSTEM "fonts.dtd">
<fontconfig>
  <!-- Load default system configuration to ensure we have standard fonts and settings -->
  <include>/etc/fonts/fonts.conf</include>

  <!-- Add our bundled fonts -->
  <dir>/app/IBMiAccess_v1r1/Fonts</dir>
  
  <!-- Add user and host fonts just in case default config misses them in this sandbox -->
  <dir>/run/host/user-fonts</dir>
  <dir prefix="xdg">fonts</dir>
  
  <!-- Force antialiasing and hinting -->
  <match target="font">
    <edit name="antialias" mode="assign">
      <bool>true</bool>
    </edit>
    <edit name="hinting" mode="assign">
      <bool>true</bool>
    </edit>
    <edit name="hintstyle" mode="assign">
      <const>hintslight</const>
    </edit>
    <edit name="rgba" mode="assign">
      <const>rgb</const>
    </edit>
    <edit name="lcdfilter" mode="assign">
      <const>lcddefault</const>
    </edit>
  </match>
  
  <cachedir prefix="xdg">fontconfig</cachedir>
</fontconfig>
EOF

# Configure shared temporary directory for printer output/uploads
# ACS writes temp files here before asking xdg-open to handle them.
# We use a path in XDG_CACHE_HOME so it's accessible by the host.
APP_TEMP_DIR="$CACHE_DIR/tmp"
mkdir -p "$APP_TEMP_DIR"

# Start the application
# We rely on _JAVA_OPTIONS set in the manifest or environment for font smoothing settings.
# Default fallback if not set: LCD smoothing and metal look and feel.
exec "$JAVA_BIN" \
    -Djava.awt.headless=false \
    -Dswing.defaultlaf=javax.swing.plaf.metal.MetalLookAndFeel \
    -Djava.awt.x11.display="$DISPLAY" \
    -Djdk.gtk.version=2 \
    -Djava.io.tmpdir="$APP_TEMP_DIR" \
    -jar /app/IBMiAccess_v1r1/acsbundle.jar "$@"
