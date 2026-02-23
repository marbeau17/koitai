# App Icon

Place the following icon files in this directory:

## app_icon.png
- Size: 1024x1024 pixels
- Format: PNG with transparency
- Design: Heart + Moon + Stars theme
- Primary color: #6C3FE0 (purple)
- This is used as the main app icon for all platforms

## app_icon_foreground.png
- Size: 1024x1024 pixels
- Format: PNG with transparency
- Design: Foreground layer for Android adaptive icons
- Should contain only the logo/symbol centered within the safe zone (66% of the total area)
- The background color (#6C3FE0) is applied separately by the adaptive icon system

## Generation
After placing the icon files, run:
```bash
dart run flutter_launcher_icons
```
