# Project Zoe - Flutter Church Management App

## Architecture Overview

This is a Flutter mobile app transitioning from legacy code to **Clean Architecture** with Provider pattern state management. The app uses a hybrid structure during migration:

### Directory Structure

- `lib/Screens/` - **Legacy screens** (being migrated out)
- `lib/features/` - **New Clean Architecture modules** (auth feature implemented)
- `lib/providers/` - **Provider pattern state management** (AuthProvider, ReportProvider, etc.)
- `lib/api/` - **Centralized API layer** with Dio HTTP client
- `lib/services/` - **Business logic services** (AuthService, ReportsService)
- `lib/models/` - **Data models** with JSON serialization

## Key Patterns & Conventions

### Authentication Flow

- **AppWrapper** (`lib/widgets/app_wrapper.dart`) handles route management based on `AuthProvider.status`
- **Session persistence** via SharedPreferences and AuthGuard
- **Fallback authentication** for development when backend is down (see `NETWORK_NAVIGATION_FIXES.md`)
- Test credentials: `john.doe@kanzucodefoundation.org` / `Xpass@123` / `demo`

### API Integration

- **Singleton ApiClient** (`lib/api/api_client.dart`) with Dio interceptors for logging
- **Base URL configuration** in `lib/api/base_url.dart` - typically `http://localhost:4002`
- **Type-safe API models** in `lib/api/api_models.dart` with proper JSON serialization
- **Service layer** abstracts API calls from providers (e.g., `AuthService.loginUser()`)

### State Management

- **Provider pattern** with ChangeNotifier for all screen state
- **Enum-based status tracking** (AuthStatus, loading states) in providers
- **Error handling** with user-friendly messages in providers
- Each screen typically has its own provider (e.g., `ReportProvider`, `DashboardProvider`)

### Report System Architecture

- **Template-based reports** loaded from `/reports/:id` endpoint
- **Dynamic form generation** from report template fields
- **Multi-group support** - users can submit reports for multiple MCs/groups
- **Hierarchical group structure** - Fellowship → Zone → Location → FOB → Network

## Development Workflow

### Running the App

```bash
flutter pub get
flutter run
```

### Backend Dependencies

- **Mock server** available in project root (see `server_readme.md`)
- **Test accounts** with different permission levels (MC Shepherd → Movement Leader)
- **Network fallback** allows development without running backend

### Testing

- Widget tests in `test/` directory
- Authentication tests in `login_test.dart`
- Run with `flutter test`

## Critical Implementation Notes

### Screen Navigation

- Use **AppWrapper** status-based navigation, not direct route pushing for auth
- **MainScaffold** handles authenticated app navigation with GNav bottom bar
- Legacy screens use named routes in `main.dart`

### Form Patterns

- **Custom components** in `lib/components/` (TextFieldComponent, DropdownComponent, CustomDatePicker)
- **Form validation** with GlobalKey<FormState> and TextEditingController disposal
- **Submit states** with loading indicators and error messages

### API Error Handling

- **Network detection** with fallback to test credentials
- **Detailed logging** via Dio interceptors for debugging
- **User-friendly error messages** displayed in UI, technical errors logged to console

### Data Models

- Models implement **fromJson/toJson** for API serialization
- **Separate API models** vs domain models (e.g., `LoginRequest`, `AuthResponse`)
- Use **null-safe** Dart patterns consistently

### Code Style

- **Material Design 3** with custom white theme (`scaffoldBackgroundColor: Color(0xFFFFFFFF)`)
- **Consistent debug prints** with emoji prefixes for easy filtering (🔄, ✅, ❌)
- **File naming** uses snake_case, screens end with `_screen.dart`

## Integration Points

### Church Management System

- **Multi-tenant** architecture with church selection during login
- **Role-based permissions** system (see `lib/helpers/app_permissions.dart`)
- **Hierarchical group management** with dynamic loading

### Notifications

- **Flutter Local Notifications** configured in `lib/services/notification_service.dart`
- Timezone support for scheduled notifications

### Local Storage

- **SharedPreferences** for authentication tokens and user data
- **Session management** through AuthGuard utility class
