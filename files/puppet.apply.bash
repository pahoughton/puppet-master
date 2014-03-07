#!/bin/bash
# puppet.apply.bash - 2014-02-07 08:47
#
# Copyright (c) 2014 Paul Houghton <paul_houghton@cable.comcast.com>
#
log=~/puppet.out
rm $log
[ -f ~/scripts/puppet.update.bash ] && ~/scripts/puppet.update.bash
puppet agent --test >> $log 2>&1
fold -w 75 -s $log
echo Log: $log
