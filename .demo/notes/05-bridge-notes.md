# Speaker Notes: Reading vs Writing

## The pivot

Everything so far has been read only, and nobody worries much about `Get-`.

It's worth saying the awkward part directly, because the audience is probably already
thinking it: letting an agent create site columns, lookup fields and managed metadata
columns on a production tenant is a different proposition.

## Four things that make it more defensible

A contract rather than a guess. We're not asking the agent to invent a schema. We give
it three JSON files validated against a JSON Schema, so its job is execution rather
than design.

Dependency order. Customers, then Contacts, then Products. Lookups resolve their target
by list title when they're created, so the wrong order fails. The agent has to reason
about this, and we'll see whether it does.

A confirmation gate. `PNP_MCP_CONFIRM_DESTRUCTIVE=true` means every write comes back and
asks first, Any command with `Delete`, `Remove` will not be executable if this is set to `true`.

An agent that can say no. If the next few minutes go the way I hope, the best moment
will be the one where it tells me SharePoint can't do what I asked.

## Timing

About 20 seconds. It's a breath between demos rather than a section of its own.
