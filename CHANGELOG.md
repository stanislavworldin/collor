# Changelog

## 1.2.2

### ⚡ Performance
- Reduced hot-path overhead for hover/drag updates by removing repeated render object lookups
- Avoided redundant state updates when pointer position did not change
- Added `RepaintBoundary` around custom-painted interactive areas

### 🛡️ Reliability
- Synced internal picker state when `initialColor` changes in parent widgets
- Stabilized slider math for hue/value/alpha mappings and clamping behavior
- Improved alpha extraction safety from ARGB
- Prevented text overflow in long color info rows

### 🧪 Tests
- Added widget test covering `initialColor` synchronization
- Updated slider interaction tests to use stable key-based finders
- `flutter analyze` clean and all tests passing

## 1.2.1

### 🎨 UI/UX
- Removed lock icon control from the dialog
- Removed top title text ("Select Color") to keep UI minimal

### 🛠️ Improvements
- Migrated to stable color APIs across codebase: `.toARGB32()`, `.r/.g/.b/.a`, `.withValues()`
- Standardized HEX/RGB/RGBA/HSVA formatting in UI and examples
- Minor code cleanup, added concise doc comments

### 🧪 Tests & Quality
- Updated tests to not rely on removed title text
- `flutter analyze` reports no issues
- All tests are green

## 1.2.0

### ✨ New Features
- Added optional `onChanged` callback for live color updates during drag/hover
- Added optional `showAlpha` flag to enable alpha (transparency) slider
- Display RGBA and HSVA values when `showAlpha: true`

### 🎨 UI/UX
- Sliders now have a subtle grey background for better contrast
- Added tooltips to color square, sliders, and confirm button
- Added explicit "Lock picker" switch (in addition to tap on color square)

### 🛠️ Improvements
- Cached hue gradient colors (performance)
- Safer access to `RenderBox` (null-safety during early frames)
- Smarter `CustomPainter.shouldRepaint` to avoid unnecessary repaints
- Replaced deprecated color comparisons with `toARGB32()` equality

### 🧪 Tests
- Stabilized tests via keys and direct onPressed invocation
- All tests are green

## 1.1.2

### 📸 UI Improvements
- Added screenshot to README.md showcasing the color picker interface
- Enhanced documentation with visual demonstration
- Improved project presentation with live demo image

## 1.1.1

### 🔧 Bug Fixes
- Fixed dart format issues in `lib/collor.dart`
- Improved code formatting across all files
- Enhanced static analysis compliance

## 1.1.0

### 🎉 Major Updates
- **Mobile Touch Support**: Full touchscreen compatibility with drag gestures
- **Copy to Clipboard**: One-click copying of color values (HEX, RGB, HSV)
- **Enhanced UI**: Improved visual feedback and modern rounded design
- **English Notifications**: All user interface text in English
- **Cross-platform**: Optimized for Web, macOS, iOS, and Android

### ✨ New Features
- Touch drag support for color picker and sliders
- Visual feedback during drag operations (larger indicators, shadows)
- Copy buttons for each color format (HEX, RGB, HSV)
- SnackBar notifications for copy actions
- Improved mobile UX with single-tap activation
- Enhanced slider visual design

### 🔧 Technical Improvements
- Replaced deprecated `withOpacity` with `withValues`
- Optimized layout for mobile screens
- Fixed layout overflow issues
- Improved gesture handling
- Better error handling and stability

### 📱 Mobile Optimizations
- Touch-friendly interface design
- Responsive layout adjustments
- Enhanced visual feedback for touch interactions
- Optimized for mobile screen sizes

## 1.0.0

Initial release of the collor color picker library.

### Features
- Interactive color square for color selection
- Hue slider for base color selection
- Value slider for brightness adjustment
- Real-time color display (HEX, RGB, HSV)
- Clean rectangular UI design
- Zero external dependencies
- Super lightweight (47KB, 325 lines of code)

### Technical Details
- Single file implementation (`color_picker_popup.dart`)
- Custom painters for color indicators
- Optimized rendering performance
- Minimal memory footprint
- Fast color calculations

### Dependencies
- Flutter SDK only
- No external packages required 
