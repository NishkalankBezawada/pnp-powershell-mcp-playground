# Demo Time act — Introduction to PnP PowerShell MCP Server

Copilot, Microsoft 365 & Power Platform community call, 22 October 2026, 7 AM PT.
A recorded demo for the [Demo Time](https://marketplace.visualstudio.com/items?itemName=eliostruyf.vscode-demo-time)
VS Code extension: six plain-English prompts against a real tenant, all read-only. The
video is played from the talk's slides, so this act has no slides of its own.

## What's here

```
pnp-community-call-2026/
├── .demo/
│   ├── demo.json      the six prompts (Demo Time act, version 3)
│   ├── notes/         recording script, one file per prompt
│   ├── commands.md    cheat-sheet: fallback, verify, failures, time budget
│   └── README.md      this file
├── speaker-notes.docx the same recording script as one Word document
├── .vscode/mcp.json   registers the MCP server for VS Code + Copilot
├── environment/       .env (local, gitignored) and .env.example
├── scripts/           DemoConnection.ps1, the manual connection fallback
└── output/            where prompts 3 and 4 write their CSVs (gitignored)
```

## Prerequisites

1. **Demo Time** extension installed in VS Code.
2. **PowerShell 7.4+** with `PnP.PowerShell` installed.
3. **`dnx`** available (the MCP server runs via `dnx PnP.PowerShell.MCPServer@0.1.7-beta`).
4. **`environment/.env`** filled in from `.env.example`: tenant, client ID, admin URL
   and exactly one certificate option.
5. **Graph `Group.Read.All`** (application) on the app registration, for prompt 5's
   group owners.

## Running it

Open `pnp-community-call-2026.code-workspace`, not the repo root. Demo Time only
loads `.demo/` from the root of the open workspace. Then open the Demo Time panel,
start recording, and run the scenes in order, reading from `speaker-notes.docx`.

## The arc

Prove the plumbing (pre-flight), then four governance questions an admin actually
gets asked: who's external, where's the storage, which sites hang on one person, and
where can outsiders get in. Nothing writes to the tenant. Two answers end up as CSVs
on disk.
