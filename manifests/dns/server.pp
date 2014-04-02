# server.pp - 2014-02-27 17:49
#
# Copyright (c) 2014 Paul Houghton <paul4hough@gmail.com>
#
class master::dns::server (
  $domain        = 'test192',
  $raddr_base    = '122.168.192',
  $zone_src_base = 'puppet:///modules/master/dns/'
  ) {

  class { 'bind' : }

  bind::server::conf { '/etc/named.conf':
    listen_on_addr    => [ 'any' ],
    listen_on_v6_addr => [ 'any' ],
    forwarders        => ['8.8.8.8',
                          '8.8.4.4' ],
    allow_query       => [ 'localnets' ],
    zones             => {
      "${domain}.lan"              => [ 'type master',
                                        "file \"${domain}.lan\"",
                                        ],
      "${raddr_base}.in-addr.arpa" => [ 'type master',
                                        "file \"${raddr_base}.in-addr.arpa\"",
                                        ],
    },
  }
  bind::server::file { ["${domain}.lan",
                        "${raddr_base}.in-addr.arpa" ]:
    ensure      => 'file',
    source_base => $zone_src_base,
  }
}
