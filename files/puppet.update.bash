#!/bin/bash
# puppet.update.bash - 2014-02-07 08:45
#
# Copyright (c) 2014 Paul Houghton <paul_houghton@cable.comcast.com>
#
# update puppet master files
log=~/puppet.out
cd /etc/puppet
git pull
/usr/local/bin/librarian-puppet update > $log 2>&1
fold -w 78 -s $log
