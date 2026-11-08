# Installing Oxidized

Outcome: Oxidized on your machine, proved by the one check
every route must pass — and an honest account of the long way
this guide's lab had to go, because the machine had no Ruby.

## The check

However you install it, the proof is the same pair of commands:

```
oxidized --version
oxidized --help
```

The lab's copy answers (transcript
`oxidized-lab/transcripts/t03-gem-oxidized.txt`):

```
$ oxidized --version
0.37.0
```

`--help` lists the switches this guide uses: `--daemonize`,
`--home-dir`, `--config-file`, `--debug`, and
`--show-exhaustive-config` (chapter 4). If `oxidized --version`
does not run, nothing else in this guide will either.

## The normal route: Ruby, then the gems

Oxidized is a Ruby program, so the normal install is two steps.
First install **Ruby** itself — from your system's packages
(`ruby` in most distributions), a version manager such as rbenv
or rvm, or the official source at ruby-lang.org. Oxidized
0.37.0 needs a currently supported Ruby; the lab's 3.3.9 is a
safe choice. You also want Ruby's development files and a C
compiler, because some of Oxidized's companion libraries are
built when installed.

Then install the three gems — Ruby's packages — with Ruby's own
installer:

```
gem install oxidized       # the daemon itself
gem install oxidized-web   # web pages and the REST API
gem install oxidized-script  # the oxs command, chapter 11's cousin
```

The lab's install brought in, among others, `net-ssh` (the SSH
client), `rugged` (the git library, compiled on the spot with
the machine's cmake), `asetus` (the config-file library), and
for the web gem `puma` (the web server) and `charlock_holmes`
(text-encoding detection, compiled against the machine's ICU
libraries) — the full list is in transcript
`oxidized-lab/transcripts/t03-gem-oxidized.txt`. On a machine
with Ruby already present, this is a few minutes and it is the
route to take.

## The route this lab actually took

This guide's lab is the cautionary tale, kept because the
chapters that follow cite its transcripts. The build machine
had **no Ruby installed** — no `ruby`, `gem`, `rbenv` or `rvm`
on PATH, nothing under `/usr/lib/ruby`, no package installed
(transcript `oxidized-lab/transcripts/t00-environment.txt`).
One off-PATH leftover did exist, and the record deserves it
stated plainly: an October task had left a working Ruby 3.2.3
in `~/workspace/ruby-labwork/`. The lab's first full search
listed it, but that command's output was delayed in transit, a
narrower re-check missed it, and the lab only learned of it
after the build below was done. It was never used; every run
in this guide used the lab-built Ruby, so no result changes —
but "none anywhere" would have been a tidier sentence than the
true one, and the guide prints the true one. The brief for
this guide set the order of attempts, and the lab followed it
(transcript `oxidized-lab/transcripts/t01-ruby-quest.txt`):

1. **Existing Ruby.** No installed Ruby; one off-PATH leftover
   in a workspace folder, found late, as above.
2. **Docker.** The Docker client (29.1.3) was installed but its
   daemon was not running. Started by hand on a scratch socket,
   the daemon did run and did pull the `hello-world` image —
   and then every container failed to start, even with
   `--privileged`, with `runc` reporting `setns: operation not
   permitted` while joining the container's mount namespace
   (transcript `oxidized-lab/transcripts/t01-docker-attempt.txt`).
   The sandbox forbids the operation containers need. Dead end,
   recorded rather than argued with.
3. **Build Ruby from source.** `ruby-3.3.9.tar.gz` from
   cache.ruby-lang.org, built with the machine's gcc into a
   scratch folder — not installed system-wide. One piece was
   missing, the libyaml headers; the lab downloaded the
   `libyaml-dev` package file and unpacked it into the same
   scratch folder (again, no system install) and pointed the
   build at it. The build and install both succeeded, and the
   result reported the two extensions that matter —
   OpenSSL 3.0.13 (so `gem` can use HTTPS) and Psych 5.1.2
   (the YAML library Oxidized 0.37.0 requires) — in transcript
   `oxidized-lab/transcripts/t02-ruby.txt`.

On to that Ruby, `gem install oxidized oxidized-web
oxidized-script` worked exactly as in the normal route above.
So: the lab's Oxidized is the project's real, current gem,
running on a Ruby the lab compiled — a fact about the lab, not
a claim about how you should install yours. If your machine has
Ruby, use it. The project's own Docker image also exists and is
the sensible route where containers run; it is documented-only
here because, on this machine, they do not.

## A note on versions

Everything in this guide is verified against **Oxidized
0.37.0**, **oxidized-web 0.18.1**, and **oxidized-script
0.7.0**, the current releases when the lab ran. Config keys and
API routes move between releases — one moved under this guide's
hands: the web extension's old `rest:` config key is now
deprecated in favour of an `extensions:` section, which the
daemon states in a warning and chapter 11 shows. Where your
copy disagrees with this guide, your copy wins.

Check: `oxidized --version` prints `0.37.0` (or a later version
you chose on purpose), and `gem list | grep oxidized` shows the
three gems. If both do, chapter 4 gives the program somewhere
to live.
