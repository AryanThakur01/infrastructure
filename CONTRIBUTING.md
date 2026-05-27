# Contributing Guide

Thank you for considering contributing! This document outlines the process and expectations.

---

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [How to Contribute](#how-to-contribute)
- [Branch Strategy](#branch-strategy)
- [Commit Convention](#commit-convention)
- [Pull Request Process](#pull-request-process)
- [Reporting Bugs](#reporting-bugs)
- [Requesting Features](#requesting-features)
- [Development Setup](#development-setup)

---

## Code of Conduct

By participating, you agree to uphold our [Code of Conduct](CODE_OF_CONDUCT.md).

---

## How to Contribute

1. **Fork** the repository
2. **Create** a branch from `main` (see [Branch Strategy](#branch-strategy))
3. **Make** your changes following our coding standards
4. **Write or update** tests as needed
5. **Submit** a Pull Request

---

## Branch Strategy

| Branch | Purpose |
|--------|---------|
| `main` | Production-ready code only |
| `develop` | Integration branch (optional, for larger teams) |
| `feature/*` | New features — `feature/add-login` |
| `fix/*` | Bug fixes — `fix/null-crash-on-login` |
| `chore/*` | Maintenance — `chore/upgrade-deps` |
| `docs/*` | Documentation only — `docs/update-api-guide` |
| `release/*` | Release prep — `release/v1.2.0` |

---

## Commit Convention

We follow [Conventional Commits](https://www.conventionalcommits.org/).

```
<type>(<scope>): <short description>

[optional body]

[optional footer — e.g., Closes #123]
```

### Types

| Type | When to use |
|------|------------|
| `feat` | New feature |
| `fix` | Bug fix |
| `docs` | Documentation changes only |
| `style` | Formatting, no logic change |
| `refactor` | Restructuring, no feature or fix |
| `test` | Adding or updating tests |
| `chore` | Build process, dependency updates |
| `perf` | Performance improvements |
| `ci` | CI/CD configuration |
| `revert` | Reverts a previous commit |

### Examples

```bash
feat(auth): add JWT refresh token support
fix(api): handle null user in profile endpoint
docs: add deployment instructions to README
test(payment): add unit tests for stripe webhook
chore: upgrade eslint to v9
```

---

## Pull Request Process

1. **Fill out** the PR template completely
2. **Link** the related issue (`Closes #123`)
3. **Keep PRs focused** — one concern per PR, ideally under 400 lines
4. **Ensure CI passes** before requesting review
5. **Request at least one reviewer** — see `CODEOWNERS`
6. **Address all review comments** or explain your reasoning
7. **Squash commits** before merging if history is messy

### PR Checklist (also in PR template)

- [ ] Tests added/updated
- [ ] Documentation updated
- [ ] No secrets or sensitive data committed
- [ ] `.env.example` updated if new env vars added
- [ ] `CHANGELOG.md` updated for significant changes

---

## Reporting Bugs

Use the [Bug Report template](.github/ISSUE_TEMPLATE/bug_report.md).

Include:
- What you expected to happen
- What actually happened
- Steps to reproduce
- Environment details (OS, version, etc.)

---

## Requesting Features

Use the [Feature Request template](.github/ISSUE_TEMPLATE/feature_request.md).

Include:
- The problem you are trying to solve
- Your proposed solution
- Any alternatives you considered

---

## Development Setup

See [docs/setup.md](docs/setup.md) for full environment setup instructions.
