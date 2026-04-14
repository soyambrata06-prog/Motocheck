# MotoCheck 🏍️

MotoCheck is a high-fidelity Flutter application designed for motorcycle enthusiasts to verify bike legality, monitor exhaust decibel levels, and access emergency SOS services. The app features a premium Black and White UI.

## 🚀 Features

- **Legality Check**: Verify if a bike's modifications are within legal limits.
- **SOS System**: Quick access to emergency services and roadside assistance.
- **Decibel Meter**: Measure exhaust noise levels in real-time.
- **Premium UI**: Clean, high-contrast Black and White design with smooth animations.
- **Multi-Tab Navigation**: Seamlessly switch between Home, Check, SOS, and Profile.

## 🛠️ Tech Stack

- **Framework**: Flutter
- **Language**: Dart
- **Architecture**: Feature-first (Clean Architecture principles)
- **Routing**: Centralized routing system
- **State Management**: (Planned) Provider/Riverpod

## 📱 Screenshots

*Coming Soon*

## 🏁 Getting Started

### Prerequisites

- Flutter SDK (latest stable version)
- Android Studio / VS Code
- Git

### Installation

1. **Clone the repository**:
   ```bash
   git clone https://github.com/soyambrata06-prog/Motocheck.git
   ```

2. **Navigate to the project directory**:
   ```bash
   cd motocheck
   ```

3. **Install dependencies**:
   ```bash
   flutter pub get
   ```

4. **Run the app**:
   ```bash
   flutter run
   ```

## 📂 Project Structure

```text
lib/
├── core/           # Theme, constants, shared services
├── data/           # Models and data sources
├── features/       # Feature-specific UI and logic
│   ├── auth/       # Login, Signup, Choice
│   ├── onboarding/ # Intro screens
│   ├── home/       # Dashboard
│   ├── check/      # Legality & Decibel check
│   └── sos/        # Emergency services
├── routes/         # Navigation config
└── shared/         # Common widgets
```

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📄 License

This project is licensed under the MIT License.
