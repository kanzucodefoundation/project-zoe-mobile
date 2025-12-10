# Project Zoe - Church Management Mobile App

A Flutter mobile application for church management built with Clean Architecture principles.

## 📱 Features

- **Authentication System** - Login/logout functionality
- **Member Management** (Coming Soon)
- **Events & Services** (Coming Soon)
- **Donations & Finance** (Coming Soon)

## 🏗️ Architecture

This project follows **Clean Architecture** principles with clear separation of concerns:

```
lib/
├── core/                           # Shared core functionality
│   ├── error/                     # Error handling (Failures)
│   └── usecases/                  # Base usecase interface
├── features/                      # Feature modules
│   └── auth/                      # Authentication feature
│       ├── domain/                # Business logic layer
│       │   ├── entities/          # Core business objects
│       │   ├── repositories/      # Abstract repository contracts
│       │   └── usecases/          # Business use cases
│       ├── data/                  # Data layer
│       │   ├── datasources/       # Remote/Local data sources
│       │   ├── models/            # Data models & JSON mapping
│       │   └── repositories/      # Repository implementations
│       └── presentation/          # UI layer
│           ├── providers/         # State management (Provider pattern)
│           └── screens/           # UI screens
├── injection/                     # Dependency injection setup
└── Screens/                       # Legacy screens (to be moved to features)
```

### Architecture Layers

1. **Domain Layer** (Innermost)

   - Contains business entities, repository interfaces, and use cases
   - Independent of external frameworks
   - Pure Dart code with no Flutter dependencies

2. **Data Layer**

   - Implements repository interfaces from domain layer
   - Contains data sources (remote API, local storage)
   - Handles data transformation between external and domain formats

3. **Presentation Layer** (Outermost)

   - Contains UI components, state management, and user interactions
   - Depends on domain layer for business logic
   - Uses Provider pattern for state management

4. **Dependency Injection**

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (≥3.9.2)
- Dart SDK (≥3.9.2)
- Android Studio / VS Code
- Git

### Installation

1. **Clone the repository:**

   ```bash
   git clone https://github.com/kasujjabash/project-zoe-mobile-app.git
   cd project-zoe-mobile-app
   ```

2. **Install dependencies:**

   ```bash
   flutter pub get
   ```

3. **Run the app:**
   ```bash
   flutter run
   ```

### Dependencies

- **get_it**: Dependency injection
- **provider**: State management
- **equatable**: Value equality
- **dio**: HTTP client for API calls
- **shared_preferences**: Local storage

## 🧪 Testing

Run tests with:

```bash
flutter test
```

## 📁 Project Structure

### Adding New Features

When adding new features, follow this structure:

```
lib/features/your_feature/
├── domain/
│   ├── entities/
│   ├── repositories/
│   └── usecases/
├── data/
│   ├── datasources/
│   ├── models/
│   └── repositories/
└── presentation/
    ├── providers/
    └── screens/
```

### State Management Pattern

This project uses the **Provider** pattern:

1. Create a `ChangeNotifier` class in `presentation/providers/`
2. Register it in `injection_container.dart`
3. Wrap your app/widgets with `ChangeNotifierProvider`
4. Use `Consumer` or `context.watch/read` in widgets

## 🔗 Backend Integration

The app is designed to work with the NestJS backend located in the `../backend/` directory.

Current backend endpoints:

- Authentication: `/auth/login`
- Users: `/users`
- Churches: `/churches`
- Persons: `/persons`
- Roles: `/roles`

## 🤝 Contributing

1. Create a feature branch: `git checkout -b feature/your-feature-name`
2. Follow the Clean Architecture structure
3. Add tests for new functionality
4. Commit your changes: `git commit -m 'Add your feature'`
5. Push to the branch: `git push origin feature/your-feature-name`
6. Create a Pull Request

## 📝 Development Guidelines

- Follow Clean Architecture principles
- Use meaningful commit messages
- Write tests for business logic
- Keep widgets small and focused
- Use dependency injection for all services
- Follow Flutter/Dart style guidelines

## 🔧 Build Configuration

### Debug Build

```bash
flutter run --debug
```

### Release Build

```bash
flutter build apk --release          # Android APK
flutter build appbundle --release    # Android App Bundle
flutter build ios --release          # iOS
```

## 📱 Platform Support

- ✅ Android
- ✅ iOS
- ✅ Web
- ✅ Windows
- ✅ macOS
- ✅ Linux

## 📄 License

This project is licensed under the MIT License.

## 🚧 Roadmap

- [ ] Complete authentication flow with backend
- [ ] Member management system
- [ ] Event scheduling and management
- [ ] Donation tracking and reporting
- [ ] Push notifications
- [ ] Offline support
- [ ] Multi-language support
