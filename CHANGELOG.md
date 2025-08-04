# Changelog

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