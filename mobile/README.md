# MiniTransfer Mobile 🚀

MiniTransfer is a premium, high-fidelity fintech mobile application built with Flutter. It provides a seamless and secure experience for instant money transfers, featuring a modern dark/light UI and full bilingual support.

## ✨ Key Features

- **Professional UI/UX**: Custom-designed interface matching premium fintech standards.
- **Multilingual Support**: Fully localized in **English** and **French** with an instant toggle.
- **Adaptive Theming**: Native support for **Dark Mode** (default) and **Light Mode**.
- **User Onboarding**: A beautiful Welcome Screen with branding and a quick debrief.
- **Secure Authentication**: Complete Login and Registration flow with validation.
- **Interactive Dashboard**: Real-time balance visibility (with toggle), quick actions, and recent transaction feed.
- **Advanced Transfer Flow**:
  - Custom numeric keypad for precise amount entry.
  - Interactive recipient search (by email) or manual entry.
  - Real-time amount formatting (FCFA).
- **Transaction History**: Color-coded and detailed list of all sent and received funds with localized date formatting.

## 🛠 Tech Stack

- **Framework**: Flutter (v3.10.4+)
- **State Management**: ValueNotifier & FutureBuilder
- **Backend Integration**: REST API (Spring Boot backend)
- **Local Storage**: SharedPreferences (for JWT, user ID, language, and theme preferences)
- **Networking**: Http package with custom ApiService interceptors

## 🚀 Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install)
- [Android Studio / VS Code](https://docs.flutter.dev/get-started/editor)
- A running instance of the [MiniTransfer Backend](https://github.com/your-repo/backend)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/your-username/minitransfer-mobile.git
   cd mobile
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure Backend URL**
   Edit `lib/config/constants.dart` and update the `baseUrl` to point to your local or hosted API.

4. **Run the app**
   ```bash
   flutter run
   ```

## 📁 Project Structure

```text
lib/
├── config/             # App constants and static configuration
├── models/             # Data models (User, Transaction, Requests/Responses)
├── screens/            # UI Screens organized by feature
│   ├── welcome/        # Landing & Language/Theme selection
│   ├── login/          # User authentication
│   ├── register/       # New user onboarding
│   ├── home/           # Dashboard & Balance overview
│   ├── transfer/       # Send money flow with custom keypad
│   └── history/        # Transaction records
├── services/           # Business logic & API integration
│   ├── api_service.dart      # HTTP base configuration
│   ├── auth_service.dart     # Login/Register logic
│   ├── user_service.dart     # Recipient search
│   ├── theme_service.dart    # Dark/Light mode management
│   ├── language_service.dart # Internationalization management
│   └── wallet_service.dart   # Balance operations
├── storage/            # Local persistence (TokenStorage)
├── widgets/            # Reusable UI components (Buttons, TextFields, Logo)
└── main.dart           # App entry point with Theme/Locale providers
```

## 🌍 Localisation & Theme

The app uses a custom `LanguageService` and `ThemeService` to persist user choices across sessions. Settings can be toggled directly from the **Welcome** or **Home** screens.

---

Made with ❤️ for MiniTransfer.
