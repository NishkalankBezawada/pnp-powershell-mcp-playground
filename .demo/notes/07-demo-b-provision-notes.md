# Speaker Notes: Provisioning Customers and Contacts

## The ask

Connect to the demo site, then provision `customers.json` and `contacts.json` in
dependency order.

## First, switching off the admin host

We're still connected to the tenant admin site from the previous demo, and the admin
host can't create lists. The prompt just says "connect to the demo site".

Worth explaining briefly: admin connection for reading the tenant, site connection for
changing a site. PnP keeps those separate deliberately.

The prompt doesn't ask the agent to confirm the URL, so watch for it yourself in the
tool output before the writes start. If it picks the wrong site, the failure is a
permissions error that looks worse than it is.

## The confirmation gate

This is the first write of the talk, so `PNP_MCP_CONFIRM_DESTRUCTIVE=true` will make the
server come back and ask.

Try not to click through it silently. Stop, read the prompt out, and say something like:

> "This is the gate. The model isn't deciding it has permission. It's asking me."

Then approve it. If VS Code offers "always allow", take it, or you'll spend the rest of
the demo clicking.

## While it works

The order is yours to explain. The prompt tells the agent to respect it but doesn't ask
it to justify it, so this one is on you: Customers, then Contacts. `CustomerLookup` on
Contacts resolves its target by list title at the time it's created, so running
Contacts first would fail because there'd be nothing to point at.

If the agent mentions the reasoning unprompted, that's a nice bonus worth pointing out,
but don't wait for it.

The lookup itself is worth a mention. `CustomerLookup` is list scoped rather than site
scoped, which is the one place these definitions deviate from the pattern. A site
scoped lookup binds to one list's GUID in one site, so it can't be reused and it breaks
if the target list is deleted and recreated. List scope keeps the definitions portable.

Taxonomy binds by name. `Country` resolves against the `Countries` term set in the
`PnP Playground` group, which I created beforehand. If it weren't there this field
would fail, and the error would say so fairly clearly.

## Setting up the next part

Once Contacts exists, describe the relationship: one customer, many contacts. Ordinary
one-to-many, nothing surprising yet.

Then set up the next beat:

> "Now let's see what happens when I ask for something SharePoint can't actually do."

## If something goes wrong

Field already exists usually means the reset script wasn't run. Ask the agent to remove
the lists and try again, or run `Reset-Demo.ps1` in a terminal.

Taxonomy resolution failing means the term sets aren't there. `Setup-DemoPrereqs.ps1`
fixes it, but it costs a minute you probably don't have.

If it's just slow, let it run and keep talking about the lookup scoping decision.
There's a comfortable minute of material in why that one column is list scoped.

## Timing

About three minutes. This is the main part of the demo.
