# 🏋️ PowerRep - Gym Training App (Offline-First)

## 📌 Project Overview
PowerRep is a Flutter-based mobile application designed for gym training and fitness tracking. The app is **offline-first**, meaning all core functionality works without internet access. Data is stored in-memory and persists across sessions via local storage.

A lightweight mock backend service exists for **manual content updates** (exercise data, plans, etc.). Once synced, all data is stored locally.

---

## 🎯 Core Objectives
- Provide structured gym training content.
- Work fully offline after initial data load.
- Maintain persistent local data (Favorites).
- Deliver a modern gym-style UI (Dark Theme).
- Support scalable exercise content via a manual sync system.

---

## 🧱 Architecture

### 📦 App Type
- Flutter Mobile App (Android/iOS)
- Offline-first architecture

### 💾 Data Strategy
- **In-Memory State**: Managed by Riverpod `Notifier`.
- **Persistence**: `shared_preferences` is used to persist user favorites.
- **No Database**: The app uses static/local JSON-like structures via a `MockDataService`.

---

## 🔄 Backend Sync Strategy
- Sync happens manually via the "Sync" button on the Home Screen.
- `MockDataService` simulates fetching the latest dataset (Exercises, Categories, Plans).
- The app merges/replaces local state with the fetched data.

---

## 🧩 Features

### 🏋️ Exercise System
- List of exercises categorized by muscle groups.
- Categories: Chest, Back, Legs, Arms, Shoulders, Cardio.
- Each Exercise contains: Name, Description, Target Muscle, Difficulty, GIF animation URL, Steps, Duration, Sets, and Reps.

### 📄 Exercise Details Page
- Custom `SliverAppBar` with large GIF preview.
- Interactive favorite toggle.
- Detailed step-by-step instructions.
- Exercise stats (Duration, Sets, Reps).

### 📅 Weekly Plan
- Predefined 7-day workout plan.
- Daily goal overview on the Home Screen.
- Detailed breakdown of exercises for each day.

### ⭐ Favorites
- Mark/unmark exercises as favorites.
- Dedicated Favorites screen for quick access.
- Persisted locally across app restarts.

### 🔍 Search & Filter
- Search exercises by name.
- Filter exercises by muscle group using `FilterChip` widgets.

---

## 🎨 UI/UX Guidelines

### Theme
- **Dark Theme**: Scaffolding background `#0F0F0F`, Surface `#1E1E1E`.
- **Accent**: `Colors.redAccent` for high energy.
- **Typography**: Google Fonts (Montserrat).

### App Identity
- **Name**: PowerRep
- **Logo**: Custom `PowerRepLogo` widget featuring a fitness icon with neon accents.

---

## 🧠 State Management
- **Riverpod**: Used for all global state (Exercises, Categories, Plans, Favorites).
- **Notifier**: `DataNotifier` handles data fetching, syncing, and favorite toggling.

---

## 📂 Project Structure
lib/
├── models/         # Exercise, Category, WorkoutPlan
├── services/       # MockDataService (Simulated BE)
├── providers/      # Riverpod DataProvider & State
├── screens/        # Home, Detail, List, Plan, Favorites, Search
├── widgets/        # Logo, Custom Cards, Stats
└── main.dart       # App Theme & ProviderScope

---

## ⚙️ Development Commands
- `flutter run`: Launch the app.
- `flutter analyze`: Check for code issues.
- `flutter test`: Run widget tests.

---

## 📌 Summary
PowerRep is a robust, visually striking gym companion that prioritizes performance and offline reliability. It uses modern Flutter patterns (Riverpod, Material 3) to deliver a seamless user experience without the complexity of a local database.
