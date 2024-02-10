#!/usr/bin/env sh

set -e

cat << EOF > $2
(require-macros :aniseed.macros)
(wrap-module-body

$(cat $1)

)
EOF
