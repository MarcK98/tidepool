#!/usr/bin/env bash
#
# Watch GitHub for the next "Deploy Staging" run and raise a macOS banner the
# moment it finishes.
#
# Why a local watcher and not a step in the workflow: the workflow runs on a
# GitHub-hosted Ubuntu runner, which cannot reach this Mac. Something on this
# side has to ask. So the workflow *publishes* the release notice (the
# `release-notice` artifact, written by deploy-staging.yml) and this script
# collects it — the banner's contents are authored by the pipeline, not made up
# here, and it only ever fires because GitHub reported a real run as completed.
#
# Needs no credentials beyond the `gh` login this machine already has.
#
#   ./scripts/watch-staging.sh                 # arm it, wait for the next deploy
#   ./scripts/watch-staging.sh --since-run 0   # fire on the most recent run (test)
#   ./scripts/watch-staging.sh --keep-going    # don't exit after the first one
#
set -euo pipefail

REPO=${TIDEPOOL_REPO:-MarcK98/tidepool}
WORKFLOW="Deploy Staging"
INTERVAL=5
TIMEOUT=5400
ARTIFACT_TIMEOUT=15
FALLBACK_URL="https://marck98.github.io/tidepool/"
SINCE=""
ONCE=1

here=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
notify="$here/notify-mac.sh"

while [ $# -gt 0 ]; do
  case "$1" in
    --repo)       REPO=${2:?}; shift 2 ;;
    --interval)   INTERVAL=${2:?}; shift 2 ;;
    --timeout)    TIMEOUT=${2:?}; shift 2 ;;
    --since-run)  SINCE=${2:?}; shift 2 ;;
    --keep-going) ONCE=0; shift ;;
    -h|--help)    sed -n '2,20p' "$0"; exit 0 ;;
    *) echo "watch-staging: unknown argument: $1" >&2; exit 2 ;;
  esac
done

log() { printf '%s  %s\n' "$(date '+%H:%M:%S')" "$*"; }

gh auth status >/dev/null 2>&1 || { log "FATAL: gh is not logged in — run 'gh auth login'"; exit 1; }

runs_json() {
  gh run list -R "$REPO" --workflow "$WORKFLOW" \
    --json databaseId,number,status,conclusion,headSha,headBranch,url --limit 20 2>/dev/null
}

# Baseline: the newest run that exists right now, including queued and running
# ones. Everything at or below this id is history and must not fire a banner.
if [ -z "$SINCE" ]; then
  SINCE=$(runs_json | jq -r '[.[].databaseId] | max // 0')
fi
log "armed · repo=$REPO · workflow=\"$WORKFLOW\" · ignoring runs <= $SINCE · polling every ${INTERVAL}s"

# Pull the notice the workflow published. Backgrounded and capped, because a
# stuck download must not be the reason the banner is late on camera.
fetch_notice() {
  local id=$1 dir=$2 pid waited=0
  gh run download "$id" -R "$REPO" -n release-notice -D "$dir" >/dev/null 2>&1 &
  pid=$!
  while kill -0 "$pid" 2>/dev/null; do
    if [ "$waited" -ge "$ARTIFACT_TIMEOUT" ]; then
      kill "$pid" 2>/dev/null || true
      log "  notice artifact timed out after ${ARTIFACT_TIMEOUT}s — using run metadata"
      return 1
    fi
    sleep 1
    waited=$((waited + 1))
  done
  wait "$pid" 2>/dev/null || { log "  no release-notice artifact — using run metadata"; return 1; }
  [ -f "$dir/release-notice.json" ] || return 1
}

announce() {
  local run="$1"
  local id number conclusion sha branch run_url url build tmp notice=""

  id=$(jq -r '.databaseId' <<<"$run")
  number=$(jq -r '.number' <<<"$run")
  conclusion=$(jq -r '.conclusion' <<<"$run")
  sha=$(jq -r '.headSha' <<<"$run")
  branch=$(jq -r '.headBranch' <<<"$run")
  run_url=$(jq -r '.url' <<<"$run")

  build=$number
  url=$FALLBACK_URL

  tmp=$(mktemp -d)
  if fetch_notice "$id" "$tmp"; then
    notice=$(cat "$tmp/release-notice.json")
    build=$(jq -r '.build // empty' <<<"$notice" || true)
    build=${build:-$number}
    local u
    u=$(jq -r '.url // empty' <<<"$notice" || true)
    [ -n "$u" ] && url=$u
    log "  release notice from the pipeline: build #$build · $url"
  fi
  rm -rf "$tmp"

  local short=${sha:0:7}

  if [ "$conclusion" = "success" ]; then
    log "BANNER · ✅ Staging deployed — build #$build"
    "$notify" \
      --title "Tidepool CI" \
      --subtitle "✅ Staging deployed — build #$build" \
      --message "${url} · ${branch} @ ${short}" \
      --sound Glass
  else
    log "BANNER · ❌ Deploy $conclusion — build #$build"
    "$notify" \
      --title "Tidepool CI" \
      --subtitle "❌ Deploy $conclusion — build #$build" \
      --message "$run_url" \
      --sound Basso
  fi
}

started=$(date +%s)
while :; do
  now=$(date +%s)
  if [ $((now - started)) -ge "$TIMEOUT" ]; then
    log "gave up after ${TIMEOUT}s without a new $WORKFLOW run"
    exit 3
  fi

  # Oldest-first, so if two deploys land close together (a merge to main and the
  # lead's explicit dispatch both fire this workflow) we announce the first one
  # to finish rather than skipping to the newest.
  hit=$(runs_json | jq -c --argjson since "$SINCE" \
    '[.[] | select(.databaseId > $since and .status == "completed")]
     | sort_by(.databaseId) | first // empty')

  if [ -n "$hit" ]; then
    finished=$(date +%s)
    log "run $(jq -r '.databaseId' <<<"$hit") completed ($(jq -r '.conclusion' <<<"$hit")) · detected ${INTERVAL}s-grained, $((finished - started))s after arming"
    announce "$hit"
    [ "$ONCE" -eq 1 ] && { log "done"; exit 0; }
    SINCE=$(jq -r '.databaseId' <<<"$hit")
  fi

  sleep "$INTERVAL"
done
