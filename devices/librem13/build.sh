#!/bin/bash
set -uexo pipefail

rm -rf .mkosi.extra.enc.dec
mkdir .mkosi.extra.enc.dec
for f in $(find mkosi.extra.enc -type f); do
    f="${f#mkosi.extra.enc\/}"
    mkdir -p .mkosi.extra.enc.dec/$(dirname $f)
    sops -d mkosi.extra.enc/$f > .mkosi.extra.enc.dec/$f
done

mkosi -f
