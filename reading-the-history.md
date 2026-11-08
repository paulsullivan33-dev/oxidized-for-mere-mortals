# Reading the history back

Outcome: the three questions an archive exists to answer —
*what does the device run now, what did it run then, and what
changed between then and now* — asked two ways: with git
directly, and through the REST API.

## With git, because it is just git

The repository is ordinary, so the reader's tools are git's.
In the lab's `branch.git` (transcripts
`oxidized-lab/transcripts/t08-git-store.txt`):

```
git --git-dir=branch.git log --format='%h %ad %s' --date=iso
git --git-dir=branch.git show HEAD:branch-router-01
```

The second prints the current stored document: the comment
head from `show version` (image, chassis, memory, processor
ID), the VTP and inventory comments, then the running
configuration itself, secrets already scrubbed by the model.
For *then*, name the commit instead of `HEAD`. For *what
changed*, diff two commits. The lab changed its fake device's
fixture — one description line edited, one `ntp server` line
added — triggered a refetch, and the diff between the two
router versions is the whole event, in git's words (transcript
`oxidized-lab/transcripts/t09-change-and-refetch.txt`):

```
 interface GigabitEthernet0/0
- description Uplink to the fictional branch LAN
+ description Uplink to the branch LAN - refitted by the lab
  ip address 10.40.1.1 255.255.255.0
…
+ntp server 10.40.0.53
 ip route 0.0.0.0 0.0.0.0 10.40.1.254
```

That small, complete, dated answer is the product. Everything
else in this guide exists to make diffs like that trustworthy
and complete.

## Through the API

The web extension answers the same questions over HTTP
(chapter 11 covers the service itself). The endpoints the lab
ran, against `http://127.0.0.1:18088`:

- **What does it run now:** `GET /node/fetch/<group>/<node>`
  returns the stored document as text — the lab's first lines
  match the git `show` above exactly (transcript
  `oxidized-lab/transcripts/t10-api-versions.txt`).
- **What versions exist:** `GET /node/version.json?node_full=<group>/<node>`
  returns the version list as JSON — for the router, two entries
  with dates, commit ids (`oid`), the committer identity from
  the config, and the message `update branch/branch-router-01`.
- **One old version, and diffs between two:** the
  `/node/version/view` and `/node/version/diffs` routes take a
  node, a group, and commit ids. The lab read their route
  definitions in the oxidized-web source and used the web
  pages' own links as their exercise ground; they are described
  here, with `view` and `diffs` themselves **documented-only**
  as API calls — the same data was read back through git and
  through `/node/fetch`, which were run.
- **Search:** the web interface can search stored
  configurations (`/nodes/conf_search`) — useful when the
  question is "which devices still have this line?". Named
  here, documented-only; the lab's three short documents did
  not need it.

Note what the API cannot give you: a version for a node that
never fetched. `depot-gateway-01` has no versions, no document,
and its node entry says why (chapter 11). The archive's silences
are typed, at least.

## Keeping the archive itself

A plain git repository of text files is about as durable as
data gets — but it lives on the Oxidized host, which
chapter 13 argues is a machine worth an attacker's attention.
Back the repository folder up like any other small, precious
dataset, or let a hook push it to a remote (chapter 12,
documented-only). History you cannot restore is another gap
that only looks like memory.

Check: pick one node and answer the three questions both ways —
`show` at `HEAD` and at the first commit, a diff between them,
then `/node/fetch` and `/node/version.json` in a browser or
with `curl`. The answers should agree line for line.
