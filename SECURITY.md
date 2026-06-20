# Security Policy

This document describes how to report security vulnerabilities for **PackageUpdateInfo** and what to expect from the maintainers.

PackageUpdateInfo is a PowerShell module helps you staying up to date with you installed modules. It checks all your local installed powershell modules and output a table with module names and version information.

---

## Supported Versions

Security fixes are provided for:

- The **latest released version** published to the PowerShell Gallery and/or GitHub Releases.
- The **current release line** (if multiple supported release lines exist).

> Notes:
> - Pre-release builds and arbitrary commits on branches are not considered supported for security updates.
> - If you are unsure whether your version is supported, include your module version and installation method in the report.

---

## Reporting a Vulnerability

### Preferred: GitHub Private Vulnerability Reporting
Please report security issues **privately** using GitHub Security Advisories / Private Vulnerability Reporting for this repository:

- https://github.com/AndiBellstedt/PackageUpdateInfo/security

**Do not** open a public GitHub issue for suspected vulnerabilities.

### What to Include
To help triage quickly, include:

- A clear description of the issue and potential impact
- Steps to reproduce (proof-of-concept if possible)
- Affected versions (e.g., `1.0.0`)
- Your environment:
  - PowerShell version (Windows PowerShell 5.1 / PowerShell 7+)
  - OS and version (e.g., Windows Server 2022)
  - DNS Server version (if relevant)
- Any relevant logs **with secrets removed**
- Suggested remediation (optional)

### Sensitive Data Handling
Do **not** include any of the following in reports or logs:

- API keys, tokens, or credentials
- DNS query data containing sensitive internal information
- Client IP addresses or internal network topology details
- Any personal data you are not authorized to share

---

## Response & Disclosure Process

We follow coordinated vulnerability disclosure principles.

### Targets (Best-Effort)
- **Acknowledgement**: within **14 days**
- **Initial triage** (confirming scope/severity and whether we can reproduce): within **30 days**
- **Status updates**: when progress is made (or at least every **30–60 days** for active reports)
- **Fix & release**: depends on severity and complexity (critical issues are prioritized; lower-severity issues may take longer)

### Severity
Severity is determined by maintainers considering:
- Exploitability
- Impact (confidentiality, integrity, availability)
- Scope (local vs. remote, authenticated vs. unauthenticated)
- Availability of mitigations/workarounds

### Public Disclosure
- Please allow time for a fix to be developed and released before disclosing publicly.
- If a CVE is appropriate, we may request one or coordinate issuance through GitHub.

---

## Security Scope

### In Scope
- The **PackageUpdateInfo** PowerShell module code in this repository
- Module installation script(s) shipped with the repo (e.g., `install.ps1`)
- CI/CD definitions and build scripts included in this repository (e.g., Azure Pipelines configuration)
- Localization resources and type/format definition files shipped with the module

### Out of Scope (Examples)
- Vulnerabilities in **Windows DNS Server** itself
- Vulnerabilities in **PowerShell** / the runtime
- Issues in third-party analysis tools or databases where parsed data is imported
- Issues in third-party services (e.g., GitHub) unless caused by PackageUpdateInfo’s implementation
- Social engineering, phishing, or physical attacks

If a report is out of scope but relevant, we may still suggest mitigations or upstream reporting paths.

---

## Project-Specific Security Considerations

PackageUpdateInfo performs file operations on DNS Server debug logs, which may contain sensitive network information. The following are security-sensitive areas:

### DNS Query Data Privacy
- DNS debug logs contain potentially sensitive information including:
  - Internal domain names and network topology
  - Client IP addresses (may be considered PII in some jurisdictions)
  - Query patterns that reveal user behavior
  - Failed queries that may expose internal applications or services
- When sharing parsed CSV output or statistics, ensure you have authorization to share this data.
- Consider data retention and privacy regulations (GDPR, CCPA, etc.) when storing parsed DNS data.
- Report any scenario where the module inadvertently exposes or logs sensitive query data beyond what's in the source log file.

### Log File Access and Permissions
- DNS Server debug logs typically require administrative privileges to access.
- Ensure proper file system permissions are maintained on:
  - Input DNS debug log files (typically in `C:\Windows\System32\dns\` on default installations)
  - Output CSV files containing parsed query data
  - Temporary files during processing
  - Compressed archives when using `-CompressOutput`
- Do not process DNS logs from untrusted sources or network shares without proper validation.
- When using `-RemoveSourceFile`, ensure you have proper authorization and backups, as this permanently deletes source files.

### Path Handling and Traversal
- Input file paths and output file paths can be user-controlled or come from external sources.
- The module should validate paths to prevent:
  - Path traversal attacks (e.g., `../../Windows/System32`)
  - Writing to protected system locations
  - Overwriting critical files
- Report any scenario where path validation can be bypassed or where the module writes to unintended locations.

### DNS Log Injection and Malformed Data
- DNS debug logs may contain malformed entries, either due to DNS attacks or corrupted log files.
- The module should safely handle:
  - Unexpected characters in domain names
  - Extremely long query names (potential buffer issues)
  - Malicious characters that could affect CSV parsing (delimiters, quotes, newlines)
  - Invalid IP addresses or malformed protocol fields
- Report any scenario where malformed DNS log entries cause crashes, data corruption, or unexpected behavior.

### Resource Exhaustion and DoS
- Very large DNS debug log files (multi-gigabyte) could cause:
  - Excessive memory consumption
  - CPU exhaustion during parsing
  - Disk space exhaustion from CSV output (typically 2-3x larger than input)
  - Temporary file accumulation
- The module implements streaming I/O to minimize memory footprint, but report any resource exhaustion issues.
- When using automation, ensure adequate disk space monitoring to prevent disk full conditions.

### Logging and Diagnostics
- PackageUpdateInfo uses verbose output for operational details.
- Diagnostic output should never include:
  - Sensitive DNS query data beyond what's expected in normal operation
  - File system paths that reveal internal infrastructure
  - Temporary file contents or intermediate parsing data
- Report any scenario where verbose or error output exposes sensitive information beyond the scope of the input log file.


---

## Safe Harbor for Good-Faith Research

We support good-faith security research and coordinated disclosure.

When conducting research:
- Do not degrade service availability (DoS), destroy data, or exfiltrate data
- Only test against systems and data you own or are explicitly authorized to test
- Use the private reporting channel above and avoid public disclosure until coordinated

---

## Security Updates

When a security issue is confirmed:
- A fix will be released as a new module version.
- Release notes will describe the issue and mitigation guidance, avoiding exploit details when appropriate.

---

## Acknowledgements

We appreciate responsible disclosure. With your permission, we may acknowledge your contribution in release notes or advisories.

Thank you for helping keep PackageUpdateInfo secure.