#!/bin/bash
# fake-ios.sh - a fictional network device, played by a shell script.
#
# The lab sshd runs this script as a forced command. Oxidized logs in
# over SSH, asks for a shell, and talks to this script exactly as it
# would talk to a small router or switch running an IOS-like system:
# a prompt, a handful of "show" commands, and an "exit" at the end.
# Every hostname, address and serial number below is invented.
#
# Usage: fake-ios.sh [hostname]
#
# One lab login serves two fictional devices. The lab sshd runs with
# ExposeAuthInfo, so this script can read which client key was used
# from $SSH_USER_AUTH and look the hostname up in a map file the lab
# driver writes at start-up (public key blob -> hostname). Two keys,
# two devices, one sshd. Without a map entry it answers to the name
# in $1, or to branch-router-01.

HOSTN="${1:-branch-router-01}"
MAP="${FAKE_HOSTS_MAP:-$(dirname "$0")/hosts.map}"
if [ -n "${SSH_USER_AUTH:-}" ] && [ -f "$MAP" ] && [ -f "$SSH_USER_AUTH" ]; then
  blob="$(awk '$1 == "publickey" {print $3}' "$SSH_USER_AUTH" 2>/dev/null | head -1)"
  if [ -n "$blob" ]; then
    found="$(awk -v blob="$blob" '$1 == blob {print $2}' "$MAP")"
    [ -n "$found" ] && HOSTN="$found"
  fi
fi

prompt() { printf '%s# ' "$HOSTN"; }

show_version() {
  cat <<EOF
Cisco IOS Software, C2900 Software (C2900-UNIVERSALK9-M), Version 15.7(3)M3, RELEASE SOFTWARE (fc2)
Technical Support: http://www.cisco.com/techsupport
Copyright (c) 1986-2019 by Cisco Systems, Inc.
Compiled Wed 24-Jul-19 04:15 by prod_rel_team

ROM: System Bootstrap, Version 15.0(1r)M16, RELEASE SOFTWARE (fc1)

$HOSTN uptime is 12 weeks, 3 days, 4 hours, 17 minutes
System returned to ROM by power-on
System image file is "flash:c2900-universalk9-mz.SPA.157-3.M3.bin"

cisco CISCO2911/K9 (revision 1.0) with 491520K/32768K bytes of memory.
Processor board ID FGL0000LAB1
3 Gigabit Ethernet interfaces
32768K bytes of non-volatile configuration memory.
262144K bytes of ATA CompactFlash in slot 0 (Sector size 512)

Configuration register is 0x2102
EOF
}

show_vtp_status() {
  cat <<EOF
VTP Version capable             : 1 to 3
VTP version running             : 2
VTP Domain Name                 : northfield
VTP Pruning Mode                : Disabled
Configuration last modified by 10.40.0.11 at 3-1-93 00:00:00
EOF
}

show_inventory() {
  cat <<EOF
NAME: "$HOSTN", DESCR: "CISCO2911/K9 chassis (fictional lab unit)"
PID: CISCO2911/K9      , VID: V05 , SN: FGL0000LAB1

NAME: "GigabitEthernet0/0", DESCR: "Gigabit Ethernet LAN interface"
PID: GE FE ETHERNET    , VID: N/A , SN: LAB000001
EOF
}

running_config() {
  cat <<EOF
Building configuration...

Current configuration : 1874 bytes
!
! Last configuration change at 09:12:44 UTC Mon Nov 2 2026 by labadmin
!
version 15.7
service timestamps debug datetime msec
service timestamps log datetime msec
no service password-encryption
!
hostname $HOSTN
!
boot-start-marker
boot-end-marker
!
enable secret 5 \$1\$lab\$fictionalhashvalue0000000000
!
no aaa new-model
!
ip domain name northfield.example
ip name-server 10.40.0.53
!
interface GigabitEthernet0/0
 description Uplink to the branch LAN - refitted by the lab
 ip address 10.40.1.1 255.255.255.0
 duplex auto
 speed auto
!
interface GigabitEthernet0/1
 description Spare port - shut in the lab fixture
 no ip address
 shutdown
!
ntp server 10.40.0.53
ip route 0.0.0.0 0.0.0.0 10.40.1.254
!
snmp-server community LabReadOnly RO
!
line con 0
line vty 0 4
 login local
 transport input ssh
!
end
EOF
}

prompt
while IFS= read -r raw; do
  line="$(printf '%s' "$raw" | tr -d '\r')"
  case "$line" in
    "terminal length 0" | "terminal width 0")
      ;;
    "show version")
      show_version
      ;;
    "show vtp status")
      show_vtp_status
      ;;
    "show inventory")
      show_inventory
      ;;
    "show running-config" | "show running-config view full")
      running_config
      ;;
    "exit")
      printf 'logout\r\n'
      exit 0
      ;;
    "")
      ;;
    *)
      printf '%% Invalid input detected at the marker below.\r\n'
      printf '%s\r\n' "$line"
      printf ' ^\r\n'
      ;;
  esac
  prompt
done
