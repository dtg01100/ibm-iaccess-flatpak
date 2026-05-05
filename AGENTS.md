# AGENTS.md

**Version:** 1.0
**Date:** 2026-05-05
**Purpose:** Technical reference for IBM i Access Flatpak packaging project

---

## Project Overview

This is a **third-party Flatpak packaging project** for IBM i Access Client Solutions (ACS). The project provides a Linux Flatpak distribution with desktop integration, font support, and sandboxed security.

- **Type:** Flatpak packaging (shell scripts + YAML manifest)
- **License:** MIT (packaging wrapper only) - IBM i Access binaries are proprietary
- **Architecture:** Flatpak sandbox with OpenJDK runtime

---

## Quick Setup

```bash
# Clone and enter the project
git clone https://github.com/dtg01100/ibm-iaccess-flatpak.git
cd ibm-iaccess-flatpak

# Place your licensed IBM i Access files in this directory
# (files go inside IBMiAccess_v1r1/)

# Build and install locally (user scope)
./build-flatpak.sh

# Build and install system-wide
sudo ./build-flatpak.sh --system

# Create distributable bundle
./build-flatpak.sh --bundle

# Create self-contained bundle (includes runtime)
./build-flatpak.sh --standalone
```

---

## Architecture

```
User Request
    |
    v
build-flatpak.sh (orchestrator)
    |
    +-- flatpak-builder
    |       |
    |       v
    |   com.ibm.iaccess.yaml (manifest)
    |       |
    |       v
    |   Flatpak bundle
    |       |
    v       v
flatpak install/run
        |
        v
launch-ibmiaccess.sh (launcher)
        |
        +-- Java/OpenJDK runtime
        +-- IBM i Access JAR (acsbundle.jar)
        +-- GTK3 look-and-feel
```

---

## Directory Structure

| Path | Purpose |
|------|---------|
| `/` | Root project directory |
| `IBMiAccess_v1r1/` | IBM i Access payload (user-supplied, not in repo) |
| `.flatpak-builder/` | Flatpak-builder cache and build directory |
| `build-dir/` | Flatpak build output (gitignored) |
| `repo/` | Local Flatpak repository (gitignored) |
| `.clio/` | CLIO agent memory and sessions |

**Key Files:**

| File | Purpose |
|------|---------|
| `build-flatpak.sh` | Main build orchestration script |
| `com.ibm.iaccess.yaml` | Flatpak manifest (YAML) |
| `launch-ibmiaccess.sh` | Application launcher (Java/GTK3) |
| `launch-with-system-prompt.sh` | Quick launch with system selection |
| `select-default-system.sh` | System preference selector |
| `ibm-iaccess.desktop` | Desktop entry with actions |

---

## Code Style

**Shell Scripting Conventions:**

- Use `#!/bin/bash` or `#!/bin/sh` depending on requirements
- `set -e` for scripts that should fail fast
- Use `${VAR:-default}` for optional variables
- Double-quote variable expansions: `"$VAR"` not `$VAR`
- Use `2>/dev/null` for optional dialogs that may fail
- Exit codes: `0` success, `1` failure

**YAML (Flatpak Manifest):**

- 4-space indentation (no tabs)
- Comments start with `#`
- Key ordering: app-id, runtime, sdk, modules, finish-args, command

**Desktop Entry:**

- INI-style format with `[Desktop Entry]` and `[Desktop Action]` sections
- Categories semicolon-separated: `Categories=Network;Utility;`
- MimeTypes semicolon-separated

---

## Module Naming Conventions

This project uses simple, descriptive filenames:

| Pattern | Example | Purpose |
|---------|---------|---------|
| `launch-*.sh` | `launch-ibmiaccess.sh` | Application launchers |
| `select-*.sh` | `select-default-system.sh` | Configuration selectors |
| `build-*.sh` | `build-flatpak.sh` | Build scripts |
| `*.yaml` | `com.ibm.iaccess.yaml` | Flatpak manifests |
| `*.desktop` | `ibm-iaccess.desktop` | Desktop entries |

---

## Testing

**Before Committing:**

```bash
# 1. Validate shell scripts
shellcheck build-flatpak.sh
shellcheck launch-*.sh
shellcheck select-*.sh

# 2. Validate YAML manifest
flatpak-builder --validate-yaml com.ibm.iaccess.yaml 2>/dev/null || yamllint com.ibm.iaccess.yaml

# 3. Validate desktop entry
desktop-file-validate ibm-iaccess.desktop

# 4. Syntax check all scripts
bash -n build-flatpak.sh
sh -n launch-ibmiaccess.sh

# 5. Check .gitignore is correct
# Ensure .clio/* entries exist (CLIO is auto-managed)
grep -q "\.clio/\*" .gitignore && echo "CLIO entries found"

# 6. Verify no proprietary files staged
git status | grep -i "IBMiAccess_v1r1" && echo "WARNING: IBM files staged!"
```

**Testing the Build (when IBM files available):**

```bash
# Clean build
rm -rf build-dir repo ibm-iaccess.flatpak
./build-flatpak.sh --clean --force

# Verify installed app
flatpak info com.ibm.iaccess

# Run the app
flatpak run com.ibm.iaccess
```

---

## Commit Format

```
type(scope): brief description

[Optional body with details]

[Optional footer with issue refs]
```

**Types:**

| Type | When to Use |
|------|-------------|
| `feat` | New features |
| `fix` | Bug fixes |
| `docs` | Documentation changes |
| `refactor` | Code refactoring without behavior change |
| `build` | Build system or dependency changes |
| `chore` | Maintenance tasks |

**Examples:**

```bash
git commit -m "feat(build): add --standalone bundle option"
git commit -m "fix(launcher): correct Java path detection"
git commit -m "docs(readme): clarify IBM payload requirements"
```

---

## Development Tools

**Common Commands:**

```bash
# Check Flatpak availability
flatpak --version
flatpak-builder --version

# List installed Flatpaks
flatpak list

# Remove installed package
flatpak remove com.ibm.iaccess

# View Flatpak info
flatpak info com.ibm.iaccess

# Clean all build artifacts
rm -rf build-dir repo *.flatpak

# View app logs (when running)
flatpak run com.ibm.iaccess 2>&1 | tee app.log
```

---

## Common Patterns

**YAML Manifest Structure:**

```yaml
app-id: com.ibm.iaccess
runtime: org.freedesktop.Platform//24.08
sdk: org.freedesktop.Sdk//24.08
sdk-extensions:
  - org.freedesktop.Sdk.Extension.openjdk
modules:
  - name: module-name
    buildsystem: simple
    build-commands:
      - command1
      - command2
    sources:
      - type: dir
        path: source-dir
      - type: file
        path: source-file
finish-args:
  - --socket=x11
  - --share=ipc
command: "/app/launch-command.sh"
```

**Desktop Entry Actions:**

```ini
[Desktop Action action-name]
Name=Display Name
Exec=/app/command.sh %f

[Desktop Entry]
Actions=action1;action2;action3;
```

**Shell Dialog Pattern:**

```bash
zenity --question --text="Message" 2>/dev/null
if [ $? -eq 0 ]; then
    # User said yes
else
    # User said no or cancelled
fi
```

---

## Documentation

### What Needs Documentation

| Change Type | Required Documentation |
|-------------|------------------------|
| New launch script | Update `README.md` and desktop entry actions |
| Manifest change | Update `README.md` build instructions |
| New desktop action | Add to `ibm-iaccess.desktop` with action section |
| Build option change | Update `build-flatpak.sh` help text and README |
| Runtime/SDK change | Update `RELEASE_NOTES.md` and README |

---

## Anti-Patterns (What NOT To Do)

| Anti-Pattern | Why It's Wrong | What To Do |
|--------------|----------------|------------|
| Commit IBM binaries | Proprietary files violate licensing | Keep `IBMiAccess_v1r1/` in `.gitignore` |
| Add `.flatpak` to git | Binary bundle bloats repo | Generate locally with `--bundle` |
| Hardcode paths | Reduces portability | Use variables and `/app/` paths |
| Use tabs in YAML | Inconsistent with project style | Use 4-space indentation |
| Commit handoff files | Leaks internal context | Use `git reset` before commit |

---

## Quick Reference

**Build Commands:**

```bash
# Standard build + user install
./build-flatpak.sh

# System-wide install
sudo ./build-flatpak.sh --system

# Create bundle for distribution
./build-flatpak.sh --bundle

# Self-contained (includes runtime)
./build-flatpak.sh --standalone
```

**Runtime Versions:**

- Current: `24.08` (org.freedesktop.Platform//24.08)
- OpenJDK extension: `org.freedesktop.Sdk.Extension.openjdk//24.08`

**App ID:** `com.ibm.iaccess`

---

*For project methodology and workflow, see .clio/instructions.md*
