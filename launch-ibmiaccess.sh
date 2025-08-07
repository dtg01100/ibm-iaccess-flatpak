
#!/bin/sh
#!/bin/sh
# Robust fontconfig sync for Flatpak IBM i Access
FLATPAK_FONTCONFIG="$HOME/.var/app/com.ibm.iaccess/config/fontconfig"
USER_FONTCONFIG="$HOME/.config/fontconfig"
SYSTEM_FONTCONFIG_ETC="/etc/fonts"
SYSTEM_FONTCONFIG_SHARE="/usr/share/fontconfig"

echo "[Fontconfig Sync] Starting font settings sync..." >&2
mkdir -p "$FLATPAK_FONTCONFIG"

# Copy user fontconfig
if [ -d "$USER_FONTCONFIG" ]; then
  echo "[Fontconfig Sync] Copying user fontconfig from $USER_FONTCONFIG to $FLATPAK_FONTCONFIG" >&2
  cp -r "$USER_FONTCONFIG"/* "$FLATPAK_FONTCONFIG/" 2>/dev/null || echo "[Fontconfig Sync] Warning: Failed to copy user fontconfig" >&2
else
  echo "[Fontconfig Sync] No user fontconfig found at $USER_FONTCONFIG" >&2
fi

# Copy system-wide fontconfig (etc)
if [ -d "$SYSTEM_FONTCONFIG_ETC" ] && [ -r "$SYSTEM_FONTCONFIG_ETC" ]; then
  echo "[Fontconfig Sync] Copying system fontconfig from $SYSTEM_FONTCONFIG_ETC to $FLATPAK_FONTCONFIG" >&2
  cp -rn "$SYSTEM_FONTCONFIG_ETC"/* "$FLATPAK_FONTCONFIG/" 2>/dev/null || echo "[Fontconfig Sync] Warning: Failed to copy system fontconfig (etc)" >&2
else
  echo "[Fontconfig Sync] No system fontconfig found at $SYSTEM_FONTCONFIG_ETC" >&2
fi

# Copy system-wide fontconfig (share)
if [ -d "$SYSTEM_FONTCONFIG_SHARE" ] && [ -r "$SYSTEM_FONTCONFIG_SHARE" ]; then
  echo "[Fontconfig Sync] Copying system fontconfig from $SYSTEM_FONTCONFIG_SHARE to $FLATPAK_FONTCONFIG" >&2
  cp -rn "$SYSTEM_FONTCONFIG_SHARE"/* "$FLATPAK_FONTCONFIG/" 2>/dev/null || echo "[Fontconfig Sync] Warning: Failed to copy system fontconfig (share)" >&2
else
  echo "[Fontconfig Sync] No system fontconfig found at $SYSTEM_FONTCONFIG_SHARE" >&2
fi

# Copy host fonts if exposed by Flatpak
if [ -d "/run/host/fonts" ]; then
  echo "[Fontconfig Sync] Copying host fonts from /run/host/fonts to $FLATPAK_FONTCONFIG" >&2
  cp -rn /run/host/fonts/* "$FLATPAK_FONTCONFIG/" 2>/dev/null || echo "[Fontconfig Sync] Warning: Failed to copy host fonts" >&2
else
  echo "[Fontconfig Sync] No host fonts found at /run/host/fonts" >&2
fi

echo "[Fontconfig Sync] Font settings sync complete. Limitations may apply due to Flatpak sandboxing." >&2

JAVA_BIN=/usr/lib/sdk/openjdk/bin/java
exec "$JAVA_BIN" -jar /app/IBMiAccess_v1r1/acsbundle.jar "$@"
JAVA_BIN=/usr/lib/sdk/openjdk/bin/java
exec "$JAVA_BIN" -jar /app/IBMiAccess_v1r1/acsbundle.jar "$@"
