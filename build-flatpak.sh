#!/bin/bash
# Automated Flatpak builder for IBM i Access (Third-Party)
# This script builds the Flatpak and optionally creates a distributable .flatpak bundle.
# Usage: ./build-flatpak.sh [options]
#   --bundle      Create bundle (requires runtime from Flathub); skips local install
#   --standalone  Create self-contained bundle; skips local install
#   --install     Also install locally (use with --bundle/--standalone to override default)
#   --no-install  Skip local install (default for --bundle/--standalone)
#   --system      Install system-wide (requires sudo/root; default is --user)

set -e

APP_ID="com.ibm.iaccess"
BUNDLE="ibm-iaccess.flatpak"
REPO="repo"
MANIFEST="com.ibm.iaccess.yaml"
BUILD_DIR="build-dir"
IBM_DIR="IBMiAccess_v1r1"
# Source runtime version from VERSION file (single source of truth)
if [ -f "VERSION" ]; then
	source VERSION
fi
OPENJDK_EXT="org.freedesktop.Sdk.Extension.openjdk"
RUNTIME_VER="${RUNTIME_VERSION:-24.08}"
CREATE_BUNDLE=false
STANDALONE=false
INSTALL_SCOPE="--user"
SKIP_INSTALL=false

# Derive collection ID from git remote (GitHub convention: io.github.{user}.{repo})
get_collection_id() {
	local git_remote="$1"
	local user repo
	user="$(echo "$git_remote" | sed -n 's/.*github\.com[/:]\([^/]*\)\/\([^/]*\)\.git/\1/p')"
	repo="$(echo "$git_remote" | sed -n 's/.*github\.com[/:]\([^/]*\)\/\([^/]*\)\.git/\2/p')"
	if [ -z "$user" ] || [ -z "$repo" ]; then
		echo "io.flatpak.ibmiaccess"
	else
		echo "io.github.${user}.${repo}" | tr '-' '_'
	fi
}
COLLECTION_ID="$(get_collection_id "$(git remote get-url origin 2>/dev/null || echo "")")"

# Parse arguments
EXPLICIT_INSTALL_FLAG=false
for arg in "$@"; do
	case "$arg" in
	--bundle) CREATE_BUNDLE=true ;;
	--standalone)
		CREATE_BUNDLE=true
		STANDALONE=true
		;;
	--system) INSTALL_SCOPE="--system" ;;
	--no-install)
		SKIP_INSTALL=true
		EXPLICIT_INSTALL_FLAG=true
		;;
	--install)
		SKIP_INSTALL=false
		EXPLICIT_INSTALL_FLAG=true
		;;
	*)
		echo "Unknown option: $arg"
		exit 1
		;;
	esac
done

# Determine whether to install
# - Default: install unless creating bundle
# - --install or --no-install overrides the default
if [ "$EXPLICIT_INSTALL_FLAG" = true ]; then
	# Explicit flag was passed
	if [ "$SKIP_INSTALL" = true ]; then
		DO_INSTALL=false
	else
		DO_INSTALL=true
	fi
else
	# No explicit flag: default behavior
	if [ "$CREATE_BUNDLE" = true ]; then
		DO_INSTALL=false
	else
		DO_INSTALL=true
	fi
fi

# Check manifest exists
if [ ! -f "$MANIFEST" ]; then
	echo "[ERROR] Manifest file not found: $MANIFEST" >&2
	exit 1
fi

# Validate VERSION matches manifest
if [ -f "VERSION" ]; then
	if ! grep -q "org.freedesktop.Platform//$RUNTIME_VER" "$MANIFEST"; then
		echo "[ERROR] VERSION file RUNTIME_VERSION=$RUNTIME_VER does not match manifest" >&2
		exit 1
	fi
fi

# Check for required IBM files
if [ ! -d "$IBM_DIR" ] || [ -z "$(ls -A $IBM_DIR)" ]; then
	echo "[ERROR] $IBM_DIR/ is missing or empty. Please place your licensed IBM i Access files in this directory before building." >&2
	exit 1
fi

# Check for OpenJDK Flatpak extension
if ! flatpak info "$OPENJDK_EXT//$RUNTIME_VER" >/dev/null 2>&1; then
	echo "[INFO] Installing required Flatpak extension: $OPENJDK_EXT//$RUNTIME_VER" >&2
	flatpak install -y --user flathub "$OPENJDK_EXT//$RUNTIME_VER"
else
	echo "[INFO] Required Flatpak extension $OPENJDK_EXT//$RUNTIME_VER is already installed." >&2
fi

# Clean previous build output
rm -rf "$BUILD_DIR" "$REPO" "$BUNDLE"

# Uninstall previous version (only if installing)
if [ "$DO_INSTALL" = true ]; then
	if flatpak info "$APP_ID" >/dev/null 2>&1; then
		echo "[INFO] Uninstalling previous version..."
		flatpak remove "$APP_ID" || true
	fi
fi

# Build the Flatpak
echo "[INFO] Building Flatpak..."
if [ "$DO_INSTALL" = true ]; then
	echo "[INFO] Building and installing Flatpak ($INSTALL_SCOPE)..."
	flatpak-builder --force-clean $INSTALL_SCOPE --install --repo="$REPO" --collection-id="$COLLECTION_ID" "$BUILD_DIR" "$MANIFEST"
	echo "[SUCCESS] Flatpak built and installed ($INSTALL_SCOPE)."
else
	echo "[INFO] Building without local install..."
	flatpak-builder --force-clean --repo="$REPO" --collection-id="$COLLECTION_ID" "$BUILD_DIR" "$MANIFEST"
	echo "[SUCCESS] Flatpak built successfully."
fi

# Optionally create distributable bundle
if [ "$CREATE_BUNDLE" = true ]; then
	if [ "$STANDALONE" = true ]; then
		echo "[INFO] Creating standalone self-contained bundle: $BUNDLE"
		echo "[INFO] This will embed the runtime (~500MB) for full offline use"
		flatpak build-bundle "$REPO" "$BUNDLE" "$APP_ID"
	else
		echo "[INFO] Creating distributable bundle: $BUNDLE"
		echo "[INFO] Note: Users will need org.freedesktop.Platform//$RUNTIME_VER from Flathub"
		flatpak build-bundle --runtime-repo="$REPO" "$REPO" "$BUNDLE" "$APP_ID"
	fi
	echo "[SUCCESS] Bundle created: $BUNDLE"
	echo "[INFO] Checksum:"
	sha256sum "$BUNDLE"
else
	echo "[INFO] Flatpak app is installed. To create a distributable bundle, run:"
	echo "       ./build-flatpak.sh --bundle        # Requires runtime from Flathub"
	echo "       ./build-flatpak.sh --standalone   # Self-contained, no runtime needed"
fi
