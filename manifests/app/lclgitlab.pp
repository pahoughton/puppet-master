# lclgitlab.pp - 2014-03-23 07:45
#
# Copyright (c) 2014 Paul Houghton <paul4hough@gmail.com>
#
class master::app::lclgitlab (
  $git_create_user = true,
  $vhost           = undef,
  $port            = '8280',
  ) {

  # fixme args for all values
  $databases = hiera('databases', {
    'gitlab' => {
      'host' => 'localhost',
      'name' => 'gitlab',
      'user' => 'gitlab',
      'pass' => 'gitlab'
    }
  })
  $directories = hiera('directories',{'gitlab' => '/var/lib/gitlab'})
  $email       = hiera('emails', { 'gitlab' => "gitlab@${::hostname}" })
  $groups      = hiera('groups',{'gitlab' => 'git' })
  $servers     = hiera('servers',{'pgsql' => 'localhost',
                                  'www'   => undef } )
  $users       = hiera('users', { 'git' => 'git', 'gitlab' => 'gitlab', })

  $redispkgs = $::osfamily ? {
    'Debian'  => ['redis-server',],
    default   => ['redis',],
  }
  $redissvc = $::osfamily ? {
    'Debian'  => 'redis-server',
    default   => 'redis',
  }


  ensure_packages($redispkgs)

  service { $redissvc :
    ensure  => 'running',
    enable  => true,
    require => Package[$redispkgs],
  }

  if  $databases['gitlab']['host'] == 'localhost' or
      $databases['gitlab']['host']== $::hostname {

    postgresql::server::role { $databases['gitlab']['user'] :
      createdb      => true,
      password_hash => postgresql_password( $databases['gitlab']['user'],
                                            $databases['gitlab']['pass']),
    }
    ->
    postgresql::server::db { $databases['gitlab']['name'] :
      user     => $databases['gitlab']['user'],
      # fixme really!
      encoding => 'unicode',
      password => postgresql_password($databases['gitlab']['user'],
                                      $databases['gitlab']['pass']),
    }
  }
  # fixme - gitlab service not refreshing on config file change
  class { 'gitlab' :
    git_create_user          => $git_create_user,
    git_home                 => $directories['gitlab'],
    git_email                => $email['gitlab'],
    git_comment              => 'gitolite and gitlab user',
    gitlab_dbtype            => 'pgsql',
    gitlab_dbhost            => $databases['gitlab']['host'],
    gitlab_dbname            => $databases['gitlab']['name'],
    gitlab_dbuser            => $databases['gitlab']['user'],
    gitlab_dbpwd             => $databases['gitlab']['pass'],
    gitlab_http_port         => $port,
    gitlab_relative_url_root => '/gitlab',
    gitlab_repodir           => $directories['gitlab'],
    require                  => Service[$redissvc],
  }

  if $vhost {
    # todo - add unit test
    file { '/etc/nginx/conf.d/gitlab.conf' :
      ensure  => 'absent',
      require => Class['gitlab'],
    }
    nginx::resource::upstream { 'gitlab' :
      ensure  => 'present',
      members => ["unix:${directories[gitlab]}/gitlab/tmp/sockets/gitlab.socket",],
    }
    nginx::resource::location { '/gitlab' :
      ensure              => 'present',
      vhost               => $vhost,
      location            => '/gitlab',
      proxy               => 'http://gitlab',
      proxy_read_timeout  => undef,
      location_cfg_append => { include => '/etc/nginx/conf.d/proxy.conf' },
    }
  }
}
