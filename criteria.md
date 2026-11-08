# Writing criteria for this guide

Every "for Mere Mortals" guide is written to the same nine-point
standard, so a reader who trusts one can trust the rest. Here it
is, with the verification notes for this particular guide below.

1. **Fix it first.** Reader outcomes lead, not action items: each
   chapter opens by naming the outcome it delivers, shows a check
   the reader can run to confirm they got it, and a reasonable
   reader finishes able to state what was done, what it means,
   and what to try next.
2. **Plain language.** Short sentences, everyday vocabulary,
   technical terms defined on first use. No slang, and no
   idioms that only make sense in one country — the reader may
   be translating as they go.
3. **No dead ends.** A guide never tells the reader to do
   something it cannot show them how to verify. Every claim a
   reader relies on — an install, a command, an output — is
   something this guide demonstrates or clearly labels
   documented-only below.
4. **Live-verified where it matters.** Procedures are run for
   real in the guide's lab wherever the build machine allows it,
   and the transcripts kept in the repository are the evidence.
   What could not be run is listed honestly below, never
   presented as if it had been.
5. **General audiences.** Nothing in this guide — examples,
   fixtures, names, addresses — is modelled on any particular
   reader or author's real life, network, or organisations.
   The lab's traffic is the lab talking to itself.
6. **Standalone.** A reader needs this guide, its lab, and
   nothing else. Where another guide would genuinely help, it
   is pointed to once, by name, and the chapter still completes
   without it.
7. **Honest about limits.** The limits chapter names what the
   tool cannot do: it reads configurations and does not manage
   devices — no pushing changes, no rollback, no compliance
   judgement; coverage is exactly the model list, so a device
   whose OS has no model is invisible, not merely unsupported;
   the credentials it holds can read every device on its list,
   so the Oxidized host is itself a prize and its web extension
   has no authentication of its own; and a configuration backup
   is not a device backup — images, licences, certificates and
   live state live elsewhere. Lab-proved versus documented is
   marked per limit in chapter 16.
8. **The one rule is in the text, early.** Chapter 1 and the
   README state the rule plainly — *Oxidized remembers what
   your devices said their configuration was; it fetches, it
   does not configure; and the history it keeps in git is only
   as true as the last successful fetch, so a silent collection
   failure is a gap in memory, not a confirmation* — before any
   procedure depends on it, and later chapters point back to it
   where the rule bites: the unchanged fetch that stays silent,
   the failed node whose `mtime` reads `unknown`, and the
   archive that must be watched to be believed.
9. **Builds clean.** The site builds with MkDocs in strict mode
   with no warnings, and a fresh reader following the chapters
   in order reaches the stated outcome of each.

## Verification notes for this guide

The build machine is an Ubuntu 24.04 sandbox whose login user
is root. Obtaining Ruby was the lab's first problem, and the
route matters to every claim after it. The machine had **no
Ruby installed** (nothing on PATH, no package; one off-PATH
leftover, a Ruby 3.2.3 in `~/workspace/ruby-labwork/` from an
October task, existed — the lab's first search listed it, its
delayed output was missed by a narrower re-check, and it was
never used), and **Docker could not run
containers**: a hand-started Docker 29.1.3 daemon on a scratch
socket pulled `hello-world` but every container start, even
`--privileged`, failed with runc's `setns: operation not
permitted` joining the mount namespace (transcripts t00, t01).
So the lab **built Ruby 3.3.9 from the official source tarball**
(`ruby-3.3.9.tar.gz`, cache.ruby-lang.org) with gcc 13.3 into a
scratch folder, satisfying the one missing header set by
unpacking the `libyaml-dev` .deb into scratch (no system
install); the built Ruby reports OpenSSL 3.0.13 and Psych 5.1.2
(t02). Onto it, `gem install oxidized oxidized-web
oxidized-script --no-document` installed **Oxidized 0.37.0**,
**oxidized-web 0.18.1**, **oxidized-script 0.7.0** and their
dependencies, including native builds of rugged 1.9.6,
charlock_holmes, ed25519, bcrypt_pbkdf and puma (t03). The
oxidized and oxidized-web gem *sources* were also unpacked and
read, and several source-only claims below are credited to
specific files.

The "network" is a fiction played by software: an OpenSSH
server (`/usr/sbin/sshd`) on **127.0.0.1:19088** running a shell
script, `oxidized-lab/fake-device/fake-ios.sh`, as a forced
command. The script answers an IOS-like prompt and four `show`
commands from canned text for a fictional branch network. Two
client keys make it answer as two different devices (the sshd
exposes the auth info; the script maps key to hostname). A third
node in the list has no key and a wrong fallback password, so
its failure is genuine. Oxidized ran with
`OXIDIZED_HOME=oxidized-lab/home/`, its web extension on
**127.0.0.1:18088**. All transcripts live in
`oxidized-lab/transcripts/`; `oxidized-lab/run-lab.sh` rebuilds
the setup.

Run for real, with transcripts as evidence:

- Version and help: `oxidized --version` → `0.37.0`;
  `--help` lists `--daemonize`, `--home-dir`, `--config-file`,
  `--show-exhaustive-config` (t03). First run against an empty
  home wrote a starter config and stopped with an `edit …`
  message (t04). `--show-exhaustive-config` printed the merged
  settings (t13).
- The fake device by hand first (t05): both keys answered with
  their own hostname and canned `show` output over a real SSH
  session, after two recorded false starts (a nonexistent login
  user, and sshd StrictModes refusing the lab key path — both
  fixed in the lab sshd config, which keeps the notes).
- The daemon round (t06): `Loaded 3 nodes`; web listening on
  127.0.0.1:18088; `Configuration updated` for
  branch-router-01 and branch-switch-01; depot-gateway-01
  raised `Net::SSH::AuthenticationFailed`, was retried once
  (lab `retries: 1`), and ended `status no_connection, retries
  exhausted, giving up`.
- The REST API (t07, t10): `/nodes.json` reported success in
  3.36 s and 3.30 s for the good nodes and `no_connection`,
  0.07 s, `mtime: "unknown"` for the failed one; `/` answered
  302; `/node/show/<node>` served its HTML page;
  `/nodes/stats.json` returned Ruby object description strings
  (`#<Oxidized::Node::Stats:0x…>`) instead of statistics — kept
  in the guide as a real quirk of oxidized-web 0.18.1.
  `/reload.json` answered `["reloaded list of nodes"]` and the
  log showed the reload.
- The git store (t08): one repository, `branch.git`, appeared
  beside the configured `configs.git` path (per-group split,
  mechanism read in `lib/oxidized/output/git.rb`). Commits
  `update branch/branch-router-01` and `…/branch-switch-01`,
  one file per node. The stored router document opens with the
  ios model's comment block distilled from `show version`
  (image, chassis, `Processor ID: FGL0000LAB1`, memory), then
  VTP and inventory comments, then the running config — with
  `enable secret 5 <secret hidden>` and
  `snmp-server community <configuration removed>`, proving
  `remove_secret: true` end to end.
- Change and refetch (t09): the fixture's config was edited
  (one description line, one `ntp server` line added),
  `GET /node/next/branch/branch-router-01.json` answered
  `["ok"]`, and about five seconds later a new commit landed;
  `git diff` between the two versions is exactly those two
  lines.
- Versions by API (t10): `/node/version.json?node_full=…`
  listed both router versions with oids and the configured
  committer identity; `/node/fetch/branch/branch-router-01`
  returned the stored document, matching `git show`.
- A run-once pass (t11): a copied home with `run_once: true`
  made one pass and exited 0 in about ten seconds; only the
  switch — changed since its last fetch — logged an update,
  which is also the guide's evidence that unchanged fetches
  store nothing and log nothing at info level.
- The file output (t12): a copied home with `output: file`
  stored both configs as plain files — in a `branch/` folder
  *beside* the configured `configs/` directory, the group
  quirk read in `lib/oxidized/output/file.rb`.
- `oxs --help` from oxidized-script, and the model folder
  count: 198 files in `lib/oxidized/model/` of 0.37.0 (t13).

Documented only — described from the project's docs, `--help`,
or source read in the lab, not run, and the text does not claim
otherwise:

- Installation on a machine that already has Ruby (the normal
  route), all package-manager and version-manager Ruby installs,
  Windows, and the project's Docker image (Docker cannot start
  containers in this sandbox — t01).
- Inputs other than SSH (Telnet, FTP, SCP, TFTP, HTTP, exec),
  including enable-mode handling beyond the ios model's macro,
  and SSH proxying.
- Sources other than CSV (SQL, HTTP, JSON file).
- Outputs other than git and file (http POST, gitcrypt), the
  `single_repo: true` git mode, and hooks of every kind
  (exec, githubrepo push, Slack/Spark diffs, SNS), including
  syslog-triggered fetching wired to `/node/next`.
- The `PUT /node/next` form with commit author/message, the
  `/node/version/view` and `/node/version/diffs` API calls and
  config search (their routes were read in the oxidized-web
  source; the same data was read back through git and
  `/node/fetch`, which were run), `next_adds_job`,
  SIGHUP-triggered reload (the API reload was run), service
  files for running the daemon under systemd and friends, and
  the authenticating proxy setups in `extra/`.
- Writing new models and the model unit-test harness.
- The neighbouring tools of chapter 15 are characterised, not
  benchmarked; `oxs` is help-text only.

Fixtures are this guide's own and deliberately generic: a
fictional two-device branch network (`branch-router-01`,
`branch-switch-01`, `depot-gateway-01`), invented addresses in
10.40.0.0 space, an invented domain (`northfield.example`), and
fake secrets placed to be scrubbed. No example is modelled on
any real person, network, service or organisation. The lab's
ports were 127.0.0.1:18088 (web) and 127.0.0.1:19088 (fake
device) only, and both services were stopped when the work was
done.
