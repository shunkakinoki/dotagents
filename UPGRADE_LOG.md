# Dependency upgrade log

## 2026-08-06

- `skills`: updated from `^1.5.20` to `^1.5.22`, the current stable release.
- `bun.lock` records the resolved `skills@1.5.22` package and its new transitive dependencies.
- The Makefile now invokes the project-local SDK binary and refreshes dependencies with Bun's release-age check disabled, so the declared current release is available immediately.
- Verification: `./node_modules/.bin/skills --version`, frozen-lockfile install, `make skills-install` from both `dotagents/` and the upstream `~/dotfiles` checkout, and `make sync`.
