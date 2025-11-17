# Contributing to StatsVM-Grafana

Thank you for your interest in contributing! This document provides guidelines for contributing to the project.

## 🚀 Quick Start

1. Fork the repository
2. Clone your fork:
   ```bash
   git clone https://github.com/YOUR_USERNAME/StatsVM-Grafana.git
   cd StatsVM-Grafana
   ```
3. Create a branch:
   ```bash
   git checkout -b feature/your-feature-name
   ```
4. Make your changes
5. Test your changes:
   ```bash
   make validate
   make start
   make test
   ```
6. Commit and push:
   ```bash
   git add .
   git commit -m "Description of your changes"
   git push origin feature/your-feature-name
   ```
7. Create a Pull Request

## 📋 Development Guidelines

### Code Style

- Use clear, descriptive variable names
- Add comments for complex logic
- Follow existing code formatting
- Keep configurations DRY (Don't Repeat Yourself)

### Configuration Files

- YAML files: Use 2-space indentation
- Validate before committing:
  ```bash
  make validate
  ```

### Docker Compose

- Test changes with all three configurations:
  - `docker-compose.yml` (default)
  - `docker-compose.dev.yml` (development)
  - `docker-compose.prod.yml` (production)

### Documentation

- Update README.md if adding new features
- Add examples for complex configurations
- Keep documentation up-to-date

## 🧪 Testing

### Before Submitting PR

Run the following checks:

```bash
# Validate configurations
make validate

# Start stack
make start

# Run tests
make test

# Check health
make health

# View logs to ensure no errors
make logs
```

### Testing Checklist

- [ ] All services start successfully
- [ ] No errors in logs
- [ ] Health checks pass
- [ ] Prometheus targets are up
- [ ] Grafana datasources work
- [ ] Dashboards load correctly
- [ ] Alerts are functioning

## 📝 Commit Messages

Use clear, descriptive commit messages:

**Good examples:**
- `Add Loki configuration for log aggregation`
- `Fix Prometheus retention settings`
- `Update README with deployment instructions`
- `Add example dashboard for system metrics`

**Bad examples:**
- `fix`
- `update`
- `changes`

### Commit Message Format

```
<type>: <subject>

<body (optional)>

<footer (optional)>
```

**Types:**
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Formatting changes
- `refactor`: Code refactoring
- `test`: Adding tests
- `chore`: Maintenance tasks

## 🐛 Bug Reports

When reporting bugs, include:

1. **Description**: What went wrong?
2. **Steps to Reproduce**: How can we reproduce it?
3. **Expected Behavior**: What should happen?
4. **Actual Behavior**: What actually happened?
5. **Environment**: 
   - OS version
   - Docker/Podman version
   - Docker Compose version
6. **Logs**: Relevant log output
7. **Configuration**: Any custom configurations

### Bug Report Template

```markdown
## Description
Brief description of the issue

## Steps to Reproduce
1. Step one
2. Step two
3. Step three

## Expected Behavior
What should happen

## Actual Behavior
What actually happens

## Environment
- OS: [e.g., Ubuntu 22.04]
- Docker: [e.g., 24.0.5]
- Docker Compose: [e.g., 2.20.0]

## Logs
```
Paste relevant logs here
```

## Additional Context
Any other information
```

## ✨ Feature Requests

When requesting features, include:

1. **Use Case**: Why is this needed?
2. **Proposed Solution**: How should it work?
3. **Alternatives**: What alternatives have you considered?
4. **Examples**: Show examples or mockups if applicable

## 📦 Adding New Services

When adding a new service to the stack:

1. Update all docker-compose files (default, dev, prod)
2. Add configuration files in appropriate directories
3. Update Makefile if needed
4. Add to Helm chart values
5. Update Terraform configuration
6. Add Podman Quadlet files for SystemD
7. Document in README.md
8. Add health checks in scripts/test.sh
9. Update CI/CD pipeline

## 🔒 Security

If you discover a security vulnerability:

1. **DO NOT** open a public issue
2. Email the maintainers privately
3. Provide detailed information
4. Wait for confirmation before disclosure

## 📚 Documentation Contributions

Documentation improvements are always welcome:

- Fix typos and grammar
- Improve clarity
- Add examples
- Update outdated information
- Translate to other languages

## 🎨 Dashboard Contributions

When contributing Grafana dashboards:

1. Export as JSON
2. Place in `grafana/provisioning/dashboards/json/`
3. Use descriptive filenames
4. Test that they load correctly
5. Document any custom metrics needed
6. Include screenshots in PR

## 🔧 Configuration Contributions

When contributing configuration improvements:

1. Test thoroughly
2. Document changes
3. Explain why the change is beneficial
4. Consider backward compatibility
5. Update examples

## 📋 Pull Request Process

1. **Fork** the repository
2. **Create** a feature branch
3. **Make** your changes
4. **Test** thoroughly
5. **Commit** with clear messages
6. **Push** to your fork
7. **Create** a Pull Request

### PR Checklist

- [ ] Code follows project style
- [ ] All tests pass
- [ ] Documentation updated
- [ ] Commit messages are clear
- [ ] No merge conflicts
- [ ] Changes are tested
- [ ] Screenshots included (if UI changes)

### PR Description Template

```markdown
## Description
Brief description of changes

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Breaking change
- [ ] Documentation update

## Testing
Describe testing performed

## Screenshots (if applicable)
Add screenshots here

## Checklist
- [ ] Code follows style guidelines
- [ ] Self-review completed
- [ ] Documentation updated
- [ ] No new warnings
- [ ] Tests added
- [ ] All tests pass
```

## 🤝 Code of Conduct

- Be respectful and inclusive
- Welcome newcomers
- Accept constructive criticism
- Focus on what's best for the community
- Show empathy towards others

## 💬 Getting Help

- Check existing issues
- Read the documentation
- Ask in discussions
- Be specific and provide details

## 🙏 Thank You!

Every contribution helps make this project better. Whether it's:

- Reporting a bug
- Fixing a typo
- Submitting a PR
- Suggesting a feature
- Improving documentation

Your contribution is valued and appreciated!

## 📄 License

By contributing, you agree that your contributions will be licensed under the same license as the project (MIT License).
