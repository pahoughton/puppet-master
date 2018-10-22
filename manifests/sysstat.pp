# 2015-10-10 (cc) <paul4hough@gmail.com>
#
class master::sysstat(
  $history       = 28,
  $compressafter = 31,
  $sadc_options  = '-S DISK',
  $zip           = 'bzip2',
  ) {

  ensure_packages(['sysstat','bzip2'])

  file { '/etc/sysconfig/sysstat' :
    ensure => 'file',
    content => template('master/sysstat.erb'),
  }

}
