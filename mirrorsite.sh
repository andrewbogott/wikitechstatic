#!/bin/bash

httrack --update \
    --update \
    --keep-alive \
    --search-index \
    -#L1000000 \
    --connection-per-second=5000 \
    --sockets=99 \
    --max-rate=1000000000 \
    --disable-security-limits \
    -v \
    -wikitech.wikimedia.org/wiki/Special:* \
    -wikitech.wikimedia.org/wiki/Nova_Resource:* \
    -wikitech.wikimedia.org/w/index.php?title=Special \
    -*Special:* \
    -*Nova_Resource:* \
    -*oldid=* \
    -*action=* \
    -*index.php=* \
    https://wikitech.wikimedia.org
