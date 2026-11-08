# Models — one per device OS

Outcome: what a model is, how the `ios` model turns four
commands into the stored document chapter 9 shows, and the hard
boundary a model draws around your whole archive.

## A model is a recipe, written in Ruby

A model is a small Ruby file in `lib/oxidized/model/`, named
for an operating system: `ios.rb`, `iosxr.rb`, `junos.rb`,
`eos.rb`, `routeros.rb`, `fortios.rb`, `panos.rb`… Oxidized
0.37.0 ships **198 files** in that folder including the shared
base code — just under 200 device families (transcript
`oxidized-lab/transcripts/t13-oxs-and-models.txt`; the project
also keeps a `docs/Supported-OS-Types.md` list). A model
declares, in a small domain-specific language:

- the **prompt** to expect;
- **commands** to run, each optionally with a clean-up block;
- **post-login** and **pre-logout** commands;
- per-input settings, like how Telnet's username and password
  prompts look.

Nothing else about Oxidized knows what a `show` command is.
The engine is generic; the model is the knowledge.

## The ios model, walked

The lab ran `ios`, and its stored output (chapter 9) is the
model's work, piece by piece:

- `show version` is not stored raw. Its clean-up block reads
  the output like a form: the image name and version, what it
  was compiled from, the bootstrap version, the chassis type,
  the processor board ID, the memory sizes — and rewrites them
  as a block of **comments** (lines beginning `! `) at the head
  of the stored document. The stored router config opens with
  exactly those lines: `! Image: Software: C2900-UNIVERSALK9-M,
  15.7(3)M3…`, `! Chassis type: CISCO2911/K9`,
  `! Processor ID: FGL0000LAB1` (transcript
  `oxidized-lab/transcripts/t08-git-store.txt`).
- `show vtp status` and `show inventory` are stored *as*
  comments too, prefixed `! VTP:` and plain `!` — supporting
  facts filed above the configuration they describe.
- `show running-config` runs in the model's **post** step, and
  its output *is* the body of the document, after its own
  clean-ups: the first three lines (the device's
  "Building configuration…" preamble) are cut, the ever-changing
  `ntp clock-period` and byte-count lines are dropped so they do
  not manufacture a new version every round, and — because the
  lab set `remove_secret: true` — the model's `:secret` rules
  rewrite password and community lines (chapter 13).
- Every command's output also passes the `:all` rules, which
  for `ios` remove the device's own `% Invalid input` error
  echoes, so a command one hardware variant does not support
  does not scar the document.

That is the pattern in every model: a few commands kept raw,
a few distilled into comments, and a layer of tidying between
the device's chatter and the archive. Two models for similar
systems can still store noticeably different documents —
the archive is faithful to the *model's idea* of the device,
which is a point chapter 16 returns to.

## Choosing, mapping, and writing models

You choose a model per node in `router.db` (chapter 5), with
`model_map` translating friendly names first. Choose by the
operating system the device *reports*, not the badge on the
box: a switch running IOS-XE takes a different model from one
running classic IOS, and a wrong model usually fails at the
prompt or the first command — a loud failure, fortunately.

Writing a new model is a documented craft — the project's
`docs/Creating-Models.md` walks it, and the model unit tests
run models against recorded device output without hardware.
It is **documented-only in this guide**: the lab wrote no model,
it only read `ios.rb` against the output it produced. Adding a
model for an unsupported system is real Ruby programming, but
small: most models are a page of commands and clean-ups.

## The boundary

Chapter 1's rule has a corollary that belongs to this chapter:
**coverage is exactly the model list.** A device whose
operating system has no model cannot be fetched — there is
nothing to tell Oxidized what to type or how to read the
reply. It is not backed up badly; it is invisible, and it will
not appear in `router.db` warnings or the API as anything but
absent. When you inventory a network for Oxidized, the model
list is the checklist: every OS family on your floor needs a
file in that folder, or a plan to write one, before the device
can be remembered at all.

Check: find your devices' OS names in the model folder (or the
project's supported-OS list), and open one model file: name its
prompt, its post-login commands, and the command whose output
becomes the stored body. If you can do that for the models in
your `router.db`, the archive's shape will not surprise you.
