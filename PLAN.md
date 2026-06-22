# Sarastya Cloud Drive — Mobile (Flutter) repo plan

> This repo (`Sarastya-project-mobile`) is the **Flutter** client for **Sarastya Drive**, a
> Telegram-backed cloud drive. Part of a 4-repo system (see umbrella `Sarastya-project`). Work on
> branch **`feat/cloud-drive`**; `main` keeps the old ProjekTask app.
>
> **Cross-agent source of truth** — no agent-specific memory is used. Status: ☐ todo · ◐ wip · ☑ done

## Scope: focused client

Repurpose the existing Flutter scaffold (Provider · Dio · flutter_secure_storage · go_router).
Target a clean, demo-solid **read/stream client** — not full parity.

**In scope:** splash, login/register (JWT), drive browse (folders + items grid), search, item /
media detail, image viewing, **video streaming** (point `<video>`/player at the stream domain),
download trigger (open the bot deep link), loading/empty/error states.
**Out of scope (for now):** uploads, trash/restore, private-space PIN, metadata editing.

## API access
- Dio base URL → **`https://drive.tncp.web.id/papi`** (the web proxies this to the .NET API; fits
  the 2-domain constraint, no separate API host). JWT in interceptor + secure storage (scaffold
  already has `services/api_client.dart`, `token_storage.dart`, `utils/api_error.dart`).
- Stream URLs come from `GET /papi/items/{id}/stream-info`; video plays from **stream.tncp.web.id**.

## Tasks
- 4A ☐ Models: `User, Folder, Item, Part, Tag` (replace Project/Task). Dio base URL + JWT interceptor.
       Services: `auth_service`, `drive_service` (browse/search/detail), `stream_service`.
- 4B ☐ Screens: splash, login, register, drive browse (grid + folder nav), search, item/media
       detail, video player, download action.
- 4C ☐ Loading/error feedback; theme; build APK; README + APK release instructions.

## Build
- `flutter build apk --release` → attach to a GitHub Release on this repo (brief requires installable
  APK + instructions). Android first; iOS optional.
