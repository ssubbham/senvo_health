# Contributing to Senvo PPG Scanner

Thank you for your interest in contributing to Senvo! We welcome contributions from everyone.

## Getting Started

1. Fork the repository
2. Clone your fork: `git clone https://github.com/yourusername/senvo_health.git`
3. Create a feature branch: `git checkout -b feature/your-feature-name`
4. Follow the setup instructions in [docs/SETUP.md](docs/SETUP.md)

## Development Workflow

### Code Style

- **Dart/Flutter**: Follow the [official style guide](https://dart.dev/guides/language/effective-dart/style)
  - Run `dartfmt` to auto-format code
  - Run `dart analyze` to check for issues

- **Python**: Follow [PEP 8](https://pep8.org/)
  - Use `black` for formatting
  - Use `flake8` for linting

### Commit Messages

Use clear, descriptive commit messages:

```
feat: add new feature
fix: correct a bug
docs: documentation updates
style: code style changes
refactor: code refactoring
test: add/update tests
chore: maintenance tasks
```

Example:
```
feat: implement camera permission handling

- Add runtime permission request for camera access
- Handle permission denial with user-friendly messages
- Update AndroidManifest.xml with camera permission
```

### Pull Request Process

1. Update documentation if needed
2. Add tests for new features
3. Ensure all tests pass: `flutter test`
4. Update README if introducing new features
5. Create a pull request with:
   - Clear description of changes
   - Reference to any related issues
   - Screenshots if UI changes

## Testing

All new code must be tested:

```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/ppg_processing_test.dart

# Generate coverage
flutter test --coverage
```

## Documentation

- Update docstrings for all public methods
- Add comments for complex logic
- Update API docs if endpoints change
- Keep README.md current

## Issue Reporting

When reporting bugs, include:

1. **Description**: Clear explanation of the issue
2. **Steps to Reproduce**: Exact steps to reproduce
3. **Expected Behavior**: What should happen
4. **Actual Behavior**: What actually happens
5. **Environment**: OS, device model, Flutter version
6. **Logs**: Relevant error messages or logs

### Bug Report Template

```markdown
## Description
Brief description of the bug

## Steps to Reproduce
1. Step 1
2. Step 2
3. Step 3

## Expected Behavior
What should happen

## Actual Behavior
What actually happens

## Screenshots (if applicable)
Add any relevant screenshots

## Environment
- OS: iOS/Android
- Device: iPhone 12/Samsung Galaxy S21
- Flutter version: 3.13.1
- App version: 1.0.0

## Logs
```
Paste relevant error logs here
```
```

## Feature Requests

We welcome feature suggestions! Please include:

1. **Use Case**: Why this feature is needed
2. **Proposed Solution**: Your idea for implementation
3. **Alternative Approaches**: Other ways to solve it
4. **Additional Context**: Any other relevant info

## Code Review Guidelines

When submitting code:

- Keep changes focused and atomic
- Write clear, self-documenting code
- Add meaningful comments for complex sections
- Ensure backward compatibility
- Consider performance implications
- Test edge cases

Reviewers will check:

- Code quality and style
- Test coverage
- Documentation completeness
- Backward compatibility
- Performance impact

## Areas for Contribution

- **PPG Algorithms**: Improve signal processing and vital estimation
- **UI/UX**: Enhance user interface and experience
- **Testing**: Add more comprehensive tests
- **Documentation**: Improve setup guides and API docs
- **Backend**: Enhance cloud API and data processing
- **ML Models**: Improve heart rate and SpO2 estimation
- **Localization**: Add support for more languages
- **Accessibility**: Improve app accessibility

## Questions?

- Check existing [GitHub issues](https://github.com/ssubbham/senvo_health/issues)
- Review [docs/](docs/) directory
- Create a new discussion or issue

## License

By contributing, you agree that your contributions will be licensed under the same license as the project.

---

Thank you for contributing to Senvo! 🎉
