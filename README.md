# Stretching

![Icon](./icon.png?raw=true 'Icon')

## Requirements

- Flutter: `2.5.0-5.0.pre`
- Dart SDK: `2.14.0-377.0.dev`

## Versions

- Android SDK: `16-30`
- IOS: `10-14`

### Build

flutter build apk --target "lib/main.dart" --release --split-per-abi --split-debug-info --obfuscate

### Update Dependencies

dart pub upgrade --null-safety --precompile

### Generate Assets

flutter pub run "tool/generate_assets.dart" --class-name AssetsCG --output-file "lib\\generated\\assets.g.dart" --exclude "\\fonts\\"

### Generate Localization

flutter pub run "tool/generate_localization.dart" -f keys -S "assets/translations" -O "lib/generated" -o localization.g.dart

### Create Launch Icons

flutter pub run flutter_launcher_icons:main

### Native Splash

flutter pub run flutter_native_splash:create
flutter pub run flutter_native_splash:remove

### Localization

- `resConfigs` in app/gradle defaultOptions
