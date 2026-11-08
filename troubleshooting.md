# Troubleshooting

Outcome: the failures every Oxidized user meets, each with the
check that names it. Every entry here happened in this guide's
lab or follows directly from a log line it produced.

## "It just says *edit …/config* and stops"

That is not a crash; it is the first-run behaviour (chapter 4).
Oxidized wrote a starter config — or a starter section for the
part you have not configured yet, output and source sections
included — and stopped so you would fill it in. Edit the file
it names and run again. Expect it two or three times while a
fresh home grows.

## "Loaded 0 nodes" — or the wrong count

The source is not saying what you think it is. Check, in order:
the config's `source: csv: file:` path is the file you edited;
the `map:` positions match your line format (a missing `ip`
field shifts nothing, but a *reordered* line shifts everything);
comment lines begin with `#`. `oxidized --show-exhaustive-config`
shows the merged source settings the daemon actually used.
Then use `/reload.json` or SIGHUP after fixing the file —
restarting works too, but the reload proves the daemon saw it
(chapter 12; the lab's reload is in `t10-api-versions.txt`).

## A node sits at `no_connection`

The job never got in. The daemon log carries the underlying
error; the lab's gateway shows the commonest (transcript
`t06-daemon-log.txt`):

```
… raised Net::SSH::AuthenticationFailed with msg "Authentication failed for user root@127.0.0.1"
… status no_connection, retry attempt 1
… status no_connection, retries exhausted, giving up
```

Work it from the device outward: can you log in *by hand* from
the Oxidized host with the same key or password (the lab
verified its fake device by hand first, transcript `t05`)? Is
the port right — a node missing its `ssh_port` var is knocking
on port 22? Is the username the one the *node* resolves to
(group and node settings override the global, chapter 5)?
Authentication refused by an sshd that allows only keys is
exactly the lab's case: the node had no `ssh_keys`, fell back
to a password the server does not accept. Fix the credential
the node actually uses, not the global one it may be ignoring.

## A node fails later — prompt and timeout failures

Got in, then died: the signature of a **prompt** mismatch or a
**model** mismatch. The device must print something the model's
prompt pattern matches, after login and after every command.
Wrong model for the OS is the usual cause (chapter 8: choose by
the OS the device reports). A device that pages its output will
stall a model without the right post-login (`terminal length 0`
and family) — the wait ends at `timeout` for one operation or
`timelimit` for the job, and the status says which. Raise
`timelimit` for genuinely slow devices; do not raise it to
hide a prompt problem.

## "It fetches, but nothing is ever committed"

Three suspects. The configuration did not actually change —
models drop volatile lines (byte counts, clock lines) precisely
so identical rounds make no commit, and unchanged rounds are
silent at the default log level (chapter 6): check the node's
`mtime` and last-job status in `/nodes.json` before concluding
anything is broken. The output section points somewhere else
than where you are looking — remember the per-group split
(chapter 9): your commits may be in `<group>.git` beside the
configured path. Or the output section was never completed and
the daemon is still stopping at an *edit* message you are
reading as a start (first entry above).

## The web port answers nothing — or the daemon dies with the web on

If fetches work but `127.0.0.1:18088` refuses: the extension is
not loaded (`load: true` present?), the gem is missing (that
combination makes Oxidized refuse to start, saying
`oxidized-web not found` — install the gem or remove the
section), or something else holds the port. Note the deprecation
trap: a leftover `rest:` line **overrides** the `extensions:`
section (chapter 11) — remove it. And check you are asking the
port you configured; the default is 8888, not the lab's 18088.

## A node's history starts over

It moved repository: renamed group, renamed node, or a changed
output path. History is per repository and per filename
(chapter 9); the old versions still exist in the old
repository, under the old name — git can read them there, and
the API, which follows the current list, cannot.

## `/nodes/stats.json` returns gibberish

On oxidized-web 0.18.1 it returns Ruby object strings
(chapter 11). Not your bug, and not your data loss: read counts
from the web pages, statuses from `/nodes.json`, and test any
endpoint's shape on your version before scripting against it.

Check: for one sick node, state its status from `/nodes.json`,
find the matching log lines, and name the step of chapter 7's
fetch where it died — connect, authenticate, prompt, command,
or store. That naming is the diagnosis; the fix is usually one
config line.
