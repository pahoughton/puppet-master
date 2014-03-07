# access.pp - 2014-02-26 09:58
#
# Copyright (c) 2014 Paul Houghton <paul4hough@gmail.com>
#
# class master::sendmail::access {
#   relays  => ['192.168.122',]
#   rejects => ['trash.com',]
# }
class master::sendmail::access (
  $relays  = undef,
  $rejects = undef,
  ) {

  file { '/etc/mail/access' :
    ensure => 'file',
    content => template('master/sendmail/access.erb')
  }
}
