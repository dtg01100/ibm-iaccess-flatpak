# Release Notes

## v1.0.0
- **Type:** Third-party Flatpak packaging wrapper
- **Git tag:** v1.0.0
- **Tested ACS payload:** 1.1.9.3 (place your licensed IBM i Access files in `IBMiAccess_v1r1/` before building)
- **Bundle name:** `ibm-iaccess.flatpak`
- **Runtime/SDK:** org.freedesktop.Platform//24.08, org.freedesktop.Sdk//24.08
- **OpenJDK extension:** org.freedesktop.Sdk.Extension.openjdk//24.08

### Checksums
```
sha256: 1136f88cce46faab9adcfdd84fe205b903b4218558c265c59d91cbd618de91f5
```

### Notable changes
- Cleaned build commands (removed redundant debug/chmod placeholder, removed unused icon source entry).
- Added chmod to fix permissions on IBM binaries during build.
- Removed unused `fontconfig-flatpak.xml`.
- Documented semantic tagging starting at v1.0.0 (via git tags, not manifest).

### Known limitations
- User install only (`--user`).
- Fontconfig sync is best-effort; sandbox constraints may still limit rendering.
- Proprietary IBM payload is not included; you must supply it.
- Unofficial package; not supported by IBM.
