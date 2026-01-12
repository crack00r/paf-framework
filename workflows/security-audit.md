# Workflow: Security Audit

> Comprehensive security review of a feature or system

## When to use?
- Before launching a new feature
- Regularly (quarterly)
- After security incident
- For GDPR-relevant changes

## Process

```
┌─────────────────────────────────────────────────────────────────────────┐
│                        SECURITY AUDIT WORKFLOW                           │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│  1. SCOPE DEFINITION (Alex + Nina)                                     │
│  └── What will be checked? Which assets? Which threats?                │
│           │                                                             │
│           ▼                                                             │
│  2. AUTOMATED SCAN (Scanner)                                           │
│  └── SAST, Dependency Check, Secret Scan                               │
│           │                                                             │
│           ▼                                                             │
│  3. MANUAL REVIEW (Alex + Max)                                         │
│  ├── Authentication & Authorization                                     │
│  ├── Input Validation                                                   │
│  ├── Data Protection                                                    │
│  ├── GDPR Compliance                                                    │
│  ├── Business Logic Flaws                                               │
│  └── Code Quality (Maintainability)                                     │
│           │                                                             │
│           ▼                                                             │
│  4. ARCHITECTURE REVIEW (David + Sophia)                               │
│  └── Security Architecture, System Design                              │
│           │                                                             │
│           ▼                                                             │
│  5. SECURITY REPORT (Leo + George)                                     │
│  └── Document findings, severity, recommendations                      │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
```

## Claude Code Prompt

```
I want to run a PAF Security Audit for [FEATURE/SYSTEM].

**Phase 1: Scope (Alex + Nina)**
- Define audit scope (Alex)
- Identify critical assets (Alex)
- Prioritize threats (Nina)

**Phase 2: Automated Scan (Scanner)**
- npm audit / Dependency Check
- SAST Scan
- Secret Detection

**Phase 3: Manual Review (Alex + Max)**
- [ ] Authentication (Login, Session, Token)
- [ ] Authorization (Who can do what?)
- [ ] Input Validation (XSS, SQLi, etc.)
- [ ] Data Protection (Encryption, PII)
- [ ] GDPR (Consent, Deletion, Audit)
- [ ] API Security (Rate Limiting, Auth)
- [ ] Error Handling (Info Leakage)
- [ ] Code Quality & Maintainability (Max)

**Phase 4: Architecture Review (David + Sophia)**
- Security architecture review
- System design security assessment
- Scalability security implications

**Phase 5: Security Report (Leo + George)**
- Document all findings (Leo)
- Severity: CRITICAL/HIGH/MEDIUM/LOW
- Recommendations
- Summary and aggregation (George)

Write everything in .paf/COMMS.md sections for each agent.
```

## Security Checklist

### Authentication
- [ ] Passwords hashed (bcrypt/argon2)
- [ ] Session Management secure
- [ ] MFA available
- [ ] Password Policy

### Authorization
- [ ] Least Privilege
- [ ] Role-Based Access
- [ ] Object-Level Authorization

### Input
- [ ] All inputs validated
- [ ] XSS Prevention
- [ ] SQL Injection Prevention
- [ ] File Upload Validation

### Data
- [ ] Encryption at Rest
- [ ] Encryption in Transit (TLS)
- [ ] PII minimized
- [ ] Backup Encryption

### GDPR
- [ ] Consent Management
- [ ] Right to Delete
- [ ] Right to Access
- [ ] Data Retention Policy
- [ ] Audit Trail

### API
- [ ] Rate Limiting
- [ ] API Key Management
- [ ] CORS correct
- [ ] Error messages secure