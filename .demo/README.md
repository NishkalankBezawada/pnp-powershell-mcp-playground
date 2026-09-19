# Demo Time deck — PnP PowerShell MCP Server

A 10–12 minute live demo built for the [Demo Time](https://marketplace.visualstudio.com/items?itemName=eliostruyf.vscode-demo-time)
VS Code extension. Natural language in, PnP PowerShell out, against a real tenant.

## What's here

```
.demo/
├── demo.json      the 10 beats, wired as Demo Time steps
├── slides/        4 slides — title, concept, bridge, recap
├── notes/         speaker notes, one per beat
├── assets/        speaker photo, logos
├── commands.md    stage cheat-sheet: prompts, recovery, time budget
└── README.md      this file
```

Supporting pieces outside `.demo/`:

| Path | Why |
|---|---|
| `.vscode/mcp.json` | Registers the MCP server for VS Code + Copilot |
| `.mcp.json` | The same server for Claude Code — mentioned, not demoed |
| `Create-lists-demo/scripts/Setup-DemoPrereqs.ps1` | Creates the term sets the Taxonomy columns need |
| `Create-lists-demo/scripts/Reset-Demo.ps1` | Puts the site back so you can rehearse again |
| `Create-lists-demo/scripts/DemoConnection.ps1` | Shared `.env` + certificate connection helper |

## Prerequisites

1. **Demo Time** extension installed in VS Code.
2. **PowerShell 7.4+** with `PnP.PowerShell` installed.
3. **`dnx`** available (the MCP server runs via `dnx PnP.PowerShell.MCPServer@0.1.6-beta`),
   or install the global tool and change the command in `.vscode/mcp.json`:
   ```bash
   dotnet tool install --global PnP.PowerShell.MCPServer --prerelease
   ```
4. **`Create-lists-demo/environment/.env`** filled in — tenant, client ID, site URLs,
   and exactly one certificate option.
5. **Term sets created** — run `Setup-DemoPrereqs.ps1`. This one is easy to forget and
   it is the most likely cause of a failed demo.

## Running it

Open the repo in VS Code, open the Demo Time panel, and walk the beats in order.
Beat 9 is marked `[DROPPABLE]` — skip it if you are past nine minutes.

The last entry, `RESET`, is not part of the talk. It runs `Reset-Demo.ps1` in a
terminal so you can go again.

## The arc

Read-only first (prove the plumbing, warm the room), then writes (where the
interesting objections live), then the moment the agent says *no* — SharePoint has no
native cascading lookup, and a good agent tells you that instead of pretending.

That last beat is the argument of the whole talk, which is why it is also the one you
drop last.
