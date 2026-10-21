# Demo Commands Quick Reference

Cheat-sheet for recording the community call demo. The video is played from the
slides on the day. The script to read out is `speaker-notes.docx` (same text as
`.demo/notes/`).

---

## Before you record

1. Open **this folder** in VS Code, not the repo root: double-click
   `pnp-community-call-2026.code-workspace`. Demo Time only finds `.demo/` at the
   workspace root.
2. Check `environment/.env` is filled in (copy `environment/.env.example` if it's missing).
3. Check that the `pnp-powershell` MCP server is listed and running (MCP output pane).
4. Delete last rehearsal's CSVs from `output/` so the new ones are obviously fresh.
5. Close any editor tab that shows `.env`. The call is recorded.

---

## Connect

**The agent does this itself** in prompt 1, from `environment/.env`, with the
certificate thumbprint so there's no MFA prompt. It stays connected for prompts 2–6.

**Manual fallback** if the agent can't connect:

```powershell
pwsh -NoExit -Command ". ./scripts/DemoConnection.ps1; Connect-DemoTenant -Admin"
```

---

## The prompts

The full text is in `.demo/demo.json`. In short:

| # | Prompt | Writes |
|---|---|---|
| 1 | Pre-flight: check, connect to admin, `Get-PnPWeb`, connection status | — |
| 2 | List all external users, with paging, plus a total | — |
| 3 | Export those external users | `output/external-users.csv` |
| 4 | Top ten sites by storage, plus the tenant total | — |
| 5 | Group-connected sites with their group owners, single-owner sites flagged | — |
| 6 | Sites with external sharing enabled, grouped by level | — |

Nothing writes to the tenant.

---

## Verify by hand

Run these in the fallback session if an answer looks wrong:

```powershell
Get-PnPExternalUser -PageSize 50 | Measure-Object
```

```powershell
Get-PnPTenantSite | Sort-Object StorageUsageCurrent -Descending | Select-Object -First 10 Url, StorageUsageCurrent, StorageQuota
```

```powershell
Get-PnPMicrosoft365Group -IncludeOwners | Select-Object DisplayName, SiteUrl, @{ n = 'Owners'; e = { @($_.Owners).Count } } | Sort-Object Owners
```

```powershell
Get-PnPTenantSite | Where-Object SharingCapability -ne 'Disabled' | Group-Object SharingCapability | Select-Object Name, Count
```

---

## If something breaks

| Symptom | Cause | Fix |
|---|---|---|
| Demo Time panel is empty | Repo root opened instead of this folder | Open `pnp-community-call-2026.code-workspace` |
| MCP server not listed in Copilot | VS Code hasn't picked up `.vscode/mcp.json` | Reload window, check the MCP output pane |
| 403 on `Get-PnPTenantSite` | Connected to a site, not the admin host | Reconnect to `PNP_ADMIN_SITE_URL` |
| External user total is exactly 50 | Only the first page was read | "Keep paging until there are no more results" |
| 403 on group owners (prompt 5) | App registration lacks Graph `Group.Read.All` | Grant it before recording |
| Prompt 5 connects to every site | Agent didn't find `-IncludeOwners` | "Use Get-PnPMicrosoft365Group with -IncludeOwners instead" |
| CSV not in `output/` | MCP server's working directory isn't the workspace | Ask it to move the file, or show it where it is |

---

## Time budget

Target length of the finished video, after trimming the waits:

| Prompt | Target | Running total |
|---|---|---|
| 1. Pre-flight | 1:00 | 1:00 |
| 2. External users | 1:30 | 2:30 |
| 3. External users to CSV | 0:45 | 3:15 |
| 4. Top ten sites by storage | 1:15 | 4:30 |
| 5. Owners of group-connected sites | 1:15 | 5:45 |
| 6. External sharing | 1:30 | 7:15 |

The raw recording will be longer while Copilot thinks.
Trim or speed up those waits in the edit.
