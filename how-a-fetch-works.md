# How a fetch works

Outcome: the inside of one fetch, step by step — the session,
the prompt, the model's commands, and the three clocks that
bound it — so a slow or stuck node stops being a mystery.

## One job, from queue to store

Each fetch is a **job**. The worker keeps the nodes in a queue
ordered by due time; when a node's turn comes and a thread is
free (the lab allows 5 of the default 30, quite enough for 3
nodes), a job starts:

1. **Connect.** The input — SSH in this guide — opens a
   connection to the node's address and port (`ssh_port` var,
   default 22), and authenticates: by key if the node has
   `ssh_keys`, else by the resolved username and password, with
   the number of password prompts set to zero — Oxidized never
   sits at a password prompt waiting for a human who is not
   there.
2. **Get a shell and find the prompt.** Oxidized requests a
   terminal and a shell, then waits for output matching the
   node's **prompt** pattern — for the `ios` model,
   `/^([\w.@()-]+[#>]\\s?)$/`: a hostname ending in `#` or `>`.
   The fake device prints `branch-router-01# `, and the match is
   what tells Oxidized the device is ready. A device that never
   prints a matching prompt fails here, with a prompt error —
   the lab's gateway never got this far; it failed one step
   earlier, at authentication.
3. **Post-login commands.** The model may set the stage. The
   `ios` model sends `terminal length 0` and `terminal width 0`
   — "do not pause between pages, do not wrap lines" — because a
   pager pause (`--More--`) would otherwise stall the session
   waiting for a keypress.
4. **The model's commands.** Each `cmd` in the model runs in
   turn: the command is sent, output is collected until the
   prompt returns, and the command's clean-up rules are applied
   (chapter 8). For `ios`: `show version`, `show vtp status`,
   `show inventory`, and in a post step, `show running-config`.
5. **Pre-logout and disconnect.** The model sends `exit`, and
   the session closes.
6. **Store.** The assembled outputs go to the output plugin.
   New or changed text becomes a commit; identical text does
   not (chapter 9).

If any step raises an error, the job ends with a **status**:
`no_connection` for connect and authentication failures,
`fail` for failures further in, `timelimit` for the clock
below — each recorded against the node, visible in the API, and
the honest residue chapter 1's rule predicts.

## The three clocks

- **`timeout` (default 20 s)** bounds a *single wait*: for the
  prompt, for a command's output to settle. It is the clock that
  fires on a device that goes quiet mid-conversation.
- **`timelimit` (default 300 s in the starter config; the lab
  set 120)** bounds the *whole job*. Passed it, the job is
  killed whatever step it is on, and the status is `timelimit`.
  The project's configuration notes stress that this one is
  always enforced, even where an input does not honour
  `timeout`.
- **`interval` (default 3600 s)** is not a job clock but the
  round clock: how often each node is fetched again. Zero is
  special — no automatic rounds at all; fetches then happen only
  when triggered (chapter 12).

Retries sit between the clocks: a failed job is rescheduled up
to `retries` times (lab: 1) before the worker gives up and
waits for the next round. The lab's log shows the whole
arithmetic for the gateway in about a second
(`t06-daemon-log.txt`): fail, "retry attempt 1", fail,
"retries exhausted, giving up".

## What the numbers felt like in the lab

The fake device is a shell script on the same machine, so the
lab's timings are a floor, not a field measurement: about
**3.3 seconds per successful node**, of which real network
latency was none. The time goes in the SSH handshake, the
prompt waits, and four commands each ending in a prompt wait —
Oxidized polls the session patiently rather than reading to a
known end marker, because devices do not have one. Against a
real device across a real network, expect more; against a slow
device with a long configuration, much more. `timelimit` should
be set with your slowest device, not your fastest, in mind.

One more input note: `ssh: secure: false` in the lab's config
means a changed host key is accepted without complaint. On a
network where devices are replaced and readdressed, that is the
setting everyone ends up with; chapter 13 names what it gives
away.

Check: with `debug: true` in a throwaway config (or
`oxidized -d`), run one fetch and find, in order, the connect,
the prompt match, each command the model sends, and the store.
Then read the status names off a failed node in your own list
and match them to the steps above.
