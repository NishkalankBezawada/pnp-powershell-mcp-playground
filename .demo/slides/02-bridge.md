---
theme: default
layout: default
---

# Reading is easy. Writing is where trust matters.

Anyone will let an agent run `Get-PnPTenantSite`.

Letting it **create site columns, lookups and managed metadata fields** on a real
tenant is a different conversation.

## So what has to be true?

- **A contract, not a vibe** — JSON list definitions validated against a schema
- **Dependency order** — Customers → Contacts → Products, or the lookups don't resolve
- **A confirmation gate** — `PNP_MCP_CONFIRM_DESTRUCTIVE=true`
- **An agent that says _no_** — when SharePoint genuinely can't do the thing

---
layout: section
---
