# post.pp - 2014-03-12 03:24
#
# Copyright (c) 2014 Paul Houghton <paul4hough@gmail.com>
#
class master::firewall::post {
  firewall { '999 drop all':
    proto   => 'all',
    action  => 'drop',
    before  => undef,
  }
}
