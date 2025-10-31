# Changelog

All notable changes to this project will be documented in this file.

## [1.1.0] - 2025-10-31

### Added
- **Corporate Proxy Support** - Custom Ollama Dockerfile to handle certificate validation errors
  - `ollama/Dockerfile` - Custom build with CA certificate support and curl installation
  - `ollama/res/` - Directory for placing corporate CA certificates
  - `ollama/README.md` - Detailed instructions for certificate setup
  - `CORPORATE_PROXY_SETUP.md` - Comprehensive guide for corporate proxy users
  
### Changed
- **docker-compose.yml** - Updated Ollama service configuration
  - Changed from `image: ollama/ollama:latest` to `build: ./ollama`
  - Added fallback option for users without corporate proxy needs
  - Fixed health check with `CMD-SHELL` syntax and added `start_period: 45s`
  - Health check now properly waits for Ollama to fully start
  
- **ollama/Dockerfile** - Enhanced with additional dependencies
  - Added curl installation for health checks
  - Maintains CA certificate installation functionality
  
- **Setup Scripts** - Enhanced to support custom Ollama builds
  - `setup-windows.ps1` - Added `--build` flag and certificate error messaging
  - `setup-linux.sh` - Added `--build` flag and certificate error messaging
  
- **Documentation Updates**
  - `README.md` - Added corporate proxy section in prerequisites
  - `QUICK_REFERENCE.md` - Added certificate troubleshooting section
  - `docs/TROUBLESHOOTING.md` - Enhanced with health check troubleshooting and certificate errors
  
- **.gitignore** - Added rules to exclude certificate files for security

### Fixed
- Certificate validation errors when behind corporate proxies (Cisco Umbrella, Zscaler, etc.)
- Ollama model download failures due to TLS verification issues
- Ollama health check stuck on "starting" - now properly detects when service is ready
- Missing curl in Ollama container causing health check failures

## [1.0.0] - 2025-10-31

### Added
- Initial release with complete self-contained MCP setup
- Docker Compose configuration for MILVUS and Ollama
- Automated setup scripts for Windows and Linux
- Comprehensive documentation (18 files, ~45,000 words)
- Setup verification scripts
- Cleanup scripts
- Example use cases and workflows
- Troubleshooting guides
- Configuration guides for advanced users

### Features
- **MILVUS** - Local vector database (v2.4.0)
- **Ollama** - Local embedding service with nomic-embed-text model
- **MCP Server** - VS Code integration for claude-context
- **Cross-Platform** - Support for Windows, Linux, and macOS
- **Fully Local** - No cloud dependencies required
- **Well-Documented** - Extensive guides for all scenarios

### Documentation
- README.md - Main project documentation
- QUICK_REFERENCE.md - Command quick reference
- VSCODE_SETUP.md - VS Code MCP configuration
- USAGE.md - Detailed usage instructions
- EXAMPLES.md - Real-world examples
- CONTRIBUTING.md - Contribution guidelines
- LICENSE - MIT License
- docs/MILVUS_SETUP.md - MILVUS configuration guide
- docs/OLLAMA_SETUP.md - Ollama configuration guide
- docs/CONFIGURATION.md - Advanced configuration
- docs/TROUBLESHOOTING.md - Problem-solving guide

---

## Version Format

This project follows [Semantic Versioning](https://semver.org/):
- **MAJOR** - Incompatible changes
- **MINOR** - New features (backward compatible)
- **PATCH** - Bug fixes (backward compatible)

## Categories

- **Added** - New features
- **Changed** - Changes to existing features
- **Deprecated** - Features that will be removed
- **Removed** - Removed features
- **Fixed** - Bug fixes
- **Security** - Security fixes
