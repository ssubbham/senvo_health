#!/bin/bash
# Deployment Script for Senvo PPG Scanner

set -e

echo "🚀 Deploying Senvo PPG Scanner..."

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Configuration
API_HEROKU_APP="senvo-api"
PLATFORM="${1:-android}"  # Default to android

# Check dependencies
check_dependencies() {
    echo -e "${BLUE}Checking dependencies...${NC}"
    
    if ! command -v git &> /dev/null; then
        echo "❌ Git not found"
        exit 1
    fi
    
    if [ "$PLATFORM" = "android" ] || [ "$PLATFORM" = "both" ]; then
        if ! command -v flutter &> /dev/null; then
            echo "❌ Flutter not found"
            exit 1
        fi
    fi
    
    echo -e "${GREEN}✅ All dependencies found${NC}"
}

# Deploy to GitHub
deploy_github() {
    echo -e "${BLUE}Deploying to GitHub...${NC}"
    
    git add .
    git commit -m "chore: automated deployment $(date +'%Y-%m-%d %H:%M:%S')" || true
    git push origin main
    
    echo -e "${GREEN}✅ GitHub deployment complete${NC}"
}

# Deploy backend to Heroku
deploy_heroku() {
    echo -e "${BLUE}Deploying backend to Heroku...${NC}"
    
    if ! command -v heroku &> /dev/null; then
        echo "⚠️  Heroku CLI not found. Skipping Heroku deployment."
        return
    fi
    
    cd api
    
    # Check if Heroku remote exists
    if ! git remote get-url heroku &> /dev/null; then
        heroku create "$API_HEROKU_APP" --region us 2>/dev/null || true
    fi
    
    # Deploy
    git push heroku main
    
    cd ..
    echo -e "${GREEN}✅ Heroku deployment complete${NC}"
}

# Deploy Android to App Store/Play Store (optional)
deploy_android() {
    echo -e "${BLUE}Building Android release...${NC}"
    
    if [ ! -f "build/app/outputs/apk/release/app-release.apk" ]; then
        echo "Building APK..."
        flutter build apk --release
    fi
    
    echo -e "${YELLOW}⚠️  Manual upload to Google Play Store required${NC}"
    echo "APK location: build/app/outputs/apk/release/app-release.apk"
}

# Main deployment flow
main() {
    echo -e "${BLUE}Senvo PPG Scanner - Deployment Script${NC}"
    echo ""
    
    check_dependencies
    
    case "$PLATFORM" in
        android)
            deploy_android
            ;;
        github)
            deploy_github
            ;;
        heroku)
            deploy_heroku
            ;;
        all|both)
            deploy_github
            deploy_heroku
            deploy_android
            ;;
        *)
            echo "❌ Invalid platform: $PLATFORM"
            echo "Usage: ./deploy.sh [android|github|heroku|all]"
            exit 1
            ;;
    esac
    
    echo ""
    echo -e "${GREEN}✅ Deployment script finished!${NC}"
}

main "$@"
