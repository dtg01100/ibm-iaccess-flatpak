#!/bin/bash
# Automated Flatpak bundle builder for IBM i Access (Third-Party)
# This script builds the Flatpak repo and generates the .flatpak bundle, including proprietary IBM files from IBMiAccess_v1r1/

set -e

APP_ID="com.ibm.iaccess"
BUNDLE="ibm-iaccess.flatpak"
REPO="repo"
MANIFEST="com.ibm.iaccess.yaml"
BUILD_DIR="build-dir"
IBM_DIR="IBMiAccess_v1r1"
OPENJDK_EXT="org.freedesktop.Sdk.Extension.openjdk"
RUNTIME_VER="23.08"

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

# Build Flatpak repo
flatpak-builder --force-clean --repo="$REPO" "$BUILD_DIR" "$MANIFEST"

# Generate Flatpak bundle
flatpak build-bundle "$REPO" "$BUNDLE" "$APP_ID"

if [ -f "$BUNDLE" ]; then
  echo "[SUCCESS] Flatpak bundle created: $BUNDLE"
  echo "To install: flatpak install $BUNDLE"
else
  echo "[ERROR] Bundle creation failed." >&2
  exit 2
fi
