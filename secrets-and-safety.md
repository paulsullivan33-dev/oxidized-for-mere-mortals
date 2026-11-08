# Secrets and safety

Outcome: a clear-eyed view of what Oxidized holds — credentials
that can log in everywhere, and an archive of everything those
logins can read — and the two settings that reduce, without
removing, the exposure.

## The archive contains secrets, unless you scrub them

A running configuration is full of secrets: SNMP community
strings, local account password hashes, VPN pre-shared keys,
enable secrets. Stored raw, your git repository is a single
file-per-device collection of them — convenient for recovery,
and a remarkable thing to hand an attacker. Oxidized's answer
is the model's **`:secret` clean-ups**, switched on by one var:

```yaml
vars:
  remove_secret: true
```

The lab set it, and the stored router document shows the trade
in two lines (transcript
`oxidized-lab/transcripts/t08-git-store.txt`):

```
enable secret 5 <secret hidden>
…
snmp-server community <configuration removed>
```

The `ios` model's secret rules rewrote the fake enable-secret
hash and removed the fake community string before storage. What
scrubbing costs is real: the scrubbed archive is **not a full
backup**. Restore a device from it and you must re-enter the
secrets by hand — the archive remembers the *shape* of the
configuration, not every key that makes it work. The project's
own configuration notes say the same in one line: removing
secrets reduces usefulness as a full backup, but makes sharing
configurations safer. Choose per network: a scrubbed archive
you can show a colleague, or a complete archive you must guard
like the devices themselves. Note too that scrubbing depends on
each model's rules catching each secret's shape; a secret in a
line no rule recognises is stored. Treat a "scrubbed" archive
as *lower*-secret, not no-secret.

## The host is a prize

The deeper exposure is not the archive; it is the daemon.
To work at all, Oxidized holds credentials — a password, an SSH
key, an enable secret — that can **log in to every device on
its list**, usually with read access to full configurations and
often with more. They sit in a plain-text config file and a
plain-text `router.db`, by design: the program must be able to
read them unattended. Compromise the Oxidized host and you hold
a keyring for the whole network, neatly indexed by hostname.
Consequences worth acting on:

- Run Oxidized on a small, hardened host whose only job is
  this; patch it; give it no other roles.
- File permissions are the first wall: the lab's config, list,
  and repositories are created owner-only (`rw-------` on the
  files the lab kept) — check yours, and keep the home folder
  out of shared and backed-up-to-strangers places except as
  chapter 10 advised, deliberately.
- Give Oxidized's device accounts the least privilege that can
  *read* a configuration. On many systems a read-only account
  suffices for `show` commands; Oxidized never needs to
  configure (chapter 1), so it should not hold credentials that
  can.
- The web extension has no authentication of its own
  (chapter 11): loopback binding or an authenticating proxy in
  front is part of the install, not an extra.

The encrypted-repository output (`gitcrypt`, chapter 9)
protects the archive at rest; it does nothing for the live
credentials, which are the richer target. Named here so the
threat model stays honest.

## Host keys: the secure switch

The SSH input has a `secure` setting. With `secure: true`,
Oxidized checks device host keys the way OpenSSH does and
refuses a changed key — proof, as far as SSH gives it, that you
are talking to the device you think you are. With the lab's
`secure: false`, any key is accepted: necessary in the lab (the
fake device's key was generated minutes earlier, and real
devices get replaced), and a genuine weakening — a spoofed
device on the management network would be fetched *from*
without complaint, and its invented configuration archived as
truth. If your devices' host keys are stable, run `secure:
true` and accept the maintenance when hardware changes; if not,
at least know which choice you made. Documented from the input
source here; the lab's runs used `false` throughout.

Check: search your own stored archive for a known secret
string from a lab device (`grep -r` in the repository folder).
Scrubbing on should find the model's replacement markers —
`<secret hidden>`, `<configuration removed>` — and not the
secret. Then read your config's file permissions and the web
extension's `listen` line with an attacker's eyes.
