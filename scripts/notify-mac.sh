#!/usr/bin/env bash
#
# Post a macOS notification banner.
#
# Deliberately built on /usr/bin/osascript and nothing else: it ships with the
# OS, it already holds notification permission on a normal Mac, and it needs no
# account, token or app password. A brew-installed notifier (terminal-notifier
# and friends) is a *new* bundle id, and a new bundle id means macOS raises an
# "allow notifications?" prompt the first time it fires — which is fine on a
# workstation and fatal on camera.
#
# The banner renders as:
#
#     Tidepool CI                 <- title, bold
#     ✅ Staging deployed …       <- subtitle
#     https://… · main @ 1a2b3c4  <- message
#
# so the *title* is the visible identity. The sending binary is never shown.
#
#   ./scripts/notify-mac.sh --title "Tidepool CI" --subtitle "…" --message "…"
#   ./scripts/notify-mac.sh --demo
#
set -euo pipefail

title="Tidepool CI"
subtitle=""
message=""
sound="Glass"

while [ $# -gt 0 ]; do
  case "$1" in
    --title)    title=${2:?--title needs a value}; shift 2 ;;
    --subtitle) subtitle=${2:?--subtitle needs a value}; shift 2 ;;
    --message)  message=${2:?--message needs a value}; shift 2 ;;
    --sound)    sound=${2-}; shift 2 ;;
    --silent)   sound=""; shift ;;
    --demo)
      subtitle="✅ Staging deployed — build #99"
      message="https://marck98.github.io/tidepool/ · main @ 5ef9978"
      shift ;;
    -h|--help)  sed -n '2,25p' "$0"; exit 0 ;;
    *) echo "notify-mac: unknown argument: $1" >&2; exit 2 ;;
  esac
done

if [ "$(uname -s)" != "Darwin" ]; then
  echo "notify-mac: not macOS, printing instead: ${title} / ${subtitle} / ${message}" >&2
  exit 0
fi

# Arguments go in via `on run argv` rather than string interpolation, so a quote,
# backslash or emoji in the message can never break out into AppleScript source.
osascript - "$title" "$subtitle" "$message" "$sound" <<'APPLESCRIPT'
on run argv
	set theTitle to item 1 of argv
	set theSubtitle to item 2 of argv
	set theMessage to item 3 of argv
	set theSound to item 4 of argv
	if theSound is "" then
		display notification theMessage with title theTitle subtitle theSubtitle
	else
		display notification theMessage with title theTitle subtitle theSubtitle sound name theSound
	end if
end run
APPLESCRIPT
