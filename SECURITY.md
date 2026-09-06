# Security Policy

## 🛡️ Reporting Vulnerabilities

We take security seriously. If you discover a security vulnerability, please report it responsibly.

### How to Report

**DO NOT** open a public GitHub issue for security vulnerabilities.

Instead, please:

1. **GitHub Issues:** Open a security issue on the relevant repo
2. **Subject:** `[SECURITY] Brief description`
3. **Include:**
   - Description of the vulnerability
   - Steps to reproduce
   - Potential impact
   - Suggested fix (if any)

### What to Expect

- **Acknowledgment:** Within 48 hours
- **Initial Assessment:** Within 1 week
- **Resolution:** Depends on severity (see below)
- **Credit:** With your permission, we'll acknowledge your contribution

## 🔒 Security Severity Levels

### Critical (CVSS 9.0-10.0)
- Remote code execution
- Authentication bypass
- Data breach
- **Response:** Immediate hotfix

### High (CVSS 7.0-8.9)
- Privilege escalation
- Significant data exposure
- **Response:** Fix within 48 hours

### Medium (CVSS 4.0-6.9)
- Limited data exposure
- Denial of service
- **Response:** Fix within 1 week

### Low (CVSS 0.1-3.9)
- Minor information disclosure
- **Response:** Fix in next release

## 🚫 Out of Scope

The following are **not** considered security vulnerabilities:

- Issues requiring physical access to devices
- Social engineering attacks
- Denial of service attacks requiring massive resources
- Issues in third-party dependencies (report to them directly)
- Issues in deprecated/unsupported versions

## 🔐 Security Best Practices

### For Contributors

1. **Never commit secrets**
   - API keys, tokens, passwords → `.env` only
   - Use environment variables
   - Check `.gitignore` before committing

2. **Use secure dependencies**
   - Run `npm audit` / `pip audit` regularly
   - Update vulnerable packages
   - Use lockfiles

3. **Follow secure coding**
   - Validate all inputs
   - Use parameterized queries
   - Implement proper authentication
   - Follow principle of least privilege

4. **Test security changes**
   - Run security scanners
   - Test authentication flows
   - Verify authorization checks

### For Users

1. **Keep software updated**
   - Use latest stable versions
   - Subscribe to security advisories
   - Apply patches promptly

2. **Protect your data**
   - Use strong passwords
   - Enable 2FA where available
   - Be cautious with API keys

3. **Report issues**
   - Report suspicious activity
   - Share security concerns
   - Help improve security

## 🏗️ Security Architecture

### Data Protection

| Data Type | Storage | Encryption | Access |
|-----------|---------|------------|--------|
| User data | PostgreSQL | At rest + transit | Role-based |
| API keys | .env files | Not committed | Environment vars |
| Models | HuggingFace Hub | At rest | Public/Private |
| Bible text | Local JSON | None | Public domain |

### Authentication

- **Web:** NextAuth.js (OAuth2 + JWT)
- **API:** Bearer tokens
- **MCP:** Token-based auth
- **CI/CD:** GitHub Actions secrets

### Network Security

- **HTTPS:** Enforced on all endpoints
- **CORS:** Restricted origins
- **Rate limiting:** API endpoints
- **Input validation:** All user inputs

## 📋 Security Checklist

### Before Each Release

- [ ] Run `npm audit` / `pip audit`
- [ ] Update vulnerable dependencies
- [ ] Review authentication flows
- [ ] Test authorization checks
- [ ] Verify data encryption
- [ ] Check for hardcoded secrets
- [ ] Review error messages (no sensitive data)
- [ ] Test rate limiting
- [ ] Verify CORS configuration
- [ ] Review logging (no sensitive data)

### For New Features

- [ ] Threat modeling
- [ ] Input validation
- [ ] Authentication required?
- [ ] Authorization checks?
- [ ] Data encryption?
- [ ] Error handling?
- [ ] Logging & monitoring?
- [ ] Documentation?

## 🔄 Dependency Management

### Automated Scanning

- **GitHub Dependabot:** Automatic security updates
- **Snyk:** Vulnerability scanning
- **Trivy:** Container scanning (if applicable)

### Manual Review

- Review new dependencies before adding
- Check dependency health and maintenance
- Evaluate security track record
- Consider alternatives if needed

## 📚 Security Resources

### OWASP Top 10
- [OWASP](https://owasp.org/www-project-top-ten/)
- [OWASP API Security](https://owasp.org/www-project-api-security/)

### Low-Resource Language Security

- **Data sovereignty:** Community-owned data
- **Privacy:** No tracking without consent
- **Transparency:** Open-source code
- **Ethics:** CARE principles

### Training

- Secure coding practices
- Threat modeling
- Incident response
- Security architecture

## 🚨 Incident Response

### If You Discover a Breach

1. **Immediately:** Stop using affected service
2. **Document:** What happened, when, scope
3. **Report:** Contact maintainers immediately
4. **Preserve:** Do not delete logs/evidence
5. **Communicate:** If user data affected, notify users

### Our Response Process

1. **Triage:** Assess severity and scope
2. **Contain:** Isolate affected systems
3. **Eradicate:** Remove threat
4. **Recover:** Restore services
5. **Learn:** Post-mortem and improvements

## 🙏 Acknowledgments

We thank security researchers who help us improve security. With permission, we'll:

- Credit you in our security page
- List you in release notes
- Provide a reference letter (if needed)

## 📞 Contact

- **General questions:** GitHub Discussions
- **Real-time chat:** Discord

## 📝 Changelog

- **2026-09-07:** Initial security policy

---

**Thank you for helping keep Zolai-AI secure!** 🛡️
