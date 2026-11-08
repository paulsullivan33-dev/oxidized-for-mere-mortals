# Your first fetch

Outcome: a running daemon, a first round of fetches, and the
ability to read its log well enough to say which nodes
succeeded, which failed, and why — using the lab's first round,
in which both outcomes happened inside eleven seconds.

## The lab's devices, honestly described

The lab has no real routers. It has one **sshd** — the standard
OpenSSH server, on `127.0.0.1` port **19088** — configured to
run a shell script, `oxidized-lab/fake-device/fake-ios.sh`, as
every login's forced command. The script plays a small
IOS-like device: it prints a prompt, answers `show version`,
`show vtp status`, `show inventory` and `show running-config`
from canned text, and says goodbye on `exit`. Which device
answers depends on which SSH key you log in with: the lab sshd
exposes the authentication information, the script reads the
key from it, and a two-line map file turns keys into hostnames.
`branch-router-01` and `branch-switch-01` are that one script
wearing two keys. The third node, `depot-gateway-01`, has no
key in `router.db`; it falls back to the global password, and
the lab sshd refuses password logins entirely — so its failure
is as real as the others' success. Chapter 5's file built all
three on purpose: the success path, and the failure path, are
both part of a first fetch. A transcript of the fake device
answering a human first is
`oxidized-lab/transcripts/t05-fake-device-by-hand.txt`.

## Starting the daemon

```
export OXIDIZED_HOME=~/oxidized-lab-home   # the lab: oxidized-lab/home
oxidized
```

Run in the foreground, Oxidized logs to the terminal. (It can
daemonize with `--daemonize`, and service files for systemd and
friends ship in the project's `extra/` folder; the lab ran it
in the foreground under `nohup` so the log was a file.) The
lab's startup, from transcript
`oxidized-lab/transcripts/t06-daemon-log.txt`:

```
… I […] Oxidized::CLI -- Oxidized starting, running as pid 207889
… I […] Oxidized::Nodes -- Loading nodes
… I […] Oxidized::Nodes -- Loaded 3 nodes
… I […] Oxidized::API::Web -- Oxidized-web server listening on 127.0.0.1:18088
… I […] Oxidized::Worker -- Configuration updated for branch/branch-router-01
… I […] Oxidized::Worker -- Configuration updated for branch/branch-switch-01
… W […] Oxidized::Node -- 127.0.0.1 raised Net::SSH::AuthenticationFailed with msg "Authentication failed for user root@127.0.0.1"
… W […] Oxidized::Worker -- depot/depot-gateway-01 status no_connection, retry attempt 1
… W […] Oxidized::Node -- 127.0.0.1 raised Net::SSH::AuthenticationFailed …
… W […] Oxidized::Worker -- depot/depot-gateway-01 status no_connection, retries exhausted, giving up
```

Read it as a story. The daemon starts and writes its pid
(`207889`, also in the home folder's `pid` file). The node list
loads — 3 nodes, matching chapter 5's file. The web extension
binds its port. Then the first round runs *immediately*, not
after the first interval: the router's configuration is fetched
and stored about four seconds in, the switch's four seconds
later, and the gateway fails its login, is retried once — the
lab's `retries: 1` — and is given up on, with the worker naming
the status it settled into: `no_connection`, the status for "we
could not even get in". Each node's own timestamps are in the
API chapter (chapter 11): the successes took 3.36 and 3.30
seconds end to end, the failure 0.07 — authentication refused
is fast.

## What "updated" means, and what silence means

`Configuration updated` is the worker reporting that the output
stored a **new version**: a first fetch, or a fetch whose text
differed from the stored one. A fetch that finds the text
unchanged stores nothing and — at the default log level — says
nothing. Chapter 12's run-once transcript shows the shape: only
the switch, whose fixture had changed since its last fetch,
logs a line. Silence after a round is therefore two different
things wearing the same clothes: *fetched, unchanged*, or
*never fetched at all* — and only the per-node status
(chapter 11) tells them apart. That is chapter 1's rule again,
in work clothes.

To stop the daemon, send it SIGTERM (or Ctrl-C in its
terminal): `kill $(cat ~/.config/oxidized/pid)`. The lab
stopped its daemon and its lab sshd the same way when the
experiments were done, and both ports closed.

Check: start your daemon against a node list with at least one
reachable device. Within a few seconds the log should show
`Loaded N nodes`, then `Configuration updated` for the
reachable one — and for any node whose credentials are wrong,
an honest failure with a status, retried and given up on, just
like the gateway above.
