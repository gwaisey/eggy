#!/bin/bash

# 1. Clone Flutter SDK (Depth 1 for speed)
git clone https://github.com/flutter/flutter.git -b stable --depth 1

# 2. Set Path
export PATH="$PATH:`pwd`/flutter/bin"

# 3. Disable Analytics & Setup
flutter config --no-analytics

# 4. Build for Web
flutter build web --release

# 5. Prepare output for Vercel
# Vercel needs the build output in a predictable directory like 'public'
rm -rf public
cp -r build/web public
