# VSCode Settings Management

## Overview

This directory tracks **non-theme VSCode settings** that should be consistent across all machines. Theme and appearance settings are kept **machine-specific** to allow different preferences per machine.

## Current Approach

**Manual Filtering**: We track `settings.json` but manually exclude theme/appearance settings from commits. This allows:
- Consistent editor behavior across machines (formatting, keybindings, extensions)
- Machine-specific themes, fonts, and appearance

## Theme/Appearance Settings (DO NOT COMMIT)

The following settings should be kept **local-only** (not committed to git):

### Must Exclude
- `workbench.colorTheme` - Color theme
- `workbench.preferredDarkColorTheme` / `workbench.preferredLightColorTheme`
- `workbench.iconTheme` - Icon theme
- `workbench.productIconTheme` - Product icons
- `workbench.colorCustomizations` - Custom colors
- `editor.tokenColorCustomizations` - Syntax colors

### Should Exclude (Machine-Specific)
- `window.autoDetectColorScheme` - Light/dark auto-switching
- `window.zoomLevel` - Display zoom
- `editor.fontSize` - Font size (varies by display DPI)
- `editor.fontFamily` - Font family (may not exist on all machines)
- `terminal.integrated.fontSize` - Terminal font size
- `terminal.integrated.fontFamily` - Terminal font

## Current Status

The tracked `settings.json` currently contains:
- ✅ Editor behavior settings (word wrap, tab size, rulers)
- ✅ Language-specific formatters
- ✅ Extension configurations
- ⚠️  `window.autoDetectColorScheme: true` (line 100) - **Consider removing if you want per-machine control**
- ⚠️  Font settings (lines 15, 16, 17, 113) - **Currently tracked, override locally if needed**

## Recommended Workflow

1. **Keep theme settings out of settings.json entirely**
   - Let VSCode manage them in its user settings
   - Don't add theme-related keys to this file

2. **If you need machine-specific overrides**
   - VSCode supports machine-specific settings via Settings Sync
   - Or: manually edit locally but don't commit theme changes

3. **Before committing**
   - Review `git diff` for settings.json
   - Ensure no theme/appearance settings slipped in
   - Only commit behavioral/functional settings

## Future Improvement Ideas

- [ ] Add pre-commit hook to detect theme settings
- [ ] Create git clean/smudge filter to auto-strip theme keys
- [ ] Split into base + local files with merge script
