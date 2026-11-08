# Glossary

The terms, collected in one place. Each is defined the way
this guide uses it.

**Asetus** — The Ruby configuration library Oxidized uses for
its config file. It supplies defaults, merges your file over
them, and writes starter sections on first runs.

**Commit** — One stored version in a git repository: the
configuration text, the time, and the committer, kept forever
and comparable with every other commit.

**Extension** — An optional add-on loaded from the config's
`extensions:` section. In current Oxidized the only one is
**oxidized-web**.

**Gem** — A Ruby package, installed with the `gem` command.
Oxidized, oxidized-web, and oxidized-script are three gems.

**Group** — A label on a node, set in the node list. Groups
sort credentials, and decide which repository or folder a
stored configuration lands in.

**Hook** — An event handler: code Oxidized runs after events
such as a successful or failed fetch, to exec a command, push
a repository, or post a diff.

**Input** — A way of logging in to a device and conversing:
SSH, Telnet, FTP, SCP, TFTP, HTTP, or a local exec. SSH is
this guide's working input.

**Interval** — Seconds between fetch rounds (`interval`,
default 3600). Zero means no automatic rounds.

**Job** — One fetch attempt against one node, from connect to
store, ending in a status.

**Model** — A Ruby file that knows one device operating
system: its prompt, its commands, and how to tidy the output.
Coverage is exactly the model list.

**Model map** — The config's translation table from names
people write (`cisco`) to model names (`ios`).

**mtime** — In the API's node list, the timestamp of the node's
latest stored configuration. The value `"unknown"` means the
node has never been fetched successfully.

**Node** — One device in the list: a name, a model, an address,
a group, and its vars.

**no_connection** — A job status: the fetch failed before or
at login, so nothing was collected.

**Output** — Where fetched configurations are stored: git
(history), file (latest only), an HTTP post, or an encrypted
git repository.

**oxidized-web** — The gem that provides the web pages and
REST API, loaded as an extension.

**oxs** — The command from the oxidized-script gem: run
commands against nodes by hand, using the same models and
node list as the daemon.

**Prompt** — The device's ready signal — a hostname ending in
`#` or `>` for most models. Oxidized waits for a matching
prompt after login and after each command.

**remove_secret** — A var that, when true, tells models to
scrub secrets (password hashes, community strings) from
stored configurations.

**REST API** — The web extension's machine-readable URLs:
`/nodes.json`, `/node/fetch/…`, `/node/version.json`,
`/node/next/…`, `/reload.json`, and friends.

**router.db** — The default node-list file: colon-separated
lines, one per device. A survivor of the RANCID days.

**Run once** — `run_once: true`: make one pass over the node
list and exit, instead of running as a daemon.

**Source** — Where the node list comes from: a CSV file (this
guide), SQL, HTTP, or a JSON file.

**Timelimit** — The cap on a whole fetch job (default 300 s);
`timeout` (default 20 s) caps a single wait inside it.

**Vars** — Per-node, per-group, per-model, or global settings
that inputs and models read: `ssh_port`, `ssh_keys`, `enable`,
`remove_secret`, and more.
