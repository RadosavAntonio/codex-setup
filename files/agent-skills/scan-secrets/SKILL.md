---
name: scan-secrets
description: Scan staged changes for secrets, credentials, PII, private keys, connection strings, and accidentally staged environment files before a commit.
---

# Scan staged changes

Inspect added staged lines and staged filenames. Look for high-confidence key formats, bearer tokens, passwords, private keys, certificates, credentialed URLs, database connection strings, personal email or phone data, internal identifiers, IP addresses, and real `.env` files. Distinguish fixtures and documented placeholders from real findings.

Report each real finding with file and line. Do not commit while a real secret or PII finding remains. Never print the complete value; redact it.
