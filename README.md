# Oxidized for Mere Mortals

Ask a network device what its
configuration is and it will tell you —
today's version. It keeps no diary.
When a change breaks something at 2 a.m.,
the question *what changed?* usually has
no answer, because nobody saved
yesterday's. **Oxidized** is the program
that saves it for you: it logs in to
every router and switch on your list,
on a schedule, asks each for its
configuration, and **stores every
version in a git repository**, where
each change is a dated commit you can
read and diff.

One rule governs everything it does, and
this guide states it in chapter 1 and
keeps pointing back to it: **Oxidized
remembers what your devices said their
configuration was — it fetches, it does
not configure — and the history it keeps
is only as true as the last successful
fetch, so a silent collection failure is
a gap in memory, not a confirmation.**
It never pushes a change, never judges a
configuration, and when a device stops
answering it does not invent one: it
marks the node and moves on, and the
hole in the history is yours to notice.

The lab behind this guide ran the real
thing under awkward conditions. The
build machine had no Ruby installed, and
its Docker could not start containers —
the daemon pulled an image, then every
container died on a forbidden namespace
operation. So the lab built **Ruby
3.3.9** from the official source
tarball, installed the real gems —
**Oxidized 0.37.0**, **oxidized-web
0.18.1**, **oxidized-script 0.7.0** —
and ran the daemon against a small
fictional network played by a shell
script behind a lab sshd: two devices
that answer (`branch-router-01`,
`branch-switch-01`, one login each, the
key deciding who answers) and one that
refuses every login
(`depot-gateway-01`). Against them the
lab loaded a three-node list; fetched
and committed both good configurations;
watched the model's comment-making and
the secret-scrubbing in the stored
text; read the history back with git
and with the REST API; changed a
fixture, triggered a refetch, and got a
new commit and a two-line diff in
seconds; ran a one-pass copy and a
plain-file-output copy; and recorded the
failure node's whole biography —
authentication refused, one retry,
`no_connection`, `mtime: "unknown"`.

What the lab could not do, it did not
fake. No real network hardware was
involved — the device is a script, and
the chapters say what a real device
would add (latency, paging, dialects) —
and hooks, the SQL and HTTP sources, the
encrypted output, and writing a new
model are described from the project's
own docs and source and labelled
documented-only. `criteria.md` keeps the
full ledger.

## What this guide covers

- [**What Oxidized is**](what-oxidized-is.md) —
  the missing diary, the git archive, and the one rule
- [**The moving parts**](the-moving-parts.md) —
  source, input, model, output, worker, and the outward face
- [**Installing Oxidized**](installing-oxidized.md) —
  Ruby and the gems, plus the lab's Ruby-from-source detour
- [**The config file**](the-config-file.md) —
  the home folder, the first run that writes a starter config,
  and asking Oxidized its effective settings
- [**Your node list**](your-node-list.md) —
  `router.db`, the maps, groups, and the override ladder
- [**Your first fetch**](your-first-fetch.md) —
  the lab's fake devices, the first round, reading the log
- [**How a fetch works**](how-a-fetch-works.md) —
  the session, the prompt, the commands, the three clocks
- [**Models**](models.md) — one recipe per
  device OS, the `ios` model walked, and the coverage boundary
- [**Storing history in git**](storing-history-in-git.md) —
  commits, unchanged-means-no-commit, the per-group
  repositories, and the file output
- [**Reading the history back**](reading-the-history.md) —
  git by hand, the fetch and version API calls, and the diff
- [**The web pages and REST API**](the-web-and-rest-api.md) —
  the extension the current way, the node list as a status
  board, and one honest quirk
- [**Triggering and scheduling**](triggering-and-scheduling.md) —
  the interval, a single pass, `/node/next`, and reloads
- [**Secrets and safety**](secrets-and-safety.md) —
  scrubbing, the plain-text keyring, and the prized host
- [**Real jobs**](real-jobs.md) — the standing
  archive, the scheduled pass, and fetch-on-change
- [**The neighbours**](the-neighbours.md) —
  RANCID, Unimus, the managers, the hand-rolled script, `oxs`
- [**Limits**](limits.md) — reads only, the
  model list, the silent gap, and config-is-not-device
- [**Troubleshooting**](troubleshooting.md) —
  the *edit* stop, `no_connection`, prompt failures, vanished commits
- [**Glossary**](glossary.md) — the terms,
  collected in one place

## What it doesn't cover

Configuring devices — Oxidized never
does, and chapter 15 points at the tools
that do. Writing a new model in Ruby is
pointed to the project's own guide, not
taught. Device backups beyond the
printed configuration — images, licences,
state — are named as outside the archive
in the limits chapter, because they are.

## How to use this guide

Read chapter 1 for the rule and chapter
2 for the map of parts; chapters 3 to 6
take you from no Ruby to a first
committed configuration. Chapters 7 to 9
explain what you are looking at, 10 to 12
put the history and the triggers in your
hands, and chapter 13 is the one to read
before the archive holds anything real.
The lab lives in `oxidized-lab/`: the
config and node list in `home/`, the fake
device in `fake-device/`, the sshd setup
in `sshd/`, a driver in `run-lab.sh`, and
every claim's evidence in
`oxidized-lab/transcripts/`; its
distilled commands are
`examples/commands.txt` and its notes
`examples/lab-notes.txt`.

---

## Part of the series

This guide is one of the [For Mere Mortals](https://paulsullivan33-dev.github.io/mere-mortals/) guides: plain-language guides to the tools programmers and makers use.

Related guides:

- [Git for Mere Mortals](https://paulsullivan33-dev.github.io/git-for-mere-mortals/)
- [SSH for Mere Mortals](https://paulsullivan33-dev.github.io/ssh-for-mere-mortals/)
- [Ansible for Mere Mortals](https://paulsullivan33-dev.github.io/ansible-for-mere-mortals/)

## License

The writing in this guide is licensed under [CC BY 4.0](https://github.com/paulsullivan33-dev/oxidized-for-mere-mortals/blob/main/LICENSE). Code examples and lab scripts are licensed under the [MIT License](https://github.com/paulsullivan33-dev/oxidized-for-mere-mortals/blob/main/LICENSE-CODE).
