# Development Guidelines

## Table of Contents
- [Code Style](#code-style)
- [Git Workflow](#git-workflow)
- [Testing Guidelines](#testing-guidelines)
- [Code Review Process](#code-review-process)
- [Documentation Standards](#documentation-standards)

## Code Style

### Flutter/Dart
- Follow [Effective Dart](https://dart.dev/guides/language/effective-dart) guidelines
- Use `dart format` before committing
- Run `flutter analyze` to check for issues
- Follow the project's `analysis_options.yaml` configuration

**Key Rules:**
- Use `const` constructors where possible
- Prefer single quotes for strings
- Always declare return types
- Avoid `print()` statements (use logging instead)
- Use meaningful variable and function names

### Python
- Follow [PEP 8](https://pep8.org/) style guide
- Use `black` for code formatting (line length: 127)
- Use `isort` for import sorting
- Run `flake8` for linting
- Type hints are encouraged but not required

**Key Rules:**
- Maximum line length: 127 characters
- Use type hints for function parameters and return types
- Use docstrings for all public functions and classes
- Follow the project's `.flake8` configuration

## Git Workflow

### Branch Naming
- `feature/feature-name` - New features
- `bugfix/bug-name` - Bug fixes
- `hotfix/issue-name` - Critical production fixes
- `refactor/component-name` - Code refactoring

### Commit Messages
Follow [Conventional Commits](https://www.conventionalcommits.org/) format:

```
<type>(<scope>): <subject>

<body>

<footer>
```

**Types:**
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes (formatting, etc.)
- `refactor`: Code refactoring
- `test`: Adding or updating tests
- `chore`: Maintenance tasks

**Examples:**
```
feat(auth): Add OTP verification endpoint

- Implement OTP generation and validation
- Add rate limiting for OTP requests
- Update API documentation

Closes #123
```

### Pull Request Process
1. Create a feature branch from `develop`
2. Make your changes
3. Write/update tests
4. Update documentation
5. Run linting and tests locally
6. Create a pull request with description
7. Address review comments
8. Merge after approval

## Testing Guidelines

### Flutter Tests
- Unit tests: Test individual functions and classes
- Widget tests: Test UI components
- Integration tests: Test complete user flows

**Running Tests:**
```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# Run specific test file
flutter test test/features/auth/auth_test.dart
```

### Backend Tests
- Unit tests: Test individual functions and classes
- Integration tests: Test API endpoints
- Use pytest fixtures for test data

**Running Tests:**
```bash
# Run all tests
cd backend
pytest

# Run with coverage
pytest --cov=app --cov-report=html

# Run specific test file
pytest tests/test_auth.py
```

### Test Coverage
- Aim for >80% code coverage
- Critical paths should have 100% coverage
- Write tests before fixing bugs (TDD when possible)

## Code Review Process

### For Authors
- Keep PRs small and focused (max 400 lines)
- Write clear PR descriptions
- Add screenshots for UI changes
- Ensure all CI checks pass
- Respond to review comments promptly

### For Reviewers
- Review within 24 hours
- Be constructive and respectful
- Check for:
  - Code quality and style
  - Test coverage
  - Security issues
  - Performance implications
  - Documentation updates

## Documentation Standards

### Code Documentation
- Document all public APIs
- Use docstrings for classes and functions
- Add comments for complex logic
- Keep comments up-to-date with code

### Flutter Documentation
```dart
/// A widget that displays a presentation carousel.
///
/// This widget automatically plays through slides and supports
/// image, video, and text slide types.
class PresentationCarousel extends StatefulWidget {
  // ...
}
```

### Python Documentation
```python
def get_active_presentation(agent_id: str) -> Optional[Presentation]:
    """
    Get the active presentation for an agent.
    
    Args:
        agent_id: The UUID of the agent
        
    Returns:
        The active Presentation object or None if not found
        
    Raises:
        HTTPException: If agent is not found
    """
    # ...
```

## Environment Setup

### Required Tools
- Flutter SDK 3.19.0+
- Python 3.11+
- PostgreSQL 16+
- Redis 7+
- Docker (optional, for local services)

### Local Development
1. Clone the repository
2. Set up Flutter: `flutter pub get`
3. Set up Backend: `cd backend && pip install -r requirements.txt`
4. Configure environment variables (see `.env.example`)
5. Run database migrations: `flyway -configFiles=flyway.conf migrate`
6. Start services: `docker-compose up` (if using Docker)

## CI/CD

### Automated Checks
- Code linting (dart analyze, flake8)
- Code formatting (dart format, black)
- Unit tests
- Integration tests
- Security scanning

### Pre-commit Checklist
- [ ] Code formatted (`dart format`, `black`)
- [ ] Linting passes (`flutter analyze`, `flake8`)
- [ ] Tests pass locally
- [ ] Documentation updated
- [ ] No debug code left in

## Resources

- [Flutter Documentation](https://flutter.dev/docs)
- [FastAPI Documentation](https://fastapi.tiangolo.com/)
- [Effective Dart](https://dart.dev/guides/language/effective-dart)
- [PEP 8](https://pep8.org/)
- [Conventional Commits](https://www.conventionalcommits.org/)

