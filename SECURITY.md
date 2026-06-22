# Security Policy

This document describes how to report security vulnerabilities for **PackageUpdateInfo** and what to expect from the maintainers.

PackageUpdateInfo is a PowerShell module that helps you stay up to date with your installed PowerShell modules. It queries the PowerShell Gallery to check available versions and can automate notifications when updates are available.

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
  - OS and version (e.g., Windows 11, Windows Server 2022)
  - Module installation scope (CurrentUser or AllUsers)
- Any relevant logs **with secrets removed**
- Suggested remediation (optional)

### Sensitive Data Handling
Do **not** include any of the following in reports or logs:

- API keys, tokens, or credentials (PowerShell Gallery API keys, etc.)
- Credentials used for module authentication
- Module metadata that may reveal internal systems or network topology
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
- CI/CD definitions and build scripts included in this repository (e.g., GitHub Actions workflows)
- Type and format definition files shipped with the module
- Localization resources
- Module manifest and module configuration

### Out of Scope (Examples)
- Vulnerabilities in **PowerShell** / the runtime
- Vulnerabilities in the **PowerShell Gallery** service
- Vulnerabilities in **BurntToast** or other optional dependencies
- Issues in third-party services unless caused by PackageUpdateInfo's implementation
- Social engineering, phishing, or physical attacks

If a report is out of scope but relevant, we may still suggest mitigations or upstream reporting paths.

---

## Project-Specific Security Considerations

PackageUpdateInfo interacts with the PowerShell Gallery to retrieve module metadata and version information. The following are security-sensitive areas:

### PowerShell Gallery API Communication
- The module queries the PowerShell Gallery API for module information over HTTPS.
- Ensure your system has current root certificates and TLS support (TLS 1.2 minimum).
- The module only reads public metadata; no credentials are required for basic queries.
- Report any scenario where the module fails to verify SSL/TLS certificates or makes insecure connections.

### Data Handling and Privacy
- Module metadata retrieved from the PowerShell Gallery is public information.
- Export data (`Export-PackageUpdateInfo`) contains module names and versions from your system.
- When sharing exported data, be aware it may reveal:
  - Which modules you have installed (potentially revealing internal tooling)
  - Module versions you use (may indicate your infrastructure age/patterns)
- Do not share exported module data in untrusted channels or with unauthorized parties.
- Ensure proper file permissions on exported data files to prevent unauthorized access.

### Update Rules and Settings Storage
- `Set-PackageUpdateSetting` and `Add-PackageUpdateRule` store configuration locally.
- These configurations are stored in standard PowerShell data locations:
  - For CurrentUser scope: `$env:APPDATA\`
  - For AllUsers scope: System-protected directories (requires administrative rights)
- Ensure proper file system permissions are maintained on configuration files.
- Report any scenario where configuration data is written to unexpected locations or with improper permissions.

### Optional BurntToast Notifications
- When using the `-ShowToastNotification` parameter with BurntToast, notification content is displayed via Windows notifications.
- Notification content includes module names and update information (public data).
- BurntToast is an optional dependency; the core module functions without it.
- Report any issues where notification functionality exposes sensitive information.

### Credential and Authentication Handling
- PackageUpdateInfo does not store or manage credentials directly.
- If used in an authenticated context (e.g., private PowerShell Feeds), credential handling is delegated to PowerShell's built-in mechanisms.
- Use PowerShell credential providers and secrets management tools (e.g., Windows Credential Manager, Azure Key Vault) for managing sensitive access tokens.
- Report any scenario where the module inadvertently logs or exposes credentials.

### Malformed Module Metadata
- The PowerShell Gallery may contain malformed or unexpected module metadata.
- The module should safely handle:
  - Invalid version strings
  - Unexpected characters in module names or descriptions
  - Missing or null metadata fields
  - Extremely large response payloads
- Report any scenario where malformed metadata causes crashes, data corruption, or unexpected behavior.

### Resource Consumption
- When checking many installed modules, the module makes multiple API calls to the PowerShell Gallery.
- Network connectivity issues, API throttling, or large result sets could affect performance.
- Report any resource exhaustion issues or unexpected network behavior.

### Logging and Diagnostics
- Verbose output should contain only operational details relevant to troubleshooting.
- Output should not include:
  - Sensitive credentials or tokens
  - Internal system information beyond what's necessary for diagnostics
  - Temporary data or intermediate processing details
- Report any scenario where verbose or error output exposes sensitive information.


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
- The module will be published to the PowerShell Gallery as a new release.

---

## Recommendations for Users

- **Keep the module updated**: Install security updates promptly with `Update-Module PackageUpdateInfo`.
- **Verify module integrity**: When installing from the PowerShell Gallery, use `Install-Module` with the `-Force` flag to ensure you get the latest version.
- **Secure your configuration**: If using automation (scheduled tasks, jobs), ensure the execution context has appropriate permissions.
- **Monitor for updates**: Use the module itself to track when updates are available for your other modules.

---

## Acknowledgements

We appreciate responsible disclosure. With your permission, we may acknowledge your contribution in release notes or advisories.

Thank you for helping keep PackageUpdateInfo secure.