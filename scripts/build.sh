#!/bin/bash
# Build Script for Senvo PPG Scanner

set -e  # Exit on error

echo "🔨 Building Senvo PPG Scanner..."

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter is not installed. Please install Flutter first."
    exit 1
fi

echo -e "${BLUE}Step 1: Cleaning previous builds...${NC}"
flutter clean

echo -e "${BLUE}Step 2: Getting dependencies...${NC}"
flutter pub get

echo -e "${BLUE}Step 3: Running code generation...${NC}"
flutter pub run build_runner build --delete-conflicting-outputs

echo -e "${BLUE}Step 4: Running tests...${NC}"
flutter test

echo -e "${BLUE}Step 5: Building APK...${NC}"
flutter build apk --release

echo -e "${BLUE}Step 6: Building iOS (optional)...${NC}"
# Uncomment to build iOS
# flutter build ios --release

echo -e "${GREEN}✅ Build completed successfully!${NC}"
echo ""
echo "📦 Output files:"
echo "  - Android APK: build/app/outputs/apk/release/app-release.apk"
echo "  - iOS IPA: build/ios/iphoneos/Runner.app"
