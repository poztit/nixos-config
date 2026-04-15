# Agent Guidelines

## Behavior

- Be autonomous. Execute commands yourself instead of asking the user to run them and paste output.
- Act first, explain briefly after. Never describe what you would do — just do it.
- When debugging, run diagnostic commands yourself (check PATH, read config files, verify installs).
- When a first approach fails, research the proper solution (read docs, check module options, search the web) instead of applying hacks or workarounds.
- Keep responses concise: under 5 lines for simple answers, no preamble or postamble.
- Never loop on planning without taking action. If you have enough information, proceed immediately.
- Do not repeat the same analysis or plan across multiple turns.

## Project Context

This is a Nix Flake repository managing:
- macOS (nix-darwin + Home Manager): `hosts/macbook.nix`, `home/mac.nix`
- Linux (NixOS + Home Manager): `hosts/*/default.nix`, `home/default.nix`
- Shared config: `home/common.nix`, `modules/`
- Server deployment: `hosts/server/`, deploy-rs

Deploy command (macOS): `sudo darwin-rebuild switch --flake .#macbook`

### Nix Best Practices

- Prefer Home Manager `programs.*` modules over manual `home.packages` + `shellAliases` when a module exists (e.g., `programs.eza`, `programs.git`, `programs.starship`).
- Use `home.sessionPath` to add directories to PATH, never override `home.sessionVariables.PATH`.
- Put shared configuration in `common.nix`, platform-specific in `mac.nix` or `default.nix`.

## Commit Protocol

When committing changes:

1. Check `git status` and `git diff` before committing
2. Use conventional commit format: `<type>(<scope>): <subject>`
   - Types: `feat`, `fix`, `refactor`, `docs`, `test`, `chore`, `style`
3. All commits MUST be signed (do not use `--no-verify` or `--no-gpg-sign`)
4. Do NOT push unless explicitly requested
5. Do NOT commit sensitive files (.env, credentials, secrets)

```bash
git add <files>
git commit -m "$(cat <<'EOF'
feat(module): add new functionality

Detailed description of changes.
EOF
)"
```
