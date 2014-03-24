# gitlab.pp - 2014-03-23 07:45
#
# Copyright (c) 2014 Paul Houghton <paul4hough@gmail.com>
#
class master::nginx::mygitlab (
  $git_create_user = false,
  ) {
  $servers = hiera('servers')
  $email = hiera('email')
  $passwords = hiera('passwords')
  $homedirs = hiera('homedirs')

  package { ['redis',] :
    ensure => 'installed',
  }
  ->
  service { 'redis' :
    ensure => 'running',
    enable => true,
  }

  postgresql::server::role { 'gitlab' :
    createdb      => true,
    password_hash => postgresql_password( 'gitlab', $passwords['postgres-gitlab']),
  }
  ->
  postgresql::server::db { 'gitlab' :
    user     => 'gitlab',
    # fixme really!
    encoding => 'unicode',
    password => postgresql_password( 'gitlab', $passwords['postgres-gitlab']),
  }
  ->
  class { 'gitlab' :
    git_create_user => $git_create_user,
    git_home        => $homedirs['git'],
    git_email       => $email['gitlab'],
    git_comment     => 'gitolite and gitlab user',
    gitlab_dbtype   => 'pgsql',
    gitlab_dbhost   => $servers['postgres'],
    gitlab_dbuser   => 'gitlab',
    gitlab_dbpwd    => $passwords['postgres-gitlab'],
    gitlab_dbname   => 'gitlab',
    gitlab_repodir  => "${homedirs[git]}/repositories",
    require         => Service['redis'],
  }
}
