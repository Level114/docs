# Contributing to Bittensor Minecraft Subnet

Thank you for your interest in contributing to the Bittensor Minecraft subnet! This document provides guidelines and information for contributors.

## How to Contribute

### Reporting Issues

- Use the [GitHub Issues](https://github.com/your-org/bittensor-minecraft-subnet/issues) page
- Search existing issues before creating new ones
- Use clear, descriptive titles and detailed descriptions
- Include steps to reproduce for bugs
- Add relevant labels (bug, enhancement, documentation, etc.)

### Types of Contributions

We welcome various types of contributions:

1. **Code Contributions**
   - Bug fixes
   - New features
   - Performance improvements
   - Test coverage improvements

2. **Documentation**
   - Fixing typos and errors
   - Adding examples and tutorials
   - Improving API documentation
   - Translating documentation

3. **Community Support**
   - Answering questions in Discord
   - Helping users troubleshoot issues
   - Creating tutorials and guides

## Development Process

### Setting Up Development Environment

1. Fork the repository
2. Clone your fork: `git clone https://github.com/yourusername/bittensor-minecraft-subnet.git`
3. Create a virtual environment and install dependencies
4. Set up local development subnet (see [Local Devnet Guide](docs/04-getting-started/local-devnet.md))

### Code Standards

- Follow the [Style Guide](docs/12-contributing/style-guide.md)
- Write tests for new functionality
- Ensure all tests pass before submitting
- Use meaningful commit messages
- Keep pull requests focused and atomic

### Pull Request Process

1. Create a feature branch from `main`
2. Make your changes following our coding standards
3. Add or update tests as needed
4. Update documentation if required
5. Ensure CI/CD passes
6. Create a pull request with:
   - Clear title and description
   - Reference to related issues
   - Screenshots for UI changes
   - Testing instructions

### Testing

- Run the full test suite: `python -m pytest`
- Test your changes in a local devnet environment
- Include both unit tests and integration tests
- See [Testing & CI Guide](docs/12-contributing/testing-and-ci.md)

## Architecture Decision Records (ADRs)

For significant architectural changes, create an ADR using our [template](docs/08-governance/change-proposals-adr.md).

## Documentation Contributions

Documentation is built with MkDocs Material. To work on docs:

1. Install dependencies: `pip install mkdocs-material`
2. Serve locally: `mkdocs serve`
3. Edit markdown files in the `docs/` directory
4. Follow our documentation style guide

## Community Guidelines

- Be respectful and inclusive
- Follow our [Code of Conduct](CODE_OF_CONDUCT.md)
- Help newcomers and answer questions patiently
- Provide constructive feedback in code reviews
- Celebrate others' contributions

## Recognition

Contributors will be recognized in:
- README.md contributors section
- Release notes for significant contributions
- Community Discord announcements
- Developer reward allocations for major contributions

## Getting Help

- **Discord**: Join our [community server](https://discord.gg/your-server)
- **GitHub Discussions**: For longer-form questions and discussions
- **GitHub Issues**: For specific bugs or feature requests
- **Documentation**: Check our [FAQ](docs/11-reference/faq.md)

## Development Workflow

1. **Fork & Clone**: Start by forking the repository
2. **Branch**: Create feature branches from `main`
3. **Develop**: Make changes following our standards
4. **Test**: Ensure all tests pass locally
5. **Document**: Update documentation as needed
6. **Submit**: Create a pull request for review
7. **Iterate**: Address feedback from maintainers
8. **Merge**: Once approved, changes are merged

## Release Process

- We follow [semantic versioning](https://semver.org/)
- Releases are tagged and documented
- Breaking changes are clearly communicated
- Migration guides are provided when needed

Thank you for contributing to the Bittensor Minecraft subnet! Your contributions help make decentralized gaming a reality.
