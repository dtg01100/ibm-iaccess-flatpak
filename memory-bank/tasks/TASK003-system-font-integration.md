# TASK003 - System Font Integration for Flatpak

**Status:** Pending  
**Added:** 2025-08-07  
**Updated:** 2025-08-07

## Original Request
Create a new task to attempt to have IBM i Access font settings follow the system font settings when running as a Flatpak.

## Thought Process
- Flatpak applications are sandboxed and may not inherit all system font settings by default.
- Fontconfig errors indicate limited access to host font configuration files.
- The goal is to make the application use system fonts and respect system font settings for consistency and accessibility.
- This may require additional Flatpak permissions, use of font extensions, or configuration tweaks.

## Implementation Plan
- [ ] Research Flatpak best practices for system font integration and fontconfig support.
- [ ] Test additional finish-args and font extension usage.
- [ ] Investigate if mounting or exporting system font configuration files is possible/safe.
- [ ] Document findings and update manifest as needed.
- [ ] Validate that IBM i Access respects system font settings in the Flatpak sandbox.

## Progress Tracking
**Overall Status:** Not Started - 0%

### Subtasks
| ID  | Description                                      | Status      | Updated     | Notes |
|-----|--------------------------------------------------|-------------|-------------|-------|
| 3.1 | Research Flatpak font integration                | Not Started | 2025-08-07  |       |
| 3.2 | Test finish-args and font extension changes      | Not Started | 2025-08-07  |       |
| 3.3 | Investigate fontconfig file mounting/export      | Not Started | 2025-08-07  |       |
| 3.4 | Document and update manifest                     | Not Started | 2025-08-07  |       |
| 3.5 | Validate font settings in Flatpak                | Not Started | 2025-08-07  |       |

## Progress Log
### 2025-08-07
- Task created to address system font integration for Flatpak IBM i Access.
- Initial plan and subtasks outlined.
- Researched Flatpak fontconfig and system font integration best practices.
- Updated manifest to add --filesystem=xdg-config/fontconfig:ro for host fontconfig access.
- Tested: IBM i Access still does not fully inherit system font settings due to Flatpak sandboxing limitations.
- Workaround: Users can manually copy ~/.config/fontconfig to ~/.var/app/com.ibm.iaccess/config/fontconfig to apply custom font settings in Flatpak.
- Task status: Partial solution documented; monitoring Flatpak upstream for future improvements.
