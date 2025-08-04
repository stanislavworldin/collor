#!/bin/bash

# Deploy script for collor web demo
echo "🚀 Deploying collor web demo to GitHub Pages..."

# Switch to gh-pages branch
git checkout gh-pages

# Build web version
cd example && flutter build web --release --base-href /collor/

# Copy web files to root
cd .. && cp -r example/build/web/* .

# Add and commit changes
git add . && git commit -m "Manual deploy" && git push origin gh-pages

# Switch back to main branch
git checkout main

echo "✅ Deploy completed! Web demo available at: https://stanislavworldin.github.io/collor/" 