# basenode.pp - 2014-03-08 09:44
#
# Copyright (c) 2014 Paul Houghton <paul4hough@gmail.com>
#
# basenode.pp - 2014-01-26 03:50
#
# Copyright (c) 2014 Paul Houghton <paul4hough@gmail.com>
#
class master::basenode (
  $repo_mirror     = undef,
  $bacula_director = undef,
  $auth_key_type   = undef,
  $auth_key_value  = undef,
  $auth_key_name   = undef,
  ) {

  notify { 'FIXME - repo host mirror needs to be reachable' : }
  notify { 'FIXME - systest - package install attempted w/o repos enabled.' : }
  notify { 'fixme - all systemd files notify systemd' : }

  # make all pacakges dependent on all yumrepos.
  Yumrepo <| |> -> Package <| |>
  Apt::Source <| |> -> Package <| |>

  class { 'gcc' : }

  $common_pkgs = ['xterm',
                  'emacs',
                  'make',
                  'git',
                  'subversion',
                  'cvs',
                  'rcs',
                  'automake',
                  'sysstat',
                  'lsof',
                  'nmap',
                  'iftop',
                  'lynx',
                  'zfs-fuse',]

  $os_pkgs = $::operatingsystem ? {
    'Fedora' => [ 'unar',
                  'policycoreutils-python',
                  'bind-utils',
                  'xorg-x11-apps',
                  ],
    'CentOS' => [ 'man', ],
    'Ubuntu' => [],
    'Debian' => [],
    default  => [],
  }

  $ofam_pkgs = $::osfamily ? {
    'RedHat' => [ 'bind-utils',
                  'policycoreutils-python',
                  'redhat-lsb',
                  'xorg-x11-apps',
                  ],
    'Debian' => ['unar',
                  'bind9utils',
                  'policycoreutils',
                  'x11-apps',
                  ],
  }
  $gpg_path = '/etc/pki/rpm-gpg/RPM-GPG-KEY-rpmfusion'
  $gpg_module = 'puppet:///modules/rpmfusion/RPM-GPG-KEY-rpmfusion'

  if $repo_mirror {
    case $::operatingsystem {
      'fedora' : {
        $existing_repo_files =
          [ '/etc/yum.repos.d/fedora.repo',
            '/etc/yum.repos.d/fedora-updates.repo',
            '/etc/yum.repos.d/fedora-updates-testing.repo',
            '/etc/yum.repos.d/rpmfusion-free.repo',
            '/etc/yum.repos.d/rpmfusion-free-updates-released.repo',
            '/etc/yum.repos.d/rpmfusion-nonfree.repo',
            '/etc/yum.repos.d/rpmfusion-nonfree-updates-released.repo',]

        file { $existing_repo_files :
          ensure => 'absent',
        }
        ->
        file { "${gpg_path}-free-fedora-20":
          ensure => present,
          owner  => 'root',
          group  => 'root',
          mode   => '0644',
          source => "${gpg_module}-free-fedora-20",
        }
        ->
        file { "${gpg_path}-nonfree-fedora-20":
          ensure => present,
          owner  => 'root',
          group  => 'root',
          mode   => '0644',
          source => "${gpg_module}-nonfree-fedora-20",
        }
        ->
        file { "/etc/yum.repos.d/${repo_mirror}-${::operatingsystem}.repo" :
          ensure  => 'file',
          content => template('master/fedora.mirror.repo.erb')
        }
        file { "/etc/yum.repos.d/${repo_mirror}-rpmfusion.repo" :
          ensure  => 'file',
          content => template('master/rpmfusion.mirror.repo.erb'),
        }
        ->
        # this forces my mirror to be installed b4 any packages
        yumrepo { 'dummy' :
          descr   => 'dummy-for-puppet',
          baseurl => 'http://nowhere/',
          enabled => 0,
        }
      }
      'centos' : {
        $existing_repo_files =
          [ '/etc/yum.repos.d/CentOS-Base.repo',
            '/etc/yum.repos.d/CentOS-Debuginfo.repo',
            '/etc/yum.repos.d/CentOS-Media.repo',
            '/etc/yum.repos.d/CentOS-Vault.repo',]
        file { $existing_repo_files :
          ensure => 'absent',
        }
        ->
        file { "${gpg_path}-free-fedora-20":
          ensure => present,
          owner  => 'root',
          group  => 'root',
          mode   => '0644',
          source => "${gpg_module}-free-fedora-20",
        }
        ->
        file { "${gpg_path}-nonfree-fedora-20":
          ensure => present,
          owner  => 'root',
          group  => 'root',
          mode   => '0644',
          source => "${gpg_module}-nonfree-fedora-20",
        }
        ->
        file { "/etc/yum.repos.d/${repo_mirror}-${::operatingsystem}.repo" :
          ensure  => 'file',
          content => template('master/centos.mirror.repo.erb')
        }
        file { "/etc/yum.repos.d/${repo_mirror}-rpmfusion.repo" :
          ensure  => 'file',
          content => template('master/rpmfusion.mirror.repo.erb'),
        }

        class { 'epel' : }

        file { '/etc/pki/rpm-gpg/PaulJohnson-BinaryPackageSigningKey' :
          source => 'puppet:///modules/master/PaulJohnson-BinaryPackageSigningKey',
        }
        yumrepo { 'pjku' :
          descr       => 'pjku',
          baseurl     => 'http://pj.freefaculty.org/EL/6/$basearch',
          enabled     => 1,
          gpgcheck    => 1,
          includepkgs => 'emacs*',
          gpgkey      => 'file:///etc/pki/rpm-gpg/PaulJohnson-BinaryPackageSigningKey',
        }
      }
      'ubuntu' : {
        class { 'apt' :
          # purge_sources_list => true,
        }

        apt::source { "${repo_mirror}_saucy" :
          location    => "http://${repo_mirror}/mirrors/apt/ubuntu/",
          repos       => 'main restricted',
          include_src => false,
        }
        # apt::source { "${repo_mirror}-saucy-updates" :
        #   location => "http://${repo_mirror}/mirrors/apt/ubuntu/",
        #   repos    => 'saucy-updates main restricted',
        # }
      }
      'debian' : {
        # todo - mirror debian
      }
      default : {
        fail("Unsupported operatingsystem ${::operatingsystem}")
      }
    }
  } else {
    # no mirror, so ensure repos are avaiable
    case $::operatingsystem {
      # FIXME - no time for this bs
      # 'fedora' : {
      #   class { 'rpmfusion' : }
      # }
      'fedora' : {
      }
      'centos' : {
        class { 'rpmfusion' : }
        ->
        file { '/etc/pki/rpm-gpg/PaulJohnson-BinaryPackageSigningKey' :
          source => 'puppet:///modules/master/PaulJohnson-BinaryPackageSigningKey',
        }
        yumrepo { 'pjku' :
          descr       => 'pjku',
          baseurl     => 'http://pj.freefaculty.org/EL/6/$basearch',
          enabled     => 1,
          gpgcheck    => 1,
          includepkgs => 'emacs*',
          gpgkey      => 'file:///etc/pki/rpm-gpg/PaulJohnson-BinaryPackageSigningKey',
        }
      }
      'ubuntu' : { # todo
      }
      'debian' : { # todo
        apt::source { 'puppetlabs':
          location   => 'http://apt.puppetlabs.com',
          repos      => 'main',
          key        => '4BD6EC30',
          key_server => 'pgp.mit.edu',
        }
      }
      default : {
        fail("unsupported operatingsystem ${::operatingsystem}")
      }
    }
  }

  # case $::osfamily {
  #   'RedHat' : { }
  #   'Debian' : { }
  # }

  ensure_packages( $ofam_pkgs )
  ensure_packages( $os_pkgs )
  ensure_packages( $common_pkgs )

  service { 'zfs-fuse' :
    ensure  => 'running',
    enable  => true,
    require => Package['zfs-fuse'],
  }
  file { '/root/scripts' :
    ensure => 'directory',
    owner  => 'root',
    group  => 'root',
  }->
  file { '/root/scripts/pagent' :
    ensure => 'file',
    mode   => '+x',
    owner  => 'root',
    group  => 'root',
    source => 'puppet:///modules/master/pagent',
  }

  # addmin groups
  $admgroups = $::osfamily ? {
    'RedHat' => ['sudo','adm','wheel','puppet'],
    'debian' => ['sudo','adm','puppet'],
    default  => ['puppet'],
  }
  group { $admgroups :
    ensure => 'present',
  }
  ->
  class { 'sudo' :
    purge               => false,
    config_file_replace => false,
  }
  ->
  sudo::conf { 'group: sudo' :
    priority => 10,
    content  => "%sudo ALL=(ALL) NOPASSWD: ALL\n",
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

  Firewall {
    before  => Class['master::firewall::post'],
    require => Class['master::firewall::pre'],
  }

  # FIXME - some 'firewall' still being applied to fedora - looks ok though
  # does not work with fedora - todo
  if $::operatingsystem != 'Fedora' {
    class { ['master::firewall::pre', 'master::firewall::post']: }
    class { 'firewall': }
    firewall { '010 accept http(s)(80,443)' :
      proto   => 'tcp',
      port    => [80,443],
      action  => 'accept',
    }
  } else {
    # FIXME - there has to be a better way
    exec { ['firewall-cmd --zone=public --add-service=http',
            'firewall-cmd --permanent --zone=public --add-service=http',
            'firewall-cmd --zone=public --add-service=https',
            'firewall-cmd --permanent --zone=public --add-service=https',
            ] : }
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
  }->
  exec { 'update info dir' :
    command => 'info-dir-update.bash',
    cwd     => '/usr/share/info',
  }
  file { '/etc/profile.d/custom.sh' :
    ensure => 'file',
    source => 'puppet:///modules/master/custom.sh',
  }
}
