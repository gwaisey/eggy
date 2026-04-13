#!/bin/bash
set -e

echo "--- Starting Vercel Build Process ---"

# 1. Clone Flutter SDK (Depth 1 for speed)
if [ ! -d "flutter" ]; then
  echo "Cloning Flutter SDK..."
  git clone https://github.com/flutter/flutter.git -b stable --depth 1
else
  echo "Flutter SDK already exists, skipping clone."
fi

# 2. Set Path
export PATH="$PATH:`pwd`/flutter/bin"

# 3. Disable Analytics & Setup
echo "Configuring Flutter..."
flutter config --no-analytics

# 4. Inject Environment Variables for Production
# These are retrieved from the Vercel Dashboard Settings
echo "Injecting Secure Environment Variables..."
echo "OPENROUTER_API_KEY=$OPENROUTER_API_KEY" > .env
echo "OPENROUTER_MODEL=$OPENROUTER_MODEL" >> .env
echo "SERPER_API_KEY=$SERPER_API_KEY" >> .env

# 5. Build for Web
echo "Building Flutter Web application (Release)..."
flutter build web --release

# 5. Prepare output for Vercel
echo "Preparing output directory..."
rm -rf public
cp -r build/web public

echo "--- Build Complete: Ready for Serving ---"
