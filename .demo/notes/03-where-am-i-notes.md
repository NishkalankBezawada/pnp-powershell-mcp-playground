# Speaker Notes: Pre-Flight

## Why this beat is here

Partly it's a real check. If the tenant, the certificate or the network has a problem,
this is the cheapest place to find out, and there's still time to recover.

It also happens to show three tools and a real sign-in in about forty-five seconds,
which is a reasonable way to start.

## Step 1: the environment check

Expect something like:

```
pwsh            : Available, 7.6.6
PnP.PowerShell  : Installed, 3.1.0
Session         : Not connected
Account         : None
```

"Not connected" is the expected answer, so there's no need to apologise for it. It's
worth explaining why:

> "It says I'm not signed in, and that's true. This server has no credentials of its
> own. It reuses a connection I make, which is the whole security model really."

One small detail you might point out: it says the module is installed but doesn't claim
to know whether it's the latest version. That distinction is a good sign.

## Step 2: showing that it can connect

The prompt only says "connect to the tenant admin site". No URL, no client id, no
thumbprint.

The server's environment check reports which app registration, persisted login or
certificate the machine can actually authenticate with, and gives the connect command
with the values it can work out. So the agent doesn't need to be told, and it never
reads the `.env` file.

If it works, that's worth a sentence:

> "I didn't give it a URL or a credential. It worked out how this machine signs in."

Two details, if there's time. `Get-PnPWeb` is a real call to the service, whereas
`Get-PnPConnection` would only report local state and might still look fine with a
broken certificate. And it needs the admin host specifically, because PnP won't
silently elevate an ordinary site connection.

## Step 3: putting it back

`Disconnect-PnPOnline`, then check the session status again and confirm it's not
connected.

This isn't just tidiness. Without it, beat 5 would inherit a connection nobody saw you
make, and the connect step there would be invisible.

## If step 2 fails

Not ideal, but better here than halfway through provisioning. Common causes:

- The thumbprint in `.env` doesn't match anything in the certificate store. Check with
  `Get-ChildItem Cert:\CurrentUser\My | Select-Object Thumbprint, Subject`.
- The app registration is missing a permission, or admin consent was never granted.
- The agent couldn't work out how to connect at all. Either tell it the admin URL
  directly, or fall back to a terminal:
  `pwsh -NoExit -Command ". ./Create-lists-demo/scripts/DemoConnection.ps1; Connect-DemoTenant -Admin"`

Whatever goes wrong, the error usually names the cause, which is worth pointing out.

## Timing

About 45 seconds. If all three steps look fine, move on.
