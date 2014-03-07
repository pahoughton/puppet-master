# init.pp 2014-03-03 11:58
#
# Copyright (c) 2014 Paul Houghton <paul4hough@gmail.com>
#
# Microsoft .Net application support.
class dotnet {
  package { 'mono-web' :
    ensure => 'installed',
  }
