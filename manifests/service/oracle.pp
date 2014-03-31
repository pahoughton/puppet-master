# oracle.pp - 2014-03-28 12:49
#
# Copyright (c) 2014 Paul Houghton <paul4hough@gmail.com>
#
class master::service::oracle(
  $user  = 'oracle',
  $group = 'oracle',
  $source = undef,
  $pkg
  ) {

  $directories = hiera('directories',{ 'oracle' => '/srv/oracle' })
  $uris        = hiera('uris',{ 'app' => 'puppet:///master' })

  $instdir = "${directories[oracle]}/install"

  $appsrc = $source ? {
    undef   => $uris['app'],
    default => $source,
  }


  $ospkgs = $::osfamily ? {
    'debian' => ['x11-utils',],
    'RedHat' => [ 'xorg-x11-utils',
                  'gcc-c++',
                  'libstdc++-devel',
                  'zlib-devel',
                  'libaio-devel',],
  }
  # todo server
  # ensure_packages($ospkgs)
  # ensure_packages($pkgs)

  # $pkgs = ['ksh',]

  $bpkg = 'oracle-instantclient12.1-basic-12.1.0.1.0-1.x86_64.rpm'
  $dpkg = 'oracle-instantclient12.1-devel-12.1.0.1.0-1.x86_64.rpm'

  file { $instdir :
    ensure  => 'directory',
    owner   => $user,
    group   => $group,
    mode    => '0775',
  }

  exec { "wget -q ${appsrc}/${bpkg}" :
    cwd     => $instdir,
    user    => $user,
    group   => $group,
    creates => "${instdir}/${bpkg}",
    require => File[$instdir],
  }

  exec { "wget -q ${appsrc}/${dpkg}" :
    cwd     => $instdir,
    user    => $user,
    group   => $group,
    creates => "${instdir}/${dpkg}",
    require => File[$instdir],
  }

  # # fixme still not working :(
  # package { "${instdir}/${bpkg}" :
  #   ensure => 'present',
  #   source => "${instdir}/${bpkg}",
  # }

  # package { "${instdir}/${dpkg}" :
  #   ensure => 'present',
  #   source => "${instdir}/${dpkg}",
  # }

  # $zone = 'oracle-serv-1.zip'
  # $ztwo = 'oracle-serv-2.zip'

  # $exectwo = "wget -q ${appsrc}/${ztwo} && cd ${instdir} && unar ${ztwo}"

  # exec { $exectwo :
  #   cwd     => $instdir,
  #   user    => $user,
  #   group   => $group,
  #   creates => "${instdir}/oracle-serv-2.zip",
  # }
  # notify { "odd no ${execone}" : }
}
