# IBM i Access Flatpak (Third-Party Package)

**This is an unofficial, third-party Flatpak package for IBM i Access. It is not affiliated with, endorsed by, or supported by IBM.**

## Overview

This project packages the IBM i Access client as a Flatpak for Linux desktop environments, providing easier installation, desktop integration, and improved font support. It is intended for personal use and experimentation only.

- **Packaged as Flatpak**: Modern Linux packaging for sandboxed, portable deployment
- **Desktop Integration**: Includes desktop file and icon for launcher support
- **Fontconfig Sync**: Attempts to keep font settings in sync with the host system at startup (see limitations)
- **OpenJDK Runtime**: Uses Flatpak OpenJDK extension for Java support

## Features

- **Easy Installation**: One-command installation and updates via Flatpak
- **Desktop Integration**: Full desktop launcher integration with application icon
- **Font Rendering**: Automated fontconfig synchronization for better text rendering quality
- **Security**: Sandboxed environment isolates the application from the rest of your system
- **Portability**: Works across different Linux distributions without per-distribution packaging
- **Clean Repository**: Excludes all proprietary IBM files from version control for legal compliance
- **Automatic Updates**: Supports seamless updates when new wrapper versions are released

## Versioning & releases

This project uses a dual-versioning system to distinguish between the packaging wrapper and the IBM payload:

- **Wrapper Versioning**: `vMAJOR.MINOR.PATCH` (starting at **v1.0.0**). These versions track changes to the Flatpak packaging, scripts, and configuration. Managed via `git tag`.
- **Payload Versioning**: The IBM ACS version you supply is tracked separately in release notes (tested with **ACS 1.1.9.3**). The payload version does not affect the wrapper version number.
- **Bundle Name**: `ibm-iaccess.flatpak` (contains all files from `IBMiAccess_v1r1/` directory).
- **Detailed Information**: See `RELEASE_NOTES.md` for comprehensive release details, checksums, and compatibility information.

**Version Relationships:**
- Wrapper `v1.0.0` + IBM ACS `1.1.9.3` = Working combination
- Wrapper updates are independent of IBM ACS updates
- You can use different IBM ACS versions with the same wrapper (at your own risk)

## Installation & Automated Bundle Creation

> **Note:** You must provide your own licensed IBM i Access files. This package does **not** include any proprietary IBM binaries or resources in the repository, but the final Flatpak bundle will include all files you place in `IBMiAccess_v1r1/`.

### Prerequisites

- **Flatpak**: Ensure Flatpak version 1.0+ is installed on your system. Most modern distributions include Flatpak by default.
- **Flathub Repository**: Required for downloading the OpenJDK extension:
  ```bash
  flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
  ```
- **OpenJDK Extension**: This Flatpak requires the OpenJDK extension. It should be installed automatically during the build/install process, but if you encounter issues, ensure `org.freedesktop.Sdk.Extension.openjdk` version `24.08` is installed:
  ```bash
  flatpak install --user flathub org.freedesktop.Sdk.Extension.openjdk//24.08
  ```
- **IBM i Access License**: You must have a valid IBM i Access Client Solutions license and access to the installation files.

### Quick Start (Automated Build)

1. Clone this repository:
   ```bash
   git clone https://github.com/dtg01100/ibm-iaccess-flatpak.git
   cd ibm-iaccess-flatpak
   ```
2. Place your IBM i Access files in the `IBMiAccess_v1r1/` directory as described in the [File Requirements](#file-requirements) section.
   - Tested payload: ACS 1.1.9.3 (you must supply your licensed files).
3. Run the automated build script:
   ```bash
   ./build-flatpak.sh
   ```

## Build Script Reference

The `build-flatpak.sh` script automates the entire build and installation process. Here are all available options:

### Basic Usage
```bash
./build-flatpak.sh [OPTIONS]
```

### Available Options

| Option | Description | Default |
|--------|-------------|---------|
| `--user` | Install for current user only | **Default** |
| `--system` | Install system-wide (requires sudo) | No |
| `--bundle` | Create distributable `.flatpak` file | No |
| `--clean` | Clean build artifacts before building | Yes |
| `--force` | Force rebuild even if up-to-date | No |
| `--help` | Show help message | N/A |

### Build Script Examples

**Standard user installation:**
```bash
./build-flatpak.sh
```

**System-wide installation:**
```bash
sudo ./build-flatpak.sh --system
```

**Create distributable bundle:**
```bash
./build-flatpak.sh --bundle
# Creates: ibm-iaccess.flatpak
```

**Force rebuild with cleanup:**
```bash
./build-flatpak.sh --clean --force
```

**System installation with bundle:**
```bash
sudo ./build-flatpak.sh --system --bundle
```

### Build Process Steps

The build script performs these operations automatically:

1. **Validation**: Checks for required files and dependencies
2. **Cleanup**: Removes old build artifacts (unless disabled)
3. **Build**: Runs `flatpak-builder` with the manifest
4. **Install**: Installs the Flatpak package
5. **Bundle Creation**: Creates distributable file (if requested)
6. **Post-build**: Sets up desktop integration

### Build Requirements

The script checks for these prerequisites:
- Flatpak installation
- Available disk space (500+ MB)
- IBM i Access files in `IBMiAccess_v1r1/`
- Proper file permissions
- OpenJDK extension availability

### Build Artifacts

During the build process, these temporary files are created:
- `build-dir/` - Flatpak build directory (auto-cleaned)
- `repo/` - Local Flatpak repository (persistent for updates)
- `ibm-iaccess.flatpak` - Distributable bundle (if `--bundle` used)

### Trouleshooting Build Issues

**Permission errors:**
```bash
# Fix permissions and retry
chmod +x build-flatpak.sh
sudo chown -R $USER:$USER .  # For user builds
```

**Missing dependencies:**
```bash
# Install Flatpak and Flathub
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
```

**Space issues:**
```bash
# Clean build directory
rm -rf build-dir
./build-flatpak.sh --clean
```

4. Launch the application:
   ```bash
   flatpak run com.ibm.iaccess
   ```

### Manual Build (Advanced)

If you prefer manual steps or need to create a bundle separately:
```bash
# Build and install locally
flatpak-builder --force-clean build-dir com.ibm.iaccess.yaml
flatpak-builder --run build-dir com.ibm.iaccess.yaml /app/launch-ibmiaccess.sh

# After local build, create a distributable bundle
flatpak build-bundle --runtime-repo=repo repo ibm-iaccess.flatpak com.ibm.iaccess
```

Then install and run the bundle:
```bash
flatpak install --user ibm-iaccess.flatpak
flatpak run com.ibm.iaccess
```

### Licensing & Distribution

**Important Legal Notes:**

- **Bundle Contents**: The final Flatpak bundle (`ibm-iaccess.flatpak`) will include all files from `IBMiAccess_v1r1/`, including proprietary IBM binaries you supply.
- **Your Responsibility**: You are fully responsible for complying with IBM's licensing terms when distributing or installing the bundle.
- **Distribution Rights**: Only distribute to users who have valid IBM i Access licenses.
- **Repository Clean**: This Git repository contains no proprietary IBM files - only the packaging scripts and configuration.
- **No Warranty**: The packaging wrapper is provided under MIT License, but IBM i Access itself remains subject to IBM's licensing terms.

## System Requirements

### Minimum Requirements
- **Operating System**: Linux distribution with Flatpak support
- **Flatpak**: Version 1.0 or higher
- **Disk Space**: 500 MB for the Flatpak bundle + IBM i Access files
- **RAM**: 2 GB minimum (4 GB recommended for optimal performance)
- **Java**: OpenJDK 8 or higher (handled automatically by Flatpak extension)

### Supported Distributions
- Ubuntu 18.04+ / Debian 10+
- Fedora 30+
- openSUSE Leap 15.1+
- Arch Linux
- Any other distribution with current Flatpak support

### Desktop Environments
- GNOME, KDE Plasma, XFCE, LXQt, and other X11-based desktops
- **Note**: Wayland is not currently supported; application falls back to X11

## File Requirements

### Required IBM i Access Files

You must obtain a licensed copy of IBM i Access Client Solutions and place the following files in the `IBMiAccess_v1r1/` directory:

**Core Application Files:**
- `acsbundle.jar` - Main application bundle
- `Startprog.jar` - Launcher program
- `JTOpen.jar` - JDBC driver
- `jt400.jar` - IBM Toolbox for Java
- `Help.jar` - Help system

**Configuration Files:**
- `AcsConfig.properties` - Application configuration (will be modified during build)
- `default.css` - Default stylesheets

**Native Libraries:**
- `lib/` directory containing platform-specific native libraries
- `Icons/` directory containing application icons (must include `logo128.png`)

**Optional but Recommended:**
- Documentation files and manuals
- Sample configuration files

**Tested Configuration:**
- **IBM i Access Client Solutions 1.1.9.3** - This is the version confirmed to work with this packaging

> **Important**: Do not include installer files (`.exe`, `.msi`) or Windows-specific files. Only include the extracted Linux/Java application files.

## Troubleshooting

### Common Issues and Solutions

**Application won't start**
```bash
# Check if Flatpak is installed
flatpak --version

# Verify the application is installed
flatpak list | grep com.ibm.iaccess

# Check for permission issues
flatpak run com.ibm.iaccess 2>&1 | head -20
```

**Font rendering issues**
- The application uses system fonts via fontconfig, but sandboxing may limit access
- Try running with explicit font permissions:
  ```bash
  flatpak run --filesystem=~/.fonts:ro com.ibm.iaccess
  ```

**File browser/external applications not opening**
- The package is configured to use `xdg-open` for external applications
- Ensure your default applications are properly configured:
  ```bash
  xdg-mime query default text/plain
  ```

**Network connectivity issues**
- Verify network permissions are granted:
  ```bash
  flatpak permissions show com.ibm.iaccess
  ```

**Build failures**
```bash
# Clean build directory and retry
rm -rf build-dir repo
./build-flatpak.sh

# Check OpenJDK extension is installed
flatpak list | grep openjdk
```

**Java errors or crashes**
- The application uses OpenJDK 11 via Flatpak extension
- Check Java version in the sandbox:
  ```bash
  flatpak run --command=java com.ibm.iaccess -version
  ```

### Getting Help

- Check the build logs for detailed error messages
- Verify all required files are present in `IBMiAccess_v1r1/`
- Ensure you're using a tested IBM i Access version (1.1.9.3)
- Report packaging issues on GitHub (not IBM product bugs)

## Uninstallation

### Remove the Flatpak Package

**User Installation (default):**
```bash
flatpak uninstall --user com.ibm.iaccess
```

**System Installation:**
```bash
flatpak uninstall --system com.ibm.iaccess
# May require sudo
```

### Clean Up Related Files

**Remove application data:**
```bash
rm -rf ~/.var/app/com.ibm.iaccess
```

**Remove OpenJDK extension (if no longer needed):**
```bash
flatpak uninstall --user org.freedesktop.Sdk.Extension.openjdk//24.08
```

**Verify complete removal:**
```bash
flatpak list | grep iaccess
flatpak info com.ibm.iaccess  # Should return "not found"
```

## Limitations & Known Issues

- **Font Settings**: Fontconfig settings are synced at startup, but Flatpak sandboxing may prevent full system font integration. Some font rendering issues may persist.
- **Proprietary Files**: IBM binaries and resources are **not** included and must be supplied by the user.
- **No Official Support**: This package is not supported by IBM. Use at your own risk.
- **Sandboxing**: Some system integrations (e.g., printing, advanced font settings) may be limited by Flatpak permissions.

## Legal Disclaimer

**Critical Warnings:**

- **Third-Party Package**: This is an **unofficial, third-party package**. It is not affiliated with, endorsed by, or supported by IBM in any way.
- **IBM License Required**: IBM i Access is a proprietary product. You must have a valid IBM license to use IBM i Access files with this package.
- **No IBM IP in Repository**: No IBM intellectual property is distributed in this Git repository - only packaging scripts.
- **Use at Your Own Risk**: The maintainers are not responsible for any issues, data loss, damages, or licensing violations.
- **No Official Support**: Do not contact IBM for support with this packaging. IBM support will not assist with third-party packaging solutions.

## Contributing

Contributions are welcome for packaging improvements, documentation, and usability. Please do **not** submit proprietary IBM files or code.

## Reporting Issues

Please use the GitHub Issues page to report packaging bugs, documentation errors, or feature requests. Do **not** report IBM product bugs here.

## License

This repository is provided under the MIT License for packaging scripts and documentation. IBM i Access files are **not** included and are subject to IBM's licensing terms.

---

**This repository is for personal use and experimentation only. It is not an official IBM product.**
