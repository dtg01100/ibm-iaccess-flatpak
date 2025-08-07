# IBM i Access Flatpak (Third-Party Package)

**This is an unofficial, third-party Flatpak package for IBM i Access. It is not affiliated with, endorsed by, or supported by IBM.**

## Overview

This project packages the IBM i Access client as a Flatpak for Linux desktop environments, providing easier installation, desktop integration, and improved font support. It is intended for personal use and experimentation only.

- **Packaged as Flatpak**: Modern Linux packaging for sandboxed, portable deployment
- **Desktop Integration**: Includes desktop file and icon for launcher support
- **Fontconfig Sync**: Attempts to keep font settings in sync with the host system at startup (see limitations)
- **OpenJDK Runtime**: Uses Flatpak OpenJDK extension for Java support

## Features

- Easy installation via Flatpak
- Desktop launcher and icon
- Automated fontconfig workaround for better font rendering
- Excludes all proprietary IBM files from version control
- Memory Bank documentation for project history and tasks

## Installation & Automated Bundle Creation

> **Note:** You must provide your own licensed IBM i Access files. This package does **not** include any proprietary IBM binaries or resources in the repository, but the final Flatpak bundle will include all files you place in `IBMiAccess_v1r1/`.

### Quick Start (Automated Build)

1. Clone this repository:
   ```bash
   git clone https://github.com/dtg01100/ibm-iaccess-flatpak.git
   cd ibm-iaccess-flatpak
   ```
2. Place your IBM i Access files in the `IBMiAccess_v1r1/` directory as described in the documentation.
3. Run the automated build script:
   ```bash
   ./build-flatpak.sh
   ```
   - This will build the Flatpak repo and generate `ibm-iaccess.flatpak` including all files from `IBMiAccess_v1r1/`.
4. Install the bundle:
   ```bash
   flatpak install ibm-iaccess.flatpak
   ```
5. Run the application:
   ```bash
   flatpak run com.ibm.iaccess
   ```

### Manual Build (Advanced)

If you prefer manual steps:
```bash
flatpak-builder --force-clean build-dir com.ibm.iaccess.yaml
flatpak-builder --run build-dir com.ibm.iaccess.yaml /app/launch-ibmiaccess.sh
```

### Licensing & Distribution

- The final Flatpak bundle (`ibm-iaccess.flatpak`) will include all files from `IBMiAccess_v1r1/`, including proprietary IBM binaries you supply.
- You are responsible for complying with IBM's licensing terms when distributing or installing the bundle.

## Limitations & Known Issues

- **Font Settings**: Fontconfig settings are synced at startup, but Flatpak sandboxing may prevent full system font integration. Some font rendering issues may persist.
- **Proprietary Files**: IBM binaries and resources are **not** included and must be supplied by the user.
- **No Official Support**: This package is not supported by IBM. Use at your own risk.
- **Sandboxing**: Some system integrations (e.g., printing, advanced font settings) may be limited by Flatpak permissions.

## Legal Disclaimer

- This is a **third-party, unofficial package**. It is not affiliated with, endorsed by, or supported by IBM.
- IBM i Access is a proprietary product. You must have a valid license to use IBM i Access files with this package.
- No IBM intellectual property is distributed in this repository.
- Use at your own risk. The maintainers are not responsible for any issues, data loss, or damages.

## Contributing

Contributions are welcome for packaging improvements, documentation, and usability. Please do **not** submit proprietary IBM files or code.

## Reporting Issues

Please use the GitHub Issues page to report packaging bugs, documentation errors, or feature requests. Do **not** report IBM product bugs here.

## Memory Bank

This project uses a Markdown-based Memory Bank for tracking tasks, decisions, and project history. See the `memory-bank/` directory for details.

## License

This repository is provided under the MIT License for packaging scripts and documentation. IBM i Access files are **not** included and are subject to IBM's licensing terms.

---

**This repository is for personal use and experimentation only. It is not an official IBM product.**
