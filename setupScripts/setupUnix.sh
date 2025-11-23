#!/usr/bin/env bash
set -euo pipefail

# Enable extglob for advanced pattern matching (used in trimming)
shopt -s extglob

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

CONFIG_PATH="$SCRIPT_DIR/setup-config.psv"

TAGS=""
IDS=""
DRY_RUN=0
FORCE=0
PRUNE=0

usage() {
  echo "Usage: $0 [--tags TAG1,TAG2] [--ids id1,id2] [--dry-run] [--force] [--prune]"
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --tags) TAGS="$2"; shift 2;;
    --ids) IDS="$2"; shift 2;;
    --dry-run) DRY_RUN=1; shift;;
    --force) FORCE=1; shift;;
    --prune) PRUNE=1; shift;;
    -h|--help) usage; exit 0;;
    *) echo "Unknown arg: $1"; usage; exit 2;;
  esac
done


if [[ ! -f "$CONFIG_PATH" ]]; then
  echo "Config not found: $CONFIG_PATH" >&2; exit 2
fi

REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Detect platform (mac vs linux)
platform_type="linux"
if [[ "$(uname)" == "Darwin" ]]; then
  platform_type="mac"
fi

# Read PSV lines, ignore comments and blank lines, normalize pipes and split fields
PLANNED_IDS=()
PLANNED_SRCS=()
PLANNED_DESTS=()
while IFS= read -r rawline || [[ -n $rawline ]]; do
  # trim
  line="${rawline##+([[:space:]])}"
  line="${line%%+([[:space:]])}"
  [[ -z "$line" || "${line:0:1}" == "#" ]] && continue
  # normalize spaces around pipes
  norm=$(printf "%s" "$line" | sed -E 's/[[:space:]]*\|[[:space:]]*/|/g')
  IFS='|' read -r id src platform dest tags _ <<< "$norm"
  # Count fields by splitting into an array
  IFS='|' read -ra fields <<< "$norm"
  if (( ${#fields[@]} < 4 )); then
    echo "Warning: Skipping malformed line (expected at least 4 fields): '$line'" >&2
    continue
  fi
  id="${id:-}"; src="${src:-}"; platform="${platform:-}"; dest="${dest:-}"; tags="${tags:-}"


  # platform filter (accepts all, unix, or detected platform)
  if [[ "$platform" != "all" && "$platform" != "unix" && "$platform" != "$platform_type" ]]; then continue; fi

  # tag filter
  if [[ -n "$TAGS" && -n "$tags" ]]; then
    match=0
    IFS=',' read -r -a entrytags <<< "$tags"
    IFS=',' read -r -a tagfilter <<< "$TAGS"
    for et in "${entrytags[@]}"; do for tf in "${tagfilter[@]}"; do [[ "$et" == "$tf" ]] && match=1; done; done
    [[ $match -eq 0 ]] && continue
  fi

  # ids filter
  if [[ -n "$IDS" ]]; then
    match=0
    IFS=',' read -r -a idfilter <<< "$IDS"
    for idf in "${idfilter[@]}"; do [[ "$idf" == "$id" ]] && match=1; done
    [[ $match -eq 0 ]] && continue
  fi

  src_abs="$REPO_ROOT/$src"
  dest_expanded=$(eval echo "$dest")
  PLANNED_IDS+=("$id")
  PLANNED_SRCS+=("$src_abs")
  PLANNED_DESTS+=("$dest_expanded")
  echo "Planned: $id -> $dest_expanded -> $src_abs"

done < "$CONFIG_PATH"

all_success=0
planned_set=()
for d in "${PLANNED_DESTS[@]}"; do planned_set+=("$(realpath -m "$d")"); done

# perform linking
for i in "${!PLANNED_IDS[@]}"; do
  id="${PLANNED_IDS[$i]}"; src="${PLANNED_SRCS[$i]}"; dest="${PLANNED_DESTS[$i]}"
  if [[ ! -e "$src" ]]; then echo "Source missing for $id: $src"; all_success=1; continue; fi
  dest_parent=$(dirname "$dest")
  if [[ ! -d "$dest_parent" ]]; then
    if [[ $DRY_RUN -eq 1 ]]; then
      echo "DRY RUN: Would create parent directory $dest_parent"
    else
      echo "Creating parent directory $dest_parent"
      mkdir -p "$dest_parent"
    fi
  fi


  if [[ -e "$dest" ]]; then
    if [[ $FORCE -eq 1 ]]; then
        if [[ $DRY_RUN -eq 1 ]]; then
          echo "DRY RUN: Would remove existing $dest"
        else
          if [[ -L "$dest" ]]; then
            echo "Removing symlink $dest"
            rm "$dest"
          else
            backup="$dest.backup.$(date +%s)"
            echo "Backing up $dest -> $backup"
            mv "$dest" "$backup"
          fi
        fi
    else
      if [[ -L "$dest" ]]; then
        target=$(readlink -f "$dest")
        src_resolved=$(readlink -f "$src")
        if [[ "$target" == "$src_resolved" ]]; then
          echo "Already linked: $dest -> $src"
          continue
        fi
      fi
      echo "Destination exists and is not desired link: $dest (use --force to replace)"; all_success=1; continue
    fi
  fi

  if [[ $DRY_RUN -eq 1 ]]; then
    echo "DRY RUN: would create link $dest -> $src"
    continue
  fi

  if ln -s "$src" "$dest" 2>/dev/null; then
    echo "Created symlink $dest -> $src"
  else
    echo "Failed to create symlink $dest -> $src"; all_success=1
  fi

done

if [[ $PRUNE -eq 1 ]]; then
  if [[ -n "$TAGS" || -n "$IDS" ]]; then
    echo "Prune skipped because --tags or --ids filters were used. Run prune with the full config to avoid accidental removal of valid links."
  else
  # Find parent directories to scan
  parents=()
  for d in "${PLANNED_DESTS[@]}"; do parents+=("$(dirname "$d")"); done
  unique_parents=($(printf "%s\n" "${parents[@]}" | sort -u))
  for parent in "${unique_parents[@]}"; do
    [[ ! -d "$parent" ]] && continue
    for child in "$parent"/*; do
      [[ ! -L "$child" ]] && continue
      target=$(readlink -f "$child")
      if [[ "$target" == "$REPO_ROOT"* ]]; then
        # check if in planned_set
        matched=0
        for p in "${planned_set[@]}"; do
          if [[ "$p" == "$(realpath -m "$child")" ]]; then matched=1; break; fi
        done
        if [[ $matched -eq 0 ]]; then
          if [[ $DRY_RUN -eq 1 ]]; then echo "DRY RUN: Would prune $child (points to $target)"; else echo "Pruning $child (points to $target)"; rm "$child"; fi
        fi
      fi
    done
  done
  fi
fi

exit $all_success
