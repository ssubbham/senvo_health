# Senvo PPG Scanner - Architecture

## Project Structure

```
senvo_health/
├── lib/                          # Flutter app source code
│   ├── main.dart                 # App entry point
│   ├── core/                     # Core utilities and constants
│   ├── features/                 # Feature modules
│   │   └── ppg_scan/             # PPG scanning feature
│   │       ├── domain/           # Business logic
│   │       │   ├── entities/     # Domain models
│   │       │   ├── repositories/ # Repository interfaces
│   │       │   └── usecases/     # Use cases
│   │       └── presentation/     # UI layer
│   │           ├── bloc/         # BLoC state management
│   │           ├── pages/        # Pages/screens
│   │           └── widgets/      # Reusable widgets
│   └── services/                 # Services layer
│       ├── camera/               # Camera integration
│       ├── permissions/          # Permission handling
│       └── signal_processing/    # Signal analysis & vitals estimation
├── test/                         # Unit and integration tests
├── android/                      # Android native code
├── ios/                          # iOS native code
├── api/                          # Backend API (Python Flask)
│   ├── app.py                    # Flask application
│   ├── requirements.txt          # Python dependencies
│   └── Procfile                  # Heroku deployment config
├── ml/                           # Machine learning models & training
│   ├── train_heart_rate_model.py # HR model training script
│   └── requirements-ml.txt       # ML dependencies
├── docs/                         # Documentation
│   ├── ARCHITECTURE.md           # This file
│   ├── SETUP.md                  # Setup instructions
│   └── API.md                    # API documentation
└── scripts/                      # Build and deployment scripts
    ├── deploy.sh                 # Deployment script
    └── build.sh                  # Build script

```

## Architecture Layers

### 1. **Presentation Layer** (`lib/features/ppg_scan/presentation/`)
- **Pages**: Full-screen UI components
- **Widgets**: Reusable UI components
- **BLoC**: State management using flutter_bloc

### 2. **Domain Layer** (`lib/features/ppg_scan/domain/`)
- **Entities**: Pure data models (PPGSample, VitalsResult, etc.)
- **Repositories**: Abstract interfaces for data sources
- **Use Cases**: Business logic and application rules

### 3. **Services Layer** (`lib/services/`)
- **Camera Service**: Hardware camera abstraction
- **Permission Service**: Runtime permission handling
- **Signal Processing**: PPG signal analysis and vitals estimation

### 4. **Backend** (`api/`)
- Flask REST API for cloud processing
- User authentication and data storage
- Historical data analysis

### 5. **ML** (`ml/`)
- TensorFlow/PyTorch model training
- Model conversion to TFLite
- Model validation and testing

## PPG Scanning Flow

1. **Initialization**
   - Request camera permission
   - Initialize camera controller
   - Enable torch flash

2. **Acquisition** (10 seconds)
   - Capture video frames at ~30 FPS
   - Extract 64×64 ROI from frame center
   - Convert YUV420/BGRA to averaged green channel

3. **Processing**
   - Apply bandpass filter
   - Calculate Signal Quality Index (SQI)
   - Reject if SQI < threshold

4. **Estimation**
   - Frequency-domain heart rate extraction
   - SpO2 ratio-of-ratios calculation (experimental)
   - Blood pressure heuristic (experimental)

## Key Technologies

- **Flutter**: Cross-platform mobile UI framework
- **Dart**: Programming language
- **BLoC**: State management pattern
- **Camera Plugin**: Native camera integration
- **TensorFlow Lite**: On-device ML inference
- **Flask**: Python backend framework
- **SQLite**: Local data storage

## State Management (BLoC Pattern)

```
User Action → Event → BLoC → State → UI Update
```

The `PPGScanBloc` manages:
- Camera initialization and permissions
- Frame capture and processing
- Signal analysis and vitals estimation
- UI state updates

## Testing Strategy

- **Unit Tests**: Signal processing, vital estimation algorithms
- **Widget Tests**: UI component rendering and interaction
- **Integration Tests**: End-to-end scanning workflow

Run tests with:
```bash
flutter test
```

## Performance Considerations

- **Memory**: Frame streaming with backpressure (processor busy flag)
- **Battery**: Torch flash optimization, efficient sampling rates
- **Accuracy**: 64×64 ROI with green channel filtering
- **Latency**: Real-time frame processing (~30ms per frame)

## Future Enhancements

1. Multi-wavelength PPG for better SpO2
2. Remote photoplethysmography (rPPG) via RGB camera
3. Offline ML model for vitals estimation
4. Cloud sync and health analytics
5. Wearable device integration
6. Historical trend analysis
