---
description: Comprehensive security scan and vulnerability assessment (OWASP, SAST, dependencies, secrets)
---

# Security Scan and Vulnerability Assessment

You are a security expert. Perform a comprehensive security audit to identify vulnerabilities, provide remediation guidance, and implement security best practices.

## Requirements
$ARGUMENTS

## Process

### 1. Detect Project Type

Scan the project to identify technologies:
- Python (requirements.txt, setup.py, pyproject.toml)
- JavaScript/Node.js (package.json)
- Go (go.mod)
- Rust (Cargo.toml)
- Docker (Dockerfile)
- Terraform (*.tf)

### 2. Code Vulnerability Scan (SAST)

Search the codebase for these vulnerability patterns:

**CRITICAL:**
- SQL Injection: raw queries with string concatenation/interpolation
- Hardcoded Secrets: API keys, passwords, tokens in source code
- Code Evaluation: eval(), exec(), Function() usage

**HIGH:**
- XSS: innerHTML, dangerouslySetInnerHTML, document.write with user input
- Path Traversal: unsanitized file path operations
- CSRF: disabled CSRF protection
- CORS: wildcard origin configuration

**MEDIUM:**
- Insecure Random: Math.random(), rand() for security-sensitive operations
- Debug Mode: debug=True in production configs
- Missing Security Headers: no helmet() or equivalent

### 3. Dependency Vulnerability Scan

Check for known vulnerabilities in dependencies:
- **npm**: `npm audit --json`
- **pip**: `pip-audit` or `safety check`
- **cargo**: `cargo audit`
- **go**: `govulncheck`

### 4. Secret Detection

Search for leaked secrets:
- API keys and tokens
- Database connection strings
- Private keys
- AWS/GCP/Azure credentials
- Passwords in config files

Use patterns:
```
grep -rn "(?i)(api[_-]?key|apikey|secret|password|token)\s*[:=]\s*[\"'][^\"']{8,}"
grep -rn "(?i)bearer\s+[a-zA-Z0-9\-\._~\+\/]{20,}"
grep -rn "(?i)(aws[_-]?access|aws[_-]?secret)\s*[:=]"
```

### 5. Framework-Specific Checks

**React/Next.js:**
- dangerouslySetInnerHTML usage
- eval() in components
- Exposed API routes without auth

**Django:**
- @csrf_exempt decorators
- Raw SQL queries
- DEBUG = True

**Express:**
- Missing helmet middleware
- Wildcard CORS
- No rate limiting

### 6. Generate Report

```markdown
# Security Scan Report

**Date**: <date>
**Project**: <project-name>
**Risk Score**: <0-100>

## Summary
- Critical: N findings
- High: N findings
- Medium: N findings
- Low: N findings

## Findings

### [Finding Title]
- **Severity**: CRITICAL|HIGH|MEDIUM|LOW
- **Category**: SAST|Dependencies|Secrets|Config
- **File**: path/to/file:line
- **CWE**: CWE-XXX
- **Description**: What was found
- **Remediation**: How to fix it

## Dependency Vulnerabilities
<List of vulnerable packages with CVEs>

## Recommendations
1. Immediate actions (Critical/High)
2. Short-term improvements (Medium)
3. Long-term hardening (Low)
```
