#!/bin/bash

# 📱 Budget Manager - iPhone Build Script
# This script automates the build process for your iPhone

set -e  # Exit on error

echo "🚀 Starting iPhone build process..."
echo ""

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Step 1: Check Flutter installation
echo "📋 Step 1: Checking Flutter installation..."
if ! command -v flutter &> /dev/null; then
    echo -e "${RED}❌ Flutter is not installed!${NC}"
    echo "Please install Flutter from: https://docs.flutter.dev/get-started/install/macos"
    exit 1
fi
echo -e "${GREEN}✅ Flutter is installed${NC}"
echo ""

# Step 2: Check Xcode installation
echo "📋 Step 2: Checking Xcode installation..."
if ! command -v xcodebuild &> /dev/null; then
    echo -e "${RED}❌ Xcode is not installed!${NC}"
    echo "Please install Xcode from the App Store"
    exit 1
fi
echo -e "${GREEN}✅ Xcode is installed${NC}"
echo ""

# Step 3: Run Flutter Doctor
echo "📋 Step 3: Running Flutter Doctor..."
flutter doctor
echo ""

# Step 4: Clean previous builds
echo "📋 Step 4: Cleaning previous builds..."
flutter clean
echo -e "${GREEN}✅ Cleaned${NC}"
echo ""

# Step 5: Get dependencies
echo "📋 Step 5: Getting Flutter dependencies..."
flutter pub get
echo -e "${GREEN}✅ Dependencies installed${NC}"
echo ""

# Step 6: Check connected devices
echo "📋 Step 6: Checking for connected devices..."
flutter devices
echo ""
echo -e "${YELLOW}⚠️  Make sure your iPhone is connected via USB${NC}"
echo -e "${YELLOW}⚠️  Developer Mode must be enabled on your iPhone${NC}"
echo -e "${YELLOW}⚠️  Trust this computer when prompted on your iPhone${NC}"
echo ""
read -p "Press Enter when your iPhone is connected and ready..."
echo ""

# Step 7: Open Xcode for code signing
echo "📋 Step 7: Opening Xcode for code signing setup..."
echo -e "${YELLOW}⚠️  In Xcode:${NC}"
echo "   1. Select 'Runner' in the left sidebar"
echo "   2. Go to 'Signing & Capabilities' tab"
echo "   3. Select your Apple ID under 'Team'"
echo "   4. Verify Bundle ID: com.dylanmoses.budgetManager"
echo ""
open ios/Runner.xcworkspace
read -p "Press Enter after configuring code signing in Xcode..."
echo ""

# Step 8: Build and run on iPhone
echo "📋 Step 8: Building and installing on iPhone..."
echo -e "${YELLOW}Choose build mode:${NC}"
echo "1) Debug mode (faster, with debugging features)"
echo "2) Release mode (optimized, production-ready)"
read -p "Enter choice (1 or 2): " build_mode

if [ "$build_mode" = "2" ]; then
    echo "Building in RELEASE mode..."
    flutter run --release
else
    echo "Building in DEBUG mode..."
    flutter run
fi

echo ""
echo -e "${GREEN}🎉 Build process complete!${NC}"
echo ""
echo -e "${YELLOW}📱 If this is your first time:${NC}"
echo "   1. Go to Settings → General → VPN & Device Management"
echo "   2. Trust your Apple ID developer certificate"
echo "   3. Open the app again"
echo ""
echo -e "${GREEN}✅ The app should now be running on your iPhone!${NC}"
