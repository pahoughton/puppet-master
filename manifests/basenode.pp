# basenode.pp - 2014-03-08 09:44
#
# Copyright (c) 2014 Paul Houghton <paul4hough@gmail.com>
#
# basenode.pp - 2014-01-26 03:50
#
# Copyright (c) 2014 Paul Houghton <paul4hough@gmail.com>
#
class master::basenode (
  $mirror_host     = undef,
  $mirror_purge    = undef,
  $bacula_director = undef,
  $auth_key_type   = undef,
  $auth_key_value  = undef,
  $auth_key_name   = undef,
  ) {

  notify { 'todo - systemd files notify systemd' : }

  # make all pacakges dependent on repos.
  Yumrepo <| |> -> Package <| |>
  Apt::Source <| |> -> Package <| |>

  if ! defined(Class['gcc']) {
    class { 'gcc' : }
  }

  $pkgs = [ 'automake',
            'cvs',
            'emacs',
            'git',
            'iftop',
            'lsof',
            'lynx',
            'make',
            'nmap',
            'rcs',
            'subversion',
            'sysstat',
            'unar',
            'xterm',
            'zfs-fuse',
            ]
  $ofpkgs = $::osfamily ? {
    'Debian' => [ 'bind9utils',
                  'policycoreutils',
                  'x11-apps',
                  ],
    'RedHat' => [ 'bind-utils',
                  'policycoreutils-python',
                  'redhat-lsb',
                  'xorg-x11-apps',
                  ],
    default   => [],
  }


  ensure_packages( $pkgs )
  ensure_packages( $ofpkgs )

  if $::kernel == 'Linux' {

    $ofmirror = $::osfamily ? {
      'Debian' => 'master::mirror::aptmirror',
      'RedHat' => 'master::mirror::yum',
      default  => [],
    }
    class { $ofmirror :
      host  => $mirror_host,
      purge => $mirror_purge,
    }

    $admgroups = $::osfamily ? {
      'RedHat' => ['sudo','adm','puppet'],
      'Debian' => ['sudo','adm','puppet'],
      default  => ['puppet'],
    }
    group { $admgroups :
      ensure => 'present',
    }
    file { '/root/scripts' :
      ensure => 'directory',
    }
    ->
    file { '/root/scripts/pagent' :
      ensure => 'file',
      mode   => '+x',
      source => 'puppet:///modules/master/pagent',
    }

    service { 'zfs-fuse' :
      ensure  => 'running',
      enable  => true,
      require => Package['zfs-fuse'],
    }

    if $auth_key_value and $auth_key_name and $auth_key_type {
      ssh_authorized_key { "root:${auth_key_name}" :
        ensure => 'present',
        user   => 'root',
        name   => $auth_key_name,
        key    => $auth_key_value,
        type   => $auth_key_type,
      }
    }

    if member(['Ubuntu','Fedora',],$::operatingsystem) {

      class { 'sudo' :
        purge               => false,
        config_file_replace => false,
      }
      ->
      sudo::conf { 'group: sudo' :
        priority => 10,
        content  => "%sudo ALL=(ALL) NOPASSWD: ALL\n",
        require  => Group['sudo'],
      }
    }

    case $::operatingsystem {
      'Fedora' : {
        # fixme - there has to be a better way
        exec { ['firewall-cmd --zone=public --add-service=http',
                'firewall-cmd --permanent --zone=public --add-service=http',
                'firewall-cmd --zone=public --add-service=https',
                'firewall-cmd --permanent --zone=public --add-service=https',
                ] :
        }
      }
      default : {
        Firewall {
          before  => Class['master::firewall::post'],
          require => Class['master::firewall::pre'],
        }
        class { ['master::firewall::pre', 'master::firewall::post']: }
        class { 'firewall': }
        firewall { '010 accept http(s)(80,443)' :
          proto   => 'tcp',
          port    => [80,443],
          action  => 'accept',
        }
      }
    }
    if $bacula_director {
      class { 'bacula::fd' :
        dir_host => $bacula_director,
      }
    }
    file { '/usr/bin/info-dir-update.bash' :
      ensure => 'file',
      source => 'puppet:///modules/master/info-dir-update.bash',
      mode   => '0755',
    }
    ->
    exec { 'update info dir' :
      command => 'info-dir-update.bash',
      cwd     => '/usr/share/info',
    }
    file { '/etc/profile.d/custom.sh' :
      ensure => 'file',
      source => 'puppet:///modules/master/custom.sh',
    }
  }
}
