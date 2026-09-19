# Speaker Notes: The Input Contract

## What's on screen

The fields block from `customers.json`. Three columns: a Text column, a Taxonomy
column, and a multi-line Note column.

## A few quick points

There's a `$schema` at the top. These files validate against
`sharepoint-list.schema.json`, with `additionalProperties: false` throughout, so a typo
gets caught before anything touches the tenant. The agent is reading a contract rather
than free text.

The columns are site scoped with fixed `id` GUIDs. That gives them stable identity, so
it's the same column reused across sites and across re-runs rather than a new GUID each
time.

Country is a Taxonomy column, and it binds to a term set by name. The term store has to
have that term set already. That's a genuine real-world dependency, and I created it
beforehand. Worth admitting rather than glossing over.

## Why this matters

The agent isn't designing the data model. I designed the data model. The agent is
turning a declarative contract into forty or so PnP PowerShell calls in the right
order.

That's a more honest description of the value, and it's also an easier thing to take to
a governance board than "the AI designs your information architecture".

## Timing

About 30 seconds.
