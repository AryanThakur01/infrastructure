# Security Policy

## Supported Versions

| Version | Supported |
|---------|-----------|
| latest  | ✅        |
| < 1.0   | ❌        |

## Reporting a Vulnerability

**Do NOT open a public GitHub issue for security vulnerabilities.**

Please report them privately via one of these methods:

1. **GitHub Private Vulnerability Reporting** (preferred): Use the "Report a vulnerability" button on the Security tab.
2. **Email:** aryan197297@gmail.com

### What to include

- Description of the vulnerability
- Steps to reproduce
- Potential impact
- Suggested fix (if any)

### What to expect

- **Acknowledgement** within 48 hours
- **Status update** within 7 days
- **Fix timeline** communicated based on severity

I follow responsible disclosure — I will credit you in the release notes unless you prefer to remain anonymous.

## Security Best Practices for Contributors

- Never commit secrets, tokens, or credentials
- Always use `.env.example` for environment variable templates
- Validate and sanitize all user inputs
- Use parameterized queries to prevent SQL injection
- Keep dependencies updated (Dependabot is configured)
- Follow the principle of least privilege
