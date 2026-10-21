---
theme: default
layout: default
---

# What is the PnP PowerShell MCP Server?

A local stdio MCP server that lets any MCP client drive PnP PowerShell.

It does **not** authenticate for you. It reuses your `Connect-PnPOnline` session.

| Family | Example tool | What it answers |
|---|---|---|
| **Discover** | `pnp_find_command` | Which cmdlet does this? |
| **Execute** | `pnp_run_command` | Do it, and tell me where I'm signed in |
| **Community** | `pnp_suggest_script` | Has someone already solved this? |

14 tools in total.

---
layout: default
---

# Two things people miss

## Sessions persist

Connect once. Every later call reuses that connection.

## It ships MCP resources, not just tools

`pnp://best-practices` · `pnp://cmdlet/Get-PnPWeb`

So the agent can read the documentation, not only run the command.

---
layout: section
---
