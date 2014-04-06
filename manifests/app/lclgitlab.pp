# lclgitlab.pp - 2014-03-23 07:45
#
# Copyright (c) 2014 Paul Houghton <paul4hough@gmail.com>
#
class master::app::lclgitlab (
  $git_create_user = true,
  ) {
  # fixme args for all values
  $databases = hiera('databases', { 'gitlab' => 'gitlab' })
  $email     = hiera('emails', { 'gitlab' => "gitlab@${::hostname}" })
  $groups    = hiera('groups',{'gitlab' => 'git' })
  $homedirs  = hiera('homedirs',{ 'gitlab' => '/srv/gitlab'} )
  $passwords = hiera('passwords', { 'pgsql-gitlab' => 'gitlab' })
  $servers   = hiera('servers',{ 'pgsql' => 'localhost' } )
  $users     = hiera('users', { 'git' => 'git',
                                'pgsql-gitlab' => 'gitlab', })

  # for templates
  $user    = $users['git']
  $homedir = $homedirs[$user]

  package { ['redis',] :
    ensure => 'installed',
  }
  ->
  service { 'redis' :
    ensure => 'running',
    enable => true,
  }

  if $servers['pgsql'] == 'localhost' or $servers['pgsql'] == $::hostname {

    postgresql::server::role { $users['pgsql-gitlab'] :
      createdb      => true,
      password_hash => postgresql_password( $users['gitlab'],
                                            $passwords['pgsql-gitlab']),
    }
    ->
    postgresql::server::db { $databases['pgsql-gitlab'] :
      user     => $users['pgsql-gitlab'],
      # fixme really!
      encoding => 'unicode',
      password => postgresql_password($users['pgsql-gitlab'],
                                      $passwords['pgsql-gitlab']),
    }
  }

  # file { $homedirs['gitlab'] :
  #   ensure   => 'directory',
  #   owner    => $users['gitlab'],
  #   group    => $groups['gitlab'],
  # }
  class { 'gitlab' :
    git_create_user => $git_create_user,
    git_home        => $homedirs['gitlab'],
    git_email       => $email['gitlab'],
    git_comment     => 'gitolite and gitlab user',
    gitlab_dbtype   => 'pgsql',
    gitlab_dbhost   => $servers['pgsql'],
    gitlab_dbuser   => $users['pgsql-gitlab'],
    gitlab_dbpwd    => $passwords['pgsql-gitlab'],
    gitlab_dbname   => $databases['pgsql-gitlab'],
    gitlab_repodir  => "${homedirs[gitlab]}/repositories",
    require         => Service['redis'],
  }
}
