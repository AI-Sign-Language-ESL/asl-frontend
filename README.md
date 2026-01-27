<a id="readme-top"></a>

<div align="center">
  <a href="https://github.com/AI-Sign-Language-ESL/asl-frontend">
    <img src="https://avatars.githubusercontent.com/u/228776460?s=400&u=c69294e3b9a90eed4ef31dc37ee3ced57c2add89&v=4"
         alt="TAFAHOM Logo"
         height="150"
         style="border-radius: 12px">
  </a>

  <h2 align="center">ASL Flutter App</h2>

  <p align="center">
    Cross-platform Flutter application for Arabic Sign Language translation 🤟📱
    <p align="center">
      <img alt="GitHub License" src="https://img.shields.io/github/license/AI-Sign-Language-ESL/asl-frontend">
      <img alt="Flutter" src="https://img.shields.io/badge/Flutter-3.x-blue">
      <img alt="Dart" src="https://img.shields.io/badge/Dart-3.x-blue">
      <img alt="GitHub issues" src="https://img.shields.io/github/issues/AI-Sign-Language-ESL/asl-frontend">
   
</div>

---

## 📌 About The Project

**ASL Flutter App** is the frontend client for the **ASL / Tafahom API**, designed to provide an intuitive and accessible interface for Arabic Sign Language translation.

The app allows users to:
- Translate **text → sign language**
- Translate **voice → sign language**
- Translate **sign video → text**
- Translate **sign video → voice**
- Use **real-time streaming translation** via WebSockets

The app is built using **Flutter**, enabling deployment on **Android, iOS, and Web** from a single codebase.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

---

## 🚀 Key Features

- 📱 **Cross-platform** (Android, iOS, Web)
- 🤟 **Sign → Text** translation
- 🔤 **Text → Sign** translation
- 🎙️ **Voice input support**
- 🎥 **Camera & video upload**
- 📡 **Live WebSocket streaming**
- 🔐 **JWT Authentication & Google Sign-In**
- 🎨 **Modern, accessible UI**

<p align="right">(<a href="#readme-top">back to top</a>)</p>

---

<a id="getting-started"></a>

### 🛠️ Getting Started

Follow these steps to run the Flutter app locally.

---

### 📦 Prerequisites

Make sure you have:

- Flutter **3.x+**
- Dart **3.x**
- Android Studio / VS Code
- Android Emulator or physical device
- ASL Backend API running

### Check Flutter installation:

```sh
flutter doctor
```
### ⚙️ Installation

1. Clone the repository
```sh
git clone https://github.com/AI-Sign-Language-ESL/asl-frontend.git
```
3. Navigate to the project directory
```sh
cd asl-frontend
```
5. Install Flutter dependencies
```sh
flutter pub get
```

### Run the app

1. For mobile:
```sh
flutter run
```
3. For web:
```sh
flutter run -d chrome
```
<p align="right">(<a href="#readme-top">back to top</a>)</p>
🔧 Usage
🔤 Text Translation
Enter Arabic text and receive:

Gloss

Sign video

🎙️ Voice Translation
Speak Arabic and receive sign translation.

🎥 Sign Video Translation
Upload or record sign language video to receive:

Text

Voice output

📡 Live Streaming
Enable live translation using WebSocket connection for continuous recognition.
