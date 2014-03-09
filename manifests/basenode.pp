# basenode.pp - 2014-03-08 09:44
#
# Copyright (c) 2014 Paul Houghton <paul4hough@gmail.com>
#
# basenode.pp - 2014-01-26 03:50
#
# Copyright (c) 2014 Paul Houghton <paul4hough@gmail.com>
#
class master::basenode (
  $repo_mirror,
  $auth_key_type  = undef,
  $auth_key_value = undef,
  $auth_key_name  = undef,
  ) {  
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
                  'zfs-fuse',
                  'policycoreutils-python',
                  'unar',]
                   
  if $repo_mirror {
    $existing_repo_files = $::operatingsystem ? {
      'fedora' => [ '/etc/yum.repos.d/fedora.repo',
                    '/etc/yum.repos.d/fedora-updates.repo',
                    '/etc/yum.repos.d/fedora-updates-testing.repo',
                    '/etc/yum.repos.d/rpmfusion-free.repo',
                    '/etc/yum.repos.d/rpmfusion-free-updates-released.repo',
                    '/etc/yum.repos.d/rpmfusion-nonfree.repo',
                    '/etc/yum.repos.d/rpmfusion-nonfree-updates-released.repo',],
      'centos' => ['/etc/yum.repos.d/CentOS-Base.repo',
                   '/etc/yum.repos.d/CentOS-Debuginfo.repo',
                   '/etc/yum.repos.d/CentOS-Media.repo',
                   '/etc/yum.repos.d/CentOS-Vault.repo',
                   '/etc/yum.repos.d/epel.repo',
                   '/etc/yum.repos.d/pjku.repo',
                   '/etc/yum.repos.d/puppetlabs.repo',],

      'ubuntu' => [],
      default  => undef,
    }
    if ! $existing_repo_files {
      fail("Unsupported operatingsystem ${::operatingsystem}")
    } else {
# FIXME      fail("files  ${::operatingsystem}  ${existing_repo_files}")
      file { $existing_repo_files : 
        ensure => 'absent',
      }->
      file { "/etc/yum.repos.d/${repo_mirror}.repo" :
        ensure => 'file',
        content => template('master/fedora.mirror.repo.erb'),
      }->
      # I'm hopping this forces my mirror to be installed
      # before any packages
      yumrepo { 'dummy' :
        descr   => 'dummy-for-puppet',
        baseurl => 'http://nowhere/',
        enabled => 0,
      }
    }
  } else {
    fail("repo_mirror '${repo_mirror}' is not supported - yet")
  }
  
  package { $common_pkgs :
    ensure => 'installed',
  }
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
  $sudo_grp = $::osfamily ? {
    'debian' => 'adm',
    'redhat' => 'wheel',
  }
  sudo::conf { "group: ${admin_grp}" :
    priority => 10,
    content  => "%${sudo_grp} ALL=(ALL) NOPASSWD: ALL\n",
  }
  if $auth_key_value {
    ssh_authorized_key { 'root-paul' :
      ensure => 'present',
      user   => 'root',
      name   => $auth_key_name,
      key    => $auth_key_value,
      type   => $auth_key_type,
    }
  }
  file { '/usr/bin/info-dir-update.bash' :
    ensure => 'file',
    source => 'puppet:///extra_files/info-dir-update.bash',
    mode   => '0755',
  }->
  exec { 'update info dir' :
    command => 'info-dir-update.bash',
    cwd     => '/usr/share/info',
  }
}
