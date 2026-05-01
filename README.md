# 📰 NewsApp — Flutter Final Project

A Flutter mobile application that provides a personalized news reading experience powered by [NewsAPI](https://newsapi.org).

---

## 🚀 Features

| Feature | Status |
|---------|--------|
| Registration & Login | ✅ |
| Home Screen with News Feed | ✅ |
| Detail Screen | ✅ |
| Favorites (Local Storage) | ✅ |
| External API Integration (NewsAPI) | ✅ |
| Settings Menu | ✅ |
| Settings Screen (Dark Theme, Region) | ✅ |
| Push Notifications | ✅ |

---

## 📁 Project Structure

```
lib/
├── main.dart                          # App entry point
├── models/
│   └── article.dart                   # Article data model
├── services/
│   ├── news_service.dart              # NewsAPI integration
│   ├── storage_service.dart           # SharedPreferences (auth + favorites)
│   └── notification_service.dart      # flutter_local_notifications
├── screens/
│   ├── login_screen.dart              # Login UI
│   ├── signup_screen.dart             # Registration UI
│   ├── home_screen.dart               # News feed
│   ├── detail_screen.dart             # Article detail
│   ├── favorites_screen.dart          # Saved articles
│   ├── settings_menu_screen.dart      # Settings menu
│   ├── settings_screen.dart           # App settings
│   └── notifications_screen.dart      # Notifications config
└── utils/
    └── app_theme.dart                 # Theme configuration
```

---

## ⚙️ Setup

### 1. Clone the repository
```bash
git clone https://github.com/YOUR_USERNAME/news_app.git
cd news_app
```

### 2. Get your NewsAPI key
- Register at [https://newsapi.org](https://newsapi.org)
- Copy your API key

### 3. Add your API key
Open `lib/services/news_service.dart` and replace:
```dart
static const String _apiKey = 'YOUR_NEWSAPI_KEY_HERE';
```

### 4. Install dependencies
```bash
flutter pub get
```

### 5. Run the app
```bash
flutter run
```

---

## 📦 Dependencies

```yaml
http: ^1.1.0                         # HTTP requests to NewsAPI
shared_preferences: ^2.2.2           # Local storage
flutter_local_notifications: ^16.3.0 # Push notifications
cached_network_image: ^3.3.1         # Image caching
url_launcher: ^6.2.4                 # Open articles in browser
intl: ^0.19.0                        # Date formatting
```

---

## 📸 Screens

- **Login** — Email + Password fields, login button, signup link
- **Signup** — Username + Email + Password fields, register button, login link
- **Home** — Category filter chips, news cards with images, settings icon in header
- **Detail** — Full article info, image, source badge, favorites button, "Read more" button
- **Favorites** — Saved articles list with swipe-to-delete
- **Settings Menu** — Profile card, menu items (Settings, Notifications, Profile, About, Logout)
- **Settings** — Dark theme toggle, language selector, region selector
- **Notifications** — Master toggle, notification types, time picker, test notification button

---

## 👤 User Stories

See [USER_STORIES.md](./USER_STORIES.md)

---

## 🛠 Built With

- **Flutter** 3.x / **Dart** 3.x
- **NewsAPI** — https://newsapi.org
- **Clean Architecture** principles
- **SharedPreferences** for local persistence
