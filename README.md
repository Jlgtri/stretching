# Stretching

## ![Icon](./icon.png?raw=true 'Icon')

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

## Creating a class from YClients API

### Create a class at quicktype.io

1. Do a request the selected method. Retrieve a json response.
2. Go to `https://app.quicktype.io/` and paste a json there.
3. Select options:

   - `Put encoder & decoder in Class`
   - `Use method names fromMap() & toMap()`
   - `Make all properties required`
   - `Make all properties final`

4. Copy and paste to the local `.dart` file.

### Process a class to the required guidelines

1. Put `// ignore_for_file: sort_constructors_first` at the top of the file
   before imports and remove any module-level comments present.
2. Rename the model via `Change Occurences` with case-sensitive switch on.
3. Put `@immutable` decorator before the class declaration.
4. Make default factory consructor `const`.
5. Replace `@required this` with `required this` in the default factory
   constuctor. Can be united with `step 16`.
6. Change the order for json serialization - `toMap()`, `fromMap()`,
   `toJson()`, `fromJson()`.
7. Put the body of the serialization on the separate flow lines
   (using `return`).
8. Rename `fromMap()` `json` parameter to `map`.
9. Replace `Map<String, dynamic>` with `Map<String, Object?>`.
10. Add type casts and tweak serialization in `fromMap()`.
11. Add `<String, Object?>` type and tweak serialization in `toMap()`.
12. Use predefined converters in `utils/json_converters.dart` if necessary.
13. Run `dart fix --apply` to replace any double quotes to the single quotes.
14. Create `copyWith` and put it before json serialization `toMap()`.
15. Create `equality` and put it after json serialization `fromJson()`.
16. Put `identical` directly to the return with `||` operator.
17. Create `toString` and put it after `equality`.
18. Split the long `toString` one liner to lines < 80 chars while keeping
    `key`: `value` on a single line.
19. Make all class function parameters `final`.
20. Create a comment for a class definition and a default factory constructor.
21. Add comments for each parameter in the class.
22. Add static comments to each method in the class.
23. Check if class is valid and repeat for all generated classes.
