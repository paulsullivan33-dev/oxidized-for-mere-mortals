# Real jobs

Outcome: three complete working setups assembled from the
earlier chapters — the nightly archive, the scheduled pass, and
the fetch-on-change — each exactly as the lab ran it, with the
one part the lab did not wire named plainly.

## Job 1: the standing archive (the daemon)

The job Oxidized exists for: a daemon on a small host, an
hourly round, a git archive, secrets scrubbed, a status board
you can glance at. It is the lab's main run, unchanged:

- `OXIDIZED_HOME` pointing at one folder (chapter 4);
- the config in `oxidized-lab/home/config` — CSV source,
  SSH input, git output, `interval: 3600`, `retries: 1`,
  `remove_secret: true`, web extension on loopback port 18088;
- `router.db` listing every device with its model, group, and
  per-node key (chapter 5).

Measured behaviour to plan around, from the lab's transcripts:
first round inside **eleven seconds** of startup for three
nodes; about **3.3 seconds per successful fetch** against a
local device (yours will be slower — real devices, real
networks); one commit per *changed* device per round; failures
retried, marked, and left visible in `/nodes.json` as
`no_connection` with `mtime: "unknown"` or a stale `mtime`.
Run it under your service manager so it survives reboots — the
project ships unit files in `extra/`; the lab, a sandbox, ran
the daemon in the foreground and stopped it by hand, which is
the only part of this job the lab did not exercise.

## Job 2: the scheduled pass (no daemon)

For a network you visit rather than live in: `run_once: true`,
fired by cron or a systemd timer, web extension off. The lab's
pass (transcript `oxidized-lab/transcripts/t11-run-once.txt`)
took about ten seconds for three nodes and exited 0. You lose
the standing status board and the trigger API; you gain a tool
that is only ever running when you can see it in the process
list. The same pass doubles as a **config test**: after editing
`config` or `router.db`, one foreground pass shows you the
loaded count, the successes, and the failures before the daemon
ever sees the change.

## Job 3: fetch on change

A device changes; something that knows — a syslog watcher, a
change ticket closing, an engineer at a keyboard — calls
`GET /node/next/<group>/<node>.json`; the new version is
committed seconds later, while the change is still warm and its
author still remembers it. The lab ran the trigger by hand
after editing its fixture (transcript
`oxidized-lab/transcripts/t09-change-and-refetch.txt`):
answer `["ok"]`, job added in the same second, commit
**about five seconds** later, and a two-line git diff that is
the change's permanent record. Wiring a syslog daemon to make
that call automatically is the classic deployment and is
**documented-only** here — the endpoint, its timing, and its
effect are verified; the syslog plumbing is ordinary and
belongs to your syslog tool's own guide. The `PUT` form,
attaching the ticket's author and message to the commit
(chapter 12), is the version worth growing into.

Across all three jobs, the operator's weekly five minutes are
the same: open `/nodes.json`, look for a node whose `mtime` has
stopped, and go and learn why. That habit — not the daemon —
is what turns an archive into a memory.

Check: assemble Job 1 for two devices of your own (or the lab's
two), let it run one round past the first, and confirm the
repository gained commits only for devices whose configuration
actually changed. Then run Job 2's pass against the same home
copy and watch it exit cleanly.
