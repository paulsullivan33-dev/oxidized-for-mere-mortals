# The web pages and REST API

Outcome: the oxidized-web extension switched on the current
way, its node list read as a status board, and the handful of
API calls this guide runs — plus one honest quirk.

## Switching it on: extensions, not rest

The web pages and API come from a separate gem,
**oxidized-web** (chapter 3 installed it). In current Oxidized
the config switches it on like this — the lab's exact section:

```yaml
extensions:
  oxidized-web:
    load: true
    listen: 127.0.0.1
    port: 18088
```

`listen` defaults to `127.0.0.1` and `port` to `8888`; the lab
kept the loopback binding and moved the port to its assigned
18088. `url_prefix` and `vhosts` options exist for putting the
service behind a name or a path. Older guides — and older
configs — use a single line, `rest: 127.0.0.1:8888`. It still
works in 0.37.0, but the daemon warns in its source and docs
that `rest` is **deprecated** in favour of the section above,
and that if `rest` is present the extension section is ignored.
This guide teaches the current form; if you inherit the old
line, know that it is living on borrowed time. (If the section
is enabled but the gem is missing, Oxidized refuses to start
and says so — the lab read that error path in the source; it
did not remove the gem to watch it fire.)

Started with the extension, the daemon logs
`Oxidized-web server listening on 127.0.0.1:18088`
(`t06-daemon-log.txt`), and the same process serves both the
fetcher and the web service.

## The node list is the status board

`GET /nodes.json` is the single most useful call. The lab's
response (transcript
`oxidized-lab/transcripts/t07-rest-api.txt`, trimmed here to
its bones) gives, per node: name, full name with group, address,
model — and a `last` block with the last job's start, end,
**status**, and duration, plus the node's stored-config
timestamp (`mtime`). The round of chapter 6 reads:

- `branch-router-01` — `status: success`, 3.36 s, `mtime` set.
- `branch-switch-01` — `status: success`, 3.30 s, `mtime` set.
- `depot-gateway-01` — `status: no_connection`, 0.07 s,
  **`mtime: "unknown"`**.

`mtime: unknown` deserves its fame: it is how the API says
*we have nothing from this device, ever*. Watching these three
fields across a fleet is the cheapest health check Oxidized
offers — a node whose `mtime` stops advancing is a node whose
memory has stopped, whatever its configuration is doing. That
is chapter 1's rule with a field name.

The web pages serve humans the same data: the front page
(`/`) redirects (HTTP 302, measured) to the node list page,
each node has a page (`/node/show/<node>`, an HTML table —
the lab captured its head in `t07`), and versions and diffs
have pages that chapter 10 used. There is **no login and no
access control** in the extension itself: anyone who can reach
the port can read every stored configuration. The project's
`extra/` folder ships proxy configurations (Apache, nginx,
HAProxy) for putting real authentication and TLS in front —
documented-only here, and not optional in spirit: bind to
loopback or put a gatekeeper in front, as chapter 13 insists.

## The rest of the calls the lab ran

- `GET /reload.json` — reloads the node list from the source,
  answering `["reloaded list of nodes"]`; the daemon log shows
  the reload (`t10-api-versions.txt`). (Sending the daemon
  SIGHUP does the same; chapter 12.)
- `GET /node/next/<group>/<node>.json` — moves a node to the
  front of the queue; the lab's change-and-refetch in
  chapter 10 rode on it. A `PUT` to the same URL can carry a
  JSON body naming the commit's author, email, and message —
  read in the source, not run.
- The read-back calls — `/node/fetch`, `/node/version.json` —
  are chapter 10's.

## One honest quirk

`GET /nodes/stats.json` exists, and in 0.18.1 it returns, per
node, a Ruby object description string —
`"#<Oxidized::Node::Stats:0x…>"` — rather than the statistics
themselves (transcript `t07-rest-api.txt`, exactly as served).
The per-node success and failure *counts* those stats objects
hold are visible in the web pages, but this JSON route does not
serialise them usefully. The guide reports it because a reader
scripting against this API will meet it in the first ten
minutes; check *your* version's answer before building on it.

Check: `curl http://127.0.0.1:18088/nodes.json` (your host and
port) and read your fleet as the lab read its three nodes —
who succeeded, who never has, and whose `mtime` has stopped
moving. If you can say those three things, the API is working
and so is your reading of it.
