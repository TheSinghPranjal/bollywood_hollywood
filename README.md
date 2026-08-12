# Movie Guess — Bollywood & Hollywood

A Flutter movie-title guessing game: vowels and numbers are revealed, consonants are hidden, and you have 10 **BOLLY-WOOD** / **HOLLY-WOOD** lives.

## Features

- 50 Bollywood + 50 Hollywood titles (`assets/data/movies.json`)
- Riverpod state management + pure, unit-tested `GameEngine`
- Industry filter, dual year-range slider, configurable timer & hints
- Progressive hints on wrong-guess strikes 6–9
- Pause / resume, rewarded +1 life (test ads), interstitial between rounds
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
