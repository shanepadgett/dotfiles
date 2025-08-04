# Contributing Guide

## Conventional Commits

Use the format: `<type>(<scope>): <description>`

### Types
- `feat` - New features or functionality
- `fix` - Bug fixes
- `chore` - Maintenance tasks, dependency updates
- `docs` - Documentation changes
- `refactor` - Code restructuring without behavior changes
- `test` - Adding or updating tests
- `ci` - CI/CD pipeline changes

### Scopes
- `shell` - Shell configuration (bashrc, zshrc, aliases, functions)
- `tools` - Application configs (vscode, zed, git, etc.)
- `scripts` - Automation and utility scripts
- `brew` - Homebrew packages and Brewfile
- `devcontainer` - Development container configuration
- `templates` - Project templates
- `install` - Installation and setup processes

### Examples
```
feat(shell): add git aliases for common workflows
fix(tools): correct vscode settings syntax error
chore(brew): update package versions in Brewfile
docs(scripts): add usage examples for dev commands
refactor(install): simplify dependency checking logic
```

### Rules
- Use lowercase for type and scope
- Keep description under 50 characters
- Use imperative mood ("add" not "adds" or "added")
- No period at end of description