#!/bin/bash
## info-dir-update.bash - 2014-03-01 06:52
#
# Copyright (c) 2014 root <paul4hough@gmail.com>
#
test -d /usr/share/info || exit 0
cd /usr/share/info
for fn in *info.gz; do install-info $fn dir; done
