# Agent Guidelines

## Commit Protocol

When working on tasks in this repository, agents must follow these commit guidelines:

### Committing Changes

1. **Commit Frequency**: Create commits after completing each logical unit of work
   - Complete a feature implementation
   - Fix a bug
   - Refactor a component
   - Update documentation

2. **Commit Messages**: Follow conventional commit format
   ```
   <type>(<scope>): <subject>

   <body>
   ```

   Types:
   - `feat`: New feature
   - `fix`: Bug fix
   - `refactor`: Code refactoring
   - `docs`: Documentation changes
   - `test`: Adding or updating tests
   - `chore`: Maintenance tasks
   - `style`: Code style changes (formatting, etc.)

3. **Signed Commits**: All commits MUST be signed
   - Ensure git is configured with GPG signing enabled
   - The commit command should allow git hooks to run (do not use `--no-verify`)
   - Example:
     ```bash
     git add <files>
     git commit -m "$(cat <<'EOF'
     feat(module): add new functionality

     Detailed description of changes.
     EOF
     )"
     ```

### Workflow Steps

1. **Before Starting**:
   - Check `git status` to understand current state
   - Review recent commits with `git log` to understand commit message style

2. **During Work**:
   - Format code according to project standards
   - Run tests if applicable
   - Ensure changes are functional

3. **Before Committing**:
   - Run `git status` to see untracked/modified files
   - Run `git diff` to review changes
   - Stage relevant files with `git add`

4. **Committing**:
   - Create signed commit with descriptive message
   - Verify commit success with `git status`

### Important Notes

- DO NOT use `--no-verify` or `--no-gpg-sign` flags
- DO NOT skip git hooks
- DO NOT push to remote unless explicitly requested
- DO NOT amend commits from other developers
- DO NOT commit sensitive files (.env, credentials, secrets)

### Example Workflow

```bash
# Check status
git status

# Review changes
git diff

# Stage files
git add src/module.nix

# Create signed commit
git commit -m "$(cat <<'EOF'
feat(module): add builder configuration

Configure remote builder settings for distributed builds.
EOF
)"

# Verify
git status
```
