# Architecture

[Back to docs](README.md) · [Getting started](getting-started.md)

Three scripts, one config file, one fake user CSV. All run locally under PowerShell 7.

```text
macOS / PowerShell 7
      |
      +-- Test-NetworkPath.ps1
      |      +-- DNS resolution
      |      +-- ICMP
      |      +-- TCP connection
      |
      +-- Test-ServiceHealth.ps1
      |      +-- osTicket          (localhost:8080)
      |      +-- LLDAP             (localhost:17170)
      |      +-- Uptime Kuma       (localhost:3001)
      |      +-- Azure Static Web App
      |
      +-- Get-AccountAudit.ps1
             +-- sample-data/users.csv
             +-- disabled-account checks
             +-- access-review checks
```

| Path | Role |
| --- | --- |
| [`scripts/Test-NetworkPath.ps1`](../scripts/Test-NetworkPath.ps1) | Path check: DNS, ping, TCP |
| [`scripts/Test-ServiceHealth.ps1`](../scripts/Test-ServiceHealth.ps1) | HTTP GET against the service list |
| [`scripts/Get-AccountAudit.ps1`](../scripts/Get-AccountAudit.ps1) | CSV identity review |
| [`config/services.example.json`](../config/services.example.json) | Checked-in template |
| `config/services.json` | Local copy (gitignored) |
| [`sample-data/users.csv`](../sample-data/users.csv) | Synthetic accounts |
| [`evidence/`](../evidence/) | Captured runs |
| `reports/` | Timestamped health CSVs (gitignored) |

Walkthroughs: [network path](network-path.md) · [service health](service-health.md) · [account audit](account-audit.md)

## Design choices

**Cross-platform first.** PowerShell 7 on macOS. Windows-only AD cmdlets are out of scope for this version.

**Objects before pretty text.** Each script returns `pscustomobject` rows. `Format-Table` / `Format-List` is a display choice, not the contract. Export and filter work because of that.

**Fake CSV, not production identity.** The audit demonstrates rule logic without employee data. Do not point it at a real export and assume it is an IAM program.

**On-demand HTTP, not monitoring.** `Test-ServiceHealth.ps1` is a diagnostic you run when something is already wrong, or when you want a snapshot. Continuous uptime stays with Uptime Kuma.

**No auto-remediation.** Scripts report. They do not restart containers, flip account flags, or rewrite group membership. That keeps v1 explainable and hard to misuse.

## What this is not

- Remote remediation
- Privileged account changes
- A production monitoring platform
- Windows-only Active Directory automation
- A replacement for Uptime Kuma
