---
theme: default
layout: default
---

# What is the PnP PowerShell MCP Server?

A **local stdio MCP server** that lets any MCP client drive PnP PowerShell.
It does **not** authenticate for you — it reuses your `Connect-PnPOnline` session.

## 14 tools, three families

| Family | Tools | What it answers |
|---|---|---|
| **Discover** | `pnp_find_command`, `pnp_get_command_docs`, `pnp_get_best_practices` | "Which cmdlet does this, and how do I call it?" |
| **Execute** | `pnp_run_command`, `pnp_check_environment`, `pnp_session_status` | "Actually do it — and tell me where I'm signed in." |
| **Community** | `pnp_search_script_samples`, `pnp_suggest_script` | "Has someone already solved this?" |

## Two things people miss

- **Sessions persist.** Connect once; every later call reuses the connection.
- **It ships MCP _resources_, not just tools** — `pnp://best-practices`, `pnp://cmdlet/Get-PnPWeb`.

---
layout: section
---
