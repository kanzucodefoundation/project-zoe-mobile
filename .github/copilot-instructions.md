```instructions
# Project Zoe — Copilot / AI Agent Guidance

This file gives focused, actionable knowledge for AI coding agents working on Project Zoe (Flutter). Keep updates concise and reference code locations.

- **Big picture:** Hybrid migration to Clean Architecture. Legacy UI lives in `lib/Screens/`; new features in `lib/features/` follow domain/data/presentation layers. Providers sit under `lib/providers/` and are used by UI and `MultiProvider` in `lib/main.dart`.

- **Startup & integration hooks:** `main.dart` calls `ApiClient().initialize()` and `notificationService.initNotification()` — preserve these initialization calls when refactoring startup flows.

- **API layer:** `lib/api/api_client.dart` is a singleton wrapping Dio. Base URL is configured in `lib/api/base_url.dart`. Use service classes in `lib/services/` (e.g., `AuthService`) to call `ApiClient` rather than instantiating Dio directly.

- **State & DI patterns:** State uses Provider + `ChangeNotifier`. Providers are typically constructed in `main.dart` via `ChangeNotifierProvider`. Dependency injection is provided via `injection/` (get_it). When adding services, register them in the DI container and prefer constructor injection for providers.

- **Auth & navigation:** `lib/widgets/app_wrapper.dart` determines auth state and routes. Do not bypass `AppWrapper` for auth transitions; use `AuthProvider` status flags for navigation decisions. Session persistence uses `SharedPreferences` (see AuthProvider implementation).

- **Testing & dev helpers:** Tests live in `test/` (including `login_test.dart`). A local/mock server is documented in `server_readme.md`. See `NETWORK_NAVIGATION_FIXES.md` for offline dev fallbacks and test credentials used in development flows.

- **Conventions & style cues:**
	- File names: snake_case; screen files often end with `_screen.dart`.
	- UI: Material 3 with a pure-white scaffold background (search for `scaffoldBackgroundColor: Color(0xFFFFFFFF)`).
	- Logging: debug prints often use emoji prefixes (🔄, ✅, ❌) — follow for consistent logs.
	- Forms: use `GlobalKey<FormState>` and dispose `TextEditingController`s in widgets.

- **Practical examples:**
	- Register a provider: check `lib/main.dart` MultiProvider setup for `AuthProvider`, `ReportProvider`, etc.
	- Call API: use `AuthService.loginUser()` which uses `ApiClient()` rather than raw Dio calls.

- **Common tasks & commands:**
	- Install deps: `flutter pub get`
	- Run app: `flutter run`
	- Run tests: `flutter test`
	- Build release: `flutter build apk --release`

- **Where to look first (fast onboarding):**
	1. `lib/main.dart` — app bootstrap and provider registration
	2. `lib/widgets/app_wrapper.dart` — auth-driven routing
	3. `lib/api/api_client.dart` and `lib/api/base_url.dart` — networking
	4. `lib/features/auth/` — canonical example of Clean Architecture layering

If anything above is unclear or you want examples expanded (DI setup, an example provider, or common refactors), tell me which area and I will extend this file.
```

- **Dynamic form generation** from report template fields
