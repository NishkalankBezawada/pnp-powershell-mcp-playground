# Speaker Notes: Products, and the Answer I'm Hoping For

> This is the beat to drop if you're running late. If you're past nine minutes, skip to
> the recap. I think it's the most interesting part, so drop it reluctantly, but drop it
> rather than overrun.

## The ask

Two things in one prompt, on purpose:

1. Provision `products.json`.
2. Make the Contact dropdown show only the contacts belonging to the Customer that was
   picked. Can you set that up?

The second half is the reason this beat exists.

## What Products actually contains

On screen at `products.json:49-72` there are two independent lookups sitting next to
each other:

- `CustomerLookup` pointing at `Customers.CustomerName`
- `ContactLookup` pointing at `Contacts.ContactPersonName`

Nothing links them. Nothing stops someone picking Contact A while Customer B is
selected. That isn't a mistake in the definition, it's just how SharePoint works.

## The answer I'm hoping for

Ideally the agent provisions the two lookups and then tells me it can't do the
filtering, because SharePoint has no native cascading lookup. There's no list level
setting, no field property and no CAML that makes one lookup filter another. There
never has been.

If it also offers the real options, so much the better:

| Option | What it involves | Effort |
|---|---|---|
| Power Apps custom form | Set the Contact dropdown's `Items` to `Filter(Contacts, CustomerLookup.Value = CustomerCard.Selected.Value)` | Low |
| SPFx form customiser | Full control of the form and the filtering | High |
| Column formatting or validation | Can flag a mismatch afterwards, but can't filter the picker | Low, and not really a fix |

## What I'd like to say here

> "This is the part I actually care about. It built what SharePoint supports and told me
> the truth about what it doesn't. If it had just said 'done', I'd have shipped a broken
> form and found out from a user."

## If it tries to fake it

This does happen. If it claims it configured cascading behaviour, ask it to show you
the cmdlet that does that. It will usually back down, and honestly the audience tends
to enjoy that more than if it had been right first time. Either outcome works for the
talk.

## Before moving on

Ask it to list the site's lists and columns, or just open the Products list in the
browser. Seeing three real lists with working lookups closes the loop.

## Timing

About 90 seconds.
