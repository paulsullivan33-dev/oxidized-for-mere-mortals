# Your node list

Outcome: a `router.db` that names your devices the way Oxidized
needs — name, model, address, group, and the per-node settings
that do not belong in the global config.

## The CSV source

The default **source** is a text file of colon-separated lines:
the old RANCID name for it, `router.db`, survives. The config
file's `source:` section says where the file is and, through
two maps, what each field means (chapter 4). The lab's file is
kept at `oxidized-lab/home/router.db`; stripped of its comments
it is three lines:

```
branch-router-01:ios:127.0.0.1:branch:19088:/…/runtime/id_router
branch-switch-01:ios:127.0.0.1:branch:19088:/…/runtime/id_switch
depot-gateway-01:ios:127.0.0.1:depot:19088
```

Read through the maps in the lab's config, the fields are:

| Position | Map entry | Meaning |
|---|---|---|
| 0 | `name` | the node's name — its identity everywhere |
| 1 | `model` | which model file to use (`ios` here) |
| 2 | `ip` | the address to connect to, so DNS is not involved |
| 3 | `group` | a label that sorts storage and credentials |
| 4 | `ssh_port` (a *var*) | the SSH port, here the lab's 19088 |
| 5 | `ssh_keys` (a *var*) | the private key file to log in with |

Two kinds of field appear. **Map** fields are the node's own
properties. **Vars_map** fields become node **vars** — the same
variable pool the config's global, group, and model sections
feed, with the node's own value winning. Anything a model or an
input understands as a var can ride in this way: `ssh_port` and
`ssh_keys` here; an `enable` password or a different username on
another network. Fields a line leaves off are simply unset for
that node — the third line has no key field, on purpose, and
chapter 6 shows what that costs it.

## Names, models, and maps between them

The `name` need not be a DNS name: with an `ip` field present
and `resolve_dns` left at its default, Oxidized connects to the
address and keeps the name as the label. Without an `ip` field,
the name is resolved. The `model` field passes through the
config's **model_map** first, which translates the names people
actually write — `cisco` becomes `ios`, `juniper` becomes
`junos` — and can translate by pattern as well. Chapter 8 is
about what a model name commits you to.

## Groups and the order of overrides

A **group** is a folder-shaped label. It decides which
repository or folder a stored configuration lands in
(chapter 9), and it is a level in the credential ladder. When
the same setting is defined in several places, the lab's source
code documentation gives the order, from weakest to strongest:

1. global config,
2. model-specific config,
3. group-specific config,
4. model-specific config *within* the group,
5. the node's own line in `router.db`.

So a fleet-wide password lives at level 1, a branch office's
different password at level 3, and one awkward device's at
level 5 — each set once, in one place. The lab only needed
levels 1 and 5 (a global fallback password, per-node keys),
which is the common small-network shape.

## The other sources, documented only

The lab ran only the CSV source. The same node list can come
from a **SQL** database, from an **HTTP** endpoint that returns
it, or from a **JSON file** — the source plugins exist in
`lib/oxidized/source/` and are described in the project's
`docs/Sources.md`. They change where the list lives, not what a
line must contain. A growing network usually graduates to SQL
or an inventory system it already trusts; the rule of
chapter 1 applies to all of them: the list is the memory's
table of contents, and a device missing from the list is a
device Oxidized has never heard of.

Check: write a two-line `router.db` for two fictional devices
with different groups, point a config at it, and start Oxidized
(chapter 6). The first log lines should say `Loaded 2 nodes` —
or, in the lab's fuller file, `Loaded 3 nodes` (transcript
`oxidized-lab/transcripts/t06-daemon-log.txt`).
