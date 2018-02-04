#!/bin/bash

( echo "# If anything changes here, sync the items in shards.txt";
rgrep -h ^require amber app |grep -v \\./|grep -v \\.js|sort|uniq ) > diffs/shards.txt

