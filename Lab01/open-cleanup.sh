#!/usr/bin/env bash
set -euo pipefail

if (( $# != 1 )) || [[ ! -d $1 || -L $1 ]]; then
    printf 'Usage: %s DIRECTORY (not a symbolic link)\n' "${0##*/}" >&2
    exit 2
fi
cleaner=$(dirname -- "$(realpath -e -- "${BASH_SOURCE[0]}")")/prune-empty.sh
target=$(realpath -e -- "$1")
command -v gnome-terminal >/dev/null
gnome-terminal --window --title='Empty-file cleanup' -- bash -c '
    "$1" "$2"
    result=$?
    printf "\nCleanup exit code: %d\nThe terminal stays open.\n" "$result"
    exec bash
' bash "$cleaner" "$target"
