# Speaker Notes: What is the PnP PowerShell MCP Server?

## The part that matters most

It does not authenticate for you. For an admin audience this is usually the most
reassuring thing you can say, so it's worth saying early and clearly.

The server shells out to the PnP.PowerShell module already installed on your machine
and reuses the connection you made with `Connect-PnPOnline`. There's no new app
registration, no extra consent, and no credentials handed to a model.

## The three families, briefly

**Discover.** `pnp_find_command` answers "which cmdlet does this?". It searches names,
verbs, nouns, parameters and examples. This is the reason it doesn't invent cmdlet
names: it looks them up rather than recalling them.

**Execute.** `pnp_run_command` does the real work. It can chain several cmdlets in one
call, and large result sets come back summarised with a cursor you can page through.

**Community.** It indexes the PnP Script Samples library, so you can search hundreds of
scripts the community has already written.

## Two things that are easy to miss

Sessions persist. You connect once and later calls reuse that connection. You can also
run two named sessions against two tenants at the same time, though we won't today.

It also ships MCP resources, not just tools: `pnp://best-practices` and
`pnp://cmdlet/{name}`. Most MCP servers only offer tools, so this is a nice extra. It
means the agent can read the documentation as well as run the command.

## If someone asks how this differs from just using Copilot

Copilot can write PnP PowerShell. It can't run it, look at the output, and decide what
to do next. That loop is the difference.

## Timing

About a minute. This is the only concept slide, so try not to linger.
