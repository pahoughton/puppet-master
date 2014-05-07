# yum.pp - 2014-05-06 04:22
#
# Copyright (c) 2014 Paul Houghton <paul_houghton@cable.comcast.com>
#
class master::mirror::yum (
  $baseurl  = '/mirrors/yum',
  $host     = undef,
  ) {
  $servers = hiera('servers',{'yummirror' => undef})
  $mhost = $host ? {
    undef   => $servers['yummirror'],
    default => $host,
  }
  $gpg_path       = '/etc/pki/rpm-gpg/rpmfusion'
  $gpg_source     = 'puppet:///modules/rpmfusion/RPM-GPG-KEY-rpmfusion'
  $os_repo_fn     = "/etc/yum.repos.d/${mhost}-${::operatingsystem}.repo"
  $fusion_repo_fn = "/etc/yum.repos.d/${mhost}-rpmfusion.repo"

  if $mhost {
    notify { "configuring to use ${mhost} yum mirror" : }
    $fusion_repo_files =
    [ '/etc/yum.repos.d/rpmfusion-free.repo',
      '/etc/yum.repos.d/rpmfusion-free-updates-released.repo',
      '/etc/yum.repos.d/rpmfusion-nonfree.repo',
      '/etc/yum.repos.d/rpmfusion-nonfree-updates-released.repo',
      ]
    file { $fusion_repo_files :
      ensure => 'absent',
    }
    file { "${gpg_path}-free.key":
      ensure => 'file',
      source => "${gpg_source}-free-fedora-20",
    }
    file { "${gpg_path}-nonfree.key":
      ensure => 'file',
      source => "${gpg_source}-nonfree-fedora-20",
    }
    file { $fusion_repo_fn :
      ensure  => 'file',
      content => template('master/mirror/rpmfusion.repo.erb'),
    }
    file { $os_repo_fn :
      ensure  => 'file',
      content => template("master/mirror/${::operatingsystem}.repo.erb")
    }
    case $::operatingsystem {
      'fedora' : {
        $existing_repo_files =
        [ '/etc/yum.repos.d/fedora.repo',
          '/etc/yum.repos.d/fedora-updates.repo',
          '/etc/yum.repos.d/fedora-updates-testing.repo',]
        file { $existing_repo_files :
          ensure => 'absent',
        }
        yumrepo { 'dummy' :
          descr   => 'dummy-for-puppet',
          baseurl => 'http://nowhere/',
          enabled => 0,
          require => [File[$os_repo_fn],
                      File[$fusion_repo_fn],
                      ],
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
        class { 'epel' : }

        file { '/etc/pki/rpm-gpg/pjku.key' :
          source => 'puppet:///modules/master/mirror/pjku.key',
        }
        yumrepo { 'pjku' :
          descr       => 'pjku',
          baseurl     => 'http://pj.freefaculty.org/EL/6/$basearch',
          enabled     => 1,
          gpgcheck    => 1,
          includepkgs => 'emacs*',
          gpgkey      => 'file:///etc/pki/rpm-gpg/pjku.key',
          require     => [Class['epel'],
                          File[$os_repo_fn],
                          File[$fusion_repo_fn],
                          File['/etc/pki/rpm-gpg/pjku.key'],
                          ],
        }
      }
      default : {
        notify {
          "::operatingsystem '${::operatingsystem}' not fully supported" :
        }
      }
    }
  } else {
    case $::operatingsystem {
      'centos' : {
        class { 'rpmfusion' : }
        ->
        file { '/etc/pki/rpm-gpg/pjku.key' :
          source => 'puppet:///modules/master/pjku.key',
        }
        yumrepo { 'pjku' :
          descr       => 'pjku',
          baseurl     => 'http://pj.freefaculty.org/EL/6/$basearch',
          enabled     => 1,
          gpgcheck    => 1,
          includepkgs => 'emacs*',
          gpgkey      => 'file:///etc/pki/rpm-gpg/pjku.key',
        }
      }
      default : {}
    }
    notify { 'no mirror host' : }
  }
}
