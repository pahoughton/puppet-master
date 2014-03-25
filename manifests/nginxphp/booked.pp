# tiki.pp - 2014-02-23 10:47
#
# Copyright (c) 2014 Paul Houghton <paul4hough@gmail.com>
#
class master::nginxphp::booked (
  $app          = 'booked',
  $tarball      = 'booked.tar.gz',
  $db_host      = 'localhost',
  $db_name      = 'booked',
  $db_user      = 'booked',
  $db_pass      = 'booked',
  $app_timezone = 'America/Denver',
  $admin_email  = 'paul_houghton@cable.comcast.com',

  ) {


  master::nginxphp::app { $app :
    appdir      => $app,
    db_host     => $db_host,
    db_name     => $db_name,
    db_user     => $db_user,
    db_pass     => $db_pass,
  }
  file { "/var/www/${tarball}" :
    ensure  => 'file',
    owner   => $master::nginxphp::www_user,
    group   => $master::nginxphp::www_group,
    source  => "puppet:///modules/master/${tarball}",
    require => File[$master::nginxphp::basedir],
    notify  => Exec["extract ${app} tar"],
  }
  exec { "extract ${app} tar" :
    command => "/bin/tar xzf /var/www/${tarball}",
    cwd     => $master::nginxphp::basedir,
    user    => $master::nginxphp::www_user,
    group   => $master::nginxphp::www_group,
    creates => "${master::nginxphp::basedir}/booked/index.php",
  }
  ->
  file { "${master::nginxphp::basedir}/booked/config/config.php" :
    ensure  => 'present',
    content => template( 'master/booked/config.php.erb'),
    owner   => $master::nginxphp::www_user,
    group   => $master::nginxphp::www_group,
    mode    => '0664',
  }
  # prep database
  $db_sql_file = "${master::nginxphp::basedir}/booked/database_schema/database.sql"
  file { $db_sql_file :
    ensure  => 'present',
    content => template( 'master/booked/database.sql.erb'),
    owner   => $master::nginxphp::www_user,
    group   => $master::nginxphp::www_group,
    mode    => '0664',
    notify  => Exec["${app} database prep"],
    require => File["${master::nginxphp::basedir}/booked/config/config.php"]
  }
  exec { "${app} database prep" :
    command     => "/usr/bin/mysql --user='${db_user}' --password='${db_pass}' '${db_name}' < ${db_sql_file}",
    require     => File[$db_sql_file],
    logoutput   => true,
    environment => "HOME=${::root_home}",
    refreshonly => true,
    subscribe   => Mysql_database[$app],
  }
}
