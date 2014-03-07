# app.pp - 2014-02-23 10:32
#
# Copyright (c) 2014 Paul Houghton <paul4hough@gmail.com>
#
define master::nginxphp::app (
  $vhost = 'localhost',
  $appdir,
  $db_driver = 'mysql',
  $db_host,
  $db_name,
  $db_user,
  $db_pass,
  ) {

  if $db_name {
    mysql::db { $db_name :
      host     => $db_host,
      user     => $db_user,
      password => $db_pass,
      grant    => ['ALL',],
    }
  }
  
  nginx::resource::location { "${title}_php":
    ensure          => 'present',
    vhost           => $vhost,
    location        => "~ /${appdir}/(.*\.php)\$",
    www_root        => $master::nginxphp::basedir,
    index_files     => ['index.php',],
    proxy           => undef,
    fastcgi         => "127.0.0.1:9000",
  }
  nginx::resource::location { "${title}_static":
    ensure          => 'present',
    vhost           => $vhost,
    location        => "~ /${appdir}/.*",
    www_root        => $master::nginxphp::basedir,
    index_files     => ['index.php',],
    proxy           => undef,
  }  
}
  
