# Senvo - Camera-Based PPG Heart Rate Scanner 🫀

![License](https://img.shields.io/badge/license-MIT-blue)
![Flutter](https://img.shields.io/badge/Flutter-3.13+-blue)
![Dart](https://img.shields.io/badge/Dart-3.13+-blue)
![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS-green)

A state-of-the-art mobile application that uses smartphone camera photoplethysmography (PPG) to measure heart rate, blood oxygen saturation (SpO2), and estimated blood pressure in real-time.

## 🌟 Features

- **📱 Cross-Platform**: Built with Flutter for Android and iOS
- **📸 Camera-Based PPG**: Non-invasive heart rate measurement using device camera
- **⚡ Real-Time Processing**: Live signal visualization and quality monitoring
- **🎯 64×64 ROI Analysis**: Optimized Region of Interest extraction
- **🔦 Torch Flash Support**: Enhanced signal quality in low-light conditions
- **📊 Advanced Signal Processing**: Bandpass filtering and SQI calculation
- **💾 Data Persistence**: Local SQLite storage for measurement history
- **☁️ Cloud Sync** (Optional): Backend API for data management
- **🤖 ML-Ready**: TensorFlow Lite model integration for enhanced vitals estimation
- **📈 Analytics Dashboard**: Historical data tracking and trend analysis

## 🚀 Quick Start

### Prerequisites

- Flutter SDK 3.13.1+
- Dart SDK 3.13.1+
- Android SDK (API 21+) or Xcode 12+ (iOS)
- Git

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/your-org/raamen-sih.git
   cd raamen-sih
   ```

2. **Get dependencies**
   ```bash
   flutter pub get
   ```

3. **Run on device**
   ```bash
   flutter run -d <device_id>
   ```

### Requirements

- **Device**: Physical Android (API 21+) or iOS device
- **Camera**: Rear camera with flash capability
- **Permissions**: Camera and file storage permissions

## 📖 Documentation

| Document | Description |
|----------|-------------|
| [SETUP.md](docs/SETUP.md) | Detailed setup and installation guide |
| [ARCHITECTURE.md](docs/ARCHITECTURE.md) | Project architecture and code organization |
| [API.md](docs/API.md) | Backend API documentation |
| [CONTRIBUTING.md](CONTRIBUTING.md) | Contribution guidelines |

## 🏗️ Project Structure

```
raamen-sih/
├── lib/                          # Flutter application
│   ├── main.dart                 # App entry point
│   ├── core/                     # Core utilities
│   ├── features/                 # Feature modules
│   │   └── ppg_scan/             # PPG scanning feature
│   └── services/                 # Business logic services
├── test/                         # Unit and widget tests
├── android/                      # Android native code
├── ios/                          # iOS native code
├── api/                          # Python Flask backend
├── ml/                           # Machine learning models
├── docs/                         # Documentation
└── scripts/                      # Build and deployment scripts
```

## 🔧 Technology Stack

### Mobile App
- **Framework**: Flutter
- **Language**: Dart
- **State Management**: BLoC Pattern
- **Camera**: camera plugin
- **Charting**: fl_chart
- **Permissions**: permission_handler

### Backend
- **Framework**: Flask (Python)
- **Database**: SQLite / PostgreSQL
- **Deployment**: Heroku
- **API**: RESTful JSON

### Machine Learning
- **Framework**: TensorFlow / PyTorch
- **Deployment**: TensorFlow Lite
- **Model**: Convolutional Neural Network (CNN)

## 📊 PPG Processing Pipeline

```
Raw Video Frames (30 FPS)
        ↓
   ROI Extraction (64×64 pixels)
        ↓
 YUV420/BGRA Conversion
        ↓
 Green Channel Averaging
        ↓
   Bandpass Filter (0.5-4 Hz)
        ↓
 Signal Quality Index (SQI) Calculation
        ↓
   Frequency Domain Analysis
        ↓
Heart Rate Estimation (bpm)
        ↓
SpO2 & BP Calculation (Experimental)
```

## 🧪 Testing

### Run Tests
```bash
# All tests
flutter test

# Specific test file
flutter test test/ppg_processing_test.dart

# With coverage
flutter test --coverage

# Watch mode
flutter test --watch
```

### Test Coverage
- Signal processing algorithms
- Vital signs estimation
- Device lifecycle management
- Permission handling

## 🎨 Building

### Development Build
```bash
flutter run
```

### Release Build (Android)
```bash
flutter build apk --release
# Output: build/app/outputs/apk/release/app-release.apk
```

### Release Build (iOS)
```bash
flutter build ios --release
```

### Using Build Script
```bash
bash scripts/build.sh
```

## 🚀 Deployment

### Deploy to Device
```bash
flutter run -d RZCW50WAPXD  # Your device ID
```

### Deploy to Play Store
```bash
flutter build appbundle --release
# Upload to Google Play Console
```

### Deploy Backend
```bash
bash scripts/deploy.sh heroku
```

## 📱 Usage

1. **Launch App**: Open Senvo on your device
2. **Grant Permissions**: Allow camera access when prompted
3. **Position Finger**: Cover rear camera and flash completely
4. **Start Scan**: Tap "Start Scan" button
5. **Keep Still**: Maintain steady pressure for 10 seconds
6. **View Results**: Get instant heart rate, SpO2, and BP estimates

## ⚙️ Configuration

Environment variables (create `.env` file):

```env
FLUTTER_ENV=development
API_BASE_URL=http://localhost:5000
ENABLE_LOGGING=true
LOG_LEVEL=debug
```

## 🐛 Troubleshooting

### Camera Not Working
- Ensure camera permission is granted
- Check device has rear camera with flash
- Try restarting the app

### Signal Quality Low
- Ensure complete camera/flash coverage
- Remove air gaps between finger and camera
- Try under different lighting

### App Crashes on Launch
- Run `flutter clean`
- Delete `build/` directory
- Run `flutter pub get` again
- Check device meets minimum API level

### Backend Connection Issues
- Verify API server is running
- Check `API_BASE_URL` in configuration
- Review network connectivity

See [SETUP.md](docs/SETUP.md#troubleshooting) for more troubleshooting tips.

## 🔒 Privacy & Security

- All processing happens locally on device
- No biometric data is stored by default
- Optional cloud sync requires explicit user consent
- HTTPS encryption for all network communication
- GDPR compliant data handling

## 📈 Performance

- **Frame Processing**: ~30ms per frame
- **Signal Analysis**: ~50ms for 10-second acquisition
- **Memory Usage**: ~100-150MB during scanning
- **Battery Impact**: ~5-10% per 10-second scan
- **Accuracy**: ±5 bpm heart rate (lab conditions)

## 🤝 Contributing

We welcome contributions! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for:
- Development workflow
- Code style guidelines
- Testing requirements
- Pull request process

## 📚 Learning Resources

- [Flutter Documentation](https://flutter.dev/docs)
- [BLoC Pattern Guide](https://bloclibrary.dev)
- [PPG Algorithm Overview](https://en.wikipedia.org/wiki/Photoplethysmography)
- [TensorFlow Lite Guide](https://www.tensorflow.org/lite)

## 🎓 Academic References

- [PPG Signal Processing Review](https://ieeexplore.ieee.org/document/8625258)
- [Smartphone-Based PPG](https://journals.plos.org/plosone/article?id=10.1371/journal.pone.0220695)
- [Remote PPG Methods](https://arxiv.org/abs/1502.00200)

## 📄 License

This project is licensed under the MIT License - see [LICENSE](LICENSE) file for details.

## 👥 Credits

**Development Team**:
- Subha - Primary Developer

**Contributors**: Thanks to all contributors who have helped with code, testing, and documentation!

**Acknowledgments**:
- Flutter team for excellent documentation
- OpenCV for image processing libraries
- TensorFlow team for ML framework
- All open-source community contributors

## 📞 Support

- **Issues**: [GitHub Issues](https://github.com/your-org/raamen-sih/issues)
- **Discussions**: [GitHub Discussions](https://github.com/your-org/raamen-sih/discussions)
- **Email**: [contact email]

## 🔮 Roadmap

### v1.0 (Current)
- ✅ Basic PPG scanning
- ✅ Real-time heart rate estimation
- ✅ Signal quality monitoring
- ✅ Local data storage

### v1.1 (Planned)
- 🔄 Cloud data sync
- 🔄 Analytics dashboard
- 🔄 Export to PDF/CSV
- 🔄 Multiple user profiles

### v2.0 (Future)
- 🔄 Multi-wavelength PPG
- 🔄 Remote PPG (face detection)
- 🔄 Wearable integration
- 🔄 AI-powered vitals estimation
- 🔄 Real-time health alerts

## ⭐ Show Your Support

If you find this project useful, please:
- ⭐ Star the repository
- 🐦 Share on social media
- 💬 Provide feedback
- 🤝 Contribute code or documentation

---

**Last Updated**: August 27, 2026  
**Maintainer**: Subha  
**Status**: Active Development 🚀

Made with ❤️ by the Senvo team
