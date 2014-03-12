# pre.pp - 2014-03-12 03:23
#
# Copyright (c) 2014 Paul Houghton <paul4hough@gmail.com>
#
class master::firewall::pre {
  Firewall {
    require => undef,
  }

  # Default firewall rules
  firewall { '000 accept all icmp':
    proto   => 'icmp',
    action  => 'accept',
  }->
  firewall { '001 accept all to lo interface':
    proto   => 'all',
    iniface => 'lo',
    action  => 'accept',
  }->
  firewall { '002 accept related established rules':
    proto   => 'all',
    ctstate => ['RELATED', 'ESTABLISHED'],
    action  => 'accept',
  }->
  firewall { '003 accept ssh from anywhere' :
    proto   => 'tcp',
    port    => [22,],
    action  => 'accept',
  }
}
