# NeuroLens Web UI

The first archived version of a Flutter web dashboard for cognitive health monitoring, designed for caregivers and healthcare professionals, for the project 'Neurolens'.

## Getting Started

```bash
flutter pub get
flutter run -d chrome
```

## Build for Production

```bash
flutter build web
```

The build output is in `build/web/`.

## Project Structure

- `lib/main.dart` — Entry point
- `lib/config/` — API configuration
- `lib/providers/` — State management (Provider)
- `lib/screens/` — UI screens
- `lib/services/` — API services
- `lib/utils/` — Helper utilities
- `lib/widgets/` — Reusable components
- `web/` — Web assets

## Backend

Works with the backend API at `localhost:6767`.

## Test Credentials

- Patient ID: `P001`
- Password: `password`
