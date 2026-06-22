## Description
<!-- Briefly describe what this PR changes and why -->


## Type of Change

- [ ] New PowerShell function or cmdlet
- [ ] Function or cmdlet update
- [ ] Module packaging or manifest change
- [ ] Test addition or fix
- [ ] Documentation update
- [ ] CI/CD workflow addition or update
- [ ] Bug fix
- [ ] Other (please describe):

## Scope

- [ ] `PackageUpdateInfo/functions/`
- [ ] `PackageUpdateInfo/internal/functions/`
- [ ] `PackageUpdateInfo/internal/scripts/`
- [ ] `PackageUpdateInfo/tests/`
- [ ] `PackageUpdateInfo/PackageUpdateInfo.psd1`
- [ ] `PackageUpdateInfo/PackageUpdateInfo.psm1`
- [ ] `PackageUpdateInfo/changelog.md`
- [ ] `.github/workflows/`
- [ ] `README.md` or other repository documentation

## Verification

- [ ] All functions are in `PackageUpdateInfo/PackageUpdateInfo.psd1`
- [ ] Aliases are kept in sync with `AliasesToExport` when applicable
- [ ] `PackageUpdateInfo/tests/pester.ps1` was run and passed locally
- [ ] No generated or build artifacts were committed

## Notes for Reviewers
<!-- Include any special notes, design decisions, or areas requiring attention -->


## Pre-Merge Checklist

- [ ] Changes are limited to the intended module or documentation area
- [ ] No sensitive information or secrets committed
- [ ] Commit message is clear and descriptive
- [ ] If this PR changes published behaviour, user-facing documentation was updated accordingly
