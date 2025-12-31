#!/bin/bash
# Automated Flatpak builder for IBM i Access (Third-Party)
# This script builds the Flatpak and installs it locally. Optionally creates a distributable .flatpak bundle.
# Usage: ./build-flatpak.sh [--bundle] [--system]
#   --bundle  Also create ibm-iaccess.flatpak bundle for distribution
#   --system  Install system-wide (requires sudo/root; default is --user)

set -e

APP_ID="com.ibm.iaccess"
BUNDLE="ibm-iaccess.flatpak"
REPO="repo"
MANIFEST="com.ibm.iaccess.yaml"
BUILD_DIR="build-dir"
IBM_DIR="IBMiAccess_v1r1"
OPENJDK_EXT="org.freedesktop.Sdk.Extension.openjdk"
RUNTIME_VER="24.08"
CREATE_BUNDLE=false
INSTALL_SCOPE="--user"

# Parse arguments
for arg in "$@"; do
  case "$arg" in
    --bundle) CREATE_BUNDLE=true ;;
    --system) INSTALL_SCOPE="--system" ;;
    *) echo "Unknown option: $arg"; exit 1 ;;
  esac
done

# Check for required IBM files
if [ ! -d "$IBM_DIR" ] || [ -z "$(ls -A $IBM_DIR)" ]; then
  echo "[ERROR] $IBM_DIR/ is missing or empty. Please place your licensed IBM i Access files in this directory before building." >&2
  exit 1
fi

# Check for OpenJDK Flatpak extension
if ! flatpak info "$OPENJDK_EXT//$RUNTIME_VER" > /dev/null 2>&1; then
  echo "[INFO] Installing required Flatpak extension: $OPENJDK_EXT//$RUNTIME_VER" >&2
  flatpak install -y "$OPENJDK_EXT//$RUNTIME_VER"
else
  echo "[INFO] Required Flatpak extension $OPENJDK_EXT//$RUNTIME_VER is already installed." >&2
fi

# Clean previous build output
rm -rf "$BUILD_DIR" "$REPO" "$BUNDLE"

# Build and install Flatpak directly
echo "[INFO] Building and installing Flatpak ($INSTALL_SCOPE)..."
echo "[INFO] Note: Release version is managed via git tags (currently targeting v1.0.0)"
flatpak-builder --force-clean $INSTALL_SCOPE --install --repo="$REPO" "$BUILD_DIR" "$MANIFEST"

echo "[SUCCESS] Flatpak built and installed successfully ($INSTALL_SCOPE)."

# Optionally create distributable bundle
if [ "$CREATE_BUNDLE" = true ]; then
  echo "[INFO] Creating distributable bundle: $BUNDLE"
  flatpak build-bundle --runtime-repo="$REPO" "$REPO" "$BUNDLE" "$APP_ID"
  echo "[SUCCESS] Bundle created: $BUNDLE"
  echo "[INFO] Checksum:"
  sha256sum "$BUNDLE"
else
  echo "[INFO] Flatpak app is installed. To create a distributable bundle, run: ./build-flatpak.sh --bundle"
fi
