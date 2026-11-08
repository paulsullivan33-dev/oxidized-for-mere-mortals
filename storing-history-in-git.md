# Storing history in git

Outcome: where the fetched configurations actually land — the
git repository's shape, what a commit looks like, why an
unchanged device makes no commit — and the plain-file output
for contrast, including the group quirk both outputs share.

## The git output

With `output: default: git`, Oxidized stores through **rugged**,
a Ruby binding for the git library — no `git` command is run,
but the repository it writes is an ordinary git repository you
can read with ordinary git. The lab's config named a repository
path ending in `configs.git`, a committer name (`Oxidized Lab`)
and a fictional email. Each stored version is one commit per
node, with the message `update <group>/<name>`. The lab's
repository after the first round and one triggered refetch
(transcript `oxidized-lab/transcripts/t08-git-store.txt` and
`t09-change-and-refetch.txt`):

```
28a7d9f 2026-11-07 22:40:20 +0000 update branch/branch-router-01
ccb480a 2026-11-07 22:39:37 +0000 update branch/branch-switch-01
382de69 2026-11-07 22:39:33 +0000 update branch/branch-router-01
```

Three commits for three stored versions — two nodes' first
fetches, and the router's second, after its fixture changed.
There is no commit for `depot-gateway-01`: it never produced a
configuration to store. And there would be no fourth commit for
a refetch that found nothing changed: the output compares the
new text with the stored text and skips identical writes, which
is why chapter 6's unchanged fetches are silent. Git history
here is a log of *changes*, not of *rounds* — the rounds are in
the daemon's log and the nodes' status times (chapter 11).

## The group quirk: one repository per group

The lab configured one repository path — and got a repository
named **`branch.git`** in the folder *beside* that path, named
for the nodes' group. This is deliberate in the source (the lab
read `lib/oxidized/output/git.rb` to be sure): unless
`single_repo: true` is set, the git output keeps **one
repository per group**, formed from the configured path's
folder plus the group's name. Nodes without a group use the
configured path itself. Inside `branch.git` there is one file
per node, named just `branch-router-01` — the group moved into
the repository name, so it comes out of the file path.

Two consequences. First, a group is a storage decision, not
just a label: renaming a group moves the archive. Decide groups
early, and by something that changes rarely — site or role, not
the current project. Second, reading history means knowing
which repository a node lives in; chapter 10 works there.

## The file output, for contrast

The lab also ran a one-pass copy of the lab with
`output: default: file` (transcript
`oxidized-lab/transcripts/t12-file-output.txt`). The file
output keeps the **latest version only**, one plain file per
node, and — the same quirk, this time read in
`lib/oxidized/output/file.rb` — grouped nodes land in a folder
named for the group *beside* the configured directory:
the lab configured `…/file-home/configs` and found its files in
`…/file-home/branch/`. No history, no commits; its `version`
answers are, in the code's own words, "not supported".

Choose git unless you have a reason not to. The file output's
one honest use is feeding the latest configurations to some
other tool that wants plain files; as an archive it is
chapter 1's memory with the past removed.

## The other outputs, documented only

Two more outputs ship with the core and were not run: **http**,
which POSTs each configuration to a URL you configure, and
**gitcrypt**, which stores into a git-crypt–encrypted
repository — the answer, partial and real, to chapter 13's
"the archive contains secrets" problem, at the price of
git-crypt's key management. Hooks can also push a git
repository to a remote after commits (chapter 12); the lab's
repository stayed local.

Check: in your repository folder, run
`git --git-dir=branch.git log --oneline` (with your group or
path) and `git --git-dir=branch.git show HEAD:<node>`; the log
should hold one commit per stored change, and the show should
print the commented document chapter 8 described.
