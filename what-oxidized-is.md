# What Oxidized is

By the end of this chapter you can say, in one sentence, what
Oxidized remembers for you — and state the one rule that decides
whether its history is evidence or just a comforting story.

## The memory you do not have

Every router and switch on a network holds a **running
configuration**: the text that tells it its addresses, its
routes, its access lists, its passwords' hashes. Ask the device
and it will print that text. Ask it next month and it prints
whatever is true *then*. Between the two askings, the device
keeps no diary. When something breaks at 2 a.m., the first
question — *what changed?* — is usually unanswerable, because
nobody saved yesterday's answer.

People improvise: a config pasted into a ticket, a file called
`router-final-v2.txt` on somebody's laptop, a backup taken the
day the device was installed and never again. **Oxidized** is
the program that replaces the improvisation. It logs in to
every device on its list, on a schedule, asks each one for its
configuration, and stores the answer in a **git repository** —
the same version-control system programmers use for code, where
every stored version is kept, dated, and comparable with every
other. Change a line on Tuesday, and on Wednesday you can read
the exact difference between Monday's configuration and
Tuesday's.

Its own one-line description, from the gem's summary, is
"software to fetch configuration from network devices and store
them" (transcript `oxidized-lab/transcripts/t03-gem-oxidized.txt`).
This guide's lab ran **Oxidized 0.37.0** against two fictional
devices and watched it do exactly that: fetch, store in git,
and — when the fixture's configuration changed — commit the
difference as a second version (transcripts
`oxidized-lab/transcripts/t06-daemon-log.txt` and
`oxidized-lab/transcripts/t09-change-and-refetch.txt`).

## The rule: it fetches, it does not configure — and absence is not proof

Two halves, one rule:

> **Oxidized remembers what your devices said their
> configuration was. It fetches; it does not configure. And the
> history it keeps in git is only as true as the last successful
> fetch — a silent collection failure is a gap in memory, not a
> confirmation that nothing changed.**

The first half is the scope. Oxidized never pushes a change,
never fixes a line, never judges a configuration good or bad.
It is a read-only witness. The second half is the warning label
that witness needs. If a device stops answering — a changed
password, a dead management address — Oxidized does not invent
a configuration for it, but it also does not stop the world.
It logs the failure, marks the node, and moves on. The git
history simply has a hole where those days should be. Read an
Oxidized archive the way you would read any witness statement:
trustworthy about what it saw, silent about what it missed.
Chapter 6's lab makes the failure concrete on purpose: of the
lab's three fictional devices, one refuses every login, and its
entry in the API reads `"status": "no_connection"` with
`"mtime": "unknown"` — no configuration, no version, no
pretence (transcript
`oxidized-lab/transcripts/t07-rest-api.txt`).

## Where it comes from

Oxidized is a free, open-source program written in **Ruby** and
distributed as a Ruby **gem** — a packaged library and program
that Ruby's own tooling installs. It began as a modern
replacement for RANCID, the long-serving tool of the same job
(chapter 15), and it shows: the shape — a device list, a login,
a fetch, a versioned store — is RANCID's shape, rebuilt with
more device types, a web interface, and a REST API. It speaks
to each kind of device through a **model**: a small file that
knows what commands that device's operating system answers and
how to tidy the output. Version 0.37.0 ships just under 200
model files (transcript
`oxidized-lab/transcripts/t13-oxs-and-models.txt`).

One honest note about this guide's lab, stated here because
everything else depends on it: the build machine had **no Ruby
installed** (one off-PATH leftover from an older task aside —
chapter 3 tells it straight), and its Docker could not start
containers. The lab
built Ruby 3.3.9 from the official source tarball and installed
the real gems onto it, then ran the real daemon against a fake
device the lab built from an sshd and a shell script. Chapter 3
tells that story in full, and `criteria.md` keeps the ledger.
Nothing in these chapters is a recollection of how Oxidized is
supposed to behave; where a behaviour is described, a transcript
in `oxidized-lab/transcripts/` shows it happening, or the text
says *documented-only*.

Check: say what Oxidized stores, where it stores it, and the
two halves of the rule — it fetches and does not configure, and
a failed fetch is a gap, not a confirmation. If you can say all
three, you have this chapter.
