# gitlab.pp - 2014-03-23 07:45
#
# Copyright (c) 2014 Paul Houghton <paul4hough@gmail.com>
#
class master::nginx::mygitlab {
  $servers = hiera('servers')
  $email = hiera('email')
  $passwords = hiera('passwords')
  $homedirs = hiera('homedirs')

  class { 'gitlab' :
    git_home       => $homedirs['git'],
    git_email      => $email['gitlab'],
    git_comment    => 'gitolite and gitlab user',
    gitlab_dbtype  => 'pgsql',
    gitlab_dbhost  => $servers['postgres'],
    gitlab_dbuser  => 'gitlab',
    gitlab_dbpwd   => $passwords['postgres-gitlab'],
    gitlab_dbname  => 'gitlab',
    gitlab_repodir => "${homedirs[git]}/repositories",
  }
}
