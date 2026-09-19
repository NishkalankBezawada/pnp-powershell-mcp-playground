# Speaker Notes: The Wiring

## What's on screen

`.vscode/mcp.json`. That's the whole setup, sixteen lines.

## Walking through it

`"type": "stdio"` means it's a local process rather than a hosted service. Nothing
leaves the machine except what PnP PowerShell itself sends to Microsoft 365.

`"command": "dnx"` runs the NuGet package directly. You can also install it as a global
tool with `dotnet tool install --global PnP.PowerShell.MCPServer --prerelease` and
point at `pnp-powershell-mcp-server` instead. Same server, slightly tidier.

`PNP_MCP_CONFIRM_DESTRUCTIVE=true` is worth pointing at. It means anything that writes,
changes or deletes will come back and ask first. We'll see it happen later.

`PNP_MCP_COMMAND_TIMEOUT_SECONDS=1800` is there because provisioning takes a while and
the default timeout is a bit short for real work.

## The point

There's no connector to install, no gateway, and no service principal for the server
itself. If you already use PnP PowerShell, this is one JSON file away.

## Worth a quick mention

The repo also has a `.mcp.json` at the root, which registers the same server for Claude
Code. One server, different clients. No need to demo it, just say it in passing.

## Timing

About 30 seconds.
