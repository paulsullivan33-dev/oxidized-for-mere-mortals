# The neighbours

Outcome: where Oxidized sits among the tools that touch the
same problem — its ancestor, its commercial cousins, the
configuration managers it is *not*, and the hand-rolled script
it replaces — characterised, not benchmarked. None of these
were run in this lab; this chapter is the map, drawn from each
project's own description.

## RANCID: the ancestor

**RANCID** ("Really Awesome New Cisco config Differ") did this
job first and for decades: log in, fetch, store in a version
control system (CVS, then Subversion, then git), and mail the
diffs. Oxidized began as its modern replacement and keeps the
shape — even the `router.db` name. RANCID still works and still
has loyal fleets; its device support is deep and battle-worn.
The differences that push people to Oxidized are the ones this
guide demonstrates: a REST API and web pages instead of mailed
diffs and file browsing, parallel fetching, a model file per
OS written in a current language, and active releases.
If you inherit a RANCID install that works, the honest advice
is that it is already keeping the memory; migrate when you need
what it lacks, not for fashion.

## Unimus and the commercial cousins

**Unimus** is the polished commercial neighbour: a commercial
network configuration backup and management system with a
proper database, a modern web interface, config search, and
support you can telephone. Closed-source and licence-fee, in
exchange for which the install is an installer, not a Ruby
toolchain. Vendor and appliance ecosystems offer similar
backup modules inside larger platforms. The choice is the
usual open-source one: Oxidized costs money nothing and
flexibility everything — including the flexibility to be your
own support department, as chapter 3's Ruby quest shows.

## Configuration managers: the other direction

**Ansible**, **Nornir**, and their kin move in the opposite
direction: they *push* desired state to devices. They can, as
a side job, *gather* configurations, and a network already
managed by one often uses its facts and backups. But their
centre of gravity is change, and chapter 1's rule is the
distinction that matters: Oxidized *only* reads. There is a
safety in a witness that cannot act — it can be given
read-only credentials (chapter 13), run unattended for years,
and never be the thing that broke the network at 2 a.m. Many
real networks run both: a manager to change things, Oxidized
to remember what the things said afterwards.

## The hand-rolled script

The smallest neighbour is the one you already have: a cron job
running `ssh device "show running-config" > file`, or an
expect script, or a backup feature in a monitoring system.
It works — until the questions get historical. No versions but
the ones you remembered to keep, no per-device prompt knowledge
past the device you wrote it for, no status board, no diff but
the one you make by hand. Oxidized is what that script becomes
when it grows up: the model files alone — just under 200 device
dialects, already debugged against real hardware — are most of
the value. Migrate when the script's second device family or
first "what did it look like in March?" arrives.

## A note on the companion tool: oxs

Oxidized's own small cousin ships in the `oxidized-script`
gem: **`oxs`**, a command-line tool that uses the same models
and node list to run commands against devices interactively —
`oxs --help` is captured in transcript
`oxidized-lab/transcripts/t13-oxs-and-models.txt`, and
`oxs --list-models` / `--list-nodes` reuse your Oxidized
source. It is the ad-hoc hand to the daemon's scheduled one.
The lab captured its help and no more; its runs are
documented-only here.

Check: name, for your network, which neighbour you would be
replacing, and state the one capability that justifies the
move. If the answer is "none, the script is enough", believe
it — until its March question arrives.
