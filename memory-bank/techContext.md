# Tech Context

## Technologies Used
- Docker (multi-stage builds)
- Bash scripting
- Markdown for documentation
- Cross-platform packaging tools


## Development Setup
- Linux as primary development OS
- Scripts for automation
- Version control for all artifacts (do NOT check proprietary IBM i Access binaries or resources into version control)

## Technical Constraints
- Must support Linux, Windows, Mac
- Documentation in multiple languages
- Secure, minimal images



## Dependencies
- Docker
- Platform-specific runtime dependencies
- IBM i Access application (proprietary, provided by third party; must NOT be checked into version control)

## Placement of Proprietary Files
To successfully build the Flatpak package, the following proprietary IBM i Access files and directories must be placed in the project root (not checked into version control):

- `IBMiAccess_v1r1/acsbundle.jar` (main application JAR)
- `IBMiAccess_v1r1/Documentation/` (documentation folder)
- `IBMiAccess_v1r1/Fonts/` (fonts folder)
- `IBMiAccess_v1r1/Icons/` (icons folder)
- `IBMiAccess_v1r1/Linux_Application/` (Linux-specific resources)

All files must retain their original directory structure as provided by IBM. Do not rename or move files outside these locations, as the Flatpak manifest expects them here for packaging.

---
