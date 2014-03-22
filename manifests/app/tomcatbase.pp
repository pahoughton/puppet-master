# tomcatbase.pp - 2014-03-20 12:45
#
# Copyright (c) 2014 Paul Houghton <paul4hough@gmail.com>
#
class master::app::tomcatbase(
  $vhost,
  $tport,
  $app,
  $tomcatdir,
  ) {
  $ports = hiera('ports',{'tomcat' => '8080'})
  $port = $tport ? {
    undef   => $ports['tomcat'],
    default => $tport,
  }
  # implicid require vhost
  nginx::resource::location { "${vhost}-${app}-tomcat-static" :
    ensure              => 'present',
    vhost               => $vhost,
    location            => "~ ^/${app}/static/",
    index_files         => undef,
    www_root            => $tomcatdir,
  }
  nginx::resource::location { "${vhost}-${app}-tomcat-proxy" :
    ensure              => 'present',
    vhost               => $vhost,
    location            => "/${app}",
    proxy               => "http://${vhost}:${port}",
    proxy_read_timeout  => undef,
    location_cfg_append => { include => '/etc/nginx/conf.d/proxy.conf' },
  }
}
