# Senvo PPG Scanner - Setup Guide

Project developed by **Team The_Underbets** (C. V. Raman Global University) for **Smart India Hackathon 2026**.

## Prerequisites

- Flutter SDK 3.13.1+
- Dart SDK 3.13.1+
- Android SDK (API 21+)
- Xcode 12+ (for iOS)
- Python 3.8+ (for ML and backend)
- Git

## Installation

### 1. Flutter App Setup

```bash
# Navigate to project directory
cd senvo_health

# Get Flutter dependencies
flutter pub get

# Run code generation (if needed)
flutter pub run build_runner build

# Check Flutter installation
flutter doctor
```

### 2. Android Setup

```bash
# Navigate to Android directory
cd android

# Build Android release
./gradlew build

# Or via Flutter
cd ..
flutter build apk --release
```

### 3. Backend Setup (API)

```bash
# Navigate to API directory
cd api

# Create virtual environment
python -m venv venv

# Activate virtual environment
# On Windows:
venv\Scripts\activate
# On macOS/Linux:
source venv/bin/activate

# Install dependencies
pip install -r requirements.txt

# Run Flask server
python app.py
```

### 4. ML Setup

```bash
# Navigate to ML directory
cd ml

# Create virtual environment
python -m venv venv

# Activate virtual environment
# On Windows:
venv\Scripts\activate
# On macOS/Linux:
source venv/bin/activate

# Install dependencies
pip install -r requirements-ml.txt

# Train model (if needed)
python train_heart_rate_model.py
```

## Running the App

### Development Mode (with hot reload)

```bash
flutter run
```

### Release Build

```bash
# Android
flutter build apk --release

# iOS
flutter build ios --release
```

### Tests

```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/ppg_processing_test.dart

# Generate coverage report
flutter test --coverage
```

## Deployment

### Deploy to Android Device

```bash
# List connected devices
flutter devices

# Run on specific device
flutter run -d <device_id>

# Build and install APK
flutter build apk --release
adb install -r build/app/outputs/apk/release/app-release.apk
```

### Deploy Backend (Heroku)

```bash
cd api

# Login to Heroku
heroku login

# Create app
heroku create senvo-api

# Deploy
git push heroku main
```

## Environment Variables

Create a `.env` file in the project root:

```
FLUTTER_ENV=development
API_BASE_URL=http://localhost:5000
ENABLE_LOGGING=true
```

## Troubleshooting

### Issue: Camera not working
- **Solution**: Ensure camera permission is granted in device settings
- Check `android/app/src/main/AndroidManifest.xml` for camera permission declaration

### Issue: Tests failing
- **Solution**: Run `flutter clean` and `flutter pub get`
- Check Flutter version matches `pubspec.yaml`

### Issue: Build fails
- **Solution**: Run `flutter doctor` to check dependencies
- Clear build cache: `flutter clean`

### Issue: Backend connection error
- **Solution**: Check API server is running (`python api/app.py`)
- Verify `API_BASE_URL` in environment variables

## Performance Tips

1. **Optimize build size**
   ```bash
   flutter build apk --release --split-per-abi
   ```

2. **Enable profiling**
   ```bash
   flutter run --profile
   ```

3. **Check FPS during scanning**
   - Enable debug painting: Press `P` in terminal

## Additional Resources

- [Flutter Documentation](https://flutter.dev/docs)
- [BLoC Pattern](https://bloclibrary.dev)
- [Camera Plugin](https://pub.dev/packages/camera)
- [PPG Algorithm](https://en.wikipedia.org/wiki/Photoplethysmography)

## Getting Help

- Check logs: `flutter logs`
- Report issues: Create GitHub issue with detailed logs
- Contact developers: See CONTRIBUTING.md
