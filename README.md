# pnp-powershell-mcp-playground

Live demos of the [PnP PowerShell MCP Server](https://github.com/pnp/pnp-powershell-mcp-server),
one folder per talk. Each one is a self-contained VS Code workspace for the
[Demo Time](https://marketplace.visualstudio.com/items?itemName=eliostruyf.vscode-demo-time) extension.

| Talk | Date | Folder |
|---|---|---|
| Copilot, Microsoft 365 & Power Platform community call | 22 Oct 2026 | [presentations/pnp-community-call-2026](presentations/pnp-community-call-2026) |
| Teamsdagen 2026 | Sep 2026 | [presentations/teamsdagen-2026](presentations/teamsdagen-2026) |
| CollabDays Bletchley Park 2026 | Sep 2026 | [presentations/collabdays-bletchley-park-2026](presentations/collabdays-bletchley-park-2026) |

## Running a talk

Open the talk's `.code-workspace` file, not this repo root. Demo Time has no setting
for the demo folder. It only loads `.demo/` from the root of the open workspace, and
Copilot reads `.vscode/mcp.json` from the same place.

Each talk has its own `.env.example`. Copy it to `.env` next to it and fill it in.
`.env` files are gitignored.
