# jenkins.pp - 2014-03-25 02:28
#
# Copyright (c) 2014 Paul Houghton <paul4hough@gmail.com>
#
define master::bkups::jenkins(
  $basedir   = undef,
  ) {

  $directories = hiera('directories',{ 'jenkins' => '/srv/jenkins' })

  $bkupbase = $basedir ? {
    undef   => $directories['jenkins'],
    default => $basedir,
  }
  bacula::dir::fileset { "${title}-jenkins" :
    include => [ [[$bkupbase],
                  [ 'signature = MD5',
                    'compression = GZIP9',
                    ],],],
    exclude => ["${bkupbase}/workspaces",
                "${bkupbase}/plugins",]
  }
  bacula::dir::job { "${title}-jenkins" :
    client  => $title,
    fileset => "${title}-jenkins",
  }
}
