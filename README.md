# 🧠 Ephemeral Mind

A beautiful, privacy-focused **offline journaling and note-taking app**, built with Flutter.  
It works **completely without internet**, including user authentication, making it ideal for private, personal use anywhere.

---

## ✨ Features

- 🔐 **Offline-first user authentication** (no external servers or APIs)
- 📝 **Journal entries stored locally** using Isar (NoSQL DB for Flutter)
- 🎨 **Dark/light theme switcher**
- 📦 **Data persistence** using Isar + SharedPreferences
- 🎬 **Smooth animations** for a polished UX
- 🖼️ **Profile image support** (with local image picker)
- 📆 **Timestamped notes** for chronological organization
-  **Supports multiple languages** using Flutter's localization system.
- 🧠 Simple and minimalistic UI for mindful journaling

---

## 🚀 Demo

> 🎥 Watch the short demo video on YouTube https://youtube.com/shorts/fbP2OOe48rk?feature=shared 
> 📱 [Download the APK](https://github.com/mdex-geek/Ephemeral-Mind/blob/main/app-release.apk) to try it yourself

## 🧰 Tech Stack

| Category | Package |
|---------|---------|
| State Management | `flutter_bloc` |
| Database | `isar`, `isar_flutter_libs` |
| Dependency Injection | Custom (no 3rd party) |
| Image & File Handling | `image_picker`, `path_provider` |
| Localization | `flutter_localization` |
| Storage | `shared_preferences` |
| Others | `uuid`, `crypto`, `equatable` |

---

## 🛠️ Getting Started

```bash
# Clone the repo
git clone https://github.com/mdex-geek/Ephemeral-Mind.git
cd Ephemeral-Mind

# Install dependencies
flutter pub get

# Run the app
flutter run


