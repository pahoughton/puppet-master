# app.pp - 2014-02-23 10:32
#
# Copyright (c) 2014 Paul Houghton <paul4hough@gmail.com>
#
define master::nginxphp::app (
  $basedir   = undef,
  $db_driver = 'mysql',
  $db_host   = 'localhost',
  $db_create = true,
  $db_name   = undef,
  $db_user   = undef,
  $db_pass   = undef,
  $vhost     = 'localhost',
  ) {

  $directories = hiera('directories',{ 'www' => '/srv/www' })

  $bdir = $basedir ? {
    undef   => $directories['www'],
    default => $basedir,
  }

  $app = $title

  if $db_name and $db_create {
    case $db_driver {
      'mysql' : {
        mysql::db { $db_name :
          host     => $db_host,
          user     => $db_user,
          password => $db_pass,
          grant    => ['ALL',],
        }
      }
      'postgresql' : {
        postgresql::server::db { $db_name :
          owner    => $db_user,
          user     => $db_user,
          password => $db_pass,
        }
      }
      default : {
        fail("unsupported backend '${db_driver}'")
      }
    }
  }

  nginx::resource::location { "${title}_php":
    ensure          => 'present',
    vhost           => $vhost,
    location        => "~ /${app}/(.*\.php)\$",
    www_root        => $bdir,
    index_files     => ['index.php',],
    proxy           => undef,
    fastcgi         => '127.0.0.1:9000',
  }
  nginx::resource::location { "${title}_static":
    ensure          => 'present',
    vhost           => $vhost,
    location        => "~ /${app}/.*",
    www_root        => $bdir,
    index_files     => ['index.php',],
    proxy           => undef,
  }
}
