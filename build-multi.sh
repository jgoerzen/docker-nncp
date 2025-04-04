#!/bin/bash

set -eo pipefail
set -x

PLATSTRING="`echo "$PLATFORM" | sed 's,/,_,g'`"

echo "PLATSTRING=$PLATSTRING"

docker buildx build --load --platform $PLATFORM -t "jgoerzen/nncp:latest-$PLATSTRING" .
docker push jgoerzen/nncp:latest-$PLATSTRING
