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
  ) {  
  $common_pkgs = ['xterm',
                  'emacs',
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
                  'unar',
                  'xorg-x11-apps',]
                   
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
    fail("repo_mirror '$repo_mirror' is not supported - yet")
  }
  package { $common_pkgs :
    ensure => 'installed',
  }
}
