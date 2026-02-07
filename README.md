# StudyBuddy

A mobile marketplace for students to buy and sell study materials. Built with Flutter and powered by a Laravel REST API backend.

## Features

- **Browse & Search** - Explore study materials with filters for school, level, module, price range, and keyword search
- **Sell Notes** - Upload study materials with file attachments and preview images
- **Secure Payments** - Purchase materials through Stripe checkout
- **Order Management** - View purchase history and download bought materials
- **User Profiles** - Manage personal details and preferences
- **Dark / Light Theme** - Manual toggle with ambient light sensor suggestion
- **Device Sensors** - Shake navigation, geolocation display, battery monitoring, connectivity status

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Frontend | Flutter (Dart ^3.8.1) |
| State Management | Provider |
| HTTP Client | Dio |
| Backend | Laravel 12 (PHP ^8.2) |
| Authentication | Laravel Sanctum (token-based) |
| File Storage | Spatie MediaLibrary |
| Payments | Stripe |
| Database | MySQL |

## Project Structure

```
lib/
├── main.dart
├── models/          # Data classes (User, Note, Material, Purchase, etc.)
├── providers/       # State management (Auth, Materials, Cart, Notes, Theme, etc.)
├── screens/         # UI pages (Login, Explore, Detail, Cart, Notes, Profile, etc.)
├── services/        # API client, storage, and device services
├── utils/           # Constants and helpers
└── widgets/         # Reusable UI components
```

## Prerequisites

- Flutter SDK ^3.8.1
- A running instance of the [StudyBuddy Laravel backend](../StudyBuddy-backend-laravel) with MySQL
- Stripe API keys configured on the backend

## Getting Started

```bash
# Install dependencies
flutter pub get

# Update the API base URL in lib/utils/constants.dart

# Run the app
flutter run
```

## Device Permissions

The app uses the following device capabilities:

| Permission | Usage |
|-----------|-------|
| Internet | API communication |
| Camera / Gallery | Selecting preview images for notes |
| Location | Displaying user's current city |
| Sensors | Ambient light detection, shake gesture |

## Backend API

The Flutter app communicates with a Laravel REST API. Key endpoint groups:

- `POST /api/register`, `POST /api/login` - Authentication
- `GET /api/materials` - Browse and filter materials
- `GET /api/my-notes`, `POST /api/notes` - Manage own notes
- `POST /api/checkout` - Stripe payment processing
- `GET /api/my-purchases` - Purchase history and downloads

See the backend repository for full API documentation.
