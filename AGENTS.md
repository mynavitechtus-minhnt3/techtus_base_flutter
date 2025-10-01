## Essential Commands
```bash
# Get packages for all modules
make pg

# Run build_runner for code generation
make fb

# Run golden tests
flutter test [test_path] --tags=golden

# Update golden test files
flutter test [test_path] --update-goldens --tags=golden

# Format code
make fm

## Check lint
make sl

## Generate assets (images, fonts, etc.)
make ga

## Generate localization files
make ln
```
