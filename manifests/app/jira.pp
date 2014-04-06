# jira.pp - 2014-04-03 23:59
#
# Copyright (c) 2014 Paul Houghton <paul4hough@gmail.com>
#
class master::app::jira (
  $vhost   = 'localhost',
  $prefix  = '/srv',
  $app     = 'jira',
  $port    = '27101',
  $ctlport = '27102',
  $source  = undef, # http://blah/jira.bin
  $bin     = 'atlassian-jira-6.2.2-x64.bin',
  ) {

  $uris = hiera('uris')

  $jirasource = $source ? {
    undef   => $uris['app'],
    default => $source,
  }
  $jirahome = "${prefix}/${app}"
  $jiradata = "${prefix}/${app}-data"

  if $vhost {
    nginx::resource::location { "${vhost}-${app}-proxy" :
      ensure              => 'present',
      vhost               => $vhost,
      location            => "/${app}",
      proxy               => "http://${vhost}:${port}",
      proxy_read_timeout  => undef,
      location_cfg_append => { include => '/etc/nginx/conf.d/proxy.conf' },
    }
  }

  file { "${::root_home}/jira-resp.txt" :
    ensure  => 'file',
    content => template('master/app/jira-resp.txt.erb'),
  }
  ->
  exec { "wget -q '${jirasource}/${bin}'" :
    cwd     => $::root_home,
    creates => "${::root_home}/${bin}",
  }
  ->
  exec { "bash ${bin} < jira-resp.txt" :
    cwd     => $::root_home,
    creates => $jirahome
  }

}
