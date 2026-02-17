#!/bin/bash
# Enable Flutter in PATH for this session
export PATH="$PATH:/Users/shyam/flut_sdk/flutter/bin"

echo "🚀 Starting Plant-Twin Frontend..."
cd plant_twin
flutter pub get
flutter run -d macos
