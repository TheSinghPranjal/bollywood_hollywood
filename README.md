# Movie Guess — Bollywood & Hollywood

A Flutter movie-title guessing game: vowels and numbers are revealed, consonants are hidden, and you have 10 **BOLLY-WOOD** / **HOLLY-WOOD** lives.

## Features

- 50 Bollywood + 50 Hollywood titles (`assets/data/movies.json`)
- Riverpod state management + pure, unit-tested `GameEngine`
- Industry filter, dual year-range slider, configurable timer & hints
- Progressive hints on wrong-guess strikes 6–9
- Pause / resume, rewarded +1 life, interstitial between rounds
- Settings persisted with SharedPreferences

## Run

```bash
flutter pub get
flutter run
```

## Test / validate

```bash
flutter test
dart tools/validate_movies.dart
```

Regenerate the movie database:

```bash
python3 tools/generate_movies.py
```

## Configuring AdMob for release

Debug and profile builds always request Google's sample ad units, so they show **Test Ad**. Release builds (`flutter build appbundle`, `flutter build ipa`, `flutter run --release`) request the production IDs in [`config/admob.json`](config/admob.json). That file is the only place to paste them. The publisher account is `pub-8661918790125012`.

Create the apps and ad units in AdMob, then replace each `TODO_…` value:

| JSON key | What to paste | Format |
| --- | --- | --- |
| `ADMOB_ANDROID_APP_ID` | Android app → App settings → App ID | `ca-app-pub-8661918790125012~##########` |
| `ADMOB_ANDROID_BANNER_ID` | Android banner ad unit | `ca-app-pub-8661918790125012/##########` |
| `ADMOB_ANDROID_REWARDED_ID` | Android rewarded ad unit | `ca-app-pub-8661918790125012/##########` |
| `ADMOB_ANDROID_INTERSTITIAL_ID` | Android interstitial ad unit | `ca-app-pub-8661918790125012/##########` |
| `ADMOB_IOS_APP_ID` | iOS app → App settings → App ID | `ca-app-pub-8661918790125012~##########` |
| `ADMOB_IOS_BANNER_ID` | iOS banner ad unit | `ca-app-pub-8661918790125012/##########` |
| `ADMOB_IOS_REWARDED_ID` | iOS rewarded ad unit | `ca-app-pub-8661918790125012/##########` |
| `ADMOB_IOS_INTERSTITIAL_ID` | iOS interstitial ad unit | `ca-app-pub-8661918790125012/##########` |

Where those values are applied:

- **Dart ad units** read `config/admob.json` (it is a bundled asset). You can override any key at compile time with `--dart-define` or `--dart-define-from-file=config/admob.json`. The keys are the same names as in the JSON file.
- **Android App ID** is injected into `AndroidManifest.xml` as `${admobAppId}`. Gradle reads `ADMOB_ANDROID_APP_ID` from the JSON for release, and Google's sample App ID for debug and profile.
- **iOS App ID** is `$(GAD_APPLICATION_IDENTIFIER)` in `ios/Runner/Info.plist`. Debug and profile xcconfigs pin the sample App ID. Release reads `ios/Flutter/AdMob.xcconfig`, which is generated from the JSON:

```bash
dart run tool/sync_admob.dart
```

Run that after every edit to the iOS App ID. A release iOS build fails if the xcconfig is stale.

Release builds also fail, instead of silently shipping test ads, when an ID is empty, still a `TODO_…` placeholder, or still one of Google's sample IDs (`ca-app-pub-3940256099942544…`):

- `flutter build appbundle` / `flutter build apk --release` runs `dart run tool/validate_admob.dart --android` before packaging.
- Xcode Release runs `tool/validate_admob_ios.sh`.
- The release app itself throws on startup if the current platform's IDs are still invalid.

Android can ship before the iOS IDs exist. The Android check only looks at the four Android keys, and the iOS check only looks at the four iOS keys.

### Verify a release build shows real ads

1. Paste the real IDs into `config/admob.json` and run `dart run tool/sync_admob.dart`.
2. Build a release artifact, for example `flutter build appbundle`. The command fails with `error: Release Android AdMob IDs are still sample values or placeholders` until the Android keys are real.
3. Install that release build (Play internal testing, or `flutter run --release` on a device). In logcat or the Xcode console, filter for `AdMob`. A good release log looks like `AdMob mode: RELEASE` and every unit starts with `ca-app-pub-8661918790125012/`.
4. Confirm the banner, rewarded, and interstitial creatives are **not** labeled Test Ad. New production units can take a while to fill; a no-fill is different from a Test Ad.
5. `flutter run` (debug) and `flutter run --profile` should still log `AdMob mode: TEST` and show Test Ad. Those builds keep Google's sample App ID even after you fill in the JSON.

Interstitials stay on the existing cadence: every 5th Next Round, and not again until 90 seconds have passed. A rewarded extra life skips the next interstitial. On launch, the app requests UMP consent before initializing Mobile Ads. If a privacy-options entry point is required, Settings shows **Ad privacy choices**.

