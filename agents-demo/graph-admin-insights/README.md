# Graph Admin Insights

A declarative agent for Microsoft 365 Copilot that answers read-only admin questions about your tenant through the **Microsoft MCP Server for Enterprise** (`https://mcp.svc.cloud.microsoft/enterprise`). It was built with Microsoft 365 Agents Toolkit and follows [Set up the Microsoft Graph MCP Server in Agents Toolkit](https://reshmeeauckloo.com/posts/agents-toolkit-mcpserver-graph/) by Reshmee Auckloo, together with Microsoft's [get-started guide](https://learn.microsoft.com/en-us/graph/mcp-server/get-started).

The project is scaffolded and the auth wiring is in place. The parts that need your tenant and an interactive sign-in are steps 1 to 6 below.

| Status | Item |
| --- | --- |
| Done | Declarative agent with an MCP action pointing at the Enterprise MCP endpoint |
| Done | `ai-plugin.json` auth set to `OAuthPluginVault` with `${{OAUTH_REFERENCE_ID}}` |
| Done | Agent name, instructions and conversation starters for admin reporting |
| To do | Tenant: register the MCP server and grant scopes (step 1) |
| To do | Entra ID client app and Teams Developer Portal OAuth client (steps 2 and 3) |
| To do | Fetch the MCP tools into `ai-plugin.json` (step 4) |
| To do | Provision and test in Microsoft 365 Copilot (steps 5 and 6) |

## Prerequisites

- An admin account with the **Application Administrator** or **Cloud Application Administrator** role
- A Microsoft 365 Copilot licence for the test user
- VS Code with the Microsoft 365 Agents Toolkit extension (`teamsdevapp.ms-teams-vscode-extension`)
- Node.js 22 (on this machine: `fnm use 22`)
- PowerShell 7 with `Microsoft.Entra.Beta` 1.0.13 or later
- Access to the [Teams Developer Portal](https://dev.teams.microsoft.com/)

## 1. Register the MCP server in the tenant (once per tenant)

From an elevated PowerShell session:

```powershell
Install-Module Microsoft.Entra.Beta -Force -AllowClobber
Connect-Entra -Scopes 'Application.ReadWrite.All', 'Directory.Read.All', 'DelegatedPermissionGrant.ReadWrite.All'
Get-EntraContext   # confirm the account and tenant
Grant-EntraBetaMCPServerPermission -ApplicationName VisualStudioCode
```

This registers the **Microsoft MCP Server for Enterprise** (appId `e8c77dc2-69b3-43f4-bc51-3213c9d915b4`) and grants its scopes to **Visual Studio Code** (appId `aebc6443-996d-45c2-90f0-388ff96faa56`). VS Code needs those scopes to fetch the tool list in step 4.

To check that it worked:

```powershell
Get-MgServicePrincipal -Property "id,appId,displayName" -Filter "appId in('e8c77dc2-69b3-43f4-bc51-3213c9d915b4','aebc6443-996d-45c2-90f0-388ff96faa56')"
```

## 2. Create the Entra ID client app for Copilot

Copilot calls the MCP server through its own OAuth client:

1. In the [Entra admin center](https://entra.microsoft.com), go to **App registrations**, select **New registration** and choose **Single tenant**.
2. Add the **Web** redirect URI `https://teams.microsoft.com/api/platform/v1.0/oAuthRedirect`.
3. Create a **client secret**. Note the **Application (client) ID**, the **Directory (tenant) ID** and the secret value.
4. Grant the delegated MCP scopes the demo needs, then grant admin consent:

   ```powershell
   Grant-EntraBetaMCPServerPermission -ApplicationId "<client-app-id>" -Scopes `
     "MCP.User.Read.All", "MCP.Group.Read.All", "MCP.GroupMember.Read.All", `
     "MCP.Organization.Read.All", "MCP.LicenseAssignment.Read.All", `
     "MCP.RoleManagement.Read.Directory", "MCP.Policy.Read.All", `
     "MCP.Policy.Read.ConditionalAccess", "MCP.Reports.Read.All", "MCP.AuditLog.Read.All"
   ```

   Every scope is read-only and delegated, so the agent never sees more than the signed-in user can. App-only permissions aren't supported. To list every available scope:

   ```http
   GET https://graph.microsoft.com/v1.0/servicePrincipals(appId='e8c77dc2-69b3-43f4-bc51-3213c9d915b4')/oauth2PermissionScopes
   ```

## 3. Register the OAuth client in the Teams Developer Portal

In [dev.teams.microsoft.com](https://dev.teams.microsoft.com/), go to **Tools** > **OAuth client registration** > **New registration** and fill in:

| Field | Value |
| --- | --- |
| Registration name | `MCPServerGraph` |
| Base URL | `https://mcp.svc.cloud.microsoft` |
| Client ID / Client secret | Values from step 2 |
| Authorization endpoint | `https://login.microsoftonline.com/<tenant-id>/oauth2/v2.0/authorize` |
| Token endpoint | `https://login.microsoftonline.com/<tenant-id>/oauth2/v2.0/token` |
| Refresh endpoint | `https://login.microsoftonline.com/<tenant-id>/oauth2/v2.0/refresh` |
| Scope | `e8c77dc2-69b3-43f4-bc51-3213c9d915b4/.default` |

Save it. Then copy the generated **OAuth client registration ID** into `env/.env.dev.user`, which git ignores; `env/.env.dev.user.example` shows the format:

```
OAUTH_REFERENCE_ID=<registration-id>
```

## 4. Fetch the MCP tools

1. Open this folder in VS Code and open `.vscode/mcp.json`.
2. Select **Start** above the `mcpsvcclou` server and sign in with your admin account.
3. Run **ATK: Fetch action from MCP**. When prompted, choose **OAuth dynamic registration** and select the tools to include.

ATK writes the tool definitions into `functions` in `appPackage/ai-plugin.json`.

> **Check after fetching:** the fetch can rewrite the auth settings. Make sure that:
> - `runtimes[0].auth` in `ai-plugin.json` is still `{"type": "OAuthPluginVault", "reference_id": "${{OAUTH_REFERENCE_ID}}"}`.
> - `m365agents.yml` hasn't gained an `oauth/register` action. If it has, remove it so provisioning doesn't create a second OAuth registration next to `MCPServerGraph`.

## 5. Provision

In the Agents Toolkit sidebar, sign in with your Microsoft 365 account and select **Lifecycle** > **Provision**. You can use the CLI instead:

```powershell
npx -y @microsoft/m365agentstoolkit-cli@latest provision --env dev
```

## 6. Test in Microsoft 365 Copilot

Open [Microsoft 365 Copilot chat](https://m365.cloud.microsoft/chat), select **Graph Admin Insights dev**, sign in when prompted and try a conversation starter, for example "How many users are in my tenant?".

## Known limitations

- The server is **read only**. Creating, updating or deleting anything isn't possible.
- Some read scenarios fail too. The source post gives listing all SharePoint sites as an example.
- To switch the server off for the tenant (it can't be deleted), use `PATCH https://graph.microsoft.com/v1.0/servicePrincipals(appId='e8c77dc2-69b3-43f4-bc51-3213c9d915b4')` with `{"accountEnabled": false}`.

## How this project was created

```powershell
npx -y @microsoft/m365agentstoolkit-cli@1.1.19 new -c declarative-agent --with-plugin yes --api-plugin-type mcp `
  --mcp-server-type remote --mcp-da-server-url "https://mcp.svc.cloud.microsoft/enterprise" --mcp-da-auth-type none `
  -n graph-admin-insights -f ./agents-demo -i false
```

After scaffolding, the `none` auth was replaced with `OAuthPluginVault`, as the post's step 5 describes.

## Project structure

| Path | Purpose |
| --- | --- |
| `.vscode/mcp.json` | MCP server entry used by **ATK: Fetch action from MCP** |
| `appPackage/ai-plugin.json` | MCP runtime, auth and tool (function) definitions |
| `appPackage/declarativeAgent.json` | Agent definition and conversation starters |
| `appPackage/instruction.txt` | Agent instructions |
| `appPackage/manifest.json` | Teams/Microsoft 365 app manifest |
| `env/` | `.env.dev` (committed), `.env.dev.user` (git-ignored, holds `OAUTH_REFERENCE_ID`) |
| `m365agents.yml` | Provision and publish lifecycle |
| `evals/prompts.json` | Starter dataset for `@microsoft/m365-copilot-eval` |

## References

- [Set up the Microsoft Graph MCP Server in Agents Toolkit](https://reshmeeauckloo.com/posts/agents-toolkit-mcpserver-graph/)
- [Get started with the Microsoft MCP Server for Enterprise](https://learn.microsoft.com/en-us/graph/mcp-server/get-started)
- [Microsoft 365 Agents Toolkit overview](https://learn.microsoft.com/en-us/microsoftteams/platform/toolkit/overview)
- [Build declarative agents](https://learn.microsoft.com/microsoft-365-copilot/extensibility/build-declarative-agents)
