#!/usr/bin/env bash
set -euo pipefail

if (( $# != 1 )) || [[ ! -d $1 || -L $1 ]]; then
    printf 'Usage: %s DIRECTORY (not a symbolic link)\n' "${0##*/}" >&2
    exit 2
fi

target=$(realpath -e -- "$1")
if [[ $target == / ]]; then
    printf 'Refusing to clean the filesystem root\n' >&2
    exit 2
fi

printf 'Pass 1: empty regular files in %q\n' "$target"
find -P "$target" -xdev -mindepth 1 -type f -empty -print -delete
printf 'Pass 2: empty directories, deepest first\n'
find -P "$target" -xdev -depth -mindepth 1 -type d -empty -print -delete
printf 'Finished; target directory retained.\n'
