# The config file

Outcome: an Oxidized home folder with a real config file in it
— the one the lab ran — and the ability to ask Oxidized itself
what your effective settings are.

## Where Oxidized lives

Oxidized keeps everything under one folder, its **home**. By
default that is `~/.config/oxidized`; the environment variable
`OXIDIZED_HOME`, or the `--home-dir` switch, moves it. Inside
it live the config file (named simply `config`), the default
node list, the **pid file** (a small file holding the running
daemon's process number), logs, and crash records. This guide's
lab set `OXIDIZED_HOME` to `oxidized-lab/home/` inside the
checkout, so everything the daemon wrote is inspectable in one
place.

## The first run writes you a config

Run `oxidized` with an empty home and it does not start. It
writes a starter config and stops, with a one-line message
(transcript `oxidized-lab/transcripts/t04-first-run-no-config.txt`):

```
$ OXIDIZED_HOME=<empty folder> oxidized   (first ever run)
edit /home/hatch/workspace/.batch-351-363/scratch-oxidized/empty-home/config
```

The starter file names the defaults a new user must replace —
`username: username`, `password: <redacted> model `junos` — and,
further down, the machinery defaults this guide relies on:
`interval: 3600`, `timeout: 20`, `timelimit: 300`,
`retries: 3`, `threads: 30`. The pattern repeats inside the
file: the first run with no git-output section writes that
section's defaults and stops again with the same *edit* message
(the output code does this in `lib/oxidized/output/git.rb`, read
in the lab). Expect two or three such stops while a config
grows; each one is Oxidized writing you the template for the
part you have not configured yet.

## The lab's config, section by section

The file the lab actually ran is kept whole at
`oxidized-lab/home/config`. Its sections, in the order a fetch
meets them:

- **Credentials and the clock.** A global `username` and
  `password` (the fallback for every node), the default `model`,
  and `interval: 3600` — seconds between rounds; a round also
  runs at startup. `timeout: 20` caps one operation's wait,
  `timelimit: 120` caps the whole fetch of one node, and
  `retries: 1` allows one retry after a failure. Chapter 7 reads
  these numbers off the lab's timings.
- **`vars:`** — global variables every model can see. The lab
  sets one: `remove_secret: true`, which tells models to scrub
  secrets from stored configurations. Chapter 13 shows the
  scrubbed lines it produced.
- **`extensions:`** — the web extension switched on, bound to
  `127.0.0.1` port `18088`. Chapter 11.
- **`input:`** — `default: ssh`, and `ssh: secure: false`:
  do not refuse a device whose host key has changed. That is the
  pragmatic setting for devices that get replaced; chapter 13
  weighs it.
- **`output:`** — `default: git`, a committer name and email,
  and the repository path. Chapter 9.
- **`source:`** — `default: csv`, the node-list file, its `:`
  delimiter, and the `map:` / `vars_map:` that say which field
  of each line is which setting. Chapter 5.

The config is **YAML** — indented `key: value` text, where the
indentation is the structure and a stray space is a real error.
One YAML sharp edge is visible in the file: the delimiter is
written `!ruby/regexp /:/`, a Ruby-specific tag that says
"treat this as a regular expression". Asetus, the library
Oxidized uses for this file, reads and writes such tags; a
generic YAML editor may not preserve them. Edit the file by
hand if you like — the lab did — but keep a copy before
experimenting.

## Asking Oxidized what it thinks

Defaults you never wrote still apply, so the file on disk is
not the whole truth. The whole truth is one command away:

```
oxidized --show-exhaustive-config
```

It prints the merged configuration — your file over the
built-in defaults — including settings no chapter has mentioned
(`resolve_dns: true`, the default prompt pattern, the stats
history size). The lab captured its first lines in transcript
`oxidized-lab/transcripts/t13-oxs-and-models.txt`. When a
behaviour surprises you, this output, not the file, is what the
daemon believed.

Check: run `oxidized` once against a fresh `OXIDIZED_HOME` and
see the *edit* message and the starter config it wrote; then
run `oxidized --show-exhaustive-config` against the lab's home
(or yours) and find `interval` and `output` in what it prints.
