# ProjekTask

A Flutter mobile app for **Project & Task management**, built for the Sarastya
project-based test. It consumes the ProjekTask REST API: users register/log in,
create projects, and manage tasks within each project (with a todo →
in_progress → done workflow).

---

## ✨ Features

- **Authentication** — register, login, and a session that survives app
  restarts. The JWT is stored in the device's encrypted storage.
- **Auto-attached bearer token** — every API call carries the token via a Dio
  interceptor; a `401` cleanly logs the user out and returns them to login.
- **Projects** — list (with per-project task counts), create, edit, and delete
  (with a confirmation dialog).
- **Tasks** — per-project task list, create/edit/delete, and one-tap status
  changes with clear, colour-coded badges.
- **Polished UX** — loading spinners, empty/error states, pull-to-refresh, and a
  SnackBar for every success/failure.

---

## 🧱 Tech stack

| Concern | Choice |
|---|---|
| Framework | Flutter (Material 3) |
| State management | **Provider** (`ChangeNotifier`) |
| Navigation | **go_router** (with an auth redirect guard) |
| HTTP | **Dio** + interceptor (bearer token + 401 handling) |
| Secure storage | **flutter_secure_storage** (JWT) |
| Dates | intl |

---

## 📁 Project structure

```
lib/
├── config/        # ApiConfig — single source of truth for the base URL
├── models/        # User, Project, ProjectDetail, Task (+ TaskStatus)
├── services/      # ApiClient (Dio + interceptor), Auth/Project/Task services
├── providers/     # AuthProvider, ProjectProvider, ProjectDetailProvider
├── screens/       # splash, login, register, projects, project detail
├── widgets/       # reusable UI (cards, form sheets, status chip, task tile)
├── router/        # go_router config + auth redirect
├── utils/         # API error parsing (handles both backend error shapes)
└── main.dart      # dependency wiring + MultiProvider + MaterialApp.router
```

The dependency graph is composed once in `main.dart` and exposed through
`Provider`/`ChangeNotifierProvider`. Services depend on a single shared
`ApiClient`; providers depend on services; screens read providers.

---

## 🌐 API configuration

The backend base URL lives in **one** place — [`lib/config/api_config.dart`](lib/config/api_config.dart):

```dart
static const String origin  = 'http://18.143.171.142:8080';
static const String baseUrl = '$origin/api';   // all REST endpoints
static const String healthUrl = '$origin/health'; // connectivity check
```

### HTTP cleartext (important)

The backend is served over **HTTP**, which Android blocks by default. Cleartext
is enabled **only for the backend host** (not globally) via a scoped network
security config:

- [`android/app/src/main/res/xml/network_security_config.xml`](android/app/src/main/res/xml/network_security_config.xml)
  permits cleartext for `18.143.171.142` only.
- It is referenced from `AndroidManifest.xml`
  (`android:networkSecurityConfig="@xml/network_security_config"`), alongside the
  `INTERNET` permission.

---

## 🚀 Getting started

### Prerequisites
- Flutter SDK (Dart `^3.12`)
- An Android emulator or device

### Run

```bash
flutter pub get
flutter run
```

### Build a release APK

```bash
flutter build apk --release
```

The APK is written to:

```
build/app/outputs/flutter-apk/app-release.apk
```

---

## 🔌 API endpoints used

| Method | Path | Purpose |
|---|---|---|
| POST | `/auth/register` | Register + receive token |
| POST | `/auth/login` | Login + receive token |
| GET | `/auth/me` | Validate session |
| GET | `/projects` | List projects (with task counts) |
| GET | `/projects/{id}` | Project detail + tasks |
| POST | `/projects` | Create project |
| PUT | `/projects/{id}` | Update project |
| DELETE | `/projects/{id}` | Delete project (cascade) |
| POST | `/projects/{projectId}/tasks` | Create task |
| PUT | `/tasks/{id}` | Update task / change status |
| DELETE | `/tasks/{id}` | Delete task |

Task status values: `todo`, `in_progress`, `done`.

---

## 🔐 Auth & error handling notes

- The token is sent as `Authorization: Bearer <token>` on every request by the
  Dio interceptor.
- On any `401`, the interceptor deletes the stored token and notifies
  `AuthProvider`, which drops the user back to the login screen and shows a
  "session expired" message.
- The API returns two error shapes — validation errors
  (`ValidationProblemDetails` with an `errors` map) and a generic
  `{ "message": ... }`. [`utils/api_error.dart`](lib/utils/api_error.dart)
  normalises both (plus transport failures) into a friendly message.
