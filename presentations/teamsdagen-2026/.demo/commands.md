# Demo Commands Quick Reference

Cheat-sheet for the PnP PowerShell MCP Server demo. Keep it open on the second screen.

---

## Before you walk on stage

```powershell
pwsh -File ./Create-lists-demo/scripts/Setup-DemoPrereqs.ps1
```

Creates the `PnP Playground` term group and the three term sets the Taxonomy columns
bind to. **Without this, Demo B fails on `Country`, `ProductID` and `ProductName`.**
Idempotent — safe to re-run.

---

## Connect

**The agent does this itself.** The prompts just say "connect to the tenant admin
site" or "connect to the demo site" and let `pnp_check_environment` work out how this
machine authenticates. Nothing hands it a URL or a credential, and it never reads
`.env`.

The deck connects three times:

| Beat | Target | Why |
|---|---|---|
| 4 | admin host, then disconnects | Proves the certificate works, leaves a clean slate |
| 5 | admin host | `Get-PnPTenantSite` needs it; PnP will not silently elevate |
| 8 | the demo site | The admin host cannot create lists |

Certificate auth via `PNP_CERT_THUMBPRINT`, deliberately, so there is no MFA prompt
mid-demo.

**Manual fallback if the agent cannot work out how to connect.** The helper script
reads `.env` and does it directly:

```powershell
pwsh -NoExit -Command ". ./Create-lists-demo/scripts/DemoConnection.ps1; Connect-DemoTenant -Admin"
```

Drop `-Admin` for the demo site. The same helper backs `Setup-DemoPrereqs.ps1` and
`Reset-Demo.ps1`, which is why it stays on disk even though the prompts no longer
mention it.

> **Alternative worth knowing:** the MCP server supports *named sessions*, each with
> its own connection. You could hold an `admin` session and a `site` session at once
> and skip the reconnect. Simpler on stage to just reconnect, but it's a good answer
> if someone asks.

---

## Reset between rehearsals

```powershell
pwsh -File ./Create-lists-demo/scripts/Reset-Demo.ps1
```

Drops Products → Contacts → Customers, then the eight site columns. Prompts for
confirmation; add `-Force` in a tight rehearsal loop. Term sets are kept — add
`-IncludeTermSets` only if you want a truly clean slate.

---

## The prompts (generated from demo.json)

**4. Pre-Flight - Check, Connect, Prove, Disconnect**

```
Using the PnP PowerShell MCP server, run a pre-flight check in three steps. Report back after each step.

STEP 1. Check the environment: is pwsh available, is the PnP.PowerShell module installed and current enough, is this session connected, and if so as which account and URL?

STEP 2. If the session is not connected, prove that it can connect. Connect to the tenant admin site, then run Get-PnPWeb and show me the Url and Title that come back. That is a real round trip to the service rather than a local state check.

STEP 3. Now disconnect again so the next demo starts from a clean slate. Run Disconnect-PnPOnline, then check the session status once more and confirm it reports not connected. Leaving it disconnected is intentional, so do not reconnect.
```

**5. Demo : Get Sites With No Owner**

```
Using the PnP PowerShell MCP server, connect to the tenant admin site, and find every site collection in this tenant that has no owner. Search for the right cmdlet first rather than assuming one. Show me the site URL, the template and the last modified date, and tell me how many there are in total. This step is read-only. Do not change anything.
```

**8. Demo - Provision Customers and Contacts**

```
Using the PnP PowerShell MCP server, connect to the demo site and provision two SharePoint lists from the JSON definitions in Create-lists-demo/listDefinitions: first customers.json, then contacts.json. Create every list, site column, list column and view exactly as the JSON declares. Respect the dependency order. Report what you created.
```

**9. Demo - Products and the Cascading Lookup [DROPPABLE]**

```
Now provision products.json from Create-lists-demo/listDefinitions to the same site. It has two lookups: Customer and Contact. I want the Contact dropdown to only show contacts belonging to the Customer that was picked on that item, so picking a Customer filters the Contact choices. Set that up, and if SharePoint cannot do it at the list level then say so plainly and tell me what my actual options are.
```

---

## Verify the result

```powershell
Get-PnPList | Where-Object { $_.Title -in 'Customers','Contacts','Products' } | Select-Object Title, ItemCount, DefaultViewUrl
```

```powershell
Get-PnPField -List Products | Where-Object { $_.TypeAsString -eq 'Lookup' } | Select-Object InternalName, TypeAsString
```

---

## If something breaks

| Symptom | Cause | Fix |
|---|---|---|
| Taxonomy field fails to resolve | Term sets missing | `Setup-DemoPrereqs.ps1` |
| "Field already exists" | Previous run not cleaned up | `Reset-Demo.ps1 -Force` |
| Lookup target not found | Ran Products or Contacts first | Provision in order: Customers → Contacts → Products |
| 403 on `Get-PnPTenantSite` | Connected to a site, not the admin host | Reconnect to `PNP_ADMIN_SITE_URL` |
| Endless approval prompts | `PNP_MCP_CONFIRM_DESTRUCTIVE=true` | Accept "always allow" on the first one |
| MCP server not listed in Copilot | VS Code hasn't picked up `.vscode/mcp.json` | Reload window, check the MCP output pane |

---

## Time budget

| Beat | Target | Running total |
|---|---|---|
| 1. Title | 0:20 | 0:20 |
| 2. What is it | 1:00 | 1:20 |
| 3. The wiring | 0:30 | 1:50 |
| 4. Pre-flight (check, connect, prove, disconnect) | 0:45 | 2:35 |
| 5. Demo A — no owner | 2:00 | 4:35 |
| 6. Bridge | 0:20 | 4:55 |
| 7. The contract | 0:30 | 5:25 |
| 8. Demo B — provision | 3:00 | 8:25 |
| 9. Products *(droppable)* | 1:30 | 9:55 |
| 10. Recap | 0:40 | 10:35 |

**Past 9:00 when beat 8 finishes? Skip beat 9 and go to the recap.**
