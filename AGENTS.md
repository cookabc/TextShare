# AGENTS.md

## Build Commands
- **Build**: `./build.sh` - Compiles all Swift files and creates executable in build/TextToShare
- **Run**: `./build/TextToShare` - Launch the macOS application
- **Clean**: `rm -rf build/` - Remove build directory

## Code Style Guidelines

### Imports & Structure
- Import Cocoa/Foundation at top of each Swift file
- Use CoreGraphics for image operations
- Keep imports minimal and relevant

### Naming Conventions
- Classes: PascalCase (e.g., `ImageGenerator`, `PopupWindow`)
- Functions/Methods: camelCase (e.g., `generateImage`, `setupStatusBarItem`)
- Variables: camelCase with descriptive names
- Constants: Use `let` for immutable values

### Types & Error Handling
- Use optionals (`?`) for values that may be nil
- Use guard statements for early returns and validation
- Log errors with descriptive messages using the `log()` function pattern
- Return Bool for success/failure operations

### Formatting
- 4-space indentation
- Add logging with timestamps for debugging
- Use Auto Layout constraints for UI components
- Keep functions focused and under 50 lines when possible

### Architecture
- Separate concerns: UI (PopupWindow), logic (ImageGenerator), app lifecycle (AppDelegate)
- Use delegation patterns for UI events
- Maintain clean separation between view and model layers