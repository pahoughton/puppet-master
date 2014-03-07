#!/bin/sh
# init-perl-fcgi.sh - 2014-02-26 12:22
#
# Copyright (c) 2014 Paul Houghton <paul4hough@gmail.com>
#
#
# perl-fcgi – this script starts and stops the nginx daemon
#
# chkconfig: - 95 25
# description: perl FCGI service
# processname: perl-fcgi
# pidfile: /var/run/perl-fcgi.pid

# Source function library.
. /etc/rc.d/init.d/functions

# Source networking configuration.
. /etc/sysconfig/network

# Check that networking is up.
[ "$NETWORKING" = "no" ] && exit 0

perlfastcgi="/usr/bin/perl-fcgi-wrapper.pl"
prog=$(basename perl)

lockfile=/var/lock/subsys/perl-fastcgi

start() {
    [ -x $perlfastcgi ] || exit 5
    echo -n $"Starting $prog: "
    daemon $perlfastcgi
    retval=$?
    echo
    [ $retval -eq 0 ] && touch $lockfile
    return $retval
}

stop() {
    echo -n $"Stopping $prog: "
    killproc $prog -QUIT
    retval=$?
    echo
    [ $retval -eq 0 ] && rm -f $lockfile
    return $retval
}

restart() {
    stop
    start
}

reload() {
    echo -n $”Reloading $prog: ”
    killproc $perlfastcgi -HUP
    RETVAL=$?
    echo
}

force_reload() {
    restart
}
rh_status() {
    status $prog
}

rh_status_q() {
    rh_status >/dev/null 2>&1
}

case "$1" in
    start)
        rh_status_q && exit 0
        $1
        ;;
    stop)
        rh_status_q || exit 0
        $1
        ;;
    restart)
        $1
        ;;
    reload)
        rh_status_q || exit 7
        $1
        ;;
    force-reload)
        force_reload
        ;;
    status)
        rh_status
        ;;
    condrestart|try-restart)
        rh_status_q || exit 0
        ;;
    *)
        echo $"Usage: $0 {start|stop|status|restart|condrestart|try-restart|reload|force-reload}"
        exit 2
    esac
