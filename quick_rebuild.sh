#!/bin/bash

# 🔄 Quick Rebuild Script
# Use this for faster rebuilds after making code changes

set -e

echo "🔄 Quick rebuild and install..."
echo ""

# Check if iPhone is connected
echo "📱 Checking for connected iPhone..."
devices=$(flutter devices)
if ! echo "$devices" | grep -q "ios"; then
    echo "❌ No iPhone detected!"
    echo "Please connect your iPhone via USB"
    exit 1
fi

echo "✅ iPhone detected"
echo ""

# Quick rebuild without cleaning
echo "🔨 Building..."
flutter run

echo ""
echo "✅ Done!"
