#!/usr/bin/env bash
# Prints an `xcodebuild -destination` argument for a simulator that actually
# exists on this machine.
#
# Pinning a device name is the usual way this breaks: `name=iPhone 16 Pro`
# resolves OS to `latest`, and if the newest installed runtime has no iPhone 16
# Pro, xcodebuild fails with "no available devices matched" even though a
# perfectly good simulator is sitting right there. GitHub's macOS images rotate
# which runtimes and devices they ship, so the destination has to be discovered,
# not assumed. Picking by UDID also side-steps the arm64/x86_64 ambiguity.
#
# Preference order: newest iOS runtime, and within it the highest-numbered
# iPhone — closest to what a person would pick in Xcode.
set -euo pipefail

udid=$(
  xcrun simctl list devices available --json |
    /usr/bin/python3 -c '
import json, re, sys

data = json.load(sys.stdin)["devices"]

def runtime_key(name):
    m = re.search(r"iOS[-. ](\d+)[-.](\d+)", name)
    return (int(m.group(1)), int(m.group(2))) if m else (0, 0)

def device_key(name):
    m = re.search(r"iPhone\s+(\d+)", name)
    return (int(m.group(1)) if m else 0, name)

best = None
for runtime, devices in data.items():
    if "iOS" not in runtime:
        continue
    phones = [d for d in devices if d.get("isAvailable") and d["name"].startswith("iPhone")]
    if not phones:
        continue
    phone = max(phones, key=lambda d: device_key(d["name"]))
    candidate = (runtime_key(runtime), device_key(phone["name"]), phone["udid"])
    if best is None or candidate[:2] > best[:2]:
        best = candidate

if best is None:
    sys.exit("no available iOS simulator found")
print(best[2])
'
)

echo "platform=iOS Simulator,id=${udid}"
