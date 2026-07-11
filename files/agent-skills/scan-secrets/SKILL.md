---
name: scan-secrets
description: Scan staged files for secrets, PII, and sensitive data before committing. Use proactively before git commit.
---

Scan all staged files for secrets, PII, and sensitive data before committing.

## What To Scan For

### Secrets

- API keys, tokens, passwords, licence keys.
- Private SSH keys: `id_rsa`, `id_ed25519`, `*.pem`, `*.key`.
- Certificates and keystores: `*.p12`, `*.pfx`, `*.keystore`.
- Database connection strings with credentials.
- Bearer tokens, `sk-` prefixed keys, `pk_` prefixed keys.
- This repo specifically: `GRAPHQL_SCHEMA_REPO_PAT`, `CONTENTFUL_PERSONALISATION_API_KEY_*`, and anything from `.env`.

### PII

- Email addresses. Replace with `user@example.com` or placeholders.
- Phone numbers and physical addresses.
- Corporate tenant IDs, user OIDs, OAuth URLs with personal identifiers.
- Device fingerprints, hardware IDs, telemetry data.
- Internal or personal IP addresses.
- Client numbers, access tokens such as `x-hl-access-token` and `x-hl-client-number`.

## Process

Run these checks against staged files:

```bash
git diff --cached | grep -iE "api.key|secret|token|password|Bearer|sk-|pk_|PRIVATE KEY|PAT" && echo "SECRETS FOUND" || echo "No secrets"
git diff --cached | grep -iE "@[a-z]+\\.(com|co\\.uk|org|net|io)|[0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3}" && echo "PII FOUND" || echo "No PII"
git diff --cached --name-only | grep -E "(^|/)\\.env" && echo ".env STAGED" || echo "No .env staged"
```

For each finding, determine whether it is a real secret or a false positive. Report real findings with file paths and line numbers. Do not proceed with the commit if real secrets or PII are found.
