# Limits

Outcome: the honest boundary of the tool, in one place — what
Oxidized cannot do, cannot know, and must not be mistaken for —
so nothing in the earlier chapters reads as a promise. Each
limit is marked as the criteria mark them: **lab-proved** where
this guide's lab demonstrated it, **documented** where it comes
from the project's source or docs.

## It reads; it does not manage (lab-proved shape, documented scope)

Oxidized has no concept of pushing a configuration, rolling one
back onto a device, or judging one. There is no "apply" in its
API, no compliance check in its models, no desired state in its
config. It fetched the lab's fake configurations and stored
them; at no point in any transcript does it offer to change one.
Restoring a device from the archive is *your* hands on the
device's own tools, with the archive open beside you. A tool
that promises memory *and* enforcement is a different tool
(chapter 15's managers).

## Coverage is exactly the model list (documented, read in the source)

No model, no fetch, no node — a device family without a file in
`lib/oxidized/model/` cannot be collected at all, and nothing
anywhere reports the absence: the device simply never enters
the story (chapter 8). With just under 200 model files the list
is long, but it is a list, and your inventory is either on it
or it is not. All of this guide's fetches used one model, `ios`.

## The archive is only as true as the last successful fetch (lab-proved)

The defining limit, and chapter 1's rule in its working form.
The lab proved both directions: a changed device produced a new
commit within seconds of a trigger, and a device with wrong
credentials produced *nothing* — no config, no version, only a
status (`no_connection`), an `mtime` of `unknown`, and two log
lines that stop repeating once the retries are exhausted
(transcripts `t06`, `t07`, `t09`). Oxidized does not alarm about
that gap by itself: no hook configured, no noise. Left
unwatched, a fleet's memory can quietly end on the day a
password rotated, while the daemon runs happily for months.
Your monitoring of `mtime` — or a failure hook, chapter 12 — is
not an enhancement; it is the difference between an archive and
a rumour.

## A config backup is not a device backup (documented)

Oxidized stores the **text the device prints when asked for its
configuration** — nothing else. Not the operating-system image,
not licences or certificates held off-config, not learned state
(dynamic neighbours, ARP and MAC tables beyond what a model
asks for), not files on the device's flash. And with
`remove_secret` on (chapter 13), not the secrets either — by
design. A device restored from an Oxidized archive still needs
its image, its licences, and its secrets from elsewhere. Call
the archive what it is — a configuration history — and keep
whatever else your recovery plan needs alongside it.

## The host concentrates risk (documented; settings lab-proved)

The Oxidized host holds read-capable credentials for every
device and the only copy of the archive, and its web extension
has no authentication of its own (chapters 11 and 13). These
are not flaws to be patched by a setting; they are the shape of
the job, to be answered with host hardening, least-privilege
device accounts, loopback binding or a proxy, and backups of
the repository. A smaller, related limit the lab did feel:
`secure: false` host-key checking — often necessary, as in the
lab — removes SSH's proof that the device is the device.

## Smaller print, honestly stated

- **Faithful to the model, not to the device** *(lab-proved)*.
  The stored document is the model's edit of the session:
  commands chosen, output distilled into comments, volatile
  lines dropped, secrets scrubbed. Two models, two truths.
  The running configuration on the device is the original; the
  archive is a very good copy with an editor's hand.
- **Unchanged is silent** *(lab-proved)*. No commit and no log
  line distinguish "fetched, same" from a round that never ran;
  only status timestamps in the API separate them (chapter 6).
- **One output shape per run** *(lab-proved)*. Git history *or*
  latest files *or* an HTTP post — the lab ran two of the three
  outputs in separate passes, not combined; having both a git
  archive and a file tree means two runs or a hook.
- **Versions belong to groups** *(lab-proved)*. The per-group
  repository split (chapter 9) means moving a node between
  groups starts its history again in a new repository.
- **Stats over the API are broken in this version**
  *(lab-proved)*. `/nodes/stats.json` returned object
  description strings, not statistics (chapter 11). Check
  before you build on any single endpoint.
- **Scale is threaded, not infinite** *(documented)*. Fetching
  is parallel up to `threads`, but each job is a live, expect-
  driven terminal session; thousands of nodes mean thousands of
  device conversations per round, bounded by `timelimit` and
  the devices' own patience. The lab's three-node timings say
  nothing about a thousand-node fleet.

Check: name the three limits from this chapter most likely to
bite your network — for most readers they are the silent gap,
the model list, and the concentrated host — and the chapter
that hands you each one's mitigation. If you can, you are
holding the tool at its true size.
