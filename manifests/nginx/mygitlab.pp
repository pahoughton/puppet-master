# gitlab.pp - 2014-03-23 07:45
#
# Copyright (c) 2014 Paul Houghton <paul4hough@gmail.com>
#
class master::nginx::mygitlab (
  $git_create_user = false,
  ) {
  # fixme args for all values
  $servers   = hiera('servers',{ 'pgsql' => 'localhost' } )
  $email     = hiera('emails', { 'gitlab' => "gitlab@${::hostname}" })
  $passwords = hiera('passwords', { 'pgsql-gitlab' => 'gitlab' })
  $homedirs  = hiera('homedirs',{ 'git' => '/srv/gitolite'} )
  $users     = hiera('users',{ 'git' => 'git' })
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

  postgresql::server::role { 'gitlab' :
    createdb      => true,
    password_hash => postgresql_password( 'gitlab', $passwords['pgsql-gitlab']),
  }
  ->
  postgresql::server::db { 'gitlab' :
    user     => 'gitlab',
    # fixme really!
    encoding => 'unicode',
    password => postgresql_password( 'gitlab', $passwords['pgsql-gitlab']),
  }
  ->
  class { 'gitlab' :
    git_create_user => $git_create_user,
    git_home        => $homedirs['git'],
    git_email       => $email['gitlab'],
    git_comment     => 'gitolite and gitlab user',
    gitlab_dbtype   => 'pgsql',
    gitlab_dbhost   => $servers['pgsql'],
    gitlab_dbuser   => 'gitlab',
    gitlab_dbpwd    => $passwords['pgsql-gitlab'],
    gitlab_dbname   => 'gitlab',
    gitlab_repodir  => "${homedirs[git]}/repositories",
    require         => Service['redis'],
  }
}
