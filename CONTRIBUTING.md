# Contributing to Win+V for Mac

Thank you for your interest in contributing to **Win+V for Mac**! We welcome bug reports, feature suggestions, documentation improvements, and pull requests.

---

## 🛠️ Development Setup

### Prerequisites
- macOS 14.0 (Sonoma) or newer
- Xcode 15+ or Swift 5.9+ Command Line Tools
- Git

### Getting the Code
```bash
git clone https://github.com/carloseorsantos/win-v-for-mac.git
cd win-v-for-mac
```

### Building & Running Locally
```bash
# Run unit tests
swift test

# Build and run the app in debug mode
swift run WinPlusV

# Build release bundle and .zip
./Scripts/build.sh

# Generate DMG installer
./Scripts/create_dmg.sh

# Install directly to /Applications
./Scripts/install.sh
```

---

## 📋 Pull Request Process

1. **Fork** the repository and create your branch from `main`:
   ```bash
   git checkout -b feature/my-new-feature
   ```
2. Make your code changes adhering to native Swift / SwiftUI conventions.
3. Add unit tests for new logic in `Tests/WinPlusVTests/`.
4. Ensure all tests pass:
   ```bash
   swift test
   ```
5. Commit your changes with clear, semantic commit messages:
   ```bash
   git commit -m "feat: add support for custom hotkey configuration"
   ```
6. Push to your fork and submit a **Pull Request**.

---

## 💡 Code Style Guidelines
- Use native **SwiftUI** and **AppKit** best practices.
- Maintain non-blocking, asynchronous dispatching for system-level operations (`CGEvent`, `NSPasteboard`).
- Keep UI components clean, responsive, and respectful of macOS Human Interface Guidelines (vibrancy, dark/light mode support).

---

## 🐛 Reporting Bugs
Please open an issue on GitHub and include:
- macOS version
- Target application where the issue occurred
- Steps to reproduce
