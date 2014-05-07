# aptmirror.pp - 2014-05-06 04:39
#
# Copyright (c) 2014 Paul Houghton <paul_houghton@cable.comcast.com>
#
class master::mirror::aptmirror (
  $baseurl  = '/mirrors/apt',
  $host     = undef,
  $purge    = false,
  ) {
  $servers = hiera('servers',{'aptmirror' => undef})
  $mhost = $host ? {
    undef   => $servers['aptmirror'],
    default => $host,
  }
  if $mhost {
    notify { "configuring to use ${mhost} apt mirror" : }
    case $::operatingsystem {
      'ubuntu' : {
        class { 'apt' :
          purge_sources_list => $purge,
        }
        apt::source { $mhost :
          location    => "http://${mhost}/mirrors/apt/ubuntu/",
          repos       => 'main restricted',
          include_src => false,
        }
      }
      default : {
        notify { "::operatingsystem '${::operatingsystem}' unsupported" : }
      }
    }
  } else {
    notify { 'no mirror host' : }
  }
}
