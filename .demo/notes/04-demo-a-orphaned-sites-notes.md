# Speaker Notes: Sites With No Owner

## The ask

Connect to the tenant admin site, then find every site collection that has no owner.

This is a real governance question. Most admins in the room will have been asked it at
some point, and quite a few will have a half finished script for it somewhere.

## The connection

Just one clause in the prompt: "connect to the tenant admin site". No URL and no
credential. Beat 4 already showed this works, so it should be quick.

If it comes up: tenant-wide cmdlets need the admin host, and PnP won't quietly elevate
an ordinary site connection. If the agent picks the wrong one, `Get-PnPTenantSite`
fails with a 403 rather than doing something unexpected.

## Things worth noticing out loud

It searches before it runs. `pnp_find_command` goes first, so the agent is discovering
that `Get-PnPTenantSite` exists and what its parameters are, rather than recalling a
cmdlet name from training data.

Large output gets summarised. A real tenant returns a lot of sites, and the server
hands back a summary plus a cursor instead of dumping everything into the context
window. `pnp_get_more_results` pages through the rest if you need it.

If it feels natural, you might say that you never told it which cmdlet to use, only
what you wanted to know. No need to force the line if the moment doesn't fit.

## This part is read only

Nothing here writes anything, which is why it goes first. It warms up the room and
shows the plumbing works before we touch anything.

## If the tenant has no ownerless sites

That's a fine result. Say the tenant looks tidy and talk about what the agent did
instead: the discovery step and the query it put together. The process is the
interesting part.

## If it's slow

Narrow the question, for example only sites under `/sites/`. Or fall back to
inventorying the demo site.

## Timing

About two minutes, which makes this the longest single block. If you're behind, skip
any follow up question and move to the bridge slide.
