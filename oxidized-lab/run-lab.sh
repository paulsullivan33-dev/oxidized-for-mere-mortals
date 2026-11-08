#!/bin/bash
# run-lab.sh - rebuild this guide's lab from scratch and run it.
#
# What it does, in order (this is exactly how the transcripts in
# transcripts/ were produced):
#   1. Generates throwaway SSH keys in the batch scratch folder:
#      one host key for the lab sshd, and two client keys - one per
#      fictional device.
#   2. Starts a lab sshd on 127.0.0.1:19088 whose only job is to run
#      fake-device/fake-ios.sh. The key you log in with decides
#      which device answers (see the script and sshd/sshd_config).
#   3. Starts Oxidized with OXIDIZED_HOME=home/ (the config and
#      router.db in this folder). Its REST API listens on
#      127.0.0.1:18088.
#   4. Waits, then prints the API's node list.
#   5. Stops Oxidized and the sshd when you press Enter.
#
# Before running: Ruby and the gems must exist. The lab built Ruby
# 3.3.9 from source into the scratch folder (t01-ruby-quest.txt,
# t02-ruby.txt) and ran:
#   gem install oxidized oxidized-web oxidized-script --no-document
# Point RUBY_BIN at that bin folder, or at any Ruby with the gems.
#
# The sandbox's login user is root and its sshd needs /run/sshd to
# exist; on a normal machine both are already true / unnecessary.

set -u
LAB="$(cd "$(dirname "$0")" && pwd)"
SCRATCH="${OXIDIZED_SCRATCH:-$HOME/workspace/.batch-351-363/scratch-oxidized}"
RT="$SCRATCH/runtime"
RUBY_BIN="${RUBY_BIN:-$SCRATCH/ruby-install/bin}"
export PATH="$RUBY_BIN:$PATH"

[ -d /run/sshd ] || sudo -n mkdir -p /run/sshd || mkdir -p /run/sshd 2>/dev/null

mkdir -p "$RT"
[ -f "$RT/ssh_host_ed25519_key" ] || ssh-keygen -t ed25519 -N '' -f "$RT/ssh_host_ed25519_key" -C lab-host
[ -f "$RT/id_router" ] || ssh-keygen -t ed25519 -N '' -f "$RT/id_router" -C lab-router
[ -f "$RT/id_switch" ] || ssh-keygen -t ed25519 -N '' -f "$RT/id_switch" -C lab-switch
cat "$RT/id_router.pub" "$RT/id_switch.pub" > "$RT/authorized_keys"
chmod 600 "$RT/authorized_keys" "$RT/id_router" "$RT/id_switch"
{ awk '{print $2" branch-router-01"}' "$RT/id_router.pub"
  awk '{print $2" branch-switch-01"}' "$RT/id_switch.pub"; } > "$RT/hosts.map"
sed -e "s|@LAB@|$LAB|g" -e "s|@RUNTIME@|$RT|g" "$LAB/sshd/sshd_config" > "$RT/sshd_config"

/usr/sbin/sshd -f "$RT/sshd_config" -E "$RT/sshd.log"
echo "lab sshd on 127.0.0.1:19088 (pid $(cat "$RT/sshd.pid"))"

export OXIDIZED_HOME="$LAB/home"
oxidized > "$SCRATCH/daemon.log" 2>&1 &
OX_PID=$!
echo "oxidized on 127.0.0.1:18088 (pid $OX_PID), log: $SCRATCH/daemon.log"
sleep 15
curl -s http://127.0.0.1:18088/nodes.json | head -40

echo
echo "Press Enter to stop the lab."
read -r _
kill "$OX_PID" 2>/dev/null
kill "$(cat "$RT/sshd.pid")" 2>/dev/null
echo "lab stopped"
