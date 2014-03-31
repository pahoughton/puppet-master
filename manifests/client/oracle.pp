# oracle.pp - 2014-03-30 08:44
#
# Copyright (c) 2014 Paul Houghton <paul4hough@gmail.com>
#
class master::client::oracle (
  $user  = 'oracle',
  $group = 'oracle',
  $source = undef,
  $pkg    = 'oracle-instclnt-12.1-sdk.tar.gz',
  $dest   = undef,
  ) {

  $directories = hiera('directories',{ 'oracle' => '/srv/oracle' })
  $uris        = hiera('uris',{ 'app' => 'puppet:///extra_files' })

  $appsrc = $source ? {
    undef   => $uris['app'],
    default => $source,
  }
  $instdir = $dest ? {
    undef   => $directories['oracle'],
    default => $dest,
  }

  file { "${instdir}/install" :
    ensure  => 'directory',
    owner   => $user,
    group   => $group,
    mode    => '0775',
  }

  exec { "wget -q ${appsrc}/${pkg}" :
    cwd     => "${instdir}/install",
    user    => $user,
    group   => $group,
    creates => "${instdir}/install/${pkg}",
    require => File["${instdir}/install"],
  }
  exec { "tar xzf ${instdir}/install/${pkg}" :
    cwd     => $instdir,
    user    => $user,
    group   => $group,
    creates => "${instdir}/sdk/lib64",
  }
}
