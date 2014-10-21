#!/bin/bash

HAPROXY="/etc/haproxy"
PIDFILE="/var/run/haproxy.pid"

CONFIG="haproxy.cfg"

DOCK_HOST_IP=$(route -n | awk '/UG[ \t ]/{print $2}')
echo -e "nameserver $DOCK_HOST_IP\nnameserver 83.142.86.1\nnameserver 83.142.86.120\nsearch lautcloud" > /etc/resolv.conf

trap 'killall curl; killall haproxy; exit $?' INT TERM EXIT

function load_config_and_reload {
  WAIT=$1
  echo curl --data-binary @haproxy.cfg.template 'confserver:6666/services'$WAIT
  curl --data-binary @haproxy.cfg.template 'confserver:6666/services'$WAIT | tee  /tmp/$CONFIG
  CURL_EXIT_CODE=$?

  if [ $CURL_EXIT_CODE -gt 128 ]; then
    echo 'received a kill signal. aborting.'
    killall haproxy
    exit
  fi

  if [ $CURL_EXIT_CODE -eq 0 ]; then
    DATE=$(date +"%Y-%m-%d--%H-%M-%S")
    CFG_FILE=$HAPROXY/haproxy-$DATE.cfg
    mv /tmp/$CONFIG $CFG_FILE
    cat $CFG_FILE
    echo 'reloading haproxy configuration'
    haproxy -V -f $CFG_FILE -p $PIDFILE -sf $(cat $PIDFILE)
    # sleep 10
    # haproxy -V -f $CFG_FILE -p $PIDFILE -st $(cat $PIDFILE)
  fi
}

load_config_and_reload

while true; do
  load_config_and_reload '?wait'

  sleep 10 # just avoiding fast paced loop
done
