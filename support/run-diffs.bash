#!/bin/bash

( echo "# If anything changes here, sync the items in shards.txt";
rgrep -h ^require amber/src/ amber/lib/*/src/ app/src/ app/lib/*/src/  |grep -v \\./|grep -v \\.js|sort|uniq ) > diffs/shards.txt

git diff diffs
