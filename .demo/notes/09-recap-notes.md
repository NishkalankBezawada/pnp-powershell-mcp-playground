# Speaker Notes: Recap and Links

## The five points, briefly

One local server, any MCP client. We used VS Code, but the same server is registered
for Claude Code in this repo's `.mcp.json`. Nothing about it is Copilot specific.

It doesn't own your credentials. It reuses the PnP connection you made. No new app
registration for the server, no consent screen, no secrets given to a model.

Discovery before execution. `pnp_find_command` is why it doesn't invent cmdlet names.
It looks them up in the real module metadata.

Destructive work stays gated. You saw the confirmation appear. That's a config flag you
control rather than a promise the model makes.

Sometimes the right answer is that you can't. Cascading lookups are still form layer
work, and it said so.

## If there's twenty seconds spare

The honest limitation is that this is only as good as the contract you give it. A vague
prompt gets you vague infrastructure. The JSON definitions did a lot of work in this
demo, and a person wrote them.

## Suggestions

Try it against a dev tenant rather than production to begin with.

The Script Samples integration is probably the underrated half. It's a good place to
start if you're not sure what to automate yet.

## Questions that tend to come up

Does it work with Copilot Studio or hosted agents? Not currently. It's a local stdio
server, so it needs a client that can start a local process.

What about least privilege? It inherits exactly the permissions of your PnP connection.
A certificate backed app registration scoped to what you need is the sensible approach.

Can it run against two tenants? Yes, using named sessions, each with its own
connection.

Is it GA? It's pre-release at the moment. The repo has the current status.

## Timing

About 40 seconds, then questions.
