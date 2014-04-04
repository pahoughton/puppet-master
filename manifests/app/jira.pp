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

  ) {


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

  notify { 'fixme - need run install with my params' : }
}
