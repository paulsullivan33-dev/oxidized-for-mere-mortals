# Triggering and scheduling

Outcome: control over *when* fetches happen — the interval, a
single pass, an immediate fetch of one node, a reloaded list —
each matched to the job it suits.

## The interval, and the round at startup

The default rhythm is `interval: 3600`: every node fetched once
an hour, plus once when the daemon starts. For a small network
that is 24 versions a day of headroom for diffs and a modest
load: the lab's nodes took about 3.3 seconds each, serially
polite at 5 threads. Shorten the interval and you shorten the
longest possible memory gap after a change; lengthen it and
the archive gets coarser. `interval: 0` turns the rounds off
entirely — fetches then happen only when triggered, which suits
networks where changes are announced by other systems.

## One pass and out: run_once

Set `run_once: true` in the config (or leave the daemon out of
it) and Oxidized makes exactly one pass over the list and
exits. The lab ran a copy of its home that way (transcript
`oxidized-lab/transcripts/t11-run-once.txt`): startup lines,
one pass — the switch updated, the gateway failed and was
given up on — and a clean exit code 0 in about ten seconds.
This is the shape for running Oxidized from a scheduler (cron,
a systemd timer) instead of keeping a daemon, and for testing a
config change: one pass, in the foreground, with the log on
your screen. Its weakness is the flip side of the daemon's
strength: between passes nothing is watching, and the web
extension is only up during the pass (the lab's run-once copy
switched it off).

## Fetch this one, now: /node/next

A change you just made should not wait for the interval. The
API call `GET /node/next/<group>/<node>.json` moves a node to
the head of the queue; the worker picks it up as soon as a
thread is free. The lab's measurement is in transcript
`oxidized-lab/transcripts/t09-change-and-refetch.txt`: the call
answered `["ok"]`, the log shows the node added to running jobs
in the same second, and the new commit landed **about five
seconds later**. Two refinements, read in the docs and source
and not re-run: setting `next_adds_job: true` makes the trigger
start a job immediately rather than at the worker's next
convenience, and the `PUT` form of the call lets the triggering
system attach its own author and message to the resulting
commit — "fetched because ticket 1234 changed the firewall" is
a commit message future-you will thank present-you for.

## Reloading the list

Add a device and the daemon must re-read its source:
`GET /reload.json` (chapter 11) or **SIGHUP** to the daemon's
pid both reload it — the lab ran the API form and saw
`Loading nodes / Loaded 3 nodes` appear in the log from the
web server's own thread (`t10-api-versions.txt`, `t06`). Config
file changes are a different matter: most take a restart. The
reload covers the *list*, not the settings.

## Hooks: reacting to events, documented only

**Hooks** are Oxidized's event handlers: on a successful fetch,
on a failure, on a commit. The shipped hooks can run a local
command (`exec`), push the git repository to a remote
(`githubrepo`), post diffs to chat systems (Slack and
Cisco Spark variants), or send notifications (AWS SNS). They
are how a real deployment wires Oxidized into the rest of a
network's life — the syslog message that says "config changed"
arrives, a hook or an API call triggers the fetch, the diff
lands in the team chat. The lab configured **no hooks**; this
section and those names are from the project's `docs/Hooks.md`
and the hook files in `lib/oxidized/hook/`, and are
documented-only. One hook the lab *can* vouch for by omission:
with no failure hook, depot-gateway-01's nightly silence is
only a log line and an API field — which is why chapter 16
lists "alerting is yours to add" among the limits.

Check: set `run_once: true` in a copy of your home and run one
pass; then, against the daemon, edit a fixture (or a real
device's harmless description line), call `/node/next`, and
time the new commit's arrival in the log. Both rhythms should
now be yours to choose between.
