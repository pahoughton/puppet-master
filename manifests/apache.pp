# apache.pp - 2014-02-28 08:18
#
# Copyright (c) 2014 Paul Houghton <paul4hough@gmail.com>
#
class master::apache (
  ) {
  class { '::apache' :
  }
}
