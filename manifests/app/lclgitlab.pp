# lclgitlab.pp - 2014-03-23 07:45
#
# Copyright (c) 2014 Paul Houghton <paul4hough@gmail.com>
#
class master::app::lclgitlab (
  $git_create_user = true,
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
  $servers     = hiera('servers',{ 'pgsql' => 'localhost' } )
  $users       = hiera('users', { 'git' => 'git', 'gitlab' => 'gitlab', })

  ensure_packages(['redis',],)

  service { 'redis' :
    ensure  => 'running',
    enable  => true,
    require => Package['redis'],
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

  class { 'gitlab' :
    git_create_user => $git_create_user,
    git_home        => $directories['gitlab'],
    git_email       => $email['gitlab'],
    git_comment     => 'gitolite and gitlab user',
    gitlab_dbtype   => 'pgsql',
    gitlab_dbhost   => $databases['gitlab']['host'],
    gitlab_dbname   => $databases['gitlab']['name'],
    gitlab_dbuser   => $databases['gitlab']['user'],
    gitlab_dbpwd    => $databases['gitlab']['pass'],
    gitlab_repodir  => "${directories[gitlab]}/repositories",
    require         => Service['redis'],
  }
}
