# PowerShell IT Support Toolkit

On-demand diagnostics for the checks support engineers already repeat: DNS, ICMP, TCP, HTTP, and obvious account-access mistakes.

The toolkit is PowerShell 7 on macOS. It reports state. It does not remediate, talk to Active Directory, or replace [Uptime Kuma](docs/architecture.md#what-this-is-not). Checks target existing local services (osTicket, LLDAP, Uptime Kuma) plus a public Azure Static Web App — not a new infrastructure stack.

Scripts emit PowerShell objects so results can be formatted, filtered, or exported. Identity data is synthetic. `config/services.json` stays local and gitignored.

## Documentation

| Page | What it covers |
| --- | --- |
| [Getting started](docs/getting-started.md) | PowerShell 7, config copy, smoke test |
| [Architecture](docs/architecture.md) | Layout, constraints, and trade-offs |
| [Test-NetworkPath](docs/network-path.md) | DNS, ICMP, and TCP reachability |
| [Test-ServiceHealth](docs/service-health.md) | HTTP checks, outage, recovery |
| [Get-AccountAudit](docs/account-audit.md) | Disabled accounts and access-review findings |

Evidence screenshots live in [`evidence/`](evidence/).
