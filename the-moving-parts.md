# The moving parts

Outcome: a map of the six parts inside every Oxidized run, so
that when a later chapter names a behaviour — a node loaded, a
login refused, a commit written, a failure retried — you know
which part produced it and which config section steers it.

## The source: where the device list comes from

Oxidized does not discover devices. You list them. The list
comes from a **source**: a file or a database that names each
**node** (Oxidized's word for one device), its **model**, and
optionally its address, its **group**, and per-node settings.
The default source is a plain colon-separated text file,
usually called `router.db`. Chapter 5 builds one; other sources
(SQL, HTTP, a JSON file) are described there and were not run in
this lab.

## The input: how it gets in

An **input** is a way of logging in and typing commands. The
working inputs are SSH, Telnet, FTP, SCP, TFTP, HTTP, and a
local exec — SSH is the one that matters and the only one this
guide runs. Oxidized opens an interactive session, waits for
the device's **prompt**, and types the model's commands one at
a time, reading until the prompt comes back (chapter 7 walks
one session line by line).

## The model: what to ask, and how to tidy the answer

A **model** is a small Ruby file named for a device operating
system — `ios.rb`, `junos.rb`, `routeros.rb`, and just under
200 more in 0.37.0. It lists the commands to run
(`show running-config` and friends), the prompt to expect, and
the clean-ups to apply: stripping pager breaks, and — if you ask
— scrubbing secrets out of the stored text. The lab runs the
`ios` model; chapter 8 reads it closely.

## The output: where versions live

An **output** stores what the model collected. The one this
guide teaches is **git**: every new version becomes a commit,
so history, dates, and differences come from git itself. The
alternative `file` output writes one plain file per device and
keeps no history — chapter 9 runs both and shows where each
puts things. (Two more outputs, an HTTP POST and an encrypted
git variant, are named there and documented-only.)

## The worker: who runs the rounds

The **worker** is the scheduler inside the daemon. It holds the
node list in memory, starts **jobs** — one fetch attempt against
one node — up to a thread limit, spaces the rounds by the
`interval` setting, and **retries** failures a set number of
times before marking the node with its failure status and
moving on. Chapter 7 reads the worker's decisions off the lab's
log: two successes in about four seconds each, one
authentication failure retried once and then given up, in the
log's own words, "retries exhausted, giving up".

## The face: hooks and the web extension

Two parts face outward. **Hooks** react to events — a fetch
succeeded, a fetch failed — by running a command, posting a
diff, or pushing the repository elsewhere; chapter 12 names
them, documented-only in this guide. The **web extension**,
from the separate `oxidized-web` gem, serves the web pages and
the **REST API** (a small set of URLs a program can call) that
chapter 11 exercises: the node list with each node's last
status, each node's stored versions, and the lever that moves a
node to the front of the queue.

Underneath them all sits the config file, chapter 4: one YAML
file that names the source, the input, the output, the
credentials, and the numbers — interval, timeout, threads,
retries — that every part above reads.

Check: name the six parts in the order a configuration meets
them — source, input, model, output, worker, and the outward
face — and say which part owns the retries. If you can, the
rest of the guide has somewhere to hang.
