#!/usr/bin/env bash
set -euo pipefail
here=$(dirname -- "$(realpath -e -- "${BASH_SOURCE[0]}")")
fixture=$(mktemp -d)
trap 'rm -rf -- "$fixture"' EXIT
mkdir -p "$fixture/target/deep/empty" "$fixture/target/keep dir" "$fixture/outside"
touch "$fixture/target/empty file" "$fixture/target/.hidden" "$fixture/target/deep/zero"
printf 'keep\n' > "$fixture/target/keep dir/data"
touch "$fixture/outside/untouched"
ln -s "$fixture/outside" "$fixture/target/linked"
"$here/prune-empty.sh" "$fixture/target"
[[ -d $fixture/target && -f "$fixture/target/keep dir/data" ]]
[[ -L $fixture/target/linked && -f $fixture/outside/untouched ]]
[[ ! -e $fixture/target/deep && ! -e "$fixture/target/empty file" && ! -e $fixture/target/.hidden ]]
"$here/prune-empty.sh" "$fixture/target"
for bad in missing '' / "$fixture/target/linked"; do
    if "$here/prune-empty.sh" "$bad"; then exit 1; fi
done
if "$here/prune-empty.sh"; then exit 1; fi
printf 'PASS: two passes, nested directories, spaces, hidden file, symlink, repeat, invalid input\n'
