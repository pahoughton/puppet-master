# jenkins-bkup.pp - 2014-03-05 06:22
#
# Copyright (c) 2014 Paul Houghton <paul4hough@gmail.com>
#
# host - jenkins host name
#
  # FIXME - we need puppetmaster wide params for these
class master::app::jenkins-bkup (
  $host     = undef,
  $basedir  = $master::app::jenkins::basedir,
  $configfn = $master::app::jenkins::configfn,
  $sched    = undef,
  $pool     = undef,
  $fileset  = 'jenkins-ci',
  ) {
  # FIXME validate - this node is a bacula-director
  if ! $host {
    fail('need the jenkins host name')
  }

  bacula::fileset { $fileset :
    include  => [ [[$basedir, $configfn],
                   ['compression = GZIP9',
                    'signature = MD5',
                    ],
                   ],
                  ],
  }->
  bacula::job { $title :
    client         => $host,
    level          => 'Full',
    jobdefs        => 'Default',
    pool           => $pool,
    fileset        => $fileset,
    sched          => $sched ? {
      undef    => 'WeeklyCycle',
      default  => $sched,
    },
  }
}
