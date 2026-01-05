#!/bin/sh
# Test variant: Nimbus Look-and-Feel
# Java's best cross-platform look-and-feel with good font support

export FONTCONFIG_PATH="/etc/fonts"
export GDK_BACKEND=x11

if [ -f "/usr/lib/sdk/openjdk/bin/java" ]; then
	export JAVA_HOME="/usr/lib/sdk/openjdk"
	JAVA_BIN="/usr/lib/sdk/openjdk/bin/java"
elif [ -f "/app/jre/bin/java" ]; then
	JAVA_BIN="/app/jre/bin/java"
else
	JAVA_BIN="java"
fi

if [ -z "$DISPLAY" ]; then
	export DISPLAY=:0
fi

export WAYLAND_DISPLAY=""
export GDK_BACKEND=x11

CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}"
export FONTCONFIG_FILE="$CACHE_DIR/fontconfig/fonts.conf"
mkdir -p "$(dirname "$FONTCONFIG_FILE")"

cat >"$FONTCONFIG_FILE" <<'EOF'
<?xml version="1.0"?>
<!DOCTYPE fontconfig SYSTEM "fonts.dtd">
<fontconfig>
  <include>/etc/fonts/fonts.conf</include>
  <dir>/app/IBMiAccess_v1r1/Fonts</dir>
  <dir>/run/host/user-fonts</dir>
  <dir prefix="xdg">fonts</dir>
  <match target="font">
    <edit name="antialias" mode="assign"><bool>true</bool></edit>
    <edit name="hinting" mode="assign"><bool>true</bool></edit>
    <edit name="hintstyle" mode="assign"><const>hintslight</const></edit>
    <edit name="rgba" mode="assign"><const>rgb</const></edit>
    <edit name="lcdfilter" mode="assign"><const>lcddefault</const></edit>
  </match>
  <cachedir prefix="xdg">fontconfig</cachedir>
</fontconfig>
EOF

APP_TEMP_DIR="$CACHE_DIR/tmp"
mkdir -p "$APP_TEMP_DIR"

# Force GTK for Java on KDE (for any UI components that use GTK)
export GDK_BACKEND=x11
export SWT_GTK3=0

# Read look-and-feel from environment
SWING_LAF="${SWING_LAF:-javax.swing.plaf.nimbus.NimbusLookAndFeel}"
JDK_GTK_VERSION="${JDK_GTK_VERSION:-}"

exec "$JAVA_BIN" \
	-Djava.awt.headless=false \
	-Djava.awt.x11.display="$DISPLAY" \
	-Djdk.gtk.version="$JDK_GTK_VERSION" \
	-Djava.io.tmpdir="$APP_TEMP_DIR" \
	-Dawt.useSystemAAFontSettings=lcd \
	-Dswing.aatext=true \
	-Dawt.font.lcdcontrast=140 \
	-Dawt.toolkit=sun.awt.X11.XToolkit \
	-Djavax.swing.defaultlaf="$SWING_LAF" \
	-jar /app/IBMiAccess_v1r1/acsbundle.jar "$@"
