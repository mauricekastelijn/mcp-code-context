# Contributing Guide

Thank you for your interest in contributing to this project! This guide will help you get started.

## How to Contribute

### Reporting Issues

If you encounter problems, please open an issue with:

1. **Clear title** - Describe the issue briefly
2. **Environment details** - OS, Docker version, Node.js version
3. **Steps to reproduce** - How to trigger the issue
4. **Expected vs actual behavior** - What should happen vs what happens
5. **Logs** - Include relevant error messages and logs
6. **Screenshots** - If applicable

**Example Issue:**
```
Title: MILVUS container fails to start on Windows 11

Environment:
- OS: Windows 11 Pro
- Docker Desktop: 4.25.0
- Node.js: v20.10.0

Steps to reproduce:
1. Run setup-windows.ps1
2. Wait for containers to start
3. MILVUS container crashes

Expected: Container should start and be healthy
Actual: Container restarts repeatedly

Logs:
[paste relevant logs]
```

### Suggesting Enhancements

We welcome suggestions! Please open an issue with:

1. **Use case** - What problem does this solve?
2. **Proposed solution** - How should it work?
3. **Alternatives considered** - What other approaches did you think about?
4. **Additional context** - Any other relevant information

### Contributing Code

#### Prerequisites

- Git installed
- Docker and Docker Compose
- Node.js >= 20.0.0 and < 24.0.0
- Familiarity with PowerShell (Windows) or Bash (Linux/Mac)

#### Setup Development Environment

1. **Fork the repository**
   ```bash
   # Fork on GitHub, then clone your fork
   git clone https://github.com/your-username/mcp-code-context.git
   cd mcp-code-context
   ```

2. **Create a branch**
   ```bash
   git checkout -b feature/your-feature-name
   # or
   git checkout -b fix/your-bug-fix
   ```

3. **Test the setup**
   ```bash
   # Windows
   .\setup-windows.ps1
   .\verify-setup.ps1

   # Linux/Mac
   ./setup-linux.sh
   ./verify-setup.sh
   ```

#### Making Changes

1. **Keep changes focused** - One feature or fix per pull request
2. **Test thoroughly** - Test on your platform before submitting
3. **Update documentation** - Update relevant .md files
4. **Follow existing patterns** - Match the style of existing code

#### Testing Your Changes

**Test Scripts:**
```bash
# Windows
.\setup-windows.ps1
.\verify-setup.ps1
.\cleanup-windows.ps1

# Linux/Mac
./setup-linux.sh
./verify-setup.sh
./cleanup-linux.sh
```

**Test Docker Configuration:**
```bash
docker-compose config
docker-compose up -d
docker-compose ps
docker-compose logs
docker-compose down -v
```

**Test on Multiple Platforms (if possible):**
- Windows 10/11
- Ubuntu 20.04/22.04
- macOS (Intel and Apple Silicon)

#### Submitting Pull Requests

1. **Commit your changes**
   ```bash
   git add .
   git commit -m "feat: add support for custom models"
   ```

   **Commit message format:**
   - `feat:` - New feature
   - `fix:` - Bug fix
   - `docs:` - Documentation changes
   - `chore:` - Maintenance tasks
   - `refactor:` - Code refactoring
   - `test:` - Test changes

2. **Push to your fork**
   ```bash
   git push origin feature/your-feature-name
   ```

3. **Create pull request**
   - Go to GitHub and create a PR
   - Fill in the PR template
   - Link related issues

**PR Template:**
```markdown
## Description
Brief description of changes

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Documentation update
- [ ] Refactoring

## Testing
- [ ] Tested on Windows
- [ ] Tested on Linux
- [ ] Tested on macOS
- [ ] Setup script works
- [ ] Verify script passes
- [ ] Documentation updated

## Related Issues
Fixes #123
```

## Development Guidelines

### Code Style

**PowerShell Scripts:**
- Use PascalCase for variables
- Include error handling
- Add comments for complex logic
- Use Write-Host with colors for output

**Bash Scripts:**
- Use snake_case for variables
- Include error handling (`set -e`)
- Add comments for complex logic
- Use colored output

**Docker Compose:**
- Use version 3.8
- Include health checks
- Document environment variables
- Use meaningful service names

**Markdown:**
- Use ATX-style headers (`#`)
- Include table of contents for long docs
- Use code blocks with language specifiers
- Keep lines under 100 characters (when possible)

### Documentation

**When adding features:**
1. Update README.md if it affects quick start
2. Add detailed docs in appropriate files
3. Update QUICK_REFERENCE.md
4. Add examples to EXAMPLES.md
5. Update TROUBLESHOOTING.md if needed

**Documentation checklist:**
- [ ] Clear and concise
- [ ] Examples included
- [ ] Cross-references to related docs
- [ ] Tested on target platform
- [ ] Screenshots/diagrams if helpful

### Project Structure

```
mcp-code-context/
├── README.md              # Main documentation
├── QUICK_REFERENCE.md     # Quick commands reference
├── VSCODE_SETUP.md        # VS Code configuration
├── USAGE.md               # How to use the MCP
├── EXAMPLES.md            # Example use cases
├── LICENSE                # MIT License
├── CONTRIBUTING.md        # This file
├── .gitignore            # Git ignore rules
├── docker-compose.yml     # Docker orchestration
├── setup-windows.ps1      # Windows setup script
├── setup-linux.sh         # Linux setup script
├── cleanup-windows.ps1    # Windows cleanup script
├── cleanup-linux.sh       # Linux cleanup script
├── verify-setup.ps1       # Windows verification
├── verify-setup.sh        # Linux verification
└── docs/
    ├── MILVUS_SETUP.md        # MILVUS documentation
    ├── OLLAMA_SETUP.md        # Ollama documentation
    ├── CONFIGURATION.md       # Configuration guide
    └── TROUBLESHOOTING.md     # Troubleshooting guide
```

## Areas for Contribution

### High Priority

- [ ] GPU support documentation and configuration
- [ ] Performance benchmarks
- [ ] Additional embedding model guides
- [ ] Automated tests
- [ ] Container health monitoring improvements

### Documentation

- [ ] Video tutorials
- [ ] More real-world examples
- [ ] Translation to other languages
- [ ] Architecture diagrams
- [ ] Troubleshooting flowcharts

### Features

- [ ] Backup/restore automation scripts
- [ ] Resource monitoring dashboard
- [ ] Alternative embedding providers
- [ ] Integration with other MCP clients
- [ ] Configuration validation script

### Testing

- [ ] Automated setup testing
- [ ] Cross-platform CI/CD
- [ ] Integration tests
- [ ] Performance tests

## Questions?

- Open an issue with the `question` label
- Check existing documentation first
- Be specific about your use case

## Code of Conduct

### Our Pledge

We are committed to providing a welcoming and inclusive environment for all contributors.

### Expected Behavior

- Be respectful and considerate
- Welcome diverse perspectives
- Focus on constructive feedback
- Help others learn and grow

### Unacceptable Behavior

- Harassment or discrimination
- Trolling or insulting comments
- Personal or political attacks
- Publishing others' private information

### Enforcement

Violations can be reported by opening an issue or contacting maintainers directly.

## Recognition

Contributors will be recognized in:
- GitHub contributors page
- Release notes for significant contributions
- Special thanks section (if added in future)

## License

By contributing, you agree that your contributions will be licensed under the MIT License.

## Thank You!

Your contributions help make this project better for everyone. We appreciate your time and effort! 🎉
