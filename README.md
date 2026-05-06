# 🏋️ PowerRep - Gym Training App

PowerRep is a Flutter-based mobile application designed for gym training and fitness tracking. The app is **offline-first**, meaning all core functionality works without internet access. Data is stored locally and persists across sessions.

## 🎯 Features

- **Offline-First Architecture**: Works fully offline after initial data load.
- **Exercise Library**: Comprehensive list of exercises categorized by muscle groups (Chest, Back, Legs, Arms, Shoulders, Cardio).
- **Workout Plans**: Structured training plans to guide your workouts.
- **Favorites**: Save your favorite exercises for quick access.
- **Detailed Exercise Pages**: Step-by-step instructions, GIF animations, and stats (Duration, Sets, Reps).
- **Modern UI**: Dark theme with a gym-style design.
- **Manual Sync**: Update exercise data and plans via a sync button.

## 🛠️ Tech Stack

- **Framework**: Flutter
- **State Management**: Riverpod
- **Local Storage**: Shared Preferences
- **Backend**: Firebase (Auth, Firestore, Storage) for potential future features
- **Image Handling**: Image Picker, Cached Network Image
- **Fonts**: Google Fonts

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (^3.11.5)
- Dart SDK (^3.11.5)
- Android Studio or Xcode for mobile development
- Firebase account (for setup)

### Installation

1. **Clone the repository**:
   ```bash
   git clone https://github.com/yourusername/powerrep.git
   cd powerrep
   ```

2. **Install dependencies**:
   ```bash
   flutter pub get
   ```

3. **Firebase Setup**:
   - Create a Firebase project at [Firebase Console](https://console.firebase.google.com/).
   - Enable Authentication, Firestore, and Storage.
   - Download `google-services.json` for Android and place it in `android/app/`.
   - For iOS, download `GoogleService-Info.plist` and place it in `ios/Runner/`.
   - Update `lib/firebase_options.dart` with your Firebase config.

4. **Run the app**:
   - For Android: `flutter run`
   - For iOS: `flutter run` (on macOS with Xcode)

### Building

- **Debug Build**: `flutter run`
- **Release Build**:
  - Android: `flutter build apk` or `flutter build appbundle`
  - iOS: `flutter build ios` (requires macOS)

## 📱 Usage

1. **Launch the App**: Open PowerRep on your device.
2. **Browse Exercises**: Navigate through categories to find exercises.
3. **View Details**: Tap on an exercise for instructions and animations.
4. **Mark Favorites**: Use the heart icon to save exercises.
5. **Sync Data**: Tap the sync button on the home screen to update content.

## 🏗️ Architecture

- **In-Memory State**: Managed by Riverpod Notifiers.
- **Persistence**: User favorites stored via Shared Preferences.
- **Data Service**: MockDataService for simulating backend sync.
- **Models**: Exercise, Category, WorkoutPlan classes.

## 🤝 Contributing

Contributions are welcome! Please fork the repository and submit a pull request.

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 📞 Contact

For questions or support, please open an issue on GitHub.
